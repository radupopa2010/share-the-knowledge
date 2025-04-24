https://mywiki.wooledge.org/BashFAQ/005 
https://www.mankier.com/1/shellcheck

shellcheck disable

```bash
# shellcheck disable=SC2035
```

```bash
function ensure {
  if ! "$@" ; then 
    echo "Command $*failed"
    exit 1
  fi
}
```

https://gist.github.com/derekp7/9978986  = RPC in bash


```bash
#!/usr/bin/env bash

# Turn on bash safety options: fail on error, variable unset and error in piped process
set -eou pipefail

#
### Args
#
ARG_1=${1:-}
#
### Globals
#
SCRIPT_NAME="$0"

function usage {
  cat << EOF

Usage: ${SCRIPT_NAME} ARG_1
EXAMPLES 
${SCRIPT_NAME} ARG_1
EOF
}

# Main entrypoint for the script
function main {
  check_args
}

function check_args {
  if [[ -z "${ARG_1}" ]] ; then
    echo "Must provide a ARG_1 to the script"
    exit 1
  fi
}

main "$@"
```

https://wiki.bash-hackers.org/howto/getopts_tutorial
```
#!/bin/bash

# The purpose of this script is to 

# Turn on bash safety options: fail on error, variable unset and error in piped process
set -eou pipefail

FORWARD_GREP_FILTER='[p]ort-forward.*bootnode'
SCRIPT_NAME="$0"
SCRIPT_PATH=$(dirname "$0")               # relative
SCRIPT_PATH=$(cd "${SCRIPT_PATH}" && pwd) # absolutized and normalized
RUN_LOCAL=false
RUN_CONTAINER=false
TEST_DIR=""

function usage {
  cat << EOF
Usage: ${SCRIPt_NAME} OPTION

OPTION can be one of -l, --local or -c, --container, but not both.
OPTION 
  -l, --local        Run script on localhost
  -c, --container    Run script inside a container
  -t, --testdir DIR  Specify which tests to run   

EXAMPLES
${SCRIPt_NAME} -l -t features
${SCRIPt_NAME} --local --testdir=features
${SCRIPt_NAME} -c -t features
${SCRIPt_NAME} --container --testdir=features

EOF
}

function die { 
  # complain to STDERR and exit with error
  echo -e "$*" >&2; exit 2; 
}  

function needs_arg { 
  if [ -z "$OPTARG" ]; then 
    die "No arg for --$OPT option" 
  fi
}

function parse_args {
  # NOTE: call   parse_args "$@"
  while getopts clt:-: OPT; do
    # support long options: https://stackoverflow.com/a/28466267/519360
    if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
      OPT="${OPTARG%%=*}"       # extract long option name
      OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
      OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
    fi
    # shellcheck disable=SC2214
    case "$OPT" in
      l | local )      RUN_LOCAL=true ;;
      c | container )  RUN_CONTAINER=true ;;
      t | testdir )    needs_arg ; TEST_DIR="${OPTARG}" ;;
      ??* )            die "Illegal option --$OPT" ;;  # bad long option
      ? )              exit 2 ;;  # bad short option (error reported via getopts)
    esac
  done
  shift $((OPTIND-1)) # remove parsed options and args from $@ list

  check_args
}

function check_args {

  if ${RUN_LOCAL} && ${RUN_CONTAINER} ; then
    die "ERROR: Only one of -l, --local or -c, --conatiner falgs can be set\n\n$(usage)"
  elif ! ${RUN_LOCAL} && ! ${RUN_CONTAINER} ; then
    die "ERROR: At least one of -l, --local or -c, --conatiner falgs must be set\n\n$(usage)"
  fi

  if [[ -z "${TEST_DIR}" ]] ; then
    die "ERROR: Must specify 'testdir' argument to script \n\n$(usage)"
  fi
}

function set_gurke_cmd {
  GURKE=""
  if ${RUN_LOCAL} ; then
    GURKE="cargo run --"
  elif  ${RUN_CONTAINER} ; then
    GURKE="gurke"
  fi
}

function spawn_test_net {
  eval "${GURKE} spawn -c ${SCRIPT_PATH}/../examples/default_local_testnet.toml"  2>&1  | tee gurke.log
  NAMESPACE="$(grep -oE 'gurke-.*' gurke.log)" 

  if [[ -z  "${NAMESPACE}" ]] ; then  
     die "'namespace' can't be empty" ; 
  else
     echo "LOG INFO namespace is ${NAMESPACE}" ;
  fi

  # When you run at localhost you can easily access the namespace
  if ! ${RUN_CONTAINER} ; then
    export NAMESPACE="${NAMESPACE}"
  fi

  sleep 5
}

function forward_svc {
  if is_port_forward_running ; then
    kill_previous_job
  fi
  start_forwading_job 
}

function run_test {


  if [[ ${TEST_DIR} = external* ]] ; then
    forward_svc
  fi
  eval "${GURKE} test ${NAMESPACE} ${SCRIPT_PATH}/../${TEST_DIR}/"
}

function cleanup {
  kubectl delete ns "${NAMESPACE}"
  # delay endding of gitlab job to give time for namesoace to be deleted
  sleep 20
}

function kill_previous_job {
  # shellcheck disable=SC2009
  job_pid=$(ps aux | grep -E "${FORWARD_GREP_FILTER}" | awk '{ print $2 }')
  echo "LOG INFO Killed forwading port 9944 into bootnode"
  kill "${job_pid}"
}

function start_forwading_job {
  echo "LOG INFO Started forwading port 9944 into bootnode"
  kubectl -n "${NAMESPACE}" \
          port-forward pod/bootnode 8080:9944 &> "forward-${NAMESPACE}.log" &

  sleep 2
}

function is_port_forward_running {
  # shellcheck disable=SC2009
  ps aux | grep -qE "${FORWARD_GREP_FILTER}" 
}


parse_args "$@"

set_gurke_cmd

spawn_test_net

run_test

cleanup
```

