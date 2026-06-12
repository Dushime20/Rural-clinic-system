import torch
import json
import os
from flask import Flask, request, jsonify
from transformers import AutoModelForSeq2SeqLM, AutoTokenizer
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = Flask(__name__)

# -------------------------------------------------------------
# 1. INITIALIZATION (Runs exactly ONCE when the server starts)
# -------------------------------------------------------------
MODEL_NAME = "mbazaNLP/Nllb_finetuned_general_en_kin"
HF_TOKEN = os.getenv("HUGGING_FACE_TOKEN")

if not HF_TOKEN:
    raise ValueError("HUGGING_FACE_TOKEN environment variable is required. Create a .env file with your token.")

print("--> Loading Mbaza NLP Engine into memory...")
device = "cuda" if torch.cuda.is_available() else "cpu"
dtype = torch.float16 if device == "cuda" else torch.float32

tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME, token=HF_TOKEN)
model = AutoModelForSeq2SeqLM.from_pretrained(
    MODEL_NAME, 
    token=HF_TOKEN,
    torch_dtype=dtype,
    low_cpu_mem_usage=True
).to(device)

print(f"--> Success: Engine loaded on {device.upper()}. API is ready!")

# -------------------------------------------------------------
# 2. THE TRANSLATION ENDPOINT
# -------------------------------------------------------------
@app.route('/translate', methods=['POST'])
def translate():
    try:
        # Get JSON data from the incoming request
        data = request.get_json()
        
        if not data or 'text' not in data:
            return jsonify({"error": "Missing 'text' key in JSON payload"}), 400
            
        text_to_translate = data['text']
        
        # Perform the rapid local inference
        inputs = tokenizer(text_to_translate, return_tensors="pt").to(device)
        translated_tokens = model.generate(
            **inputs, 
            forced_bos_token_id=tokenizer.convert_tokens_to_ids("kin_Latn"),
            max_length=100
        )
        
        result = tokenizer.batch_decode(translated_tokens, skip_special_tokens=True)[0]
        
        # Return the response as JSON
        return jsonify({
            "english": text_to_translate,
            "kinyarwanda": result
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Start the Flask server on your local network
if __name__ == '__main__':
    # '0.0.0.0' allows physical phones on the same Wi-Fi network to connect to your PC
    app.run(host='0.0.0.0', port=9000, debug=False)