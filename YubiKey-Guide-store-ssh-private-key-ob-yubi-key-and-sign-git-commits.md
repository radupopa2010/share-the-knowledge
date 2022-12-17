https://github.com/drduh/YubiKey-Guide

# How to store ssh private key on yubi-key and sign git commits

#### Requirements (MacOS)

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

##### Linux
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

Configure Yubikeys
Meta Configuration
Do these Steps On both of the Yubikeys:
```
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
Login data (account name): arsham.teymouri@gmail.com
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

Generate GPG key pair
NOTE: Disconnect Your Laptop from internet until you remove the GPG keys in the end of the process
After these steps you will have a Master key with Signing(S) and Certificate-Creation(C) capabilites + a subkey for encryption(E) and another one for authentication(A):
```
# Generate your PGP key
gpg --full-generate-key --expert
(9) ECC (sign and encrypt) *default*

pub   ed25519 2021-11-03 [SC]
      B261A1CCCA3CB4B59DFF41E1E10C8B9679919600
uid                      test teymouri <test@test.com>
sub   cv25519 2021-11-03 [E]

# Add Authentication Key to the PGP
gpg --edit-key --expert B261A1CCCA3CB4B59DFF41E1E10C8B9679919600
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
[ultimate] (1). test teymouri <test@test.com>

gpg> save
```

Backup GPG key pair
Backup Secret keys and encrypt them with a password and store it on an offline USB Device!
NOTE: Make sure to encrypt the revoke certificate and store it on the offline USB as well just in case!
```
gpg --export --armor > 8BDD39A7FCEB757492E393194C598C56456BC077.pub      # export Master public key
gpg --export-secret-keys --armor 8BDD39A7FCEB757492E393194C598C56456BC077 | gpg --symmetric --armor > 8BDD39A7FCEB757492E393194C598C56456BC077.sec 
gpg --export-secret-subkeys --armor 8BDD39A7FCEB757492E393194C598C56456BC077 | gpg --symmetric --armor > 8BDD39A7FCEB757492E393194C598C56456BC077-subkeys.sec
cat ~/.gnupg/openpgp-revocs.d/B261A1CCCA3CB4B59DFF41E1E10C8B9679919600.rev | gpg --symmetric --armor > 8BDD39A7FCEB757492E393194C598C56456BC077-revoke.sec
```

Move the GPG key pair to the first Yubikey
First we will move the Keys to the 1st Yubikey. Notice that this will remove the keys from the local machine, so for the second Yubikey we need to restore them from the backup again to be able to insert them to the 2nd Yubikey!
```
gpg --edit-key --expert B261A1CCCA3CB4B59DFF41E1E10C8B9679919600
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
[ultimate] (1). test teymouri <test@test.com>
gpg> keytocard

gpg> key 1      # deselect key 1
gpg> key 2      # select key 2
gpg> keytocard

gpg> save


##### Confirm the steps
# The line containing "Card serial no" shows that the private key is stored on the Yubikey
# the ">" shows that the key is only stored on the Yubikey and not available on the local machine anymore!
gpg -K    # list private keys
/Users/arsham/.gnupg/pubring.kbx
--------------------------------
sec>  ed25519 2021-11-03 [SC]
      8BDD39A7FCEB757492E393194C598C56456BC077
      Card serial no. = 0006 15864528
uid           [ultimate] Arsham Teymouri <arsham.teymouri@gmail.com>
ssb>  cv25519 2021-11-03 [E]
ssb>  ed25519 2021-11-03 [A]

gpg --edit-key --expert B261A1CCCA3CB4B59DFF41E1E10C8B9679919600
sec>  ed25519/4C598C56456BC077  created: 2021-11-03  expires: never
                                card-no: 0006 15864528
ssb>  cv25519/FEDBACDE1473B14D  created: 2021-11-03  expires: never
                                card-no: 0006 15864528
ssb>  ed25519/BB660F5E48725F76  created: 2021-11-03  expires: never
                                card-no: 0006 15864528

