https://github.com/drduh/YubiKey-Guide

## How to use gpg-agent to manage ssh keys and sign git commits

### Requirements (MacOS)

```
## pinentry-mac is needed for smart cards.
brew install gpg pinentry-mac

vim ~/.gnupg/gpg.conf
ask-cert-level
use-agent
auto-key-retrieve
no-emit-version

vim ~/.gnupg/gpg-agent.conf
pinentry-program /opt/homebrew/bin/pinentry-mac
enable-ssh-support
#default-cache-ttl 600     # sets the timeout (in seconds) after the last GnuPG activity (so it resets if you use it)
#max-cache-ttl 7200       # the maximum-cache-ttl option set the timespan (in seconds) it caches after entering your password

pcsctest    # get the READER name
vim ~/.gnupg/scdaemon.conf
disable-ccid
reader-port "Yubico YubiKey OTP+FIDO+CCID"

chown -R $(whoami) ~/.gnupg/
chmod 700 ~/.gnupg
find ~/.gnupg -type f -exec chmod 600 {} \;
find ~/.gnupg -type d -exec chmod 700 {} \;

vim ~/.zshrc
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
export GPG_TTY=$(tty)
gpgconf --launch gpg-agent

pkill gpg-agent
ps aux | grep gpg
gpgconf --launch gpg-agent
```

