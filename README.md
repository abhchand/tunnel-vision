[pipe.cr-tunnel.xyz](https://pipe.cr-tunnel.xyz/) provides a public URL for your localhost environment (similar to [`ngrok`](https://ngrok.com/)).

This repository contains the ansible playbook for provisioning the server

- [User Setup](#user-setup)
    + [One-time Setup](#one-time-setup)
    + [Start the Tunnel](#start-the-tunnel)
- [Developer Setup](#developer-setup)
  * [Production](#production)
    + [Pre-requisites](#pre-requisites)
    + [Running the Playbook](#running-the-playbook)
  * [Development (Virtual Machine)](#development--virtual-machine-)
    + [VM Setup](#vm-setup)
    + [Local Host Configuration](#local-host-configuration)
    + [`ansible` user setup](#-ansible--user-setup)
    + [Run the playbook](#run-the-playbook)


# User Setup

### One-time Setup

First, create an SSH keypair:

```
ssh-keygen -t rsa
```

Then in your `~/.ssh/config`, define how you connect to `exec@pipe.cr-tunnel.xyz`

```
Host *
  AddKeysToAgent yes
  IdentitiesOnly yes
  ForwardAgent yes

Match host pipe.cr-tunnel.xyz user exec
   PreferredAuthentications publickey
   IdentityFile ~/.ssh/<your-key>.pub
```

Finally, submit a pull request to add your name to the [configuration](roles/tunnel-server/vars/main.yml). You'll specify your username, the above **public** key, and a unique port number.

Example:

```yaml
tunnel_users:
  - name: abhishek
    unique_port: 1738
    public_key: ssh-rsa AAAAB3NzaC1...
```

### Start the Tunnel

```bash
export REMOTE_PORT=1738 # As configured in your pull request above
export LOCAL_PORT=3000
export USERNAME=abhishek

ssh -nNT -g -R "*:$REMOTE_PORT:0.0.0.0:$LOCAL_PORT" exec@pipe.cr-tunnel.xyz

open "$USERNAME.pipe.cr-tunnel.xyz"
```

# Developer Setup

You can run the ansible play on the production server or on a local VM instance for testing.

## Production

### Pre-requisites

You'll need:

* `ansible` installed locally ([instructions](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html))
* Credentials for the `ansible@pipe.cr-tunnel.xyz` deploy user
* Credentials for `ansible-vault`

(**Note**: All credentials can be found in `1Password`)

### Running the Playbook

Store the `ansible-vault` password for `ansible` to read:

```bash
echo "your-ansible-vault-password" > ./vault-password
```

Then, run the playbook

```bash
bin/run prod
```

Notes:

* You'll be prompted for the `ansible@pipe.cr-tunnel.xyz` ssh password
* The `BECOME` password is the same value


## Development (Virtual Machine)

### VM Setup

Create a new server and map the following ports
  - `ssh` - 2222 (host) -> 22 (virtual machine)
  - `ssh` - 8080 (host) -> 80 (virtual machine)


Log in to the VM and set up `ssh`

```bash
sudo apt install openssh-server
sudo service ssh start

# Verify it is running
sudo lsof -i -n -P | grep ssh
```

### Local Host Configuration

Add an entry for this "server" (VM) in your `/etc/hosts` file

```
sudo vi /etc/hosts

# Add below line.
# Hostname must match value in `hosts.ini` configuration!
127.0.0.1       pipe-dev.cr-tunnel.xyz
```

You can now access the virtual machine from your local host:

```
ssh -p 2222 pipe-dev.cr-tunnel.xyz
```

### `ansible` user setup

Create a user named `ansible` and add it to the sudo-ers group. (Be sure to note the password)

```bash
adduser ansible
gpasswd -a ansible sudo
```

### Run the playbook

```bash
bin/run dev
```

Notes:

* You'll be prompted for the `ansible@dev-pipe.cr-tunnel.xyz` ssh password
* The `BECOME` password is the same value
