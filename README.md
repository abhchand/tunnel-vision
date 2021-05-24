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
- [Playbook Developer Setup](#playbook-developer-setup)


# Quick Start

⚠️ **NOTE**: Make sure you've completed the **one-time setup** below before running this


```bash
tunnel-vision start -u $USER
```

Ensure the local application you are tunneling to is running locally. See `--help` menu for options to set local hostname and port on the tunnel connection.

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

# Playbook Developer Setup

If you are interested in developing or adding to this project itself (the Ansible Playbook), please see [`PLAYBOOK_DEVELOPERS_SETUP`](docs/PLAYBOOK_DEVELOPERS_SETUP.md) to get started.
