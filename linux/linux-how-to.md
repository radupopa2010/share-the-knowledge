
### Core values autonomy, mastery and purpose 

### TORVALDS' RULES 
-= TORVALDS' RULES =-
1. Get the work done
2. Do not let go
3. Have passion
4. Start small
5. Learn through trial and error
6. Embrace your uniqueness
7. Find your motivation
8. Be brutally honest
9. Create for yourself
10. Optimize your working environment
-= BONUS =-
* You don't get success overnight
* Find your path
* Earn respect

### one liners
https://linuxcommandlibrary.com/basic/oneliners.html?mc_cid=bc40d3e140&mc_eid=56e794f883

https://b-ok.cc/

https://nickjanetakis.com/blog/ = tips and tricks DEVOP + linux


http://mywiki.wooledge.org/DotFiles = .bashrc, .profile, .bash_profile

### Rapidly invoke an editor to write a long, complex, or tricky command
```
ctrl-x e
```

### readig list
https://gerlacdt.github.io/posts/effective-cli/

### yubi key edit  touch settings
https://docs.yubico.com/software/yubikey/tools/ykman/OpenPGP_Commands.html#ykman-openpgp-keys-set-touch-options-key-policy
https://www.notion.so/acmetechnologies/Yubikey-with-GPG-SSH-for-Linux-9313035b500b47ad8d4a87caf8642d2e
```
ykman openpgp keys set-touch sig cached
```

### Unbuntu change dns
https://www.baeldung.com/linux/resolve-conf-systemd-avahi  

https://phoenixnap.com/kb/ubuntu-dns-nameservers

- dig not resolving  ci11.acme-vpn.acme.io
```
disable IPv6 from the network interface
```

Ubuntu show dns servers used
```
systemd-resolve --status
```

https://www.howtogeek.com/devops/how-to-set-dns-search-order-in-ubuntu-18-04-using-netplan/


### Add key to ssh-agnet
```
ssh -i /home/radu/.ssh/google_compute_engine  radu@34.140.117.87
ssh-add ~/.ssh/google_compute_engine
```

### envsubst  
https://stackoverflow.com/questions/14155596/how-to-substitute-shell-variables-in-complex-text-files
```
export VAR1='somevalue' VAR2='someothervalue'
MYVARS='$VAR1:$VAR2'

envsubst "$MYVARS" <source.txt >destination.txt
```

### file in readonly mode even for root
https://askubuntu.com/questions/675296/changing-ownership-operation-not-permitted-even-as-root
```
chattr -i /etc/hosts
```

### gopass Copy passwords into clipboard
```
gopass --clip  personal/sudo
```

### find out which process is listening on port 5433
```
ss -ltnup 'sport = :5433'
```


### gpg yubi keylist keys
```
gpg2 --list-secret-keys
gpg2 --list-keys
```

### here doc create script
https://stackoverflow.com/questions/2953081/how-can-i-write-a-heredoc-to-a-file-in-bash-script#2954835
```
'EOF' = do NOT interpret variables or commands in here doc
 EOF  = please interpret variables and cmds

cat << 'EOF' > traffic-dump-clients.sh
#!/bin/bash
while : ; do
  nohup timeout 3600 tcpdump -Q in | grep  -o -P "IP .* >" | cut -d ' ' -f2 > clients.txt
  sort -u clients.txt >  "client-hosts-2019-09-24_15:07:58.txt"
  echo "" > clients.txt
done
EOF

```

### Create `readonly.sql` to define a role permission in SQL ; use tee to create docs 
```
$ tee readonly.sql <<EOF
CREATE ROLE "{{name}}" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO "{{name}}";
EOF
```


### How to `apt`
https://www.cyberciti.biz/faq/ubuntu-lts-debian-linux-apt-command-examples/
```
Syntax

The basic syntax is as follows:
apt [options] command
apt [options] command pkg1
apt [options] command pkg1 pkg2

# Apply all security and package updates
apt update && apt upgrade

# To see the list of packages that can be upgraded on the system
apt list --upgradable

# How to perform full system upgrade
apt full-upgrade

# How to install a new packages
apt install <pkg>

# How to remove a packages
apt remove <pkg>

# THE PURGE OPTION TO REMOVE BOTH PACKAGE AND CONFIG FILES
apt purge <pkg>

# How to List packages
apt list
```

### apt - How do I check the origin and archive of a package?
```

ls -l /var/lib/apt/lists/*Rel*

root@ci10[19:30] ~ # head -20 /var/lib/apt/lists/deb.debian.org_debian_dists_buster-updates_InRelease
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Origin: Debian
Label: Debian
Suite: oldstable-updates
Codename: buster-updates
Date: Tue, 19 Apr 2022 14:13:45 UTC
Valid-Until: Tue, 26 Apr 2022 14:13:45 UTC
Acquire-By-Hash: yes
Architectures: amd64 arm64 armel armhf i386 mips mips64el mipsel ppc64el s390x
Components: main contrib non-free
Description: Debian 10 - Updates
SHA256:
 e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855        0 contrib/Contents-amd64
 f61f27bd17de546264aa58f40f3aafaac7021e0ef69c17f6b1b4cd7664a037ec       20 contrib/Contents-amd64.gz
root@ci10[19:30] ~ # apt-cache policy  | head -20
Package files:
 100 /var/lib/dpkg/status
     release a=now
 990 https://packages.gitlab.com/runner/gitlab-runner/debian buster/main amd64 Packages
     release v=1,o=packages.gitlab.com/runner/gitlab-runner,a=buster,n=buster,l=gitlab-runner,c=main,b=amd64
     origin packages.gitlab.com
 990 https://packagecloud.io/netdata/netdata/debian buster/main amd64 Packages
     release v=1,o=packagecloud.io/netdata/netdata,a=buster,n=buster,l=netdata,c=main,b=amd64
     origin packagecloud.io
 990 https://download.docker.com/linux/debian buster/stable amd64 Packages
     release o=Docker,a=buster,l=Docker CE,c=stable,b=amd64
     origin download.docker.com
  90 http://deb.debian.org/debian buster-backports/main amd64 Packages
     release o=Debian Backports,a=buster-backports,n=buster-backports,l=Debian Backports,c=main,b=amd64
     origin deb.debian.org
  90 http://deb.debian.org/debian bullseye-backports/main amd64 Packages
     release o=Debian Backports,a=bullseye-backports,n=bullseye-backports,l=Debian Backports,c=main,b=amd64
     origin deb.debian.org
 990 http://security.debian.org/debian-security buster/updates/main amd64 Packages
     release v=10,o=Debian,a=oldstable,n=buster,l=Debian-Security,c=main,b=amd64
```

or

```
man  apt_preferences   and search for 
Determination of Package Version and Distribution Properties

```

### How do I find the package that provides a file?
```
$ dpkg -S /bin/ls
coreutils: /bin/ls
```

### search info about a package (debian handbook)
```
apt show prometheus-node-exporter-collectors 

Package: prometheus-node-exporter-collectors
Version: 0+git20210115.7d89f19-1
Priority: optional
Section: net
Maintainer: Debian Go Packaging Team <team+pkg-go@tracker.debian.org>
Installed-Size: 129 kB
Depends: daemon | systemd-sysv, moreutils, prometheus-node-exporter
Recommends: dbus, python3, smartmontools
Breaks: prometheus-node-exporter (<< 0.18.1+ds-2~)
Replaces: prometheus-node-exporter (<< 0.18.1+ds-2~)
Homepage: https://github.com/prometheus-community/node-exporter-textfile-collector-scripts
Download-Size: 26.1 kB
APT-Manual-Installed: yes
APT-Sources: http://deb.debian.org/debian bullseye/main amd64 Packages
Description: Supplemental textfile collector scripts for Prometheus node_exporter
 Optional textfile collector scripts which extend the functionality of
 Prometheus node_exporter, or process output from external binaries into
 the Prometheus metrics format, to be exposed by node_exporter.
```

