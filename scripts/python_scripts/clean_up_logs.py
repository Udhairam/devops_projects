import os
import time

def clean_logs(directory="/var/logs", days_old=7):
    now = time.time()
    cutoff = now - (days_old * 86400)

    for root, _, files in os.walk(directory):    #recursively iterates through the directory and all subfolders
        for file in files:
            path = os.path.join(root, file)        #safely combines directory and file name into a full file path
            if os.path.isfile(path) and os.path.getmtime(path) < cutoff:
                try:
                    os.remove(path)
                    print(f"Deleted: {path}")
                except Exception as e:
                    print(f"Error deleting {path}: {e}")

clean_logs()