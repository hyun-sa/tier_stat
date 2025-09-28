#!/bin/bash

usage() {
  echo "Usage: $(basename "$0") [-a] [-n interval] [-h]"
  echo
  echo "Summarizes or monitors memory usage per memory tier."
  echo
  echo "Options:"
  echo "  -a            Show detailed memory usage for each individual node within a tier."
  echo "  -n <seconds>  Run continuously, refreshing the output every <seconds>."
  echo "  -h            Display this help message and exit."
}

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

run_check() {
  local show_all_nodes=$1
  MT="/sys/devices/virtual/memory_tiering"

  for tier in "$MT"/memory_tier*; do
    [ -e "$tier" ] || continue
    tiername=$(basename "$tier")
    nodelist=$(cat "$tier"/nodelist 2>/dev/null || cat "$tier"/nodes 2>/dev/null)

    echo "[INFO] $tiername (nodes: $nodelist)"
    nodes=($(expand_nodes "$nodelist"))

    if [ "$show_all_nodes" = true ]; then
      printf "    %-8s | %'15s | %'15s | %'15s\n" "Node" "MemTotal (kB)" "MemUsed (kB)" "MemFree (kB)"
      echo "    -----------------------------------------------------------------------------"
    fi

    total=0; free=0
    for n in "${nodes[@]}"; do
      mi="/sys/devices/system/node/node${n}/meminfo"
      if [ -r "$mi" ]; then
        t=$(awk '/MemTotal/ {print $4}' "$mi")
        f=$(awk '/MemFree/  {print $4}' "$mi")
        
        if [ "$show_all_nodes" = true ]; then
          u=$((t - f))
          printf "    node%-4s | %'15d | %'15d | %'15d\n" "$n" "$t" "$u" "$f"
        fi

        total=$((total + t))
        free=$((free + f))
      fi
    done
    used=$((total - free))

    echo
    printf "Total MemTotal: %'d kB\n" "$total"
    printf "Total MemUsed : %'d kB\n" "$used"
    printf "Total MemFree : %'d kB\n\n" "$free"
  done
}

show_all_nodes=false
interval=""

while getopts ":an:h" opt; do
  case ${opt} in
    a)
      show_all_nodes=true
      ;;
    n)
      interval=$OPTARG
      ;;
    h)
      usage
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -n "$interval" ]]; then
  while true; do
    clear
    echo "--- Monitoring memory tiers (Refreshes every ${interval}s) ---"
    run_check "$show_all_nodes"
    printf "Press 'q' to quit..."
    read -t "$interval" -n 1 -s key
    if [[ "$key" == [qQ] ]]; then
        printf "\nExiting monitor mode.\n"
        exit 0
    fi
  done
else
  run_check "$show_all_nodes"
fi