### search for text inside files in a directory
```
grep -rnw <directory'> -e "pattern"
```

### show files that contain patern
```
grep -lr patern  /location/*
```

### How do I grep for multiple patterns?
```
ls -l | egrep q 'dev|home|run|boot'
```

### Grep pattern1 and pattern2 
```
grep -E 'pattern1.*pattern2'
```


### You can also find out which package a particular file belongs to:
```
# redhat
rpm -qf pyton
# pkg which /usr/local/sbin/httpd
# ubuntu
dpkg-query -S /etc/apache2
```

### What is the difference between modify and change for a file in stats command
Access - the last time the file was read
Modify - the last time the file was modified (content has been modified)
Change - the last time meta data of the file was changed (e.g. permissions)

### See Linux release
```
lsb_release -a
```

### How to uninstall postgresql from ubuntu server
```
sudo apt-get --purge remove postgresql\*
# Once all PostgreSQL packages have been removed:
rm -r /etc/postgresql/
rm -r /etc/postgresql-common/
rm -r /var/lib/postgresql/
userdel -r postgres
groupdel postgres
 #List All Postgres related packages
dpkg -l | grep postgres
```


### change gnome-terminal title
PROMPT_COMMAND='echo -ne "\033]0;SOME TITLE HERE\007"'

create a new user
adduser <new>

### How To Use chmod and chown Command
http://www.cyberciti.biz/faq/how-to-use-chmod-and-chown-command/
```
chown owner-user file
chown vivek demo.txt
```


### Full Synchronize 2 directories
```
# first check with -n flag
rsync -avn --exclude=".hg*" --delete <source> <destination>

rsync -av --exclude=".hg*" --delete <source> <destination>
```

#### How to rsync with sudo (pull)
https://askubuntu.com/questions/719439/using-rsync-with-sudo-on-the-destination-machine

On the source machine mk1
```
# 1. Find out the path to rsync:
which rsync
# /usr/bin/rsync

# 2. Create a new file in /etc/sudoers.d
username=$(whoami) && echo ${username} 
# where username is the login name of the user that rsync will use to log on. That user must be able to use sudo

sudo bash -c "echo '${username} ALL=NOPASSWD:/usr/bin/rsync' > /etc/sudoers.d/${username}-rsync"

```
Then, on the destination machine (mk2), specify that sudo rsync shall be used:
```


# open tmux, because it might run for a while
tmux
# !!! IMPORTANT NOTE: 
# on source_dir don't forget the trailing slash "/srv/torrent/games/"
# !!! IMPORTANT NOTE: 

# dry run f irst (-n) 
username=$(whoami)
sudo rsync -avzn --delete --rsync-path='sudo rsync'  ${username}@mk1.<fqdn>:/srv/torrent/games/ /srv/torrent/games | tee test-rsync-${username}.txt
# e.g

# and then remove the flag
sudo rsync -avz --delete --rsync-path='sudo rsync'   ${username}@mk1.<fqdn>:/srv/torrent/games/ /srv/torrent/games | tee history-rsync-${username}.txt
```

### Find files and sort by size, human readable
```
find . -type f -exec du -h '{}'  ';' | sort -rh
```

### Find files and sort by size
```bash
find . -type f -printf "%s\t%p\n" | sort -rn
  %p File's name.
  %s File's size in bytes.
```


### How to scan a folder recursively and find the largest files in the folder
```bash
du -ah <dir>  | sort -rh
```

### Find the top space dir hogs
cd <target_dir>
```
du -sh * | sort -rh
```
      -s, --summarize
      -h, --human-readable


### Find files and sort by size
```bash
ls -lSh
```

### Find and xargs and mv or cp 
```
find /tmp/ -ctime -1 -name 'x*' -print0 | xargs -r0 mv -t ~/play/
```
      -r means no-run-if-empty,
      -t (--target) option is GNU specific. -print0, -r, -0
https://stackoverflow.com/questions/13899746/use-xargs-to-mv-a-directory-from-find-results-into-another-directory

### Find files using regexp
```
find /home/archive/3e/ -regextype posix-egrep -regex '.*\/[0-9]{4}\/[0-9]{1,2}\/[0-9]{1,2}$'
```

### Use screen
  - Start screen 
screen -> ctrl + a -> c (create)  ||  screen -S <session_name>
  - Switching between windows
ctrl + a -> n (next) or p (previous)
  - Detaching From Screen
ctrl +a -> d
   - Re-attaching to screen
screen -r -> 
  - Stopping Screen
exit 
  - Screen Scroll Up and Down
