Ansible playbook for for [cr-tunnel.xyz](https://cr-tunnel.xyz/)

# Overview

You'll need -

- [] A remote server to deploy to (e.g. a DigitalOcean droplet). You can also deploy to a local VM (see below).
- [] Credentials for the remote `ansible` deploy user
- [] Credentials for `ansible-vault`
- [] `ansible` and `ansible-playbook` installed locally

_Notes_:

* All credentials can be found in 1Password
* In production, the `ansible` user should already exist. If you need to create it manually, see dev instructions below

# Running the Playbook

Ensure the `ansible-vault` password is available locally:

```bash
echo "your-ansible-vault-password" > ./vault-password
```

Use the `run` binstub with a specified tier.

```bash
bin/run dev
bin/run prod
```

* You'll be prompted for the ssh password (`ansible` deploy user's password).
* The `BECOME` password is the same value

# Development Setup (Virtual Machine)

You can set up a local virtual host to perform a trial run of the ansible playbook for development

### VM Setup

Create a new server and map the following ports
  - `ssh` - 2222 (host) -> 22 (virtual machine)
  - `ssh` - 8080 (host) -> 80 (virtual machine)


Add the following to your `hosts.ini` file

```
[dev:vars]
vm=1
ansible_port=2222
```

Set up `ssh` on the VM

```bash
# Install open-ssh
sudo apt install openssh-server

# Start SSH service
sudo service ssh start

# Verify it is running
sudo lsof -i -n -P | grep ssh
```

### Local Host Configuration

Add an entry for this server in your `/etc/hosts` file

```
sudo vi /etc/hosts

# Add below line.
# Hostname must match value in `hosts.ini` configuration!
127.0.0.1       pipe-dev.cr-tunnel.xyz
```

You can now access the virtual machine from your local host

```
ssh -p 2222 pipe-dev.cr-tunnel.xyz
```

### `ansible` user setup

Create a user named `ansible` on the deploy server and add it to the sudo-ers group

```bash
adduser ansible
gpasswd -a ansible sudo
```
