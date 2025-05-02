import psutil

def check_system_health():
    cpu = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory().percent
    disk = psutil.disk_usage('/').percent

    print(f"[System Health]")
    print(f"CPU Usage    : {cpu}%")
    print(f"Memory Usage : {memory}%")
    print(f"Disk Usage   : {disk}%")

    if disk > 85:
        print("Warning: Disk usage is above 85%!")

if __name__ == "__main__":
    check_system_health()


# output should look like this
#(venv) udhairam@MacBookPro DevOps Projects % "/Users/udhairam/Documents/DevOps Projects/venv/bin/python" "/Users/udhairam/Documents/DevOps Projects/python_scripts/check_system_health.py"
#[System Health]
#CPU Usage    : 17.4%
#Memory Usage : 70.8%
#Disk Usage   : 13.9%
