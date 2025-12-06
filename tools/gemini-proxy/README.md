Gemini Proxy (example)

This is a minimal Express proxy that demonstrates how to forward prompts to a server-side Gemini/Vertex AI endpoint using a server-held API key.

Setup
1. Install dependencies:

   cd tools/gemini-proxy
   npm install

2. Set environment variables:

   - `GEMINI_API_KEY` — the API key or Bearer token to call Gemini/Vertex.
   - `GEMINI_ENDPOINT` — the real REST endpoint to forward requests to (replace the placeholder in server.js).

   Example (PowerShell):

   $env:GEMINI_API_KEY = 'ya29....'
   $env:GEMINI_ENDPOINT = 'https://your-gemini-endpoint'
   node server.js

Usage
- POST /v1/gemini
  - body: { "prompt": "Your prompt here" }
  - response: proxied Gemini response (json)

Security / moderation
- server.js includes a simple blacklist-based moderation check. Replace with proper moderation API or rules per your policy.
- Keep your `GEMINI_API_KEY` out of source control and use a secrets manager in production.

Notes
- The `endpoint` in the example is a placeholder. Replace it with your provider's REST URL and payload structure.
- This proxy simply forwards responses. In production you should add rate-limiting, authentication, logging, and robust moderation.
