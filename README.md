# Unlimited Free Translation API Gateway ($0 Setup)

A production-ready serverless API gateway that reverse-engineers Google Translate's undocumented endpoint to provide **unlimited free translations** with zero API keys or rate limits.

---

## ⚡ Deployment Options

### Option 1: 1-Click Serverless Cloud Deployment (Cloudflare Workers) - RECOMMENDED
Run your translation API completely in the cloud for free ($0 operational cost, zero maintenance).

1. Log into your **Cloudflare Dashboard**.
2. Navigate to **Workers & Pages** -> click **Create Application** -> **Create Worker**.
3. Name your worker (e.g., `translation-api`) and click **Deploy**.
4. Click **Edit Code**, delete all default code, and paste the contents of [worker.js](worker.js).
5. Click **Save and Deploy**.
6. **Done!** Your public API gateway is live at:
   `https://translation-api.<your-username>.workers.dev/`

*You can open that URL in your browser to access the graphical translation dashboard!*

---

### Option 2: Local Node.js Setup
To run the translation server on your local machine:

1. Clone or download this project.
2. Open terminal in the directory and run:
   ```bash
   npm install
   npm start
   ```
3. Open `http://localhost:3000` to access the translation dashboard.

---

## 🔌 API Documentation

### 1. Translate Text
* **URL:** `/api/translate`
* **Method:** `POST` or `GET`
* **Headers:** `Content-Type: application/json`

**JSON Request Body (POST):**
```json
{
  "text": "Hello world, this is a free gateway.",
  "source": "auto",
  "target": "bn"
}
```

**Query Parameters (GET):**
`https://<your-worker-url>.workers.dev/api/translate?text=Hello&source=auto&target=es`

**JSON Response:**
```json
{
  "translatedText": "হ্যালো ওয়ার্ল্ড, এটি একটি ফ্রি গেটওয়ে।",
  "source": "auto",
  "target": "bn"
}
```
