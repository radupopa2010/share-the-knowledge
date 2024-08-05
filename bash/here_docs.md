
'EOF' = do NOT interpret variables or commands in here doc
 EOF  = please interpret variables and cmds



```bash
cat << 'EOF' > fileName.extension

content here

EOF


```

example 

```bash
cat << 'EOF' > traffic-dump-clients.sh
#!/bin/bash
while : ; do
  nohup timeout 3600 tcpdump -Q in | grep  -o -P "IP .* >" | cut -d ' ' -f2 > clients.txt
  sort -u clients.txt >  "client-hosts-2019-09-24_15:07:58.txt"
  echo "" > clients.txt
done
EOF
```