# Playbook Developer Setup

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
