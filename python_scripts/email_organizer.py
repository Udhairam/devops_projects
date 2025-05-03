import imaplib
import os

# Basic config
imap_server = "imap.gmail.com"
email_user = os.getenv("EMAIL_USER")
email_pass = os.getenv("EMAIL_PASS")
search_from = "newsletter@example.com"
label_name = "Newsletters"

# Connect and login
mail = imaplib.IMAP4_SSL(imap_server)
mail.login(email_user, email_pass)
mail.select("inbox")

# Search for emails
status, messages = mail.search(None, f'FROM "{search_from}"')

# Label and delete found emails
if status == "OK":
    for num in messages[0].split():
        mail.store(num, '+X-GM-LABELS', label_name)
        mail.store(num, '+FLAGS', '\\Deleted')
    mail.expunge()

# Logout
mail.logout()
