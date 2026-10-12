"""The local fixture from the video: an app that only answers for its own hostname.
    python3 fixture.py            # listens on 127.0.0.1:8080
    curl -i -H 'Host: app.example.test' http://127.0.0.1:8080/   -> 200 (the intended site works)
    curl -i http://127.0.0.1:8080/                                -> 404 (Host: 127.0.0.1:8080, like a default probe)
"""
from http.server import BaseHTTPRequestHandler, HTTPServer

EXPECTED_HOST = "app.example.test"


class App(BaseHTTPRequestHandler):
    def do_GET(self):
        host = (self.headers.get("Host") or "").split(":")[0]
        ok = host == EXPECTED_HOST
        body = (b"hello from app.example.test\n" if ok else f"no site for host {host!r}\n".encode())
        self.send_response(200 if ok else 404)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        print(f"{self.headers.get('Host')!r:24} {self.path} -> {args[1] if len(args) > 1 else ''}")


if __name__ == "__main__":
    HTTPServer(("127.0.0.1", 8080), App).serve_forever()
