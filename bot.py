import os
import logging
import re
import requests
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

GATEWAY_PATTERNS = {
    'Stripe': r'js\.stripe\.com',
    'PayPal': r'www\.paypal\.com/sdk/js',
    'Braintree': r'js\.braintreegateway\.com',
    'Square': r'squareup\.com',
}

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text('🔍 Send me a website URL to detect payment gateways!')

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    url = update.message.text.strip()
    if not url.startswith(('http://', 'https://')):
        url = f'http://{url}'
    
    try:
        await update.message.reply_text("🔄 Analyzing...")
        headers = {'User-Agent': 'Mozilla/5.0'}
        response = requests.get(url, headers=headers, timeout=10)
        content = response.text
        
        found = [gw for gw, pattern in GATEWAY_PATTERNS.items() if re.search(pattern, content)]
        response = "✅ Detected:\n" + "\n".join(found) if found else "❌ No gateways found"
        
    except Exception as e:
        logger.error(str(e))
        response = "⚠️ Analysis failed"
    
    await update.message.reply_text(response)

def main():
    app = Application.builder().token(os.getenv('TELEGRAM_TOKEN')).build()
    app.add_handler(CommandHandler('start', start))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    app.run_polling()

if __name__ == '__main__':
    main()