Activate copy mode in GNU/screen.
CTRL-A  Next press: [
Now, you can scroll up/down and look at your data
  - Copy from a region of screen session:
https://stackoverflow.com/questions/16111548/how-to-copy-the-gnu-screen-copy-buffer-to-the-clipboard#16286619
    1. Copy the

#### See number of CPUs
lscpu
```
lscpu | grep -E '^Thread|^Core|^Socket|^CPU\('  
```

disable CPU online
```
echo 0 > /sys/devices/system/cpu/cpu3/online
```
enable CPU online
```
echo 1 > /sys/devices/system/cpu/cpu3/online
```
### How to fix "ssh can't log in"
```
vi /etc/ssh/sshd_config  (add the <user> to AllowGroups
/etc/init.d/ssh restart
```

https://engineering.fb.com/security/scalable-and-secure-access-with-ssh/

### Fix ssh - warning: remote host identification has changed
```
ssh-keygen -f "/home/radu/.ssh/known_hosts" -R 172.18.5.146
```

### How to find creation date for a folder
UNIX doesn't support creation date.
last time the inode data was changed, which is as close as you can get:
```
ls -ldc dirname
```

### Keeping Some Output, Discarding the Rest (from bash cookbook)
Fields are delineated by whitespace
The field $0 represents the entire line of input.
NF - built-in variable called that holds the number of fields found on the current line
      - always refers to the last field.
```
awk '{print $1}' myinput.file
ls -l | awk '{print $1, $NF}'
```

### How to print third column to last column?
```
awk '{for (i=1; i<=NF-2; i++) $i = $(i+2); NF-=2; print}' logfile
# or
cut -f 3- INPUTFILE
```

### Awk change input field separator and output field separator
```
awk -F '\t' -v OFS='.' '{print $3, $5, $NF}'
#   -F use this as input filed separator
#   -v var=val
       --assign var=val
              Assign  the  value  val to the variable var, before execution of the program begins.  Such variable
              values are available to the BEGIN rule of an AWK program.
```

### Add a new user to existing group
```
usermod -aG <existing_group> <new_user>
```

### Remove user from group.
E. g. :  To keep membership for sales only group (remove user tom from printer group)
```
usermod -G sales tom
```

### Show gropus for a user
```bash
groups <user>
```

### Find external IP address from terminal
```
curl ipecho.net/plain
```

### Run curl with socks5 proxy
```
curl --preproxy "127.0.0.1:1080"  -X GET "http://ads1.r3.07.laxa.acme.net:9090/provisioning/clusters/${cluster}/racks/${rack}/hosts/${host}" | jq
```

### Use curl to post JSON payload
```
curl -X POST -H "Content-Type: application/json" -d @new-kura1.r8.01.fraa.acme.net.json <URL>
```

### curl url encode 
```bash
curl \
    --data-urlencode "paramName=value" \
    --data-urlencode "secondParam=value" \
    http://example.com
```

### curl download file
```bash
 # saves it to myfile.txt
curl http://www.example.com/data.txt -o myfile.txt -L

# The #1 will get substituted with the url, so the filename contains the url
curl http://www.example.com/data.txt -o "file_#1.txt" -L 

# saves to data.txt, the filename extracted from the URL
curl http://www.example.com/data.txt -O -L

# saves to filename determined by the Content-Disposition header sent by the server.
curl http://www.example.com/data.txt -O -J -L

# -O Write output to a local file named like the remote file we get
# -o <file> Write output to <file> instead of stdout (variable replacement performed on <file>)
# -J Use the Content-Disposition filename instead of extracting filename from URL
# -L Follow redirects
```

### curl send json data no single quotes needed
```
    cat <<EOF | curl -X PUT \
      localhost:8080/api/v1/namespaces/test/finalize \
      -H "Content-Type: application/json" \
      --data-binary @-
    {
      "kind": "Namespace",
      "apiVersion": "v1",
      "metadata": {
        "name": "test"
      },
      "spec": {
        "finalizers": null
      }
    }
    EOF
```

### Run Command As Another User
```
su - oracle -c 'ulimit -aHS'
sudo -H -u otheruser bash -c 'command'
    -H (HOME)
    -u (user)
```

### See distribution
https://www.cyberciti.biz/faq/find-linux-distribution-name-version-number/
a] /etc/*-release file.
b] lsb_release command.
c] /proc/version file.

### How Do I Find Out My Kernel Version?
```
uname -a
```

### Find Out What Partition a File Belongs To
https://www.cyberciti.biz/faq/linux-unix-command-findout-on-which-partition-file-directory-exits/
```
df -T /usr/local/
```

### Cron job every 4 hours
`0 */4 * * *`


### Edit the terminal prompt
vi `/etc/bash.bashrc`
edit PS1 variable. If hostname doesn't apear, replace \h with $(hostname)

### Common Linux log files names and usage
/var/log/messages : General message and system related stuff
/var/log/auth.log : Authenication logs
/var/log/kern.log : Kernel logs
/var/log/cron.log : Crond logs (cron job)
/var/log/maillog : Mail server logs
/var/log/qmail/ : Qmail log directory (more files inside this directory)
/var/log/httpd/ : Apache access and error logs directory
/var/log/lighttpd/ : Lighttpd access and error logs directory
/var/log/boot.log : System boot log
/var/log/mysqld.log : MySQL database server log file
/var/log/secure or /var/log/auth.log : Authentication log
/var/log/utmp or /var/log/wtmp : Login records file
/var/log/yum.log : Yum command log file.

### Verify that network interface device is up and running
ifconfig -s

### Memory monitoring
- quick view of memory status
```
free -m or free -h
```
 - to show command and sort by memory usage
```
top; c; M
```
top -d 0.1 - you can specify the delay when to update
cat /proc/meminfo - to see how much real memory is being used for caches and buffers.

The biggest problems happen when the system starts running out of memory and the kernel starts to
swap pages of working memory out to the disk in order to make room for new pages.
To see memory page faults for individual processes:
top -d 0.1 ; f - to change the displayed fields
                   - use arrows to navigate, then SPACE to select a new filed to display: * nTH = Number of Threads, * nMaj = Major Page                       Faults, * nMin = Minor Page Faults  
vmstat 2 - for getting a high-level view of how often the kernel is swapping pages in and out, how busy the CPU is, and IO utilization.

vmstat -aS M #see the "inactive" column for a rough "free" idea.

### locate the source of your memory-related problems (leaks) 
purify and  valgrind  
https://stackoverflow.com/questions/5134891/how-do-i-use-valgrind-to-find-memory-leaks

### Logrotate
https://www.linode.com/docs/uptime/logs/use-logrotate-to-manage-log-files
https://linuxconfig.org/logrotate
Most configuration of log rotation does not occur in the /etc/logrotate.conf file, but rather in files located in the /etc/logrotate.d directory
```
e. g.: logrotate.conf
/var/log/mail.log {
  # rotate logs every week
  weekly
  # save the last 5 rotated logs
  rotate 5
  # compress all of the old log files with the xz compression tool
  compress
  # recreate the log files with permissions of 0644` and postfix as the user and group owner
  create 0644 postfix postfix
  # size The size directive forces log rotation when a log file grows bigger than the specified [value].
  size 15M
  # Maintain Log File Extension: Logrotate will append a number to a file name so the access.log file will be rotated to access.log.1
  extension log
}
```

Configure Rotation Intervals Options: [ weekly, monthly, yearly ]

size [value]
The size directive forces log rotation when a log file grows bigger than the specified [value]. By default, [value] is assumed to be in bytes. Append a k to [value] to specify a size in kilobytes, M for megabytes, or G for gigabytes.
For example, size 100k or size 100M are valid directives

Experiment with the log rotation (outside of the usual cron job) by forcing an execution of the logrotate in the absence of any log files to rotate
logrotate -f /etc/logrotate.d/linuxserver 


Wildcards
Using wildcards (which is also known as globbing) allow you to select
filenames based on patterns of characters.

Wildcard Meaning
*                    Matches any characters
?                    Matches any single character
[characters]  Matches any character that is a member of the set characters
[!characters] Matches any character that is not a member of the set characters
[[:class:]]      Matches any character that is a member of the specifiedclass

Commonly Used Character Classes
[:alnum:]  Matches any alphanumeric character
[:alpha:]   Matches any alphabetic character
[:digit:]    Matches any numeral
[:lower:]   Matches any lowercase letter
[:upper:]  Matches any uppercase letter

Wildcard Examples
*                                       All files
g*                                        Any file beginning with “g”
b*.txt                                   Any file beginning with “b” followed by any characters and ending with “.txt”
Data???                               Any file beginning with “Data” followed by exactly three characters
[abc]*                                  Any file beginning with either an “a”, a “b”, or a “c”
BACKUP.[0-9][0-9][0-9]   Any file beginning with “BACKUP.” followed by exactly three numerals
[[:upper:]]*                         Any file beginning with an uppercase letter
[![:digit:]]*                          Any file not beginning with a numeral
*[[:lower:]123]                    Any file ending with a lowercase letter or the numerals “1”, “2”, or “3”

Pathname Expansion Of Hidden Files
ls -d .* | less  
echo .[!.]*  

### GLOBING -  do not match pattern
1)  enable the extglob option
shopt -s extglob
2)  example: do not match "file.sh"
ls !(*.sh)

### PROCESSES
Viewing Processes
TTY    short for “Teletype,” and refers to the controlling terminal for the process.
The presence of a “?” in the TTY column indicates no controlling terminal.
TIME  the amount of CPU time consumed by the process  [DD-]hh:mm:ss format

### TOP
  SORTING of task window
  For compatibility, this top supports most of the former top sort keys. Since this is primarily a service to former top users, these commands do not appear on any help screen.
  command sorted-field supported
  A   start time (non-display) No
  M   %MEM Yes
  N   PID Yes
  P   %CPU Yes
  T   TIME+ Yes    minutes:seconds.hundredths
                                bsdtime TIME accumulated cpu time, user + system. The display format is usually "MMM:SS", but can be shifted to the right                                 if the process used more than 999 minutes of cpu time.

###Check when the process started
https://unix.stackexchange.com/questions/53270/what-units-of-time-does-top-use 
The PID file creation date is when the process started:
ls -ld /proc/pid   (So for process 2303 it would be: ls -ld /proc/2303 )

### Customizing The Prompt
Adding Color
Unix and Unix-like systems have two rather complex subsystems to deal with the babel of terminal control (called termcap and terminfo). Character color is controlled by sending the terminal emulator an ANSI escape code embedded in the stream of characters to be displayed. The \[ and \] sequences are used to encapsulate non-printing characters.

An ANSI escape code begins with an octal 033 (the code generated by the escape key), followed by an optional character attribute, followed by an instruction. For example, the
code to set the text color to normal (attribute = 0), black text is:
\033[0;30mcentos



### Networking

### add routes
```
#!/bin/bash
host -v sie.okta.com \
    | awk '/ IN A /{print $NF}' \
    | xargs -n1 -I {} sudo ip route add {} dev tun0
