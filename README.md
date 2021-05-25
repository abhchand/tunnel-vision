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

- [One-time Setup](#one-time-setup)
    + [SSH Setup](#ssh-setup)
    + [Register new user](#register-new-user)
    + [Install the Ruby Client](#install-the-ruby-client)
- [Run](#run)
- [Playbook Developer Setup](#playbook-developer-setup)


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
   IdentityFile ~/.ssh/<your-key>
```

### Register new user

Submit a pull request to add your name and public key to the [`tunnel_users` in the configuration file](roles/tunnel-server/vars/main.yml).

Example:

```yaml
tunnel_users:
  - name: abhishek
    public_key: ssh-rsa AAAAB3NzaC1...
```

### Install the Ruby Client

```bash
curl --silent 'https://raw.githubusercontent.com/abhchand/tunnel-vision/master/lib/client/ruby/install.sh' | sh
```

# Run

You'll need to start a separate tunnel for _each target application_ you'd like to connect to.

Start your application (either manually, with `docker`, etc...)

```bash
bundle exec rails server -b 0.0.0.0 -p 3000 -e development
```

Start the tunnel to your `$APPLICATION` (`callrail`, `swappy`, etc..) on the same `host` and `port`

```bash
tunnel-vision start -u $USER -a $APPLICATION -h 0.0.0.0 -p 3000
```

Visit `https://$USER-$APPLICATION.pipe.cr-tunnel.xyz/` in your browser.

**NOTE**: If your application is `callrail`, you can visit `https://$USER.pipe.cr-tunnel.xyz/` as a shortcut.


# Playbook Developer Setup

If you are interested in developing or adding to this project itself (the Ansible Playbook), please see [`PLAYBOOK_DEVELOPERS_SETUP`](docs/PLAYBOOK_DEVELOPERS_SETUP.md) to get started.
