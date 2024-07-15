import paramiko
import os
import subprocess
import socket


# Function to get the local IP address
def get_local_ip():
  try:
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
      s.connect(("8.8.8.8", 80))
      local_ip = s.getsockname()[0]
  except Exception:
    local_ip = "127.0.0.1"
  return local_ip


# Configuration
username = "u"
password = "shengcheng2024"
hosts_file = "hosts"
private_key_path = os.path.expanduser("~/.ssh/id_rsa")
public_key_path = os.path.expanduser("~/.ssh/id_rsa.pub")
ssh_config_path = os.path.expanduser("~/.ssh/config")
local_ip = get_local_ip()  # Get local IP address

# Create or regenerate SSH config file
with open(ssh_config_path, "w") as config_file:
  config_file.write("Host *\n   StrictHostKeyChecking no\n")

# Read public key once
with open(public_key_path, "r") as file:
  public_key = file.read().strip()

# Generate SSH keys if not exists
if not os.path.exists(private_key_path):
  subprocess.run(
    [
      "ssh-keygen",
      "-t",
      "rsa",
      "-b",
      "4096",
      "-N",
      "",
      "-f",
      private_key_path,
    ],
    check=True,
  )
  print("SSH key generated.")
else:
  print("SSH key already exists.")


# Function to setup SSH connection and execute commands
def setup_ssh(host, username, password, commands):
  try:
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(host, username=username, password=password)
    for command in commands:
      stdin, stdout, stderr = client.exec_command(command)
      stdout.channel.recv_exit_status()  # This forces command execution
      errors = stderr.read().decode()
      if errors:
        print(f"Error executing {command} on {host}: {errors}")
      else:
        print(f"Executed {command} on {host} successfully.")
    client.close()
  except Exception as e:
    print(
      f"Failed to connect or execute commands on {host}: {str(e)}"
    )


# Read hosts file and process each host
with open(hosts_file, "r") as file:
  for line in file:
    if line.strip():
      parts = line.strip().split()
      if len(parts) < 2:
        print(f"Skipping malformed line: {line}")
        continue
      ip, node = parts
      print(f"Processing {node} ({ip})")

      # Commands to run on the remote host
      commands = [
        "mkdir -p ~/.ssh && chmod 700 ~/.ssh",
        f"echo '{public_key}' >> ~/.ssh/authorized_keys",
        "chmod 600 ~/.ssh/authorized_keys",
      ]

      setup_ssh(ip, username, password, commands)

      if ip == local_ip:
        print(
          f"Skipping key and config overwrite on local node: {node}"
        )
        continue  # Skip overwriting keys and config if it's the local machine
      # Copy private and public key and SSH config to the remote host
      try:
        transport = paramiko.Transport((ip, 22))
        transport.connect(username=username, password=password)
        sftp = paramiko.SFTPClient.from_transport(transport)
        sftp.put(private_key_path, "/home/u/.ssh/id_rsa")
        sftp.put(public_key_path, "/home/u/.ssh/id_rsa.pub")
        sftp.put(
          ssh_config_path, "/home/u/.ssh/config"
        )  # Also copy the SSH config file
        sftp.close()
        transport.close()
        print(
          f"Keys and SSH config copied to {node} ({ip}) successfully."
        )
      except Exception as e:
        print(
          f"Failed to copy keys and SSH config to {node} ({ip}): {str(e)}"
        )

print("Processed all nodes.")