```

### Routes and the Kernel Routing Table
- can directly reach hosts on local network: 10.23.2.0 / 24
- can reach hosts on internet via the router at 10.23.2.1
- Destination: 0.0.0.0 = default route
- Destination: 0.0.0.0, Gateway 10.23.2.1 = default gateway   
- Flags: U = ip, G = gateway

### Network interface configuration
When the interface is up, you’d be ready to add routes, which is typically just a matter of setting the default gateway, like this:
route add default gw <gw-address>


### To remove a default gateway
route del -net default

### Add traffic for 192.168.45.0 to router at 10.23.2.44:
route add -net 192.168.45.0/24 gw 10.23.2.44

### Delete a route
route del -net 192.168.45.0/24

### Boot-Activated Network Configuration
Ubuntu, for example, uses the ifupdown suite with configuration files in
/etc/network
and Fedora uses its own set of scripts with configuration in
/etc/sysconfig/network-scripts

### reset network after editing /etc/network/interfaces
sudo ifdown eth0 && ifup eth0

### restart the network service.
/etc/init.d/network restart

## Redhat
### Static Network Settings
/etc/sysconfig/network-scripts/

### NFS Client Configuration To Mount NFS Share
https://www.cyberciti.biz/tips/ubuntu-linux-nfs-client-configuration-to-mount-nfs-share.html

  NFS  - Make sure showmount is installed
apt-get update
apt-get install nfs-common

NFS - see the List Of All Shared Directories
```
showmount -e server-Ip-address
```


NFS   - Mount Shared Directory
sudo mkdir /nfs
sudo mount -o soft,intr,rsize=8192,wsize=8192 192.168.1.1:/viveks /nfs
df -hsed
       https://www.centos.org/docs//4/4.5/Reference_Guide/s2-nfs-client-config-options.html
       hard or soft — Specifies whether the program using a file via an NFS connection should stop and wait (hard) for the server to come back online, if the host serving the exported file system is unavailable, or if it should report an error (soft).
       intr — Allows NFS requests to be interrupted if the server goes down or cannot be reached.
       rsize=num and wsize=num — These settings speed up NFS communication for reads (rsize) and writes (wsize) by setting a larger data block size, in bytes, to be transferred at one time. Be careful when changing these values; some older Linux kernels and network cards do not work well with larger block sizes. For NFSv2 or NFSv3, the default values for both parameters is set to 8192. For NFSv4, the default values for both parameters is set to 32768.

NFS -  mount share directory with recommended option for database backup (to assure data integrity)
10.0.1.205:/volume8/db_archiving /var/lib/sp-syn01 nfs nolock,vers=3,tcp,sync,rw 0 0

 NFS   - How Do I Mount NFS Automatically After Reboot?
sudo vi /etc/fstab
192.168.1.1:/viveks /nfs nfs soft,intr,rsize=8192,wsize=8192

Script locations
```
  root only - /usr/local/sbin/<script.sh>
  specific user only - $HOME/bin/<script.sh>
  any user - /usr/local/bin/<script.sh>
```

### Filesystem Hierarchy Standard
http://www.pathname.com/fhs/pub/fhs-2.3.html

### How to determine which process is creating a file?
https://unix.stackexchange.com/questions/13776/how-to-determine-which-process-is-creating-a-file
`lsof /path/to/file`
or
`auditctl -w /path/to/file`
or
`loggedfs -l /path/to/log_file -c /path/to/config.xml /path/to/directory`
`tail -f /path/to/log_file`

### Mail - send email via command line
https://tecadmin.net/ways-to-send-email-from-linux-command-line/
```bash
mail -s "This is the subject" someone@example.com
echo "This is the body of the email" | mail -s "This is the subject line" rpo@3e.eu
```

### Mail - find queue size
```bash
mailq or postqueue -p o
Count 
find /var/spool/postfix/deferred -type f | wc -l
```

### Mail -Print a particular message, by ID (you can see the ID along in mailq's output)
```bash
postcat -vq [message-id] - 
```

### Mail - Process the queued mail immediately
```postqueue -f ```

### Mail - delete queue
https://www.cyberciti.biz/tips/howto-postfix-flush-mail-queue.html
`postsuper -d ALL`


### How to extend a partition in LVM
1.     See if LVM is used:
pvdisplay   or  lvdisplay 
2.     Show information about volumes
pvs
3.     Extend a partition
http://tldp.org/HOWTO/LVM-HOWTO/extendlv.html
lvextend -L+1G /dev/myvg/homevol
4.     See filesystem type
df -Th
5.     Resize the partition
resize2fs /dev/myvg/homevol


### How to change keyboard layout
1) dpkg-reconfigure keyboard-configuration
2) setupcon

### How to list installed packages
https://askubuntu.com/questions/17823/how-to-list-all-installed-packages
dpkg --get-selections

### Find first n files in a directory with a large number of files:
Explication: the find command does get terminated once head has printed the first n files
find . | head -20

### Strange characters appearing when I use the Ctrl and Arrow keys to navigate
https://askubuntu.com/questions/53556/strange-characters-appearing-when-i-use-the-ctrl-and-arrow-keys-to-navigate

The kernel  generates debugging output that you can view with 
dmesg

### dhcp server see leases
https://askubuntu.com/questions/219609/how-do-i-show-active-dhcp-leases
`cat /var/lib/dhcp/dhcpd.leases`

### Force DHCP Client (dhclient) to Renew IP Address
https://www.cyberciti.biz/faq/howto-linux-renew-dhcp-client-ip-address/
1. releases the current lease
   dhclient -r
2. obtain fresh IP:
   dhclient

### Enable SSH root login on Debian Linux Server
https://linuxconfig.org/enable-ssh-root-login-on-debian-linux-server
vi /etc/ssh/sshd_config
FROM:
PermitRootLogin without-password
TO:
PermitRootLogin yes

/boot running full - mainly for Ubuntu
https://askubuntu.com/questions/89710/how-do-i-free-up-more-space-in-boot
https://mintguide.org/system/622-purge-old-kernels-safe-way-to-remove-old-kernels.html
if the kernel was install automatically or via Update Manager
```bash
purge-old-kernels --keep 3 -qy
apt-get autoremove
apt-get autoclean
```
To list all installed kernels, run:
```bash
dpkg -l 'linux-image-*' | grep ii
```

### /usr is full
https://serverfault.com/questions/87341/ubuntu-usr-is-full-up-recommend-anything-in-there-i-can-delete
```bash
mkdir -p /home/share/doc
cp -a /usr/share/doc/  /home/share/
rmdir /usr/share/doc
ln -sfn /home/usr/share/doc /usr/share/doc
```

### Determine executable from PID
https://unix.stackexchange.com/questions/27893/if-i-see-a-process-running-using-ps-how-can-i-find-the-executable
```
cat /proc/<PID>/cmdline

