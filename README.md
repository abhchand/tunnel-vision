<div align="center">
  <a href="https://github.com/abhchand/tunnel-vision">
    <img
      width="150"
      alt="tunnel-vision"
      src="meta/logo.png?raw=true"
    />
  </a>

  <h3>tunnel-vision</h3>

  <p>A public URL for your localhost environment.</p>
</div>

---

- [Quick Start](#quick-start)
- [One-time Setup](#one-time-setup)
    + [SSH Setup](#ssh-setup)
    + [Register new user](#register-new-user)
    + [Install the Ruby Client](#install-the-ruby-client)
- [Developer Setup](#developer-setup)
  * [Production](#production)
    + [Pre-requisites](#pre-requisites)
    + [Running the Playbook](#running-the-playbook)
  * [Development (Virtual Machine)](#development--virtual-machine-)
    + [VM Setup](#vm-setup)
    + [Local Host Configuration](#local-host-configuration)
    + [`ansible` user setup](#-ansible--user-setup)
    + [Run the playbook](#run-the-playbook)



# Quick Start

⚠️ **NOTE**: Make sure you've completed the **one-time setup** below before running this

Ensure the local application you are tunneling to is running on `$APP_HOST` and `$APP_PORT`

```bash
tunnel-vision start -u $USER -h $APP_HOST -p $APP_PORT
```

Then visit `"https://$USER.pipe.cr-tunnel.xyz/"` in your browser.

# One-time Setup

### SSH Setup

Create an SSH keypair:

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

### Register new user

Submit a pull request to add your name, public key, and port to the [`tunnel_users` in the configuration file](roles/tunnel-server/vars/main.yml).

Example:

```yaml
tunnel_users:
  - name: abhishek
    unique_port: 1738
    public_key: ssh-rsa AAAAB3NzaC1...
```

### Install the Ruby Client

```bash
curl --silent 'https://raw.githubusercontent.com/abhchand/tunnel-vision/master/lib/client/ruby/install.sh' | sh
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

Store the credentials for `ansible` to read:

```bash
echo "your-ansible-vault-password" > ./ansible-vault-password
echo "your-ansible-user-password" > ./ansible-user-password
```

Then, run the playbook

```bash
bin/run prod
```

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
