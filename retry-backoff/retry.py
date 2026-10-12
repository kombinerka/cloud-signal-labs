"""Retries that help a struggling service recover instead of finishing it off.

- exponential backoff: wait 1 s, 2 s, 4 s ... (capped)
- full jitter: a random wait between 0 and that value, so clients don't retry in sync
- finite: a maximum number of attempts and a total time budget
- early stop: a simple circuit breaker stops calling after repeated failures, for a cooldown

Only retry errors that can succeed later (timeouts, 429, 5xx). Never retry a 400 or a 401.
"""
from __future__ import annotations

import random
import time
from dataclasses import dataclass, field
from typing import Callable, TypeVar

T = TypeVar("T")


class TransientError(Exception):
    """An error worth retrying, e.g. a timeout, HTTP 429 or 503."""

    def __init__(self, message: str = "", retry_after: float | None = None):
        super().__init__(message)
        self.retry_after = retry_after  # seconds, from a Retry-After header if the service sent one


class CircuitOpen(Exception):
    """Raised instead of calling while the breaker is open."""


@dataclass
class CircuitBreaker:
    failure_threshold: int = 5  # consecutive failures before opening
    cooldown: float = 30.0  # seconds to stay open before letting one call through
    _failures: int = 0
    _opened_at: float | None = None
    clock: Callable[[], float] = field(default=time.monotonic, repr=False)

    def before_call(self) -> None:
        if self._opened_at is not None and self.clock() - self._opened_at < self.cooldown:
            raise CircuitOpen("too many recent failures; not calling the service")

    def record(self, ok: bool) -> None:
        if ok:
            self._failures, self._opened_at = 0, None
        else:
            self._failures += 1
            if self._failures >= self.failure_threshold:
                self._opened_at = self.clock()


def backoff_delays(base: float = 1.0, cap: float = 30.0, attempts: int = 5, rng=random.random):
    """Delays before retry 1..attempts-1: full jitter over base * 2**n, capped."""
    for n in range(attempts - 1):
        yield rng() * min(cap, base * 2**n)


def call_with_retry(
    fn: Callable[[], T],
    *,
    attempts: int = 5,
    base: float = 1.0,
    cap: float = 30.0,
    budget: float = 60.0,
    breaker: CircuitBreaker | None = None,
    sleep: Callable[[float], None] = time.sleep,
    clock: Callable[[], float] = time.monotonic,
) -> T:
    start = clock()
    delays = backoff_delays(base, cap, attempts)
    while True:
        if breaker:
            breaker.before_call()
        try:
            result = fn()
        except TransientError as e:
            if breaker:
                breaker.record(False)
            delay = next(delays, None)
            if delay is None:
                raise  # out of attempts
            if e.retry_after is not None:
                delay = max(delay, e.retry_after)  # the service told us when; respect it
            if clock() - start + delay > budget:
                raise  # out of time
            sleep(delay)
            continue
        if breaker:
            breaker.record(True)
        return result
