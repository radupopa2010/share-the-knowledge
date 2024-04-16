```
echo 'show tables' | curl 'http://localhost:8123/?query=' --data-binary @-  | grep relayer_useroperations_1
relayer_useroperations_1
```


```
echo 'show tables' | curl --user clickhouse_operator  'http://34.139.121.219:8123/?query=' --data-binary @-
```