cat /proc/21491/cmdline 
/usr/bin/prometheus-node-exporter--collector.diskstats.ignored-devices=^(ram|loop|fd)d+$--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|run|var/lib/docker)($|/)--collector.textfile.directory=/var/lib/prometheus/node-exporter--no-collector.bonding--no-collector.fibrechannel--no-collector.ipvs--no-collector.nfs--no-collector.nfsd--no-collector.rapl--no-collector.zfs--collector.netdev.device-exclude=^lo$--no-collector.hwmon--no-collector.infiniband--no-collector.mdadm--web.listen-address=0.0.0.0:9100root@testlab-runne
```

### How to display network traffic in the terminal?
https://askubuntu.com/questions/257263/how-to-display-network-traffic-in-the-terminal
```
bmon
tcptrack
iftop
```

### How to detect network loss
```
mtr <10.0.1.205>
```

### tcpdump - how to:
https://danielmiessler.com/study/tcpdump/

### Rsyslog- troubleshooting
https://www.loggly.com/docs/troubleshooting-rsyslog/

### Rsyslog  - How to Configure Rsyslog with Any Log File
https://blog.rapid7.com/2013/12/19/how-to-configure-rsyslog-with-any-log-file-agents-bad-no-agents-good

### Rsyslog - How can I check the config?
https://www.loggly.com/docs/troubleshooting-rsyslog/
```
rsyslogd -N1
```

### Rsyslog - stop
```
systemctl stop syslog.socket rsyslog.service
```


### Rsyslog - debug
https://www.experts-exchange.com/questions/27511414/Rsyslog-State-Files-not-being-created.html
```
strace -f rsyslogd -c5 -dn > logfile 2>tracefile
```

### Rsyslog - state files not saved:
https://serverfault.com/questions/885754/how-to-debug-the-rsyslog-error-no-state-file-path-to-statefile-exists-for-p
PersistStateInterval="10" must be sent in every input(...) like below
input(type="imfile"
      File="/var/opt/leonardo/p_leo13/trace/leolisp.out"
      Tag="sp-leo13-trace-leolisp-out"
      PersistStateInterval="10"
      StateFile="leolisp-statefile"
      Severity="info")

Rsyslog - version  5.x
https://serverfault.com/questions/396136/how-to-forward-specific-log-file-outside-of-var-log-with-rsyslog-to-remote-serv#396194
$ModLoad imfile
$InputFileName /var/opt/leonardo/p_leo08/trace/daemon.log
$InputFileTag sp-leo08-trace-daemon
$InputFileStateFile daemon-statefile
$InputFileSeverity info
$InputFileFacility local3
$InputRunFileMonitor
$PersistStateInterval 10

### FTP - automate ftp host.com
https://superuser.com/questions/396594/login-with-linux-ftp-username-and-password
```
cat machine data.acme.com login YOUR_LOGIN_USER password SECRET_PASSWORD > ~/.NETRC
ftp data.acme.com
pas
put FILE_NAME
FTP - send files to ftp using curl
curl -u USER:PASSWORD -T FILE ftp://server/dir/file
```

### FTP - Recover the FTP password via TCPDUMP
https://networkingnotesblog.wordpress.com/2017/03/16/recover-the-ftp-password-via-tcpdump/

### Find out if you ssh-ed in a vm or a physical server
http://www.golinuxhub.com/2014/06/how-do-you-check-machine-is-physical-or.html
```
dmidecode -s system-product-name

