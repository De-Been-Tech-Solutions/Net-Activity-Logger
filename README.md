# Net-Activity-Logger
A lightweight Bash script to monitor network throughput and active peers on Linux.  Originally built to diagnose Steam download throttling on gigabit connections, but works with any process or all traffic.

Features:

1. Logs per-second throughput (MB/s) on a chosen network interface.

2. Captures active TCP peers (with optional process filter).

3. Outputs in CSV-style format (easy to parse, graph, or upload as .txt).

4. Works on any modern Linux distro (tested Fedora/Nobara/Ubuntu).

Usage
chmod +x net_log.sh
./net_log.sh <iface> [interval_seconds] [process_filter] | tee output.txt

Arguments

<iface> → network interface (e.g. enp3s0 for Ethernet, wlp4s0 for Wi-Fi).

[interval_seconds] → optional, defaults to 1.

[process_filter] → optional, defaults to steam.

steam → log only Steam/steamwebhelper traffic.

xivlauncher → log only FFXIV’s XIVLauncher traffic.

all → log all established connections.

Examples
Monitor Steam
./net_log.sh enp3s0 1 steam | tee steam_log.txt


Sample output:

timestamp,iface,mb_per_s,peers
2025-08-24T17:07:10+09:30,enp3s0,11.46,"23.11.170.102:443 146.75.103.52:443"
2025-08-24T17:07:11+09:30,enp3s0,11.52,"202.130.202.97:443 23.60.149.116:443"

Monitor FFXIV (XIVLauncher)
./net_log.sh enp3s0 1 xivlauncher | tee ffxiv_log.txt

Monitor all traffic
./net_log.sh enp3s0 1 all | tee full_log.txt

Example Use Case

On a gigabit line:

Steam downloads cap at ~115 Mb/s.

FFXIV patcher and wget saturate ~900 Mb/s.

Logs show Steam is stuck regardless of IPv4/IPv6, region, or SteamCMD/GUI, while other apps perform normally.

License

This project is licensed under the GNU General Public License v3.0 (GPL-3.0).
You may freely use, modify, and share this script, but any derivative work must also be licensed under GPL-3.0.

See the LICENSE
 file for full details.
