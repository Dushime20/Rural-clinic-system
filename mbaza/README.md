# Mbaza NLP Translation Service

A Flask-based translation service using Mbaza NLP for English to Kinyarwanda translation.

## Features

- **Single Translation**: Translate individual text strings
- **Batch Translation**: Translate multiple texts in one request (optimized)
- **Thread-Safe**: Uses locking for concurrent request handling
- **Health Check**: Monitor service availability

## Prerequisites

- Python 3.8+
- Hugging Face account and API token

## Setup

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure Environment Variables

Create a `.env` file in the `mbaza` directory:

```bash
cp .env.example .env
```

Edit `.env` and add your Hugging Face token:

```env
HUGGING_FACE_TOKEN=your_actual_token_here
```

**Get your token from:** https://huggingface.co/settings/tokens

### 3. Start the Service

**Development:**
```bash
python app_optimized.py
```

**Production:**
```bash
python run_production.py
```

The service will start on `http://localhost:9000`

## API Endpoints

### Single Translation
**POST** `/translate`

```json
{
  "text": "Hello world"
}
```

Response:
```json
{
  "english": "Hello world",
  "kinyarwanda": "Mwaramutse isi"
}
```

### Batch Translation
**POST** `/translate/batch`

```json
{
  "texts": ["Hello", "Goodbye", "Thank you"]
}
```

Response:
```json
{
  "count": 3,
  "translations": [
    {"english": "Hello", "kinyarwanda": "Mwaramutse"},
    {"english": "Goodbye", "kinyarwanda": "Murabeho"},
    {"english": "Thank you", "kinyarwanda": "Murakoze"}
  ]
}
```

### Health Check
**GET** `/health`

Response:
```json
{
  "status": "healthy",
  "device": "cpu",
  "model": "mbazaNLP/Nllb_finetuned_general_en_kin"
}
```

## Model Loading

The Mbaza NLP model takes approximately **10-20 seconds** to load on startup. Wait for the message:

```
--> Success: Engine loaded on CPU. API is ready!
```

## Performance

- **Single requests**: ~2-3 seconds per translation
- **Batch requests**: ~0.3-0.5 seconds per item (significantly faster)
- **Concurrent requests**: Handled via thread-safe locking

## Security

⚠️ **Never commit your `.env` file or Hugging Face token to version control!**

The `.env` file is excluded via `.gitignore` to prevent accidental commits.

## Troubleshooting

### Model fails to load
- Ensure you have a valid Hugging Face token
- Check internet connectivity (model downloads on first run)
- Verify sufficient disk space for model files

### Port already in use
Change the port in `app_optimized.py`:
```python
app.run(host='0.0.0.0', port=9001, ...)  # Use different port
```

### Translation errors
- Check logs for detailed error messages
- Verify the service is fully loaded before making requests
- Ensure request format matches API documentation

## Integration

This service is used by the AI Health Companion backend for translating medical reports to Kinyarwanda.

See: `ai_health_companion_backend/src/services/translation.service.ts`