# get serial number for
sudo dmidecode -s chassis-serial-number
```



### Debian - Get rid of useless configuration files
https://raphaelhertzog.com/2011/01/31/debian-cleanup-tip-1-get-rid-of-useless-configuration-files 

### Mastering Debian and Ubuntu
https://raphaelhertzog.com/mastering-debian/


### Compare 2 directors and find the identical files
```bash
diff -rs dir1 dir2 | grep identical
```

### Networking - identify free / used IPs on a network:
https://stackoverflow.com/questions/13669585/how-to-get-a-list-of-all-valid-ip-addresses-in-a-local-network
```bash
nmap -sP 192.168.1.*
```
# or
```bash
nmap -sP 172.18.5.129/25
```
# or
https://serverfault.com/questions/586714/nmap-find-free-ips-from-the-range
```
nmap -v -sn -n 192.168.1.0/24 -oG - | awk '/Status: Down/{print $2}'
# or
for ip in 172.18.5.{129..254}; do  { ping -c 1 -W 1 $ip ; } &> /dev/null || echo $ip  & done | sort
```

### nmap - scan for specific port 9121
```
nmap -p 9121 10.1.2.17
```

### See network cards drivers
```
for f in /sys/class/net/*; do
    dev=$(basename $f)
    driver=$(readlink $f/device/driver/module)
    if [ $driver ]; then
        driver=$(basename $driver)
    fi
    addr=$(cat $f/address)
    operstate=$(cat $f/operstate)
    printf "%10s [%s]: %10s (%s)\n" "$dev" "$addr" "$driver" "$operstate"
done
```


### Using "ip" command
https://www.fosslinux.com/3027/how-to-find-ip-and-mac-address-by-command-line-in-linux.htm
Show IP address of an interface
```
ip addr show eth0
```

### Show MAC address of an interface
```
ip link show
```

### Bring interface up with ip command
```
# ip link set dev <interface> up
```

### Rename network interface
```
ip link set peth0 name eth0
```

### Speedup scp
```
root@sp-leo01-sbcl:/home/leo# ssh root@sp-leo01 'cd /home/leo; tar cvf - * ' | (cd /home/leo; tar xvf -)
```

### CURL - download and extract 
```
curl -L https://github.com/variantdev/vals/releases/download/v0.15.0/vals_0.15.0_linux_amd64.tar.gz | tar -xz
```

### Debug finding libraries
LD_DEBUG=libs /opt/leo/bin/leonardo start

Systemd configuration files
    - system unit dir, (globally configured)
    ﻿/usr/lib/systemd/system
   - system configuration directory (local definitions)
    /etc/systemd/system
sp-rabbitmq01
strace
https://www.tecmint.com/strace-commands-for-troubleshooting-and-debugging-linux/
https://www.thegeekstuff.com/2011/11/strace-examples/

### profile a process
```
strace -r -f -p 15757 -o statistics.txt
```

seful strace switches
```
-f (to follow forks) 
-p pid (to attach to the running slapd)
-s 255 (to get long strings)
-T (to get time spent in system calls)
```

### Creating simlynks
```
ln -s "to-here" <- "from-here"
```

### sed -  search and replace in a list of file
```
sed -i 's/vpn-servers/vpn_servers/g' $(grep 'vpn-servers' -rl --exclude-dir=.git  | tr '\n' ' ')
```

### sed - Print only matching group
https://stackoverflow.com/questions/17511639/sed-print-only-matching-group#17511700
```
echo "foo bar <foo> bla 1 2 3.4" |
 sed -n 's/.*\([0-9][0-9]*[\ \t][0-9.]*[ \t]*$\)/\1/p'
2 3.4
#or
grep -o
# 2020-11-19: it's better to split the line in 3 groups and then print only your wish 
 sed -nE 's/(.*)datetime="(.*)" (.*)/\2/p'
```
### sed - Delete line at line-number in file

### sed - Print matching pattern
```
sed -n '/www2.r6.03.lona.acme.net/p' /home/rpopa/.ssh/known_hosts
www2.r6.03.lona.acme.net,10.20.134.172 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGgsZOCI6kY1MMQbXGrDG4Ft4AtumaBmoDR3pleNhk5rTteJhq7j5xhDQGuCYyXoQYNhzLXvzp976DQZ5fmVna4=
```

### sed - delete matching pattern from file
```
# first print the matching pattern like cmd above
# then test the delete
sed -n '/www2.r6.03.lona.acme.net/d' /home/rpopa/.ssh/known_hosts
sed -in '/www2.r6.03.lona.acme.net/d' /home/rpopa/.ssh/known_hosts
```

```
sed -i -e '31d' /home/radu/.ssh/known_hosts
```

### Search and replace in file
```
sed -i -E 's/(.*-F *)("ref=v[0-9]*")/\1 "ref=v4"/' substrate_trigger_pipeline.sh
```

### Search and replace in file on macbook; pattern in multiple files
```
fgrep 'asdasd' -rl | head -1 | while read -r fname ; do echo working wiking with $fname ; sed -i '' -E 's/(.*)(asdasd)(.*)/\1<secret_pass>\3/g'  "${fname}"  ; done
```

### sed search and replace, but line mus contain another  pattern before the substituion
```
radu@radu-x1-carbon:~/Music/coding-2021-09-03$ echo 'some data myself 1.2.3.4' | sed  -e "/myself/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/FOUND_IP/"
some data myself FOUND_IP
radu@radu-x1-carbon:~/Music/coding-2021-09-03$ echo 'some data myselffff 1.2.3.4' | sed  -e "/myself/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/FOUND_IP/"
some data myselffff FOUND_IP
radu@radu-x1-carbon:~/Music/coding-2021-09-03$ echo 'some data other 1.2.3.4' | sed  -e "/myself/ s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/FOUND_IP/"
some data other 1.2.3.4
```

### Test web-server connectivity with netcat
https://linuxhandbook.com/nc-command/ 
```
netcat -vz sp-pmm01 80
nc -v -z -n localhost 9252

curl --connect-timeout 1 -s 10.117.128.76:8000 ; echo $?
```

### Test connectivity with curl
```
curl -v telnet://127.0.0.1:22
```

### Linux List The Open Ports And The Process That Owns Them
read this https://linuxacademy.com/blog/linux/netstat-network-analysis-and-troubleshooting-explained/
```
sudo lsof -i
sudo netstat -lptu
sudo netstat -tuna
```

### Netstat without netstat for containers 
https://staaldraad.github.io/2017/12/20/netstat-without-netstat/
```
grep -v "rem_address" /proc/net/tcp  | awk 'function hextodec(str,ret,n,i,k,c){
    ret = 0
    n = length(str)
    for (i = 1; i <= n; i++) {
        c = tolower(substr(str, i, 1))
        k = index("123456789abcdef", c)
        ret = ret * 16 + k
    }
    return ret
} {x=hextodec(substr($2,index($2,":")-2,2)); for (i=5; i>0; i-=2) x = x"."hextodec(substr($2,i,2))}{print x":"hextodec(substr($2,index($2,":")+1,4))}'
```

### Remove ssh key
 remove with:
```
ssh-keygen -f "/home/radu/.ssh/known_hosts" -R sp-leo02
```

### Apt add repository
sudo add-apt-repository ppa:alexlarsson/flatpak


### Copy text from terminal (file) to system clipboard
```
xclip -sel clip < ~/.ssh/id_rsa.pub
```


### Scripts location:
https://askubuntu.com/questions/308045/differences-between-bin-sbin-usr-bin-usr-sbin-usr-local-bin-usr-local
Please refer to the Filesystem Hierarchy Standard (FHS) for Linux for this.
- /bin : For binaries usable before the /usr partition is mounted. This is used for trivial binaries used in the very early boot stage or ones that you need to have available in booting single-user mode. Think of binaries like cat, ls, etc.
- /sbin : Same, but for scripts with superuser (root) privileges required.
- /usr/bin : Same as first, but for general system-wide binaries.
/usr/sbin : Same as above, but for scripts with superuser (root) privileges required

### Make bookable Windows usb from linux gparted os/
https://www.cyberciti.biz/faq/create-a-bootable-windows-10-usb-in-linux 

### Fix the MBR – Guide for Windows XP, Vista, 7, 8, 8.1, 10
https://neosmart.net/wiki/fix-mbr/ 
bootrec /FixMbr
bootrec /FixBoot
bootrec /ScanOs
bootrec /RebuildBcd

### Use Linux Software RAID - find RAID Status:
https://www.thomas-krenn.com/en/wiki/Linux_Software_RAID 
mdadm -D /dev/md123
cat /proc/mdstat

### Use Linux Software RAID - check array:

smartctl
S.M.A.R.T. (Self-Monitoring, Analysis and Reporting Technology
https://www.thomas-krenn.com/en/wiki/SMART_tests_with_smartctl
All modern hard drives offer the possibility to monitor its current state via SMART attributes
see if drive is healthy
```
smartctl -H /dev/sda
```

### smartctl Viewing the Test Results
```
sudo smartctl -a /dev/sdc
```

### How do I find out what hard disks are in the system?
https://unix.stackexchange.com/questions/4561/how-do-i-find-out-what-hard-disks-are-in-the-system
```
lsblk
fdisk -l
lsscsi
```

### Find serial for disk
```
kura1 ~ # lsblk --nodeps -o name,hctl,serial,type,tran /dev/sdk
NAME HCTL       SERIAL   TYPE TRAN
sdk  7:0:0:0    S1Z1MAYM disk sas

smartctl -i /dev/sda
```

### Re-scan disks
https://www.cyberciti.biz/tips/vmware-add-a-new-hard-disk-without-rebooting-guest.html
https://serverfault.com/questions/5336/how-do-i-make-linux-recognize-a-new-sata-dev-sda-drive-i-hot-swapped-in-without
```
echo "- - -" >> /sys/class/scsi_host/host_$i/scan
```

Detect faulty/bad disk
```
dmesg -T | grep -i 'i/o'
```


```
smartctl --scan | sed 's/#.*//' | while IFS= read dev; do echo -n "$dev: "; smartctl -H $dev | grep -i health; done
# or
for disk in /dev/sd[c-z] ; do printf "$disk: "; timeout -s 9 5 smartctl -i "$disk" | grep -i serial; done
```

### Ansible tutorial
https://www.linuxjournal.com/content/weekend-reading-ansible

### mtr
MTR is a simple, cross-platform command-line network diagnostic tool that combines the functionality of commonly used traceroute and ping programs into a single tool
https://www.tecmint.com/mtr-a-network-diagnostic-tool-for-linux/

### Unban IP
https://serverfault.com/questions/384230/fail2ban-unblock-ipaddress

Use the --line-numbers option to iptables to get a listing which shows the line numbers for the rules in a chain e.g.

```
iptables -L -n
# or 
iptables -L  -v -n --line-numbers
# or
iptables -L fail2ban-SSH -v -n --line-numbers
Chain fail2ban-SSH (1 references)
num   pkts bytes target     prot opt in     out   source              destination
1       19  2332 DROP       all  --  *      *     193.87.172.171      0.0.0.0/0
2       16  1704 DROP       all  --  *      *     222.58.151.68       0.0.0.0/
3       15   980 DROP       all  --  *      *     218.108.224.81      0.0.0.0/0
4        6   360 DROP       all  --  *      *     91.196.170.231      0.0.0.0/0
5     8504  581K RETURN     all  --  *      *     0.0.0.0/0           0.0.0.0/0
```

Then use iptables -D chain rulenum to remove the ones you don't want e.g.

```
iptables -D fail2ban-SSH 1
# or 
iptables -D input_dynamic 5
```

would delete the 

```
1       19  2332 DROP       all  --  *      *     193.87.172.171      0.0.0.0/0
```

or 

```
i=10.126.65.46
iptables -L  -v -n --line-numbers | grep -B4 $i
Chain input_dynamic (1 references)
num   pkts bytes target     prot opt in     out     source               destination         
1       75  4500 DROP       tcp  --  *      *       10.11.132.177        0.0.0.0/0            multiport dports 22
2     2969  178K DROP       tcp  --  *      *       10.126.65.46         0.0.0.0/0            multiport dports 22


bastion1 ~ # iptables -D  input_dynamic 2
```

acme
```
function get_banned_ip {
  iptables -L  -v -n --line-numbers | grep DROP
}
function skip_first_4 {
  tail +4 
}
function unban_ip {
  chain_index=$1
  iptables -D  input_dynamic "${chain_index}"
}
# test output
while read -r chain_index _2 _3 _4 _5 _6 _7 _8 ip _9 ; do 
  echo "unban_ip ${chain_index} ${ip}" 
done < <(get_banned_ip | skip_first_4) 
# run prod by removeing echo
while read -r chain_index _2 _3 _4 _5 _6 _7 _8 ip _9 ; do 
  smartctlunban_ip ${chain_index} 