## Linux
Configure gpgp client for ssh
  - [**scdaemon** - Smartcard daemon for the GnuPG system](https://linux.die.net/man/1/scdaemon)
  - [GnuPG system](https://gnupg.org/)
  - [**gpg-agent** - Secret key management for GnuPG](https://linux.die.net/man/1/gpg-agent)
  
  The GNU Privacy Guard  is a complete and free implementation of the OpenPGP standard as defined by RFC4880 
  (also known as PGP). GnuPG allows you to encrypt and sign your data and communications; 
  it features a versatile key management system, along with access modules for all kinds of public key directories.
  GnuPG, also known as GPG, is a command line tool with features for easy integration with other applications. 
  A wealth of frontend applications and libraries are available. GnuPG also provides support for S/MIME and Secure Shell (ssh).
  - [**ssh-agent** - authentication agent](https://linux.die.net/man/1/ssh-agent)
```
sudo apt install scdaemon
sudo killall gpg-agent
sudo killall ssh-agent
eval $( gpg-agent --daemon --enable-ssh-support )
echo 'export SSH_AUTH_SOCK="/run/user/$(id -u)/gnupg/S.gpg-agent.ssh"' >> ~/.bashrc
echo 'gpgconf --launch gpg-agent' >> ~/.bashrc
source ~/.bashrc

ssh-add -L            # confirm
```

### Configure Yubikeys
#### Required software

[ykman - Configure your YubiKey via the command line](https://developers.yubico.com/yubikey-manager/)

##### Debian and Ubuntu
```bash
sudo apt update
sudo apt -y upgrade
sudo apt -y install wget gnupg2 gnupg-agent dirmngr cryptsetup scdaemon pcscd secure-delete hopenpgp-tools yubikey-personalization
```

You may additionally need (particularly for Ubuntu 18.04 and 20.04):

```bash
sudo apt -y install libssl-dev swig libpcsclite-dev
```

To install and use the `ykman` utility

```bash
sudo apt -y install python3-pip python3-pyscard

sudo apt-add-repository ppa:yubico/stable
sudo apt update
sudo apt install -y yubikey-manager

sudo systemctl start pcscd
# Make sure pcscd is started

sudo systemctl status pcscd
● pcscd.service - PC/SC Smart Card Daemon
     Loaded: loaded (/lib/systemd/system/pcscd.service; indirect; vendor preset: enabled)
     Active: active (running) since Mon 2022-12-19 19:24:32 EET; 6s ago
TriggeredBy: ● pcscd.socket
       Docs: man:pcscd(8)
   Main PID: 7585 (pcscd)
      Tasks: 5 (limit: 38187)
     Memory: 1.3M
        CPU: 21ms
     CGroup: /system.slice/pcscd.service
             └─7585 /usr/sbin/pcscd --foreground --auto-exit


ykman list
YubiKey 5C NFC (5.4.3) [OTP+FIDO+CCID] Serial: 20551026


ykman openpgp info

```

#### NixOS
https://github.com/drduh/YubiKey-Guide#nixos

### Meta Configuration
Do these Steps On both of the Yubikeys (you should have 2 ):

```bash
gpg --edit-card
gpg/card> admin
gpg/card> help
gpg/card> passwd    # change Admin PIN, default for Yubikey is 12345678
gpg/card> 3
gpg/card> 2         # unblock and change PIN
gpg/card> name      # Set your name
gpg/card> lang      # set language preference
Language preferences: en
gpg/card> sex       # set your gender
Salutation (M = Mr., F = Ms., or space): M
gpg/card> login     # set your email address
Login data (account name): user.userfamilyname@gmail.com
gpg/card> key-attr  # change encryption algorithm for Signature, Encryption and Authentication keys (repeat the process 3 times)
gpg/card> 2         # choose elliptic curve
gpg/card> 1         # default
gpg/card> list      # confirm the change by checking "Key attributes" field
Key attributes ...: ed25519 cv25519 ed25519
gpg/card> uif 1 on  # enable touch id for signing certificate
gpg/card> uif 2 on  # enable touch id for decrypt certificate
gpg/card> uif 3 on  # enable touch id for authentication certificate
gpg/card> list
```

#### Generate GPG key pair
NOTE: **Disconnect Your Laptop from internet** until you remove the GPG keys in the end of the process
After these steps you will have a Master key with Signing(S) and Certificate-Creation(C) capabilities + a subkey for encryption(E) and another one for authentication(A):

```bash
gpg --full-generate-key --expert
(9) ECC (sign and encrypt) *default*

gpg: directory '/home/user/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/home/user/.gnupg/openpgp-revocs.d/${PUBLIC_KEY}.rev'
public and secret key created and signed.

pub   ed25519 2022-12-19 [SC]
      DBE0B8427CD7E8606C8CB852F7391C70EA811321
uid                      User UserFamilyName <user@gmail.com>
sub   cv25519 2022-12-19 [E]
```

```bash
gpg --list-keys
/home/user/.gnupg/pubring.kbx
-----------------------------
pub   ed25519 2022-12-19 [SC]
      DBE0B8427CD7E8606C8CB852F7391C70EA811321
uid           [ultimate] User UserFamilyName <user@gmail.com>
sub   cv25519 2022-12-19 [E]
sub   ed25519 2022-12-19 [A]
```


We are going to use `${PUBLIC_KEY}` in following instructions, so set this as a
variable now.

`PUBLIC_KEY=DBE0B8427CD7E8606C8CB852F7391C70EA811321`


##### Add Authentication Key to the PGP
```bash
gpg --edit-key --expert ${PUBLIC_KEY}
gpg> addkey
Your selection? (11) ECC (set your own capabilities)
Possible actions for this ECC key: Sign Authenticate
Current allowed actions: Sign
   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished

Your selection? S            # disable the Signing capability
Current allowed actions:     # this line shows the current capabilities
   (S) Toggle the sign capability
   (A) Toggle the authenticate capability
   (Q) Finished
Your selection? A            # enable Authetication capability
Current allowed actions: Authenticate     # confirm by looking at this line
Your selection? Q

Please select which elliptic curve you want:
   (1) Curve 25519 *default*
Your selection? 1

Please specify how long the key should be valid.
Key is valid for? (0)

Is this correct? (y/N) y
Really create? (y/N) y

sec  ed25519/E10C8B9679919600
     created: 2021-11-03  expires: never       usage: SC
     trust: ultimate      validity: ultimate
ssb  cv25519/DFBE17381376246A
     created: 2021-11-03  expires: never       usage: E
ssb  ed25519/48B2EEDAD8D771CE
     created: 2021-11-03  expires: never       usage: A
[ultimate] (1). test userfamilyname <test@test.com>

gpg> save
```


##### Backup GPG key pair
Backup Secret keys and encrypt them with a password and store it on an offline USB Device!
NOTE: Make sure to encrypt the revoke certificate and store it on the offline USB as well just in case!
1. export Master public key
```bash
gpg --export --armor > ${PUBLIC_KEY}.pub      
cp ${PUBLIC_KEY}.pub ~/.gnupg/${PUBLIC_KEY}.pub
```
encrypt private key and save to file
```bash
gpg --export-secret-keys --armor ${PUBLIC_KEY} \
  | gpg --symmetric --armor > ${PUBLIC_KEY}-secret-keys.sec 
```

encrypt subkey and save to file
```bash
gpg --export-secret-subkeys --armor ${PUBLIC_KEY} \
  | gpg --symmetric --armor > ${PUBLIC_KEY}-subkeys.sec
```

encrypt revoke certificate and save to file
```bash
cat ~/.gnupg/openpgp-revocs.d/${PUBLIC_KEY}.rev \
  | gpg --symmetric --armor > ${PUBLIC_KEY}-revoke.sec
```

copy all keys to backup
```bash
mkdir backups
cp ${PUBLIC_KEY}.pub \
   ${PUBLIC_KEY}-revoke.sec \
   ${PUBLIC_KEY}-secret-keys.sec \
   ${PUBLIC_KEY}-subkeys.sec \
   backups/
```


Move the GPG key pair to the first Yubikey
First we will move the Keys to the 1st Yubikey. Notice that this will remove the keys from the local machine, so for the second Yubikey we need to restore them from the backup again to be able to insert them to the 2nd Yubikey!
```bash
gpg --edit-key --expert ${PUBLIC_KEY}
gpg> keytocard
Really move the primary key? (y/N) y
Please select where to store the key:
   (1) Signature key
   (3) Authentication key
Your selection? 1

gpg: WARNING: such a key has already been stored on the card!

Replace existing key? (y/N) y

# Select the 1st subkey and move it to Yubikey
# Basicyally repeat all steps 3 times
gpg> key 1      # the "*" character in front of the ssb shows which key is selected

sec  ed25519/E10C8B9679919600
     created: 2021-11-03  expires: never       usage: SC
     trust: ultimate      validity: ultimate
ssb* cv25519/DFBE17381376246A
     created: 2021-11-03  expires: never       usage: E
ssb  ed25519/48B2EEDAD8D771CE
     created: 2021-11-03  expires: never       usage: A
[ultimate] (1). test userfamilyname <test@test.com>
gpg> keytocard

gpg> key 1      # deselect key 1
gpg> key 2      # select key 2
gpg> keytocard

gpg> save
```


##### Confirm the steps
  - The line containing "Card serial no" shows that the private key is stored on the Yubikey
  - the ">" shows that the key is only stored on the Yubikey and not available on the local machine anymore!

```bash
gpg --list-secret-keys    # list private keys
/Users/user/.gnupg/pubring.kbx
--------------------------------
sec>  ed25519 2021-11-03 [SC]
      ${PUBLIC_KEY}
      Card serial no. = 0006 15864528
uid           [ultimate] user userFamilyName <user.userfamilyname@gmail.com>
ssb>  cv25519 2021-11-03 [E]
ssb>  ed25519 2021-11-03 [A]



gpg --edit-key --expert ${PUBLIC_KEY}
sec>  ed25519/4C598C56456BC077  created: 2021-11-03  expires: never
                                card-no: 0006 15864528
ssb>  cv25519/FEDBACDE1473B14D  created: 2021-11-03  expires: never
                                card-no: 0006 15864528
ssb>  ed25519/BB660F5E48725F76  created: 2021-11-03  expires: never
                                card-no: 0006 15864528

gpg --card-status
# you should see "card no" for all the keys stored on the Yubikey
General key info..: pub  ed25519/4C598C56456BC077 2021-11-03 user userFamilyName <user.userfamilyname@gmail.com>
sec>  ed25519/4C598C56456BC077  created: 2021-11-03  expires: never
                                card-no: 0006 15864528
ssb>  cv25519/FEDBACDE1473B14D  created: 2021-11-03  expires: never
                                card-no: 0006 15864528
ssb>  ed25519/BB660F5E48725F76  created: 2021-11-03  expires: never
                                card-no: 0006 15864528
```

After these steps, the private keys has been moved to the Yubikey and not being available on the local disk anymore!

##### Move the GPG key pair to the Second Yubikey.

According to the docs by running `keytocard` function, should remove from local
keystore, but for me it didn't happen:
```bash
gpg --list-secret-keys
/home/user/.gnupg/pubring.kbx
-----------------------------
sec>  ed25519 2022-12-19 [SC]
      DBE0B8427CD7E8606C8CB852F7391C70EA811321
      Card serial no. = 0006 20551026
uid           [ultimate] User UserFamilyName <user@gmail.com>
ssb>  cv25519 2022-12-19 [E]
ssb>  ed25519 2022-12-19 [A]
```

so I had to delete them manually with

```bash
gpg --delete-secret-key ${PUBLIC_KEY}
```


Now import the keys again from the backup.
Encrypt the GPG private key and import it alongside with the public one:


NOTE: there should be no ">" in after "sec", "uid", etc.

```
cd ~/backups
gpg --import ${PUBLIC_KEY}.pub     # import the public key
gpg -o decrypted-private-key -d ${PUBLIC_KEY}-secret-keys.sec
gpg --import decrypted-private-key     # import the private key

gpg --list-secret-keys
      # Confirm that the keys exist on the local filesystem by not seeing ">" character!
/home/user/.gnupg/pubring.kbx
-----------------------------
sec  ed25519 2022-12-19 [SC]
     DBE0B8427CD7E8606C8CB852F7391C70EA811321
     Card serial no. = 0006 20551026
uid           [ultimate] user userfamilyname <user@gmail.com>
ssb  cv25519 2022-12-19 [E]
ssb  ed25519 2022-12-19 [A]
```

**Point GPG to the second Yubikey. This step is needed whenever you swap the Yubi-keys**


```bash
gpg-connect-agent "scd serialno" "learn --force" /bye
pkill gpg-agent
gpgconf --launch gpg-agent
```

Now Move the Keys to the second Yubikey:
```bash
gpg --edit-key --expert ${PUBLIC_KEY}
gpg> trust    # you should see "trust: ultimate" and "validity: ultimate" after the process
Your decision? 5 (I trust ultimately)
Do you really want to set this key to ultimate trust? (y/N) y
sec  ed25519/E10C8B9679919600
     created: 2021-11-03  expires: never       usage: SC
     trust: ultimate      validity: ultimate
ssb  cv25519/DFBE17381376246A
     created: 2021-11-03  expires: never       usage: E
ssb  ed25519/48B2EEDAD8D771CE
     created: 2021-11-03  expires: never       usage: A
[ultimate] (1). test userfamilyname <test@test.com>

gpg> keytocard
Really move the primary key? (y/N) y
Please select where to store the key:
   (1) Signature key
   (3) Authentication key
Your selection? 1

gpg: WARNING: such a key has already been stored on the card!

Replace existing key? (y/N) y

# Select the 1st subkey and move it to Yubikey
gpg> key 1      # the "*" character in front of the ssb shows which key is selected

sec  ed25519/E10C8B9679919600
     created: 2021-11-03  expires: never       usage: SC
     trust: ultimate      validity: ultimate
ssb* cv25519/DFBE17381376246A
     created: 2021-11-03  expires: never       usage: E
ssb  ed25519/48B2EEDAD8D771CE
     created: 2021-11-03  expires: never       usage: A
[ultimate] (1). test userfamilyname <test@test.com>
gpg> keytocard

gpg> key 1      # deselect key 1
gpg> key 2      # select key 2
gpg> keytocard

gpg> save

#### Confirm the keys are stored on the Yubikey
gpg --list-secret-keys
gpg --edit-key --expert ${PUBLIC_KEY}
gpg --card-status
```

Confirm the data of both Yubikeys are the same

```bash
#### Test 1
# Check the keys and their signature to be the same on both of the keys
# Connect the first Yubikey
gpg --card-status
gpgconf --launch gpg-agent
# remove the first yubikey and connect the second one
gpg --card-status
gpgconf --launch gpg-agent

#### Test 2
# Encrypt something with the Public Key and try to decrypt it with both of the Yubikeys
# replace User UserFamilyName  with real user that you used
echo "hello world" > test-enc.txt

gpg --recipient "User UserFamilyNamei" -e test-enc.txt        # encrypt
cat test-enc.txt.gpg
# encrypted content here
gpg --recipient "User UserFamilyName" -d test-enc.txt.gpg      # decrypt
gpg: encrypted with 255-bit ECDH key, ID 8076517A2FA29A32, created 2022-12-19
      "User UserFamilyName <user@gmail.com>"
hello world

# reload agent
gpg-connect-agent "scd serialno" "learn --force" /bye

# verify the second card no is present in all places

gpg --card-status 
Reader ...........: 1050:0407:X:0
Application ID ...: D2760001240103040006205510260000
Application type .: OpenPGP
Version ..........: 3.4
Manufacturer .....: Yubico
Serial number ....: 20551026
Name of cardholder: User 
Language prefs ...: [not set]
Salutation .......: 
URL of public key : [not set]
Login data .......: [not set]
Signature PIN ....: not forced
Key attributes ...: ed25519 cv25519 ed25519
Max. PIN lengths .: 127 127 127
PIN retry counter : 2 0 3
Signature counter : 0
KDF setting ......: off
Signature key ....: DBE0 B842 7CD7 E860 6C8C  B852 F739 1C70 EA81 1321
      created ....: 2022-12-19 09:19:59
Encryption key....: 8475 ED1C D388 03A6 9C95  3349 8076 517A 2FA2 9A32
      created ....: 2022-12-19 09:19:59
Authentication key: F1E1 A7FD 4494 D528 C456  B693 6C87 7495 BB0B B2CA
      created ....: 2022-12-19 09:32:17
General key info..: pub  ed25519/F7391C70EA811321 2022-12-19 User UserFamilyName <user@gmail.com>
sec>  ed25519/F7391C70EA811321  created: 2022-12-19  expires: never     
                                card-no: 0006 20551026
ssb>  cv25519/8076517A2FA29A32  created: 2022-12-19  expires: never     
                                card-no: 0006 20551026
ssb>  ed25519/6C877495BB0BB2CA  created: 2022-12-19  expires: never     
                                card-no: 0006 20551026
```

**cleanup: delete all private keys, except for the public key**

```bash
rm decrypted-private-key
# delete ${PRIVATE_KEY}* files also
```


Publish Your Public GPG Key
Enable internet
```
gpg --keyserver keys.openpgp.org --send-key ${PUBLIC_KEY}
# replace ${PUBLIC_KEY} with real value instead of variable for this step
gpg: sending key F7391C70EA811321 to hkp://keys.openpgp.org

# now check you email, confirm the GPG key and then find it on the web console:
# use ${PUBLIC_KEY} to verify

https://keys.openpgp.org/

#### Optional: Edit Yubikeys and specify the Public key url for both of the yubikeys
gpg --edit-card
gpg/card> admin
gpg/card> url
URL to retrieve public key: https://keys.openpgp.org/vks/v1/by-fingerprint/${PUBLIC_KEY}
```

Cleanup the Keys from Your Local Machine
```
find ~/.gnupg -type f -not -iname '*.conf' -exec rm {} \;   # remove ecerything except configs
pkill gpg-agent
gpgconf --launch gpg-agent

gpg --keyserver keys.openpgp.org --receive-keys ${PUBLIC_KEY}     # Import Public Key
# if previous step fails, use
gpg --import ${PUBLIC_KEY}.pub

echo "gpg --import ~/.gnupg/${PUBLIC_KEY}.pub" >> ~/.bashrc
# edit ~/.bashrc and make sure it is before `gpgconf --launch gpg-agent`
echo "never gonna give you up" | gpg --armor --sign        # connect yubikey and test
```

**Multiple Yubikeys
every time you disconnect one of the Yubikeys and Insert the other one, you must run this command:**
```
gpg-connect-agent "scd serialno" "learn --force" /bye
```


Github: Signing and Authentication using Yubikeys
```
## Authentication
## Add your key to the github account and remove the previous ssh-key there
ssh-add -L | grep cardno > ~/.ssh/id_rsa_yubikey.pub

## Signing
vim ~/.gitconfig
[user]
        email = user.userfamilyname@gmail.com
        name  = user userFamilyName
        signingkey = user.userfamilyname@gmail.com
[commit]
        gpgsign = true

pkill gpg-agent 
pkill ssh-agent
gpgconf --launch gpg-agent
```

Add your GPG Key to Github/GitLab
```
gpg --list-secret-keys
gpg --armor --export 49B46413995BE582B45DB1AAD53D78E6BF32A46F
```

#### Require touch
https://github.com/drduh/YubiKey-Guide#require-touch

By default, YubiKey will perform encryption, signing and authentication operations without requiring any action from the user, after the key is plugged in and first unlocked with the PIN.



**Following commands do not work for me at the moment, but I previously I had
a config that worked**

Make sure you can run
```bash
ykman openpgp info
OpenPGP version:            3.4
Application version:        5.4.3
PIN tries remaining:        3
Reset code tries remaining: 0
Admin PIN tries remaining:  3
Signature PIN:              Always
Touch policies:            
  Signature key:      Off
  Encryption key:     Off
  Authentication key: Off
  Attestation key:    Off
```

**If you can't run `ykman openpgp info`, try with a reboot** and make sure
```bash
sudo systemctl status pcscd
○ pcscd.service - PC/SC Smart Card Daemon
     Loaded: loaded (/lib/systemd/system/pcscd.service; indirect; vendor preset: enabled)
     Active: inactive (dead) since Mon 2022-12-19 19:31:33 EET; 22s ago
TriggeredBy: ● pcscd.socket
       Docs: man:pcscd(8)
    Process: 8324 ExecStart=/usr/sbin/pcscd --foreground --auto-exit $PCSCD_ARGS (code=exited, status=0/SUCCESS)
   Main PID: 8324 (code=exited, status=0/SUCCESS)
        CPU: 41ms

Dec 19 19:30:12 pop-os systemd[1]: Started PC/SC Smart Card Daemon.
Dec 19 19:31:33 pop-os systemd[1]: pcscd.service: Deactivated successfully.
```


Authentication:

```bash
ykman openpgp keys set-touch aut on

ykman openpgp keys set-touch aut on
Enter Admin PIN: 
Set touch policy of AUT key to on? [y/N]: y


ykman openpgp info
OpenPGP version:            3.4
Application version:        5.4.3
PIN tries remaining:        3
Reset code tries remaining: 0
Admin PIN tries remaining:  3
Signature PIN:              Always
Touch policies:            
  Signature key:      Off
  Encryption key:     Off
  Authentication key: On
  Attestation key:    Off


```
Continue with the following cmd, same as above

Signing:

```bash
ykman openpgp keys set-touch sig on
```

Encryption:

```bash
ykman openpgp keys set-touch enc on
```

[How to delete a subkey](https://sites.google.com/view/chewkeanho/guides/gnupg/delete-subkey)
