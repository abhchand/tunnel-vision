# Ansible Vault

[`ansible-vault`](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
is used to encrypt/decrypt strings so they can safely be stored
inside this repository.

Its default behavior is to encrypt the *whole* file. If we only
want some keys encrypted, we have to handle encryption/decryption
manually.

# Setup

You'll need the master vault password in a local file:
```bash
echo $MASTER_PASSWORD > ./vault-password
```

Alternately you can ask to be prompted for the password using
`--ask-vault-pass` in the below commands.

# Encrypt

```bash
ansible-vault encrypt_string mySecretString --vault-password-file ./vault-password
```

# Decrypt

```bash
echo -e '$ANSIBLE_VAULT;1.1;AES256
41533763333636303466313136383263623162376333343230623139323765643431626135646638
3931333861623538313132663939923738343030393034640a663834353738623663346365316363
32376437356336393535376430316232326231316239393337643062623837313035316139373761
3735346534326438650a383966663166646537333263613366326436316161363461616139631286
3264' | ansible-vault decrypt --vault-password-file ./vault-password && echo
```