gpg --card-status
# you should see "card no" for all the keys stored on the Yubikey
General key info..: pub  ed25519/4C598C56456BC077 2021-11-03 Arsham Teymouri <arsham.teymouri@gmail.com>
sec>  ed25519/4C598C56456BC077  created: 2021-11-03  expires: never
                                card-no: 0006 15864528
ssb>  cv25519/FEDBACDE1473B14D  created: 2021-11-03  expires: never
                                card-no: 0006 15864528
ssb>  ed25519/BB660F5E48725F76  created: 2021-11-03  expires: never
                                card-no: 0006 15864528
```

After these steps, the private keys has been moved to the Yubikey and not being available on the local disk anymore!

Move the GPG key pair to the Second Yubikey
As the private keys has been removed by running keytocard function, we need to import them again from the backup.
Encrypt the GPG private key and import it alongside with the public one:

```
cd ~/backups
gpg --import 8BDD39A7FCEB757492E393194C598C56456BC077.pub     # import the public key
gpg -o decrypted-private-key -d 8BDD39A7FCEB757492E393194C598C56456BC077.sec
gpg --import decrypted-private-key     # import the private key

gpg -K
      # Confirm that the keys exist on the local filesystem by not seeing ">" character!
```

Point GPG to the second Yubikey, This step is needed whenever you swap the Yubikeys:
```
gpg-connect-agent "scd serialno" "learn --force" /bye
pkill gpg-agent
gpgconf --launch gpg-agent
```

Now Move the Keys to the second Yubikey:
```
gpg --edit-key --expert B261A1CCCA3CB4B59DFF41E1E10C8B9679919600
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
[ultimate] (1). test teymouri <test@test.com>

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
[ultimate] (1). test teymouri <test@test.com>
gpg> keytocard

gpg> key 1      # deselect key 1
gpg> key 2      # select key 2
gpg> keytocard

gpg> save

#### Confirm the keys are stored on the Yubikey
gpg -K
gpg --edit-key --expert B261A1CCCA3CB4B59DFF41E1E10C8B9679919600
gpg --card-status
```

Confirm the data of both Yubikeys are the same
```
#### Test 1
# Check the keys and their signature to be the same on both of the keys
# Connect the first Yubikey
gpg --card-status

# remove the first yubikey and connect the second one
gpg --card-status

#### Test 2
# Encrypt something with the Public Key and try to decrypt it with both of the Yubikeys
gpg -r arsham.teymouri@gmail.com -e <file-name>     # encrypt
gpg -r arsham.teymouri@gmail.com -d <filename>      # decrypt
```

Publish Your Public GPG Key
```
gpg --keyserver keys.openpgp.org --send-key 8BDD39A7FCEB757492E393194C598C56456BC077

# now check you email, confirm the GPG key and then find it on the web console:
https://keys.openpgp.org/

#### Optional: Edit Yubikeys and specify the Public key url for both of the yubikeys
gpg --edit-card
gpg/card> admin
gpg/card> url
URL to retrieve public key: https://keys.openpgp.org/vks/v1/by-fingerprint/8BDD39A7FCEB757492E393194C598C56456BC077
```

Cleanup the Keys from Your Local Machine
```
find ~/.gnupg -type f -not -iname '*.conf' -exec rm {} \;   # remove ecerything except configs
pkill gpg-agent
gpgconf --launch gpg-agent

gpg --keyserver keys.openpgp.org --receive-keys 8BDD39A7FCEB757492E393194C598C56456BC077     # Import Public Key
echo "never gonna give you up" | gpg --armor --sign        # connect yubikey and test
```

Multiple Yubikeys
every time you disconnect one of the Yubikeys and Insert the other one, you must run this command:
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
        email = arsham.teymouri@gmail.com
        name  = Arsham Teymouri
        signingkey = arsham.teymouri@gmail.com
[commit]
        gpgsign = true

pkill gpg-agent ssh-agent
gpgconf --launch gpg-agent
```

Add your GPG Key to Github/GitLab
```
gpg --list-secret-keys
gpg --armor --export 49B46413995BE582B45DB1AAD53D78E6BF32A46F
```
