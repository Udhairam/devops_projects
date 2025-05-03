import os
import time
import psutil
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import logging

# configuration values (can be overridden by environment variables)
MAX_CPU = int(os.getenv("MAX_CPU", 80))            # CPU usage threshold (%)
MAX_MEMORY = int(os.getenv("MAX_MEMORY", 80))      # Memory usage threshold (%)
CHECK_EVERY = int(os.getenv("CHECK_EVERY", 60))    # Check interval in seconds

SMTP_SERVER = os.getenv("SMTP_SERVER", "smtp.example.com")
SMTP_PORT = int(os.getenv("SMTP_PORT", 587))
EMAIL_FROM = os.getenv("EMAIL_FROM", "your-email@example.com")
EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD", "your-email-password")
EMAIL_TO = os.getenv("EMAIL_TO", "recipient@example.com")

# logger setup
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

def send_email_alert(subject, body):
    """Send an alert email with the provided subject and body."""
    message = MIMEMultipart()
    message["From"] = EMAIL_FROM
    message["To"] = EMAIL_TO
    message["Subject"] = subject
    message.attach(MIMEText(body, "plain"))

    try:
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(EMAIL_FROM, EMAIL_PASSWORD)
            server.send_message(message)
        logging.info(f"Email alert sent: {subject}")
    except Exception as error:
        logging.error(f"Could not send email: {error}")

def check_system_usage():
    """Check current CPU and memory usage, and send alerts if thresholds are crossed."""
    cpu = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory().percent

    if cpu > MAX_CPU:
        send_email_alert("CPU Alert", f"High CPU usage detected: {cpu}%")

    if memory > MAX_MEMORY:
        send_email_alert("Memory Alert", f"High memory usage detected: {memory}%")

def start_monitoring():
    """Start the resource monitoring loop."""
    logging.info(f"Starting system monitor (check every {CHECK_EVERY}s)")
    try:
        while True:
            check_system_usage()
            time.sleep(CHECK_EVERY)
    except KeyboardInterrupt:
        logging.info("Monitoring stopped manually.")

if __name__ == "__main__":
    start_monitoring()