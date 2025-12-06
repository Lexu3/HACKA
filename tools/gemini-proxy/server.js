const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');

const app = express();
app.use(bodyParser.json());

// Read GEMINI API key / token from env
const GEMINI_KEY = process.env.GEMINI_API_KEY || '';
const GEMINI_ENDPOINT = process.env.GEMINI_ENDPOINT || '';
// If true, append ?key=API_KEY instead of using Authorization header
const GEMINI_USE_API_KEY = (process.env.GEMINI_USE_API_KEY || 'false').toLowerCase() === 'true';
// Kind of payload to send: 'vertex_text_bison' uses Vertex AI Generative Models REST shape
const GEMINI_KIND = process.env.GEMINI_KIND || 'generic';

if (!GEMINI_ENDPOINT) {
  console.warn('Warning: GEMINI_ENDPOINT is not set. Set GEMINI_ENDPOINT to your provider endpoint.');
}
if (!GEMINI_KEY) {
  console.warn('Warning: GEMINI_API_KEY is not set. Requests may fail if endpoint requires auth.');
}

// Basic moderation example: deny prompts containing blacklisted words
const blacklist = ['illegal', 'porn', 'hate']; // customize as needed
function moderate(prompt) {
  const lower = prompt.toLowerCase();
  for (const b of blacklist) {
    if (lower.includes(b)) return { allowed: false, reason: `Contains blocked word: ${b}` };
  }
  return { allowed: true };
}

app.post('/v1/gemini', async (req, res) => {
  const { prompt } = req.body || {};
  if (!prompt) return res.status(400).json({ error: 'Missing prompt' });

  const mod = moderate(prompt);
  if (!mod.allowed) return res.status(403).json({ error: 'Moderation failure', reason: mod.reason });

  if (!GEMINI_ENDPOINT) return res.status(500).json({ error: 'Server not configured with GEMINI_ENDPOINT' });

  try {
    let endpoint = GEMINI_ENDPOINT;
    const headers = { 'Content-Type': 'application/json' };
    if (!GEMINI_USE_API_KEY && GEMINI_KEY) {
      headers['Authorization'] = `Bearer ${GEMINI_KEY}`;
    }

    let payload = {};
    // Build payload according to selected kind
    if (GEMINI_KIND === 'vertex_text_bison') {
      // Vertex AI generative models (text-bison / similar) expect instances with content
      payload = {
        instances: [ { content: prompt } ],
        parameters: { temperature: 0.2, maxOutputTokens: 512 }
      };
      // If using API key, append to query
      if (GEMINI_USE_API_KEY && GEMINI_KEY) endpoint = `${endpoint}?key=${GEMINI_KEY}`;
    } else {
      // Generic forward: wrap prompt in { prompt: '...' }
      payload = { prompt };
      if (GEMINI_USE_API_KEY && GEMINI_KEY) endpoint = `${endpoint}?key=${GEMINI_KEY}`;
    }

    const resp = await axios.post(endpoint, payload, { headers, timeout: 30000 });

    // Forward response body
    res.status(resp.status).send(resp.data);
  } catch (err) {
    console.error('Error forwarding to Gemini:', err?.response?.data || err.message || err);
    const status = err?.response?.status || 500;
    const body = err?.response?.data || err.message || 'Unknown error';
    res.status(status).json({ error: body });
  }
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`Gemini proxy listening on http://localhost:${port}`));