# redirect all script output to a log file
```
exec &>> /var/log/cron.log
```

The Bash builtin getopts function can be used to parse long options  by putting a dash character followed by a colon into the optspec:

```bash
#!/usr/bin/env bash 
optspec=":hv-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            case "${OPTARG}" in
                loglevel)
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    echo "Parsing option: '--${OPTARG}', value: '${val}'" >&2;
                    ;;
                loglevel=*)
                    val=${OPTARG#*=}
                    opt=${OPTARG%=$val}
                    echo "Parsing option: '--${opt}', value: '${val}'" >&2
                    ;;
                *)
                    if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                        echo "Unknown option --${OPTARG}" >&2
                    fi
                    ;;
            esac;;
        h)
            echo "usage: $0 [-v] [--loglevel[=]<value>]" >&2
            exit 2
            ;;
        v)
            echo "Parsing option: '-${optchar}'" >&2
            ;;
        *)
            if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                echo "Non-option argument: '-${OPTARG}'" >&2
            fi
            ;;
    esac
done
```


reading data from user input
read [-options] [variable]

if not [variable[s]]: $REPLY is created

Options
-a array Assign the input to array, starting with index zero. We
will cover arrays in Chapter 35.read – Read Values From Standard Input
-d delimiter The first character in the string delimiter is used to
indicate end of input, rather than a newline character.
-e Use Readline to handle input. This permits input editing
in the same manner as the command line.
-i string Use string as a default reply if the user simply presses
Enter. Requires the -e option.
-n num Read num characters of input, rather than an entire line.
-p prompt Display a prompt for input using the string prompt. 

-r Raw mode. Do not interpret backslash characters as escapes.
-s Silent mode. Do not echo characters to the display as
they are typed. This is useful when inputting passwords
and other confidential information.
-t seconds Timeout. Terminate input after seconds. read returns a
non-zero exit status if an input times out.
-u fd Use inp

Case syntax

case [word] in
    [pattern [| pattern])  commands;; ]

Patterns
a)    Matches if word equals “a”.
[[:alpha:]])   Matches if word is a single alphabetic character.
???)    Matches if word is exactly three characters long.
*.txt)     Matches if word ends with the characters “.txt”.
*)    Matches any value of word. It is good practice to include this
as the last pattern in a case command, to catch any values of
word that did not match a previous pattern; that is, to catch any
possible invalid values.
Matches if word equals “a”.

Bash tests expressions (for if )
File Expressions
The following expressions are used to evaluate the status of files:

