# sops + PGP secrets setup

Store API keys and other secrets as SOPS-encrypted files in this repo, using
PGP (GPG) keys as recipients. sops decrypts through gpg-agent, so on VMs you
can forward your laptop's gpg-agent socket over SSH (RemoteForward, section 4)
and no key material ever lands on the VM.

## 1. install

```sh
# macOS
brew install sops gnupg

# Debian/Ubuntu (droplet; gnupg + sops are already installed by cloud-init.yaml)
apt-get install -y gnupg
curl -fsSL -o /usr/local/bin/sops https://github.com/getsops/sops/releases/download/v3.13.3/sops-v3.13.3.linux.amd64
chmod +x /usr/local/bin/sops
```

## 2. create a PGP key and add its fingerprint as a recipient

```sh
gpg --quick-gen-key 'Your Name <you@example.com>' default default never
gpg --list-secret-keys --keyid-format long   # copy the 40-hex-char fingerprint
# one-liner for just the fingerprint:
gpg --list-secret-keys --with-colons | awk -F: '/^fpr/ {print $10; exit}'

# headless device where pinentry can't prompt (e.g. an iPad root shell):
# generate a passphrase-less key instead — gpg then never needs to prompt:
gpg --batch --pinentry-mode loopback --passphrase '' \
    --quick-gen-key 'Your Name <you@example.com>' default default never
```

Empty output from `--list-secret-keys` just means that keyring has no secret
keys — e.g. the key was generated as a different user (each user has their own
`~/.gnupg`), or you are on the VM where only the *public* key was imported.
Generate the key on the device that should own it and read the fingerprint
there. (On the VM an empty secret-key list is expected and fine: decryption
there goes through the forwarded gpg-agent, no local secret key needed.)

### one key for both SSH and sops (optional)

A bare SSH public key cannot be a sops/PGP recipient (gpg cannot encrypt to
`ssh-ed25519 ...`). Instead, give your PGP key an authentication subkey and
export that as your SSH public key — then one key, held only by gpg-agent,
serves both SSH (forwardable with `ssh -A`) and sops (forwardable with the
RemoteForward in section 4):

```sh
gpg --quick-add-key '<FPR>' ed25519 auth never
gpg --export-ssh-key '<FPR>!'    # -> ssh-ed25519 AAAA... openpgp:0x... (authorized_keys / GitHub)
echo 'enable-ssh-support' >> ~/.gnupg/gpg-agent.conf
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
```

Edit `.sops.yaml` and replace the placeholder fingerprint. One fingerprint
per laptop/workstation, comma separated (a YAML list works too):

```yaml
creation_rules:
  - pgp: 'FPR_LAPTOP, FPR_WORKSTATION'
```

The rule has no `path_regex`, so this single rule matches every file —
intended here. When encrypting, the *public* keys of all recipients must be
in the local keyring (`gpg --import` / keyservers handle that).

## 3. create and encrypt a secrets file

Run sops from the repo root (where `.sops.yaml` lives):

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

# commit only the encrypted file; plaintext secrets.yaml is gitignored,
# so force-add the encrypted one:
git add -f secrets.yaml .sops.yaml
git commit -m "add encrypted secrets"
```

The committed file contains only `ENC[...]` ciphertext plus the wrapped file
key — safe for a public repo.

## 4. decrypt / use on a VM (forward gpg-agent over SSH)

Unlike age/ssh recipients, PGP decryption goes through gpg-agent, so agent
forwarding works. Forward the gpg-agent socket itself (plain `ssh -A` only
forwards SSH_AUTH_SOCK) in `~/.ssh/config` on the laptop:

```
Host vm
    HostName <vm-ip>
    RemoteForward /root/.gnupg/S.gpg-agent /home/<you>/.gnupg/S.gpg-agent.extra
    StreamLocalBindUnlink yes
```

On the VM, import your public key and make sure no local gpg-agent is running,
then use sops as usual:

```sh
# on the laptop:  gpg --export -a 'FPR' > pubkey.asc   (then scp to the VM)
# on the VM:
gpg --import pubkey.asc
gpgconf --kill gpg-agent        # stop a local agent so the forwarded socket is used
rm -f /root/.gnupg/S.gpg-agent* # remove stale sockets if present
# (once per boot is enough: a local gpg-agent autostarts at first gpg use and
#  grabs /root/.gnupg/S.gpg-agent; StreamLocalBindUnlink yes in ~/.ssh/config
#  already removes a stale socket file at connect, the kill handles a running
#  local agent. If forwarding works right away, you don't need this at all.)

