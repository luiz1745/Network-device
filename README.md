# 🕵️ Network Detective

A Bash script that discovers devices on your local network and gathers basic information about each one: open ports, running services, operating system guesses, and service banners.

Built for Kali Linux and other Debian-based distributions.

> ⚠️ **Legal disclaimer:** Use this tool **only on networks you own or have explicit written permission to test**. Scanning networks without authorization may be illegal in your country. The author is not responsible for misuse.

---

## ✨ Features

- 🔎 **Multi-technique host discovery** using `arp-scan`, `netdiscover`, `nmap` ping scan, and a full ping sweep to wake up sleeping devices
- 🌐 **Automatic network detection** from your routing table (falls back to `192.168.1.0/24`)
- 🚪 **Port scan** of the top 20 most common ports on every host found
- 🧪 **Service and version detection** (`nmap -sV`)
- 💻 **OS fingerprinting** (`nmap -O`)
- 🏷️ **Banner grabbing** on common ports (HTTP, SSH, FTP, SMB, RDP, MySQL, etc.)
- 🤔 **Basic device guessing** (web server, Linux/SSH host, Windows machine, printer, IoT/mobile)
- 📁 **Organized output**: every scan is saved in its own timestamped folder
- 📊 **Final summary report** printed in the terminal

---

## 📋 Requirements

- Linux (tested on Kali Linux)
- Root privileges (`sudo`), required by `arp-scan`, `netdiscover`, and `nmap -O`
- The following tools:
  - `nmap`
  - `arp-scan`
  - `netdiscover`
  - `curl`
  - `netcat` (`nc`)

The script checks for `nmap`, `arp-scan`, `netdiscover`, and `curl` and tries to install any that are missing using `apt`. Make sure `netcat` is installed too:

```bash
sudo apt update && sudo apt install -y nmap arp-scan netdiscover curl netcat-traditional
```

---

## 🚀 Installation

```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
chmod +x network_scanner.sh
```

Or just save the script manually:

```bash
nano network_scanner.sh   # paste the code, then Ctrl+X, Y, Enter
chmod +x network_scanner.sh
```

---

## ▶️ Usage

```bash
sudo ./network_scanner.sh
```

No arguments are needed. The script detects your network automatically and runs the whole workflow.

---

## ⚙️ How it works

1. **Setup**: prints a banner, checks dependencies, detects your network, and creates the results folder.
2. **Discovery** (4 steps):
   1. `arp-scan --localnet`
   2. `netdiscover` in passive print mode
   3. `nmap -sn` ping scan
   4. Ping sweep of all 254 addresses, followed by a second `arp-scan`
3. **IP extraction**: merges all results and removes duplicates.
4. **Device analysis**: for each IP it runs a port scan, service detection, OS detection, and banner grabbing, then tries to guess the device type.
5. **Report**: prints the network summary and the list of devices with their number of open ports.

---

## 📂 Output structure

Each run creates a folder named `network_scan_YYYYMMDD_HHMMSS/`:

```
network_scan_20261018_120000/
├── arp_scan.txt          # First ARP scan results
├── netdiscover.txt       # Netdiscover results
├── nmap_ping.txt         # Nmap ping scan results
├── arp_final.txt         # ARP scan after the ping sweep
├── all_ips.txt           # Unique list of discovered IPs
└── devices/
    └── <ip>/
        ├── nmap_basic.txt     # Top 20 ports scan
        ├── nmap_services.txt  # Service and version detection
        ├── nmap_os.txt        # OS detection
        ├── banners.txt        # Banner grabbing results
        └── web_info.txt       # HTTP headers (if port 80 is open)
```

---

## 🖥️ Example output

```
╔══════════════════════════════════════╗
║         NETWORK DETECTIVE 🕵️‍♂️       ║
║    Scanner de Rede Avançado          ║
╚══════════════════════════════════════╝

[+] Verificando dependências...
[+] Descobrindo rede local...
[+] Rede detectada: 192.168.1.0/24
[1/4] 🎯 Escaneando com ARP-SCAN...
...
📊 RESUMO DA REDE:
Rede escaneada: 192.168.1.0/24
Total de IPs encontrados: 12
```

---

## ⚠️ Known limitations

- 🔊 **Noisy**: it generates a lot of traffic and will likely trigger IDS/IPS and firewall alerts.
- 🐢 **Slow on large networks**: devices are analyzed one at a time.
- 🌐 **Local networks only**: designed for a single local subnet.
- 🎯 **Device identification is a guess**: it is based only on open ports and may be wrong.

---

## 🛣️ Possible improvements

- Command-line arguments (target network, output folder, port range)
- Faster scanning with parallel analysis
- HTML or JSON report export
- Better device fingerprinting using MAC vendor lookup

---

## 📄 License

Choose a license for your project (for example, [MIT](https://choosealicense.com/licenses/mit/)) and add a `LICENSE` file.

---

## 👤 Author

Created by **Luiz**.
