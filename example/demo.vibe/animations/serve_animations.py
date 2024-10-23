import http.server
from http.server import SimpleHTTPRequestHandler
import socketserver
import os

# Define a handler that adds CORS headers
class CORSRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')  # Allow all origins
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

# Set the directory to the current working directory (CWD)
web_dir = os.getcwd()
os.chdir(web_dir)

# Set the port you want to serve on
PORT = 8000

# Create the server object
with socketserver.TCPServer(("", PORT), CORSRequestHandler) as httpd:
    print(f"Serving files from {web_dir} on port {PORT}")
    httpd.serve_forever()

