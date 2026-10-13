"""A minimal RAG pipeline, standard library only, to see every step. Retrieval here is simple keyword scoring
(TF-IDF); real systems use embeddings, hybrid search and a re-ranker, but the steps are the same.
    python3 rag.py "How much can I spend on meals?"
Step 4 prints the prompt you would send to any LLM. Set OPENAI_API_KEY or ANTHROPIC_API_KEY and add your own call
there to get an actual answer.
"""
import math
import re
import sys
from collections import Counter
from pathlib import Path

WORD = re.compile(r"[a-z0-9]+")


def chunks(folder: Path, size: int = 40, overlap: int = 10):
    """Step 1: split every document into overlapping chunks of `size` words."""
    for f in sorted(folder.glob("*.md")):
        words = f.read_text(encoding="utf-8").split()
        for i in range(0, max(1, len(words) - overlap), size - overlap):
            yield {"source": f"{f.name}#{i // (size - overlap) + 1}", "text": " ".join(words[i:i + size])}


class Index:
    """Step 2: index every chunk for search (TF-IDF over lowercase words)."""

    def __init__(self, items):
        self.items = list(items)
        self.tf = [Counter(WORD.findall(c["text"].lower())) for c in self.items]
        df = Counter(w for tf in self.tf for w in tf)
        self.idf = {w: math.log((1 + len(self.items)) / (1 + n)) + 1 for w, n in df.items()}

    def search(self, question: str, k: int = 2):
        """Step 3: find the chunks most related to the question."""
        q = WORD.findall(question.lower())
        scored = [(sum(tf[w] * self.idf.get(w, 0) for w in q) / math.sqrt(1 + sum(tf.values())), c)
                  for tf, c in zip(self.tf, self.items)]
        return [c for s, c in sorted(scored, key=lambda x: -x[0])[:k] if s > 0]


def prompt(question: str, found) -> str:
    """Step 4: put the chunks into the prompt, next to the question, with the rule: answer from these sources."""
    sources = "\n".join(f"[{c['source']}] {c['text']}" for c in found) or "(nothing found)"
    return ("Answer the question using ONLY the sources below. Cite the source in brackets. "
            "If the sources don't contain the answer, say you don't know.\n\n"
            f"Sources:\n{sources}\n\nQuestion: {question}")


if __name__ == "__main__":
    question = " ".join(sys.argv[1:]) or "How much can I spend on meals?"
    index = Index(chunks(Path(__file__).parent / "docs"))
    found = index.search(question)
    print("Retrieved:", [c["source"] for c in found], "\n")
    print(prompt(question, found))