done < <(get_banned_ip | skip_first_4)
```

```
sudo fail2ban-client set ssh-boka unbanip 10.126.65.78
```

### Less - case insensitive search
```
-i  
```

https://access.redhat.com/sites/default/files/attachments/12052018_systemd_6.pdf

### systemctl list all failed services

```
systemctl list-units --state=failed
```

### systemctl show details about a failed service
```
sudo systemctl status -l smartd.service
```

### systemctl To show all installed unit files use
```
systemctl list-unit-files
```

### systemctl show logs for failing service
```
journalctl -u service-name.service -b
```

### Finding the PID of the process using a specific port
```
lsof -i :25
```


### curl - send json with variales
```
curl "http://localhost:8080" \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
--data @<(cat <<EOF
{
  "me": "$USER",
  "something": $(date +%s)
  }
EOF
)
```


### Connecting to acme vpn with pulse secure
```
# 1. Install the package
sudo dpkg -i ps-pulse-linux-9.0r2.0-b819-ubuntu-debian-64-bit-installer.deb

# 2. launch the Pulse Secure UI from the cmd line to see any error messages (I had to install a missing lib)
/usr/local/pulse/pulseUi

# 3. To install a certificate with pulse secure client, Both Private(cert) and Public(cacert) certificate should have same name.
# 3.1 Rename user certificate
cp cert.pem pulseCert.pem
# 3.2 Rename user key
cp key.pem pulseCert.key
# 3.3 Now you can install the certificate
/usr/local/pulse/PulseClient_x86_64.sh install_certificates -inpub /home/radu/k/certs/pulseCert.pem -inpriv /home/radu/k/certs/pulseCert.key
# 4. Finally connect using the Pulse Secure UI
```


### set MTU to 1200
```
sudo ip l set mtu 1200 dev tun0
```

### regex (regular expressions ) and globing


Special Character
Meaning in Globs
Meaning in Regex
*
zero or more characters
zero or more of the character it follows
?
single occurrence of any character
zero or one of the character it follows but not more than 1
.
literal "." character
any single character


https://www.linuxjournal.com/content/globbing-and-regex-so-similar-so-different


commands seen at mbrot
```
show lldp neighbors |match mule
show lacp interfaces ae2
```


See bond status and composing interfaces 

```
cat /proc/net/bonding/bond0
```

how to use jq
https://blog.appoptics.com/jq-json/
https://docs.gitlab.com/ee/administration/troubleshooting/log_parsing.html
https://engineering.spec-trust.com/posts/self-documenting-interactive-make

jq - get length of list
```
arato-cli prod get | jq '.lona | length'
```
jq - count objects that have  key==value

```
 jq '[.[] | select(.group=="netops")] | length' ~/tmp/infs-363-arato-migration/lona-alerts.json
```

jq - list keys

jq - get list of hosts
```
jq '.hosts | keys' ./720-lona-infrastructure/r3.03.lona-compute.input
```

# jq - process list of lists
```
jq '.[]|.[].createdBy'
```
jq example
```
$ haggr-query -Pm 500 /status | jq -r  'select(.target|startswith("rms")).response?.taikais[]?|. as $t|$t.slots[]?|"\($t.name):\(.slotId) \(.state.state) \(.state.stateReason) \(.state.stateReasonNote)"' | awk '/DISABLED|UNKNOWN/' | wc -l
```

### jq process list of objects

```
radu@radu-x1-carbon:~/p/simnet/scripts$ echo $content 
[{"name":"README.md","path":"simnet_tests/README.md","sha":"9c6a74c568231cc076ea3c89bb63323e12a69398","size":2037,"url":"https://api.github.com/repos/acmetech/polkadot/contents/simnet_tests/README.md?ref=master","html_url":"https://github.com/acmetech/polkadot/blob/master/simnet_tests/README.md","git_url":"https://api.github.com/repos/acmetech/polkadot/git/blobs/9c6a74c568231cc076ea3c89bb63323e12a69398","download_url":"https://raw.githubusercontent.com/acmetech/polkadot/master/simnet_tests/README.md","type":"file","_links":{"self":"https://api.github.com/repos/acmetech/polkadot/contents/simnet_tests/README.md?ref=master","git":"https://api.github.com/repos/acmetech/polkadot/git/blobs/9c6a74c568231cc076ea3c89bb63323e12a69398","html":"https://github.com/acmetech/polkadot/blob/master/simnet_tests/README.md"}},{"name":"configs","path":"simnet_tests/configs","sha":"e52171fe22e15f36840441b7650eb0f4b26d1da8","size":0,"url":"https://api.github.com/repos/acmetech/polkadot/contents/simnet_tests/configs?ref=master","html_url":"https://github.com/acmetech/polkadot/tree/master/simnet_tests/configs","git_url":"https://api.github.com/repos/acmetech/polkadot/git/trees/e52171fe22e15f36840441b7650eb0f4b26d1da8","download_url":null,"type":"dir","_links":{"self":"https://api.github.com/repos/acmetech/polkadot/contents/simnet_tests/configs?ref=master","git":"https://api.github.com/repos/acmetech/polkadot/git/trees/e52171fe22e15f36840441b7650eb0f4b26d1da8","html":"https://github.com/acmetech/polkadot/tree/master/simnet_tests/configs"}},{"name":"run_tests.sh","path":"simnet_tests/run_tests.sh","sha":"0717d99db7b3415cd3c116d313dbc6fb37876edf","size":2788,"url":"https://api.github.com/repos/acmetech/polkadot/contents/simnet_tests/run_tests.sh?ref=master","html_url":"https://github.com/acmetech/polkadot/blob/master/simnet_tests/run_tests.sh","git_url":"https://api.github.com/repos/acmetech/polkadot/git/blobs/0717d99db7b3415cd3c116d313dbc6fb37876edf","download_url":"https://raw.githubusercontent.com/acmetech/polkadot/master/simnet_tests/run_tests.sh","type":"file","_links":{"self":"https://api.github.com/repos/acmetech/polkadot/contents/simnet_tests/run_tests.sh?ref=master","git":"https://api.github.com/repos/acmetech/polkadot/git/blobs/0717d99db7b3415cd3c116d313dbc6fb37876edf","html":"https://github.com/acmetech/polkadot/blob/master/simnet_tests/run_tests.sh"}},{"name":"tests","path":"simnet_tests/tests","sha":"c152aadff3462ef8157d390f66b99f7615794029","size":0,"url":"https://api.github.com/repos/acmetech/polkadot/contents/simnet_tests/tests?ref=master","html_url":"https://github.com/acmetech/polkadot/tree/master/simnet_tests/tests","git_url":"https://api.github.com/repos/acmetech/polkadot/git/trees/c152aadff3462ef8157d390f66b99f7615794029","download_url":null,"type":"dir","_links":{"self":"https://api.github.com/repos/acmetech/polkadot/contents/simnet_tests/tests?ref=master","git":"https://api.github.com/repos/acmetech/polkadot/git/trees/c152aadff3462ef8157d390f66b99f7615794029","html":"https://github.com/acmetech/polkadot/tree/master/simnet_tests/tests"}}]
radu@radu-x1-carbon:~/p/simnet/scripts$ 


radu@radu-x1-carbon:~/p/simnet/scripts$ jq '.[] | "\(.name) \(.type)"' <<< "${content}" --raw-output
README.md file
configs dir
run_tests.sh file
tests dir


while read -r _name _type ; do
    echo "Do whatever with ${_name} ${_type}"
