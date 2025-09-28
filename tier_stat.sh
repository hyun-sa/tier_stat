#!/bin/bash


MT="/sys/devices/virtual/memory_tiering"

expand_nodes() {
  local s="$1"; local out=()
  IFS=, read -ra parts <<< "$s"
  for p in "${parts[@]}"; do
    if [[ "$p" == *-* ]]; then
      start=${p%-*}; end=${p#*-}
      for ((i=start;i<=end;i++)); do out+=($i); done
    else
      out+=($p)
    fi
  done
  printf "%s " "${out[@]}"
}

for tier in "$MT"/memory_tier*; do
  [ -e "$tier" ] || continue
  tiername=$(basename "$tier")
  nodelist=$(cat "$tier"/nodelist 2>/dev/null || cat "$tier"/nodes 2>/dev/null)

  echo "[INFO] $tiername (nodes: $nodelist)"
  nodes=($(expand_nodes "$nodelist"))

  total=0; free=0
  for n in "${nodes[@]}"; do
    mi="/sys/devices/system/node/node${n}/meminfo"
    if [ -r "$mi" ]; then
      t=$(awk '/MemTotal/ {print $4}' "$mi")
      f=$(awk '/MemFree/  {print $4}' "$mi")
      total=$((total + t))
      free=$((free + f))
    fi
  done
  used=$((total - free))

  printf "MemTotal: %'d kB\n" "$total"
  printf "MemUsed : %'d kB\n" "$used"
  printf "MemFree : %'d kB\n\n" "$free"
done