# verify the forwarded agent is really the laptop's: lists keygrips held by
# the agent (should match your key on the laptop, not be empty/local):
gpg-connect-agent 'keyinfo --list' /bye
ls -la /root/.gnupg/S.gpg-agent     # socket present (type 's') = RemoteForward established

# print plaintext (avoid logging it; the passphrase prompt appears on the laptop)
sops --decrypt secrets.yaml

# run a program with the secrets as env vars
sops exec-env secrets.yaml './myprogram'

# export into the current shell
set -a; source <(sops --decrypt --output-type dotenv secrets.yaml); set +a
./myprogram
```

### fresh VM checklist

The PGP **secret** key never goes on a VM — that's the point of the forwarding.
A new VM only needs:

1. `gnupg` + `sops` installed (cloud-init already installs gnupg; add sops with
   the curl command from section 1).
2. Your **public** key imported: `gpg --import pubkey.asc` (commit `pubkey.asc`
   to the repo — public keys are safe to share) or
   `gpg --keyserver keyserver.ubuntu.com --recv-keys <FPR>`.
3. The repo cloned (cloud-init already does this), so `.sops.yaml` and the
   encrypted `secrets.yaml` are present.
4. On the **laptop**, a `Host` entry with the `RemoteForward` above — that
   lives in `~/.ssh/config` on the laptop, so it applies to every new VM
   automatically; nothing key-related is configured on the VM itself.

Note: plain `ssh -A` / `ForwardAgent yes` only forwards SSH *signing*. sops/PGP
decryption on the VM needs the gpg-agent socket `RemoteForward`, which is a
separate directive.

## 5. add a new workstation later

```sh
# on the new device: gpg --quick-gen-key ..., then add its fingerprint to
# .sops.yaml, then re-wrap existing files and commit:
sops updatekeys secrets.yaml
git commit -am "add PGP recipient for new workstation"
```

## 6. revoke a lost laptop

```sh
# remove its fingerprint from .sops.yaml, then re-wrap:
sops updatekeys secrets.yaml
# old commits may still be decryptable by the lost key -> rotate the actual
# API key at the provider (Mistral, Cloudflare, ...) and scrub git history
```

## 7. multiple devices

One PGP key per device (`gpg --quick-gen-key` on each), one fingerprint per
device in `.sops.yaml`. Each recipient can decrypt independently; for k-of-n
use `key_groups:` with `shamir_threshold:` instead.

## troubleshooting

`error loading config: no matching creation rules found` means sops did not
find a usable `.sops.yaml`: it looks for the config starting in the current
directory and walking up. Run sops from the repo root (`cd ~/vimrc`), or
point at the config explicitly from anywhere:
`sops --config ~/vimrc/.sops.yaml --decrypt ~/vimrc/secrets.yaml`.
(With the single rule above having no `path_regex`, every file matches once
the config is found.)

`sops metadata not found` means the file you passed is not encrypted yet —
`--decrypt`, `exec-env`, and `sops <file>` / `sops --in-place <file>` (edit)
only work on files that already contain the `sops:` metadata block, or on a
file that does not exist yet (edit then creates and encrypts it). If
`secrets.yaml` is still the plaintext copy from `secrets.example.yaml`,
encrypt it first: `sops encrypt --in-place secrets.yaml` (legacy form
`sops -e -i secrets.yaml` also works).

A leftover placeholder fingerprint fails with gpg errors like "No public key"
or "Unusable public key" — replace it with a real fingerprint first (section 2).

## security notes

- Only ciphertext is committed; never commit plaintext `secrets.yaml`
  (it is gitignored).
- Commit `.sops.yaml` (fingerprints only) and the encrypted `secrets.yaml`.
  **Never commit secret keys** (`gpg --export-secret-keys`), `~/.gnupg`, or
  revocation certificates. The *public* key (`gpg --export -a '<FPR>'`) is
  safe to share — publish it on a keyserver or your GitHub profile so others
  can encrypt to you.
- File structure/metadata (key names, timestamps) is visible in a public repo.
- A forwarded gpg-agent means root on the connected VM can use your key while
  the session is open — only forward to VMs you trust.