done< <(jq 'x`.[] | "\(.name) \(.type)"' <<< "${content}" --raw-output)
```


### set a value in a file
https://spin.atomicobject.com/2021/06/08/jq-creating-updating-json/
https://unix.stackexchange.com/questions/663385/replace-a-value-in-file-with-jq-one-liner
```
NODE="~acme-ci-subsquid-01~acme-ci~"
SUBSQUID_IMAGE="docker.io/acmefi/subsquid-processor"
existing=$(jq -r '.[] 
                     | select(.node=="'${NODE}'").containers[] 
                     | select(.image=="'${SUBSQUID_IMAGE}'").version' \
                docker-version.json)

echo "${existing}"


jq -r '(.[] 
         | select(.node=="'${NODE}'").containers[] 
         | select(.image=="'${SUBSQUID_IMAGE}'").version)|= "new-image"' \
    docker-version.json \
    > new-docker-version.json


new=$(jq -r '.[] 
                     | select(.node=="'${NODE}'").containers[] 
                     | select(.image=="'${SUBSQUID_IMAGE}'").version' \
                new-docker-version.json)
echo "new is ${new}"
```

### reverse ip lookup
```
dig -x 10.13.131.177 @10.8.8.8
```

### Replacing an LSI raid disk with MegaCli
https://www.advancedclustering.com/act_kb/replacing-a-disk-with-megacli/


### Check disk in hardware raid
```
sudo MegaCli -PDList -aALL| grep -i -E 'slot|error'
sudo MegaCli -PDList -aALL|grep 'Firmware state'
```
 
### run the cmd below and look for anything that is not "Firmware state: Online, Spun Up"
```
sudo megacli -PDList -a0 | grep -i 'Firmware state'
```


### find disk info with smartctl
```
smartctl --scan
hostname -f; dmidecode -s 'system-serial-number'; smartctl -a /dev/bus/1 -d megaraid,17 mk2.r2.03.lona.acme.net
```

### megacli - Check RAID rebuild
```
megacli -PDRbld -ShowProg -PhysDrv [32:10] -aALL
```

### megacli -  Check RAID Status With Megacli
    → go to the oob interface → storage → virtual disk
or
```
sudo megacli -AdpAllInfo -aALL | grep 'Device Present' -A 10
```

### megacli - configure disk as hot spare
```
sudo megacli -PDHSP -Set -PhysDrv [32:6] -a0
```

### This command helps to understand which process was the first one entering D state and which kernel function it was calling. Can be helpful
```
ps ax -o state,cmd,etime,wchan --sort=etime | awk '$1=="D
```

### How to gentoo
### gentoo list installed packages
```
equery list "*"
```

### Gentoo - package management
https://wiki.gentoo.org/wiki/Handbook:AMD64/Working/Portage



### LDAP tutorial - good one
https://www.digitalocean.com/community/tutorials/understanding-the-ldap-protocol-data-hierarchy-and-entry-components

### ldapsearch - how to search everything
```
#
#  Get a dump of all ldap data
#

ldapsearch -xH ldaps://ldap.lax-prod1.prod.acme.net  > all-ldap.data.txt
#          -x  Use simple authentication instead of SASL
#          -H  ldapuri
#              Specify URI(s) referring to the ldap server(s); a list of URI, separated by whitespace or  commas  is  expected;  only  the  proto‐
#              col/host/port fields are allowed.  As an exception, if no host/port is specified, but a DN is, the DN is used to look up the corre‐
#              sponding host(s) using the DNS SRV records, according to RFC 2782.  The DN must be a non-empty sequence  of  AVAs  whose  attribute
#              type is "dc" (domain component), and must be escaped according to RFC 2396.

#
# Do a rough search for a user cn and uid to identify some attributes to use in future filters
#

grep -e "Radu Popa" -e "rpopa" -n all-ldap.data.txt
1056:dn: cn=Radu Popa,ou=Staff,o=acme Inc,c=US
1058:mail: rpopa@acme.com
1065:cn: Radu Popa
1075:uid: rpopa
1077:homeDirectory: /home/rpopa
1079:displayName: Radu Popa
15877:member: cn=Radu Popa,ou=Staff,o=acme Inc,c=US
15994:member: cn=Radu Popa,ou=Staff,o=acme Inc,c=US
16196:member: cn=Radu Popa,ou=Staff,o=acme Inc,c=US
16900:member: cn=Radu Popa,ou=Staff,o=acme Inc,c=US
17225:member: cn=Radu Popa,ou=Staff,o=acme Inc,c=US
17948:member: cn=Radu Popa,ou=Staff,o=acme Inc,c=US

#
#  Give me all entries where member contains Radu Popa
#

# SQL equivalent: 
# SELECT  dn cn description objectClass FROM all_ldap_data WHERE member='cn=Radu Popa,ou=Staff,o=acme Inc,c=US'
ldapsearch -xH ldaps://ldap.lax-prod1.prod.acme.net  "member=cn=Radu Popa,ou=Staff,o=acme Inc,c=US" dn cn description objectClass
# you can specify o branch of the DIT (Data Information Tree) with the -b option.
# e.g
ldapsearch -xH ldaps://ldap.lax-prod1.prod.acme.net -b "ou=Access,o=acme Inc,c=US"  "member=cn=Radu Popa,ou=Staff,o=acme Inc,c=US" dn cn description objectClass 
#
# The OR Filter
# 
# search for 2 filters: member=cn=Radu.. OR memberUid=rpopa
ldapsearch -xH ldaps://ldap.lax-prod1.prod.acme.net   "(|(member=cn=Radu Popa,ou=Staff,o=acme Inc,c=US)(memberUid=rpopa))" dn cn description objectClass
#
# The AND filter + NOT
#
# give me all the entries where member=cn=Radu Popa and description does not contain "titan"
ldapsearch -xH ldaps://ldap.lax-prod1.prod.acme.net "(&(!(description=*titan*))(member=cn=Radu Popa,ou=Staff,o=acme Inc,c=US))" dn cn description objectClass
```

### how to test a branch of a conf package
```
cd  /var/portage/repos/acme-private/app-upconf/salt-templates/
vi salt-templates-9999.ebuild
# and edit
GK_ORG=austin
EGIT_BRANCH="salt-syndic"
ebuild salt-templates-9999.ebuild clean manifest install qmerge
```

### linux system performance
http://www.brendangregg.com/blog/2020-03-08/lisa2019-linux-systems-performance.html

https://blog.haschek.at/2020/the-perfect-file-server.html

### Check the expiration date of an SSL certificate
```
openssl s_client -servername <NAME> -connect <HOST:PORT> 2>/dev/null | openssl x509 -noout -dates
# example
SERVER_NAME=elasticsearch.acme-stg.acme.io
HOST="${SERVER_NAME}"
PORT=443

openssl s_client -servername "${SERVER_NAME}" -connect "${HOST}:${PORT}" 2>/dev/null | openssl x509 -noout -dates
notBefore=Feb 10 13:34:27 2022 GMT
notAfter=May 11 13:34:26 2022 GMT
```

### dump to the html file
```
sudo lshw -html > config.html
```

view it
```
xdg-open config.html
```



### open stack tutorial : https://www.youtube.com/watch?v=_gWfFEuert8

### systemd  specifiers %1  https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Specifiers

### system76 nvidia drivers commands
https://forums.developer.nvidia.com/t/external-monitor-getting-no-input-from-laptop-on-ubuntu-22-04-with-geforce-rtx-3050-ti-mobile/223855
```
apt list | grep nvidia-driver

nvidia-smi

xrandr --listproviders

lspci | grep VGA

```

https://explainshell.com/explain?cmd=tar+xfvzc+file.tar.gz

### Sending quires to graphql
```
curl -g -X POST -H "Content-Type: application/json" -d ' {"query": "query MyQuery { overviewStats { accountHoldersCount activeUsersCount totalValueLocked { price } } }" }' https://stats.acmenodes.tech/graphql
{"data":{"overviewStats":{"accountHoldersCount":2101,"activeUsersCount":74,"totalValueLocked":[{"price":0.001145410336646028},{"price":45.30089034356953},{"price":0.9992989455271616}]}}}
```
