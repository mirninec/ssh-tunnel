# SSH Tunnel Daemon

This script implements a simple daemon for creating and maintaining a persistent SSH tunnel on Ubuntu. It checks the tunnel's status and restores it in case of disconnection.

---

## Requirements

- Installed SSH client (`openssh-client`).
- Passwordless SSH access to the remote server.
- Administrator (sudo) privileges for systemd setup.

## Installation and Usage

### 1. Download the Script

```sh
wget https://your-github-link.com/ssh-tunnel.sh
```

Grant execution permissions to the script:

```sh
chmod +x ssh-tunnel.sh
```

Move the script to a system directory (e.g., /usr/local/bin):

```sh
sudo mv ssh-tunnel.sh /usr/local/bin/
```

Configure parameters in the script if necessary (modify SSH_PORT, LOCAL_PORT, REMOTE_USER, REMOTE_HOST, and LOG_FILE at the beginning of the script).

### 2. Systemd Integration

To run the script as a daemon using systemd, follow these steps:

Create a systemd unit file. Create the file `/etc/systemd/system/ssh-tunnel.service` with the following content:

```ini
[Unit]
Description=SSH Tunnel Daemon
After=network.target

[Service]
ExecStart=/usr/local/bin/ssh-tunnel.sh
Restart=always
RestartSec=60
User=root  # or another user with SSH permissions

[Install]
WantedBy=multi-user.target
```

Reload systemd to apply changes:

```sh
sudo systemctl daemon-reload
```

Enable and start the service:

```sh
sudo systemctl enable ssh-tunnel.service
sudo systemctl start ssh-tunnel.service
```

Check service status:

```sh
sudo systemctl status ssh-tunnel.service
```

### Viewing Logs

Systemd logs:

```sh
sudo journalctl -u ssh-tunnel.service -f
```

Script logs:

```sh
sudo tail -f /var/log/ssh-tunnel.log
```

### Script Overview

- **SSH_PORT**: The port on which the SSH server runs. This is a variable that can be changed at the beginning of the script.
- **LOCAL_PORT**: The local port for the SOCKS proxy. Also configurable in the script.
- **REMOTE_USER**: The username on the remote server.
- **REMOTE_HOST**: The remote server's address.
- **LOG_FILE**: Path to the log file.

The script runs in an infinite loop, checking every 60 seconds whether the SSH tunnel is active and restoring it if necessary.

### Important

Ensure that the user running the script has passwordless SSH access, or modify the script to handle password input.
This script is intended for Linux-based systems with pre-configured SSH access to the remote server.

### Example: Setting Up Passwordless SSH Access

1. Check for existing keys:

```sh
ls ~/.ssh
```

2. If no keys exist, generate an SSH key pair:

```sh
cd ~/.ssh/
ssh-keygen
```

3. Copy the public key to the remote server:

```sh
ssh-copy-id -i ~/.ssh/id_rsa.pub $REMOTE_USER@$REMOTE_HOST
```

4. Verify the connection:

```sh
ssh -p $SSH_PORT $REMOTE_USER@$REMOTE_HOST
```

### Example Usage

After starting the SSH tunnel, you can use the SOCKS proxy on local port $LOCAL_PORT. For example, in Firefox:

<ol>
<li>Open network settings.</li>
<li>Select "Manual proxy configuration." </li>
<li>Enter `localhost` in the "SOCKS Host" field and `$LOCAL_PORT` in the "Port" field.</li>
<li>Save the settings.</li>
</ol>

For command-line usage, e.g., with _curl_ or _wget_:

```sh
curl --socks5 localhost:$LOCAL_PORT example.com
```

```sh
wget --proxy-user= --proxy-password= --socks5-hostname=localhost:$LOCAL_PORT example.com
```

### Possible Issues

**SSH key is not recognized:** Ensure that you have copied the correct public key to the server and that the `.ssh/authorized_keys` file on the server has the correct permissions.

**Tunnel is not restoring:** Check the script and systemd logs for errors. Additional permissions or script modifications may be required.

### License

This project is distributed under the MIT License. See the [LICENSE](LICENSE) file for details.
