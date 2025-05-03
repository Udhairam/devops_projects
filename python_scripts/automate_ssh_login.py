import paramiko

def run_ssh_command(host, user, password, command):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        ssh.connect(host, username=user, password=password, timeout=10)
        stdin, stdout, stderr = ssh.exec_command(command)
        output = stdout.read().decode().strip()
        error = stderr.read().decode().strip()

        if output:
            print("Output:\n", output)
        if error:
            print("Error:\n", error)
    finally:
        ssh.close()

#replace with secure method in real cases
run_ssh_command("192.192.192.192", "root", "yourpassword", "ls -l")
