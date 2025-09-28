# tier_stat

`tier_stat` is a simple Bash script that displays **memory usage per tier (Total / Used / Free)** on Linux systems that support memory tiering.

Modern Linux kernels (5.15+, especially 6.x) can manage heterogeneous memory (e.g., DRAM, PMEM, CXL) as **memory tiers**.  
This script reads from `/sys/devices/virtual/memory_tiering/` and NUMA node stats under `/sys/devices/system/node/node*/meminfo` to aggregate memory usage for each tier.

---

## 📦 Features
- Show **Total / Used / Free** per memory tier
- Automatically parses NUMA node lists (`nodelist`)
- Human-readable output (kB with thousand separators)
- Pure Bash + awk, no external dependencies

---

## 🛠️ Requirements
- Linux kernel 5.15+ (with memory tiering support)
- NUMA enabled (`/sys/devices/system/node/node*/meminfo` must exist)
- Bash and awk available

---

## 🚀 Usage

```bash
# 1. Clone repository
git clone https://github.com/<YOUR_ID>/tier_stat.git
cd tier_stat

# 2. Make it executable
chmod +x tier_stat.sh

# 3. Run
./tier_stat.sh

# HELP
./tier_stat.sh -h
Usage: tier_stat.sh [-a] [-n interval] [-h]

Summarizes or monitors memory usage per memory tier.

Options:
  -a            Show detailed memory usage for each individual node within a tier.
  -n <seconds>  Run continuously, refreshing the output every <seconds>.
  -h            Display this help message and exit.
```

## EXAMPLE
```bash
./tier_stat.sh 
[INFO] memory_tier4 (nodes: 0)
MemTotal: 131222908 kB
MemUsed : 53017256 kB
MemFree : 78205652 kB

[INFO] memory_tier480 (nodes: 1)
MemTotal: 263144264 kB
MemUsed : 2066284 kB
MemFree : 261077980 kB
```
