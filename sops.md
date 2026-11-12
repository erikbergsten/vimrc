# sops + age secrets setup

Store API keys and other secrets as SOPS-encrypted files in this repo, using
SSH public keys as age recipients. Any machine whose SSH private key is in the
forwarded agent can decrypt — no passwords or extra credentials per VM.

## 1. install

```sh
# macOS
brew install sops age

# Debian/Ubuntu (droplet)
apt-get install -y age
curl -Lo /usr/local/bin/sops https://github.com/getsops/sops/releases/latest/download/sops-latest.linux.amd64
chmod +x /usr/local/bin/sops
```

## 2. add your public key as a recipient

Edit `.sops.yaml` and replace the placeholder with your SSH public key:

```sh
cat ~/.ssh/id_ed25519.pub
# ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your-laptop
```

One `ssh-ed25519 ...` line per laptop/workstation. SSH skips keys that are
not present on a machine, and the age/SSH recipient decryption goes through
the local ssh-agent, so agent forwarding (`AllowAgentForwarding yes`) is
enough on VMs.

## 3. create and encrypt a secrets file

Run sops from the repo root (where `.sops.yaml` lives), and always on
`secrets.yaml` — never on `secrets.example.yaml`:

```sh
cd ~/vimrc
cp secrets.example.yaml secrets.yaml
$EDITOR secrets.yaml        # put real values in

# encrypt the finished file in place (bare `sops encrypt secrets.yaml` prints
# ciphertext to stdout and leaves the file plaintext — always pass --in-place,
# or redirect to a different file: `sops encrypt secrets.yaml > secrets.enc.yaml`):
sops encrypt --in-place secrets.yaml

# alternative: create the file directly in the sops editor (encrypts on save):
#   rm secrets.yaml && sops secrets.yaml

# commit only the encrypted file; plaintext secrets.yaml is gitignored
git add .sops.yaml secrets.yaml
git commit -m "add encrypted secrets"
```

The committed file contains only `ENC[...]` ciphertext plus the wrapped file
key — safe for a public repo.

## 4. decrypt / use on a VM (with agent forwarded)

```sh
# print plaintext (avoid logging it)
sops --decrypt secrets.yaml

# run a program with the secrets as env vars
sops exec-env secrets.yaml './myprogram'

# export into the current shell
set -a; source <(sops --decrypt --output-type dotenv secrets.yaml); set +a
./myprogram

# one-shot env (breaks on values with spaces; prefer exec-env or source)
env $(sops --decrypt --output-type dotenv secrets.yaml | xargs) ./myprogram
```

## 5. add a new workstation later

```sh
# append the new laptop's ssh-ed25519 pubkey to .sops.yaml, then:
sops updatekeys secrets.yaml
git commit -am "add age recipient for new workstation"
```

## 6. revoke a lost laptop

```sh
# remove its pubkey line from .sops.yaml, then re-wrap:
sops updatekeys secrets.yaml
# old commits may still be decryptable by the lost key -> rotate the actual
# API key at the provider (Mistral, Cloudflare, ...) and scrub git history
```

## 7. multiple SSH keys (one per device)

`~/.ssh/config` — list all keys, SSH tries each:

```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_laptop1
    IdentityFile ~/.ssh/id_ed25519_workstation
    IdentitiesOnly yes
```

Add every pubkey to GitHub (Settings -> SSH keys) and to `.sops.yaml`.

## troubleshooting

`error loading config: no matching creation rules found` means sops found a
`.sops.yaml` but no creation rule matched the file you passed. sops looks for
`.sops.yaml` starting in the current directory and walking up, and matches
`path_regex` against the file path relative to that config file. So:

- run sops from the repo root (`cd ~/vimrc`), and
- pass `secrets.yaml`, not `secrets.example.yaml` or another path — from
  anywhere else, point sops at the config explicitly:
  `sops --config ~/vimrc/.sops.yaml --decrypt ~/vimrc/secrets.yaml`

A leftover placeholder recipient fails differently ("malformed SSH recipient"):
replace it with your real public key in `.sops.yaml` first (section 2).

`sops metadata not found` means the file you passed is not encrypted yet —
`--decrypt`, `exec-env`, and `sops <file>` / `sops --in-place <file>` (edit)
only work on files that already contain the `sops:` metadata block, or on a
file that does not exist yet (edit then creates and encrypts it). If
`secrets.yaml` is still the plaintext copy from `secrets.example.yaml`,
encrypt it first: `sops encrypt --in-place secrets.yaml` (legacy form
`sops -e -i secrets.yaml` also works). Also avoid a catch-all
`path_regex: .*` — it makes every file in the repo a sops target; keep the
rule scoped to `secrets.yaml`.

## security notes

- Only ciphertext is committed; never commit plaintext `secrets.yaml`.
- File structure/metadata (key names, timestamps) is visible in a public repo.
- Agent forwarding means root on a connected VM can sign with your keys while
  the session is open — only forward to VMs you trust.
