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
    + [Config File](#config-file)
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

Start your application. This could be manually, indirectly via `docker`, etc...

```bash
bundle exec rails server -b 0.0.0.0 -p 5000 -e development  # e.g callrail
bundle exec rails server -b 0.0.0.0 -p 7000 -e development  # e.g swappy
```

Start a tunnel to your application on the same `host` and `port`

```bash
tunnel-vision start -a callrail -h 0.0.0.0 -p 5000  # e.g. callrail
tunnel-vision start -a swappy -h 0.0.0.0 -p 7000    # e.g. swappy
```

The `tunnel-vision` client will provide with the appropriate tunnel URL.

See `tunnel-vision help start` for more information about options and their default values.

### Config File

Hate typing? The `tunnel-vision` client will automatically read from a config file (`~/.tunnel-vision-config`) if present.

The config is a JSON file options for each application. Any values specified on the command line will always override values in the config file.

```json
{
  "callrail": {
    "local_hostname": "127.0.0.1",
    "local_port": 5000
  },
  "swappy": {
    "local_hostname": "127.0.0.0",
    "local_port": 7000
  }
}
```

Note that the config names are the snake case version of the long option name (e.g. `-h` -> `local-hostname` -> `local_hostname`)

# Playbook Developer Setup

If you are interested in developing or adding to this project itself (the Ansible Playbook), please see [`PLAYBOOK_DEVELOPERS_SETUP`](docs/PLAYBOOK_DEVELOPERS_SETUP.md) to get started.
