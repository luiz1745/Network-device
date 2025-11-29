🕵️‍♂️ NETWORK DETECTIVE - CÓDIGO COMPLETO
bash
#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${CYAN}"
echo "╔══════════════════════════════════════╗"
echo "║         NETWORK DETECTIVE 🕵️‍♂️       ║"
echo "║    Scanner de Rede Avançado          ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

# Função para verificar se comando existe
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}[ERRO] Comando $1 não encontrado. Instalando...${NC}"
        sudo apt update && sudo apt install -y $1
    fi
}

# Verificar dependências
echo -e "${YELLOW}[+] Verificando dependências...${NC}"
check_command nmap
check_command arp-scan
check_command netdiscover
check_command curl

# Descobrir a rede automaticamente
echo -e "${YELLOW}[+] Descobrindo rede local...${NC}"
NETWORK=$(ip route | grep -oP '(\d+\.\d+\.\d+)\.\d+/\d+' | head -1)
if [ -z "$NETWORK" ]; then
    NETWORK="192.168.1.0/24"
    echo -e "${RED}[!] Rede não detectada, usando padrão: $NETWORK${NC}"
else
    echo -e "${GREEN}[+] Rede detectada: $NETWORK${NC}"
fi

# Criar diretório para resultados
RESULTS_DIR="network_scan_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

# Função para escanear com múltiplas técnicas
scan_network() {
    echo -e "${BLUE}[1/4] 🎯 Escaneando com ARP-SCAN...${NC}"
    sudo arp-scan --localnet --retry=5 > "$RESULTS_DIR/arp_scan.txt"
    
    echo -e "${BLUE}[2/4] 🎯 Escaneando com NETDISCOVER...${NC}"
    sudo netdiscover -r $NETWORK -P > "$RESULTS_DIR/netdiscover.txt"
    
    echo -e "${BLUE}[3/4] 🎯 Escaneando com NMAP (ping scan)...${NC}"
    nmap -sn $NETWORK > "$RESULTS_DIR/nmap_ping.txt"
    
    echo -e "${BLUE}[4/4] 🎯 Ativando dispositivos com ping...${NC}"
    # Ping em toda a rede para ativar dispositivos
    for ip in {1..254}; do
        ping -c 1 -W 1 ${NETWORK%.*}.$ip &> /dev/null &
    done
    wait
    
    # Scan final com todos ativos
    echo -e "${BLUE}[+] Scan final com dispositivos ativos...${NC}"
    sudo arp-scan --localnet --retry=3 > "$RESULTS_DIR/arp_final.txt"
}

# Função para extrair IPs únicos
extract_ips() {
    echo -e "${YELLOW}[+] Extraindo IPs únicos...${NC}"
    
    # Combinar todos os IPs encontrados
    cat "$RESULTS_DIR/arp_scan.txt" "$RESULTS_DIR/netdiscover.txt" "$RESULTS_DIR/nmap_ping.txt" "$RESULTS_DIR/arp_final.txt" 2>/dev/null | \
    grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | \
    sort -u | grep "${NETWORK%.*}" > "$RESULTS_DIR/all_ips.txt"
    
    IP_COUNT=$(wc -l < "$RESULTS_DIR/all_ips.txt")
    echo -e "${GREEN}[+] Encontrados $IP_COUNT IPs únicos${NC}"
}

# Função para analisar cada dispositivo
analyze_devices() {
    echo -e "${YELLOW}[+] Analisando cada dispositivo...${NC}"
    
    while read -r ip; do
        if [ -n "$ip" ]; then
            echo -e "${PURPLE}"
            echo "┌─────────────────────────────────────"
            echo "│ 🔍 ANALISANDO: $ip"
            echo "└─────────────────────────────────────"
            echo -e "${NC}"
            
            # Criar diretório para o IP
            mkdir -p "$RESULTS_DIR/devices/$ip"
            
            # Scan básico do IP
            echo -e "${CYAN}[+] Scan básico...${NC}"
            nmap -sS --top-ports 20 $ip > "$RESULTS_DIR/devices/$ip/nmap_basic.txt"
            cat "$RESULTS_DIR/devices/$ip/nmap_basic.txt"
            
            # Detecção de serviços
            echo -e "${CYAN}[+] Detecção de serviços...${NC}"
            nmap -sV --version-intensity 5 $ip > "$RESULTS_DIR/devices/$ip/nmap_services.txt" 2>/dev/null &
            
            # Detecção de OS
            echo -e "${CYAN}[+] Detecção de sistema...${NC}"
            nmap -O $ip > "$RESULTS_DIR/devices/$ip/nmap_os.txt" 2>/dev/null &
            
            # Banner grabbing em portas comuns
            echo -e "${CYAN}[+] Banner grabbing...${NC}"
            for port in 80 443 22 21 23 53 110 135 139 143 445 993 995 1723 3306 3389 5900 8080; do
                timeout 2 nc -zv $ip $port &>/dev/null && {
                    echo "Porta $port: ABERTA" >> "$RESULTS_DIR/devices/$ip/banners.txt"
                    timeout 3 nc $ip $port < /dev/null >> "$RESULTS_DIR/devices/$ip/banners.txt" 2>&1
                    echo "" >> "$RESULTS_DIR/devices/$ip/banners.txt"
                } &
            done
            
            wait
            
            # Mostrar resultados resumidos
            echo -e "${GREEN}[+] Resumo do dispositivo $ip:${NC}"
            grep -E "(open|filtered|closed)" "$RESULTS_DIR/devices/$ip/nmap_basic.txt" | head -10
            
            # Tentar identificar dispositivo
            identify_device "$ip"
            
            echo ""
        fi
    done < "$RESULTS_DIR/all_ips.txt"
}

