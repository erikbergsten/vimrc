# vimrc + sops secrets

Personal dotfiles (tmux, nvim, bash) plus SOPS-encrypted secrets in this repo.
[sops.md](sops.md) is the full reference — this is the day-to-day flow:
**encrypt on a VM today, decrypt on a new VM tomorrow, same forwarded key.**

The PGP private key never leaves your laptop (it lives in gpg-agent there).
VMs only ever hold the public key; decryption works because the gpg-agent
socket is forwarded over SSH.

## the workflow

### on the laptop, once: `~/.ssh/config`

```
Host vm*
    RemoteForward /root/.gnupg/S.gpg-agent /home/<you>/.gnupg/S.gpg-agent.extra
    StreamLocalBindUnlink yes
```

This lives on the laptop, so it applies to every new VM automatically.
(Note: `ssh -A` / `ForwardAgent yes` only forwards SSH signing — sops/PGP
decryption needs this `RemoteForward` socket instead.)

### on any VM today: encrypt and commit

```sh
# prereqs: sops + gnupg installed, repo cloned, public key imported
gpg --import pubkey.asc          # committed in this repo (public key only)
cd /root/vimrc                   # .sops.yaml with your PGP fingerprint is here

cp secrets.example.yaml secrets.yaml
$EDITOR secrets.yaml
sops encrypt --in-place secrets.yaml   # encryption needs only the PUBLIC key

git add -f secrets.yaml .sops.yaml     # -f: the plaintext name is gitignored
git commit -m "add encrypted secrets" && git push
```

Only `ENC[...]` ciphertext and the wrapped data key are committed.

### tomorrow: new VM, decrypt with the same forwarded key

```sh
# cloud-init provisions the VM and clones this repo; then:
gpg --import pubkey.asc
gpgconf --kill gpg-agent; rm -f /root/.gnupg/S.gpg-agent*   # use the forwarded socket
cd /root/vimrc
sops --decrypt secrets.yaml        # passphrase prompt appears on your laptop
sops exec-env secrets.yaml './myprogram'
```

## tmux config

install by creating a symlink

```
mkdir ~/.config/tmux/
ln -s $PWD/tmux.conf ~/.config/tmux/tmux.conf
```

### settings & bindings

#### panes

- `prefix v` / `prefix t`: split window vertically / horizontally (replaces the default `"` / `%` bindings, which are unbound)
- `main-pane-width 86`: the main pane is sized to fit an 80-column vim with line numbers (`numberwidth=5`) plus the 81st-column highlighter, for files with < 100000 lines
- `prefix h/j/k/l`: select pane left/down/up/right (vim-style)
- `Alt-h/j/k/l`: same, without the prefix
- `prefix H/J/K/L`: resize pane by 10 cells in that direction
- `prefix Ctrl-h/j/k/l`: resize pane by 1 cell in that direction
- `prefix r`: reload the config (`source-file ~/.config/tmux/tmux.conf`)
- `prefix x`: break the current pane out into its own window
- `prefix 0`: swap the current pane with pane 0
- `prefix Ctrl-x`: join the current pane into window 0
- `prefix T`: rename the current pane via a prompt; pane titles show in the top border (`[#P: name]`)

#### layouts

- `prefix a`: toggle `synchronize-panes` (send input to all panes in the window)
- `prefix A`: `main-vertical` layout
- `prefix Ctrl-a`: `main-vertical` layout, with the right pane resized to fit two 80-column vim columns

#### copy & paste (Wayland)

- `mode-keys vi`: copy mode uses vi keybindings; `set-clipboard off` so tmux doesn't touch the clipboard itself
- `prefix s`: enter copy mode
- `v`: start selection (vi-style); `Ctrl-v`: rectangle (column) selection
- `Enter` / `y`: copy selection to the Wayland clipboard via `wl-copy` and exit copy mode
- `Y`: save the selection to `~/.clip` instead of the clipboard
- `prefix P`: paste — from `~/.clip` via `wl-paste` when in a pane, or from the clipboard (paste-buffer)

#### misc

- `prefix w` / `prefix W`: send `watch` / `watch10` commands to the running program (restarting a watch in the active pane)
- `prefix Ctrl-b`: send a literal `Ctrl-b` to the program inside the pane


## init.vim

important features:

- rendering whitespaces (tabs, trailing spaces and newlines)
- color columns
- many nice bindings

install by creating as symlink

```
mkdir ~/.config/nvim/
ln -s $PWD/init.vim ~/.config/nvim/init.vim
```
