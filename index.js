import express from 'express';
import fetch from 'node-fetch';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve HTML Dashboard
app.get('/', (req, res) => {
  res.send(getHtmlDashboard());
});

// Translation Endpoint
app.post('/api/translate', async (req, res) => {
  const { text, source = 'auto', target = 'en' } = req.body;

  if (!text) {
    return res.status(400).json({ error: "Text field is required" });
  }

  try {
    const translatedText = await translateText(text, source, target);
    res.json({ translatedText, source, target });
  } catch (err) {
    res.status(500).json({ error: err.toString() });
  }
});

// Google Translate Undocumented Fetcher (Bypasses limits and API keys)
async function translateText(text, source, target) {
  const maxChunk = 1000;
  if (text.length > maxChunk) {
    const chunks = chunkText(text, maxChunk);
    const translatedChunks = [];
    for (const chunk of chunks) {
      const trans = await performTranslate(chunk, source, target);
      translatedChunks.push(trans);
    }
    return translatedChunks.join(' ');
  }
  return performTranslate(text, source, target);
}

async function performTranslate(text, source, target) {
  const url = `https://translate.googleapis.com/translate_a/single?client=gtx&sl=${source}&tl=${target}&dt=t&q=${encodeURIComponent(text)}`;
  const response = await fetch(url, {
    headers: {
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    }
  });
  const data = await response.json();
  
  if (data && data[0]) {
    return data[0].map(item => item[0]).filter(Boolean).join('');
  }
  throw new Error("Invalid translation response");
}

function chunkText(str, size) {
  const numChunks = Math.ceil(str.length / size);
  const chunks = new Array(numChunks);
  for (let i = 0, o = 0; i < numChunks; ++i, o += size) {
    chunks[i] = str.substr(o, size);
  }
  return chunks;
}

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});

// Premium UI Dashboard
function getHtmlDashboard() {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ZipLoot - Unlimited Free Translation Gateway</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&family=Syne:wght@700;800&family=Space+Mono&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg: #0b0f19;
      --card-bg: rgba(255, 255, 255, 0.02);
      --border: rgba(255, 255, 255, 0.05);
      --primary: #818cf8;
      --success: #10b981;
      --text: #cbd5e1;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: var(--bg);
      color: var(--text);
      font-family: 'Inter', sans-serif;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
    }
    header {
      border-bottom: 1px solid var(--border);
      padding: 20px 40px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      background: rgba(11, 15, 25, 0.8);
      backdrop-filter: blur(12px);
      position: sticky;
      top: 0;
      z-index: 100;
    }
    .logo {
      font-family: 'Syne', sans-serif;
      font-size: 22px;
      font-weight: 800;
      background: linear-gradient(135deg, #818cf8 0%, #10b981 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      letter-spacing: -0.5px;
    }
    .container {
      max-width: 1000px;
      width: 100%;
      margin: 45px auto;
      padding: 0 20px;
      flex: 1;
    }
    .translator-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 20px;
      margin-bottom: 30px;
    }
    .card {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 24px;
      backdrop-filter: blur(10px);
    }
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 15px;
    }
    h2 { font-family: 'Syne', sans-serif; font-size: 16px; color: #fff; }
    select {
      background: rgba(0, 0, 0, 0.3);
      color: #fff;
      border: 1px solid var(--border);
      padding: 6px 12px;
      border-radius: 6px;
      font-family: 'Inter', sans-serif;
      font-size: 13px;
      outline: none;
      cursor: pointer;
    }
    textarea {
      width: 100%;
      height: 250px;
      background: rgba(0, 0, 0, 0.2);
      border: 1px solid var(--border);
      border-radius: 8px;
      color: #fff;
      padding: 15px;
      font-family: 'Inter', sans-serif;
      font-size: 15px;
      line-height: 1.6;
      resize: none;
      outline: none;
    }
    textarea:focus { border-color: var(--primary); }
    .btn-container { text-align: center; margin-bottom: 40px; }
    .btn {
      padding: 14px 32px;
      background: linear-gradient(135deg, #818cf8 0%, #10b981 100%);
      color: #fff;
      border-radius: 50px;
      font-family: 'Syne', sans-serif;
      font-weight: 700;
      border: none;
      cursor: pointer;
      font-size: 15px;
      box-shadow: 0 4px 15px rgba(129, 140, 248, 0.3);
      transition: all 0.2s ease;
    }
    .btn:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(129, 140, 248, 0.4); }
    .api-docs {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 30px;
    }
    .api-docs h3 { font-family: 'Syne', sans-serif; color: #fff; font-size: 18px; margin-bottom: 15px; }
    .api-docs pre {
      background: rgba(0, 0, 0, 0.3);
      border: 1px solid var(--border);
      padding: 15px;
      border-radius: 8px;
      font-family: 'Space Mono', monospace;
      font-size: 13px;
      color: #818cf8;
      overflow-x: auto;
    }
  </style>
</head>
<body>
  <header>
    <div class="logo">⚡ ZIPLOOT TRANSLATE</div>
  </header>
  <div class="container">
    <div class="translator-grid">
      <!-- Source Panel -->
      <div class="card">
        <div class="card-header">
          <h2>Source Language</h2>
          <select id="sourceLang">
            <option value="auto">Auto Detect</option>
            <option value="en" selected>English</option>
            <option value="bn">Bengali</option>
            <option value="es">Spanish</option>
            <option value="fr">French</option>
            <option value="ar">Arabic</option>
            <option value="hi">Hindi</option>
          </select>
        </div>
        <textarea id="sourceText" placeholder="Type or paste text to translate..."></textarea>
      </div>

      <!-- Target Panel -->
      <div class="card">
        <div class="card-header">
          <h2>Target Language</h2>
          <select id="targetLang">
            <option value="bn" selected>Bengali</option>
            <option value="en">English</option>
            <option value="es">Spanish</option>
            <option value="fr">French</option>
            <option value="ar">Arabic</option>
            <option value="hi">Hindi</option>
          </select>
        </div>
        <textarea id="targetText" placeholder="Translation will appear here..." readonly></textarea>
      </div>
    </div>

    <div class="btn-container">
      <button class="btn" onclick="translate()">TRANSLATE TEXT</button>
    </div>

    <!-- API Docs -->
    <div class="api-docs">
      <h3>🔌 Developer API Usage</h3>
      <p style="font-size: 14px; color: #94a3b8; margin-bottom: 15px;">Integrate this gateway into your own scripts and apps with absolute zero rate limits:</p>
      <pre>POST /api/translate
Content-Type: application/json

{
  "text": "Hello world",
  "source": "en",
  "target": "bn"
}</pre>
    </div>
  </div>

  <script>
    async function translate() {
      const text = document.getElementById("sourceText").value;
      const source = document.getElementById("sourceLang").value;
      const target = document.getElementById("targetLang").value;
      const targetArea = document.getElementById("targetText");

      if (!text.trim()) return;

      targetArea.value = "Translating...";

      const res = await fetch("/api/translate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ text, source, target })
      });
      const data = await res.json();
      if (res.ok) {
        targetArea.value = data.translatedText;
      } else {
        targetArea.value = "Error: " + data.error;
      }
    }
  </script>
</body>
</html>`;
}