file1 -ef file2 Is True If:
file1 -nt file2 file1 is newer than file2.
file1 -ot file2 file1 is older than file2.
-b file file exists and is a block-special (device) file.
-c file file exists and is a character-special (device) file.
-d file file exists and is a directory.
-e file file exists.
-f file file exists and is a regular file.
-g file file exists and is set-group-ID.
-G file file exists and is owned by the effective group ID.
-k file file exists and has its “sticky bit” set.
-L file file exists and is a symbolic link.
-O file file exists and is owned by the effective user ID.
-p file file exists and is a named pipe.
-r file file exists and is readable (has readable permission for
384
file1 and file2 have the same inode numbers (the two
filenames refer to the same file by hard linking).test
the effective user).
-s file file exists and has a length greater than zero.
-S file file exists and is a network socket.
-t fd fd is a file descriptor directed to/from the terminal. This
can be used to determine whether standard
input/output/error is being redirected.
-u file file exists and is setuid.
-w file file exists and is writable (has write permission for the
effective user).
-x file file exists and is executable (has execute/search
permission for the effective user).


String Expressions
string Is True If...

-n string The length of string is greater than zero.
-z string The length of string is zero.
string1 = string2
string1 == string2 string1 and string2 are equal. Single or double
equal signs may be used, but the use of double
equal signs is greatly preferred.
string1 != string2 string1 and string2 are not equal.
string1 > string2 string1 sorts after string2.
string1 < string2 string1 sorts before string2.


Integer Expressions
Expression Is True If...

integer1 -eq integer2 integer1 is equal to integer2.
integer1 -ne integer2 integer1 is not equal to integer2.
integer1 -le integer2 integer1 is less than or equal to integer2.
integer1 -lt integer2 integer1 is less than integer2.
integer1 -ge integer2 integer1 is greater than or equal to integer2.
integer1 -gt integer2 integer1 is greater than integer2.


```bash
function is_empty_dir {
  local dir_path=$1
  ! find "${dir_path}" -mindepth 1 -print -quit | grep -q .
}
using it:
if [[ ! -d "${arc_month_dir}" ]] || is_empty_dir "${arc_month_dir}" ; then
  return 0
fi

 function random_string {                                                                  
   # Generate random string                                                                
   tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 20 | head -1                                
 }
```


Test globing patterns
Escape the pattern or it'll get pre-expanded into matches. Exit status is 1 for no-match, 0 for 'one or more matches'. stdout is a list of file matching the glob

```
compgen -G "<glob-pattern>"
```

https://stackoverflow.com/questions/2937407/test-whether-a-glob-has-any-matches-in-bash

Script locations:
- root only - `/usr/local/sbin/<script.sh>`
- specific user only - `$HOME/bin/<script.sh>`
- any user - `/usr/local/bin/<script.sh>`

Get script dir from inside the script

```bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
```

Looping in associative arrays

```bash
for i in "${!array[@]}"; do
  echo "key : $i"
  echo "value: ${array[$i]}"
done
```

Create array from file content

```bash
# IFS should be '\n'
readarray rows < demo.txt                                           

for row in "${rows[@]}";do                                                      
  row_array=(${row})                                                            
  first=${row_array[0]}                                                         
  echo ${first}                                                                 
done
```

Create array from var

```bash
cnxs="con1 con2"
arr=(${cnxs})
```


Arrays
https://mywiki.wooledge.org/BashSheet#Arrays 
How can I use array variables?
https://mywiki.wooledge.org/BashFAQ/005 

How do I use null bytes in Bash?
https://unix.stackexchange.com/questions/174016/how-do-i-use-null-bytes-in-bash

some thips
https://brbsix.github.io/2015/11/29/bash-scripting-dos-and-donts/

How to debug a bash script?
https://unix.stackexchange.com/questions/155551/how-to-debug-a-bash-script

```bash
set -x
..code to debug...
set +x
```

or

```bash
bash -x ./script.sh
```

Print line number

```bash
# In Bash, $LINENO contains the line number where the script currently executing
echo "${LINENO}"
```

How to execute a bash command stored as a string with quotes and asterisk
https://stackoverflow.com/questions/2005192/how-to-execute-a-bash-command-stored-as-a-string-with-quotes-and-asterisk

```bash
eval ${cmd}
```

Online man page
https://tiswww.case.edu/php/chet/bash/bashtop.html

