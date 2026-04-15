# How to use gpg-agent to manage ssh keys and sign git commits

Extra docs available at
https://github.com/drduh/YubiKey-Guide


## Introduction of technologies used.

  - [**ssh-agent** - authentication agent](https://linux.die.net/man/1/ssh-agent)
  `ssh-agent` It's a program that runs in the background on your computed and keeps your 
  key loaded into memory, so that you don't need to enter your passphrase every time you 
  need to use the key.
  - [GnuPG system](https://gnupg.org/)  
  The GNU Privacy Guard  is a complete and free implementation of the OpenPGP standard as 
  defined by RFC4880 (also known as PGP). GnuPG allows you to encrypt and sign your data 
  and communications. It features a versatile key management system, along with access
  modules for all kinds of public key directories.
  GnuPG, also known as GPG, is a command line tool with features for easy integration with
  other applications. A wealth of frontend applications and libraries are available.
  GnuPG also provides support for S/MIME and Secure Shell (ssh).
  - [**scdaemon** - Smartcard daemon for the GnuPG system](https://linux.die.net/man/1/scdaemon)
  - [**gpg-agent** - Secret key management for GnuPG](https://linux.die.net/man/1/gpg-agent)

I will use `vim` as code editor throughout this guide. Fell free to edit files using
your favorite code editor.

## 1. Requirements 
**Plugin your yubi key**

```bash
## pinentry-mac is needed for smart cards.
brew install gpg pinentry-mac
```

Add some custom behavior
```bash
vim ~/.gnupg/gpg.conf
ask-cert-level
use-agent
auto-key-retrieve
no-emit-version
```


```bash
vim ~/.gnupg/gpg-agent.conf
pinentry-program /opt/homebrew/bin/pinentry-mac
enable-ssh-support
# default-cache-ttl 600     # sets the timeout (in seconds) after the last GnuPG activity 
# (so it resets if you use it)
# max-cache-ttl 7200       # the maximum-cache-ttl option set the timespan (in seconds) it caches after entering your password
# close vim
```

Get the reader name. 
Run cmd below.
```bash
pcsctest
```
type `01`

example output
```
MUSCLE PC/SC Lite Test Program

Testing SCardEstablishContext    : Command successful.
Testing SCardGetStatusChange
Please insert a working reader   : Command successful.
Testing SCardListReaders         : Command successful.
Reader 01: Yubico YubiKey OTP+FIDO+CCID
```

and save output of line `Reader 01:`

Add reader name to ` ~/.gnupg/scdaemon.conf`
```
vim ~/.gnupg/scdaemon.conf
disable-ccid
reader-port "Yubico YubiKey OTP+FIDO+CCID"
# close vim
```

Make sure that only your user can read the content of `~/.gnupg/`
```bash
chown -R $(whoami) ~/.gnupg/
chmod 700 ~/.gnupg
find ~/.gnupg -type f -exec chmod 600 {} \;
find ~/.gnupg -type d -exec chmod 700 {} \;
```

## 2. Configure `gpg-ssh` to manage `ssh`

**As a general rule, to add 
directories to your PATH, or define additional environment variables, place those changes 
in your system's shell `profile` file.**

`zsh` on Mackbooks - according to
https://apple.stackexchange.com/questions/388622/zsh-zprofile-zshrc-zlogin-what-goes-where
you could use `.zprofile` (login shell). `~/.zshrc` could also be used, but it's not
the recommended best practice, because it's an interactive shell and not the login shell.

If you are using `bash` on a macbook -> `~/.bash_profile`

Set your shell profile file and use it from this point forward.
```bash
SHELL_PROFILE_FILE=<~/.bash_profile or ~/.zprofile or ~/.zshrc>
```

```bash
vim ${SHELL_PROFILE_FILE}
SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
GPG_TTY=$(tty)
export SSH_AUTH_SOCK GPG_TTY
gpgconf --launch gpg-agent
# close vim
```

Restart
```bash
pkill gpg-agent
# check if any GPG PID is left
ps aux | grep gpg
source "${SHELL_PROFILE_FILE}"
```


## 3. Configure Yubikeys
Required software

[ykman - Configure your YubiKey via the command line](https://developers.yubico.com/yubikey-manager/)

```bash
brew install ykman
```

When done check
```bash
ykman info
```

example output
```
Device type: YubiKey 5C NFC
Serial number: 29173990
Firmware version: 5.7.1
Form factor: Keychain (USB-C)
Enabled USB interfaces: OTP, FIDO, CCID
NFC transport is enabled.

Applications	USB    	NFC
OTP         	Enabled	Enabled
FIDO U2F    	Enabled	Enabled
FIDO2       	Enabled	Enabled
OATH        	Enabled	Enabled
PIV         	Enabled	Enabled
OpenPGP     	Enabled	Enabled
YubiHSM Auth	Enabled	Enabled
```


## 4. Meta Configuration
Do these Steps On both of the Yubikeys (you should have 2 ):

```bash
gpg --edit-card
gpg/card> admin
gpg/card> help
gpg/card> passwd    
gpg/card> 3         # change Admin PIN, default Admin PIN for Yubikey is 12345678
# when done correctly should see something like this
# PIN changed
gpg/card> 1         # 1 - change PIN, default PIN is 123456
# after changing both admin pin and unlock pin 
# Q
gpg/card> name      # Set your name (Admin PIN will be requested)
gpg/card> lang      # Change set language preference 
gpg/card> en        # chose English 
Language preferences: en
gpg/card> sex       # set your gender
Salutation (M = Mr., F = Ms., or space): M
gpg/card> login     # set your email address that you use for github.com
Login data (account name): user.userfamilyname@gmail.com
gpg/card> key-attr  # change encryption algorithm for Signature, Encryption and Authentication keys (repeat the process 3 times)
gpg/card> 2         # choose elliptic curve ((2) ECC)
gpg/card> 1         # default
gpg/card> list      # confirm the change by checking "Key attributes" field
# Key attributes ...: ed25519 cv25519 ed25519
gpg/card> uif 1 on  # enable touch id for signing certificate
gpg/card> uif 2 on  # enable touch id for decrypt certificate
gpg/card> uif 3 on  # enable touch id for authentication certificate
gpg/card> list
# following like should look like this
UIF setting ......: Sign=on Decrypt=on Auth=on
```

## 5. Generate GPG key pair
We will generate the PGP key directly on the YubiKey. This is the most secure way.
Even if you will never be able to backup your key, you will have 2 keys. If you lose 
your yubi key, you will revoke the key and remove the public key from github.com.


**Note: when generating the key, please use the email that you use for your github.com 
account**

```bash
gpg --card-edit
...
gpg/card>generate
 (d/N) N  # do not create backup key outside the yubikey
# enter PIN (not admin PIN)
0  # key never expires
# Fill in Name and !!! email address you use for github.com !!!
#  take note of "revocation certificate stored"
```

Save revocation certificate path. E.g.:
```bash
REVOCATION_CERT_PATH=/Users/radupopa/.gnupg/openpgp-revocs.d/3677D95FAA2F730C042740053751E62A1B0C3E57.rev
```

Get the name of the public key
```bash
gpg --list-keys
```

example output
```bash
...
pub   ed25519 2024-07-18 [SC]
      3677D95FAA2F730C042740053751E62A1B0C3E57
uid           [ supremă] Radu Popa (Radu Popa Github) <radupopa21be@gmail.com>
sub   ed25519 2024-07-18 [A]
sub   cv25519 2024-07-18 [E]
```

```bash
PUBLIC_KEY_ID=3677D95FAA2F730C042740053751E62A1B0C3E57
PUBLIC_KEY="${PUBLIC_KEY_ID}.public"
PUBLIC_KEY_PATH=~/.gnupg/"${PUBLIC_KEY}"
```

We are going to use `${PUBLIC_KEY}` in following instructions, so set this as a
variable now.

## 6. Save the revocation certificate for `${PUBLIC_KEY}` in 1password 
Go to 1password -> Private Valut -> New -> Document -> browse for path saved under `REVOCATION_CERT_PATH` -> Show hidden files, hold: `CMD + SHIT + .` -> After file is
uploaded set also a note "revocation certificate for  GPG key value set under 
`PUBLIC_KEY`"


## 7. Export Public key

Now export the public key locally
```bash
gpg --export --armor "${PUBLIC_KEY_ID}"  > "${PUBLIC_KEY_PATH}"
```

Verify that the keys was indeed exported
```bash
ls -l "${PUBLIC_KEY_PATH}"
```

example output
```bash
-rw-r--r--  1 radupopa  staff  4788 18 Iul 12:46 /Users/radupopa/.gnupg/3677D95FAA2F730C042740053751E62A1B0C3E57.public
```

maybe do also a visual check
```bash
cat "${PUBLIC_KEY_PATH}"
```

example trimmed output
```
-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMEZpkothYJKwYBBAHaRw8BAQdApH0J5AUmEfwxx8C0SIh4UHS1Q5DPhS8sLO3g
+gLdKRa0M1JhZHUgUG9wYSAoRm9yIEdpdGh1Yi5jb20pIDxyYWR1cG9wYTIxYmVA
Z21haWwuY29tPoiTBBMWCgA7FiEEv1RvM0BK9oz8e02QX9yhOrJATkQFAmaZKLYC
GwMFCwkIBwICIgIGFQoJCAsCBBYCAwECHgcCF4AACgkQX9yhOrJATkTCfwD+Mu3F
sQqmtc7f6nq8T8DTtoGpzVuOGQwQ2RzVouKE+YQBAIYjw1qbL3Yj+HFiUCca820G
oafH9ex6x/v2r4SJ/QENuDMEZpkothYJKwYBBAHaRw8BAQdAzDZHTV5D3WAfmdUm
7uGXd2N4lEP5fYNLQk2MO8srIbeIeAQYFgoAIBYhBL9UbzNASvaM/HtNkF/coTqy
QE5EBQJmmSi2AhsgAAoJEF/coTqyQE5El30A/3AbQ/4jaUHTbHnj9Fuw4s7/nh5G
NgXIF/TIQPaTNUUzAQDdvne4IfDzHNWxC6goHg/zkGUdm1OBRmEiKpeBaQN8CLg4
BGaZKLYSCisGAQQBl1UBBQEBB0By3/LjAX1zHS9/WMW3o76VaKMRcG9HNWpy8+l1
5xf/cQMBCAeIeAQYFgoAIBYhBL9UbzNASvaM/HtNkF/coTqyQE5EBQJmmSi2AhsM
AAoJEF/coTqyQE5EztIA/jCa7zios1yudIsGjAnLiBREcSULZi+SnGY/I65HWCg9
AP9PkHPWY2WnOqo5r/1ltEN9RwtTYZpHaqE0+K/up+ckDA==
=IJqP
-----END PGP PUBLIC KEY BLOCK-----```


### 8. Test encryption / decryption using the keys.

Generate a file:
```bash
echo "I will never give you up" > test-enc.txt
```

Set recipient user. USE the email you used when creating the key.
Encrypt the test file.
e.g. 
```bash
EMAIL_ADD=radupopa21be@gmail.com
gpg --recipient "${EMAIL_ADD}" --encrypt test-enc.txt
```

This generate a file `test-enc.txt.gpg`. Content should be encrypted
```bash
ls -l test-enc.txt.gpg
cat test-enc.txt.gpg
```

Decrypt the test file
```bash
gpg --recipient "radupopa21be@gmail.com" --decrypt test-enc.txt.gpg
```

sample output
```bash
gpg: encrypted with cv25519 key, ID 46A79F64561D5393, created 2024-07-18
      "Radu Popa (Radu Popa Github) <radupopa21be@gmail.com>"
I will never give you up
```


## 9. Publish Your Public GPG Key

**!!! Important note
keys stored on https://keys.openpgp.org do not store user ID for the public key. This will cause problems when you want to import your public key on a new machine.
example error.**

My failed example:
```bash
gpg --import DBE0B8427CD7E8606C8CB852F7391C70EA811321.asc
gpg: key F7391C70EA811321: no user ID
gpg: Total number processed: 1
```


Upload your public key to your google drive or any other cloud storage or any other
similar service. 

If you need to use the same yubi key to a different machine, you will need to import
it into GPG

For example
```bash
gpg --import "${PUBLIC_KEY_PATH}"
```


## 10. Github: Signing and Authentication using Yubikeys

Get the ssh key associated with the yubi key
```bash
  ssh-add -L | grep cardno > ~/.ssh/ssh-yubi-"${PUBLIC_KEY}"
cat ~/.ssh/ssh-yubi-"${PUBLIC_KEY}"
```

Should look like:
```bash
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAciW/6ygAuN2ESI9T2GiHTyFgM20gTGthFKXXKGdwzX cardno:29_173_990
```

Add your `ssh` key from above to the github account and remove the previous ssh-key there.

Get content of your GPG key
```bash
cat "${PUBLIC_KEY_PATH}"
```

Get name of your GPG public key
```bash
echo "${PUBLIC_KEY}"
```

sample output
```bash
3677D95FAA2F730C042740053751E62A1B0C3E57.public
```

Add your GPG Key to Github


Configure Signing
```bash
vim ~/.gitconfig
[user]
        email = <user.userfamilyname@gmail.com>
        name  = <user userFamilyName>
        signingkey = <user.userfamilyname@gmail.com>
[commit]
        gpgsign = true
# close vim
```

Make sure that no `IdentityFile` is set in `~/.ssh/config`.
```bash
cat ~/.ssh/config
```

Reload config just to make sure everything will work on next login.
```bash
pkill gpg-agent 
pkill ssh-agent
gpgconf --launch gpg-agent
```

Go to any git repos, add a new empty line to a README.md file, commit changes.
It should ask the PIN for the key. Enter that. The touch surface of the yuby key 
should blink. Touch it to sing the commit.

**Congratulations** Now you are signing git commits with a GPG stored **only** on your
yubi key.

## 11. Configure second yubi key.
Start the whole process again for step 4. 

Make sure you follow the procedure especially generate the GPG key on the yubi key and
add second `ssh` and `gpg` keys to github.com. 

start with a status to make sure that the yubi key is empty
```bash
gpg --card-status
```

**NOTE: When testing the sign commit for the second key**
Because both keys have the same email as identifier, you will have to delete the first 
key from `gpg` key ring:

```bash
gpg --list-key
```

example output 
```bash
/Users/radupopa/.gnupg/pubring.kbx
----------------------------------

pub   ed25519 2024-07-18 [SC]
      3677D95FAA2F730C042740053751E62A1B0C3E57
uid           [ supremă] Radu Popa (Radu Popa Github) <radupopa21be@gmail.com>
sub   ed25519 2024-07-18 [A]
sub   cv25519 2024-07-18 [E]

pub   ed25519 2024-07-18 [SC]
      BF546F33404AF68CFC7B4D905FDCA13AB2404E44
uid           [ supremă] Radu Popa (For Github.com) <radupopa21be@gmail.com>
sub   ed25519 2024-07-18 [A]
sub   cv25519 2024-07-18 [E]
```

```bash
gpg --delete-secret-keys 3677D95FAA2F730C042740053751E62A1B0C3E57
gpg --delete-keys 3677D95FAA2F730C042740053751E62A1B0C3E57
```

If you want to use the first key again, you will have to delete this key from the
`gpg` keyring and import the first public key and run commands from section

`Point GPG to the second Yubikey.` below


## Additional useful documentation


### Point GPG to the second Yubikey. 
This step is needed whenever you swap the Yubi-keys


```bash
gpg-connect-agent "scd serialno" "learn --force" /bye
pkill gpg-agent
gpgconf --launch gpg-agent
```
### Pin unblocking
**If you block the pin and admin pin** you can use the hex method linked in this gist
https://gist.github.com/dminca/1f8b5d6169c6a6654a95f34a80983218

Saving the steps here also
```bash
gpg-connect-agent --hex
> scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
D[0000] 69 82 i.
OK
> scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
D[0000] 69 82 i.
OK
> scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
D[0000] 69 82 i.
OK
> scd apdu 00 20 00 81 08 40 40 40 40 40 40 40 40
D[0000] 69 83 i.
OK
> scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
D[0000] 69 82 i.
OK
> scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
D[0000] 69 82 i.
OK
> scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
D[0000] 69 82 i.
OK
> scd apdu 00 20 00 83 08 40 40 40 40 40 40 40 40
D[0000] 69 83 i.
OK
> scd apdu 00 e6 00 00
D[0000] 90 00 ..
OK
> scd apdu 00 44 00 00
D[0000] 90 00 ..
OK
>
```
- unplug/plug YubiKey
- kill the GPG Agent & scdaemon

```bash
pkill gpg-agent && pkill scdaemon
```

- get a card status `gpg --card-status`
- success; YubiKey was `factory-reset` - you lost all data on it
