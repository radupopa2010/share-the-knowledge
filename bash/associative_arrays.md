
### Create array
```bash
declare -A colors
colors["red"]="#ff0000"
colors["green"]="#00ff00"
colors["blue"]="#0000ff"
```

### Looping in associative arrays
```bash
declare -A colors
colors["red"]="#ff0000"
colors["green"]="#00ff00"
colors["blue"]="#0000ff"

for i in "${!colors[@]}"; do
  echo "key : $i"
  echo "value: ${colors[$i]}"
done
```

`"${!array[@]}"` expands into the list of array indexes rather than the list 
of array elements.