shellcheck disable
Ignoring all instances in a file (0.4.4+)
Add a directive at the top of the file:

```bash
#!/bin/sh
# shellcheck disable=SC2059
```

https://kvz.io/blog/2013/11/21/bash-best-practices/ 

Bash, find files in a safe way:

```bash
 while read -d $'\0' def_file; do                                                      
   def_files+=( "${def_file}" )                                                        
   kept_files+=( "'${def_file}'" )                                                     
 done < <(find "${cnx_base_path}" -regextype posix-egrep \                             
               -regex ".*(${KEEP_AND_ARC_REGEXP})" -type f -print0)
```

Bash process files
https://mywiki.wooledge.org/BashFAQ/020

```bash
# Bash
unset a i
while IFS= read -r -d '' file; do
  a[i++]="$file"
done < <(find /tmp -type f -print0)
```

How to count the number of a specific character in each line?
https://unix.stackexchange.com/questions/18736/how-to-count-the-number-of-a-specific-character-in-each-line#18742

```bash
tr -d -c '"\n' <<< ${line} | awk '{ print length; }'
```

 # join on empty string elements of an array
```
PARAMS=("?jql=labels=ogAlias:123456789+AND+createdDate+>+-1d"                             
        "&fields=summary,status,labels,created")                                          
function join_by { local IFS="$1"; shift; echo "$*"; }   # join on empty string elements of an array                   
URL=$(join_by '' "${PARAMS[@]}")                                           
```

xarg with bash cmd

```bash
gk hosts grafana --plain | awk '{print $1}' | xargs -P10 -n1 -I{} bash -c "curl -x socks5://localhost:1080 -s -o /dev/null -w '{} %{time_total} %{http_code}\n' 'https://{}/graphite/metrics/find?query=lax-prod1.derived.*'"
```

Logging function

```bash
function log {
  local lvl msg fmt
  lvl=$1 msg=$2
  fmt='+%Y-%m-%d %H:%M:%S'
  lg_date=$(date "${fmt}")
  if [[ "${lvl}" = "DIE" ]] ; then
    lvl="ERROR"
   echo "${lg_date} - ${lvl} - ${msg}" 
   exit 1
  else
    echo "${lg_date} - ${lvl} - ${msg}" 
  fi
}
```

while read heredoc

```bash
#!/bin/bash
while read -r kura job ; do

  echo "${kura} ${job}" 

done << EOF
kura1.r11a.04.lona.acme.net http://dm1.r3.03.lona.acme.net:9143/deploy-manager/v1/batch/b0e272a8b1619ab6adf0128cc07809ac29354ade
kura1.r11a.05.lona.acme.net http://dm1.r3.03.lona.acme.net:9143/deploy-manager/v1/batch/9095774410058e7bedb2e87777d1302ed2cb28c4
kura1.r12a.04.lona.acme.net http://dm1.r3.03.lona.acme.net:9143/deploy-manager/v1/batch/76802a74b866da7827ac513c8c6dcad566bcf4a8
kura1.r12a.05.lona.acme.net http://dm1.r3.03.lona.acme.net:9143/deploy-manager/v1/batch/64b1711ee7ef3fb42ce73beb5b75e9a3819e3de5
kura1.r13a.04.lona.acme.net http://dm1.r3.03.lona.acme.net:9143/deploy-manager/v1/batch/76802a74b866da7827ac513c8c6dcad566bcf4a8
EOF
```

regex
https://riptutorial.com/bash/example/19469/regex-matching

```bash
    pat='[^0-9]+([0-9]+)'
    s='I am a string with some digits 1024'
    [[ $s =~ $pat ]] # $pat must be unquoted
    echo "${BASH_REMATCH[0]}"
    echo "${BASH_REMATCH[1]}"
    # The 0th index in the BASH_REMATCH array is the total match
    # The i'th index in the BASH_REMATCH array is the i'th captured group, where i = 1, 2, 3 ...
```

Why you shouldn't parse the output of ls(1)

## curl 

### curl - send json with variables

```bash
curl -X POST \
  https://events.pagerduty.com/v2/enqueue \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "routing_key": "$PD_ROUTING_KEY",
  "event_action": "trigger",
  "payload": {
    "summary": "Test alert from cURL",
    "source": "my-app",
    "severity": "error"
  }
}
EOF
```