# Função para tentar identificar o tipo de dispositivo
identify_device() {
    local ip=$1
    local ports=$(grep -c "open" "$RESULTS_DIR/devices/$ip/nmap_basic.txt" 2>/dev/null)
    
    echo -e "${YELLOW}[?] Tentando identificar dispositivo...${NC}"
    
    # Verificar portas específicas
    if grep -q "80/open" "$RESULTS_DIR/devices/$ip/nmap_basic.txt" 2>/dev/null; then
        echo -e "  🌐 ${GREEN}Possível servidor WEB${NC}"
        # Tentar pegar header HTTP
        timeout 3 curl -I "http://$ip" 2>/dev/null | head -5 >> "$RESULTS_DIR/devices/$ip/web_info.txt"
    fi
    
    if grep -q "22/open" "$RESULTS_DIR/devices/$ip/nmap_basic.txt" 2>/dev/null; then
        echo -e "  💻 ${GREEN}Possível servidor LINUX/SSH${NC}"
    fi
    
    if grep -q "445/open\|139/open" "$RESULTS_DIR/devices/$ip/nmap_basic.txt" 2>/dev/null; then
        echo -e "  🪟 ${GREEN}Possível dispositivo WINDOWS${NC}"
    fi
    
    if grep -q "9100/open" "$RESULTS_DIR/devices/$ip/nmap_basic.txt" 2>/dev/null; then
        echo -e "  🖨️ ${GREEN}Possível IMPRESSORA${NC}"
    fi
    
    if [ "$ports" -eq 0 ]; then
        echo -e "  📱 ${GREEN}Possível dispositivo IoT ou Mobile${NC}"
    fi
}

# Função para gerar relatório final
generate_report() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════╗"
    echo "║           RELATÓRIO FINAL           ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${GREEN}📊 RESUMO DA REDE:${NC}"
    echo -e "Rede escaneada: $NETWORK"
    echo -e "Total de IPs encontrados: $IP_COUNT"
    echo -e "Diretório com resultados: $RESULTS_DIR/"
    echo ""
    
    echo -e "${YELLOW}📋 LISTA DE DISPOSITIVOS:${NC}"
    while read -r ip; do
        if [ -n "$ip" ]; then
            ports=$(grep -c "open" "$RESULTS_DIR/devices/$ip/nmap_basic.txt" 2>/dev/null || echo "0")
            echo -e "  $ip - $ports porta(s) aberta(s)"
        fi
    done < "$RESULTS_DIR/all_ips.txt"
    
    echo ""
    echo -e "${BLUE}🎯 PRÓXIMOS PASSOS:${NC}"
    echo "1. Ver arquivos em: $RESULTS_DIR/"
    echo "2. Analisar detalhes em: $RESULTS_DIR/devices/[IP]/"
    echo "3. Usar 'cat $RESULTS_DIR/devices/[IP]/nmap_services.txt' para ver serviços"
    echo "4. Usar Wireshark para análise de tráfego específico"
}

# Execução principal
main() {
    echo -e "${YELLOW}[+] Iniciando escaneamento em: $(date)${NC}"
    
    scan_network
    extract_ips
    analyze_devices
    generate_report
    
    echo -e "${GREEN}"
    echo "✅ Escaneamento completo!"
    echo "📁 Todos os resultados salvos em: $RESULTS_DIR/"
    echo -e "${NC}"
}

# Executar script
main
🚀 PARA USAR AGORA:
Salve no Kali:

bash
cd ~
nano network_scanner.sh
Cole o código acima → Ctrl+X → Y → Enter

Execute:

bash
chmod +x network_scanner.sh
sudo ./network_scanner.sh

