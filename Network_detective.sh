#!/bin/bash

echo "🌐 Upload para GitHub - MODO FÁCIL 🚀"

# Pasta do projeto
mkdir -p ~/network-detective
cd ~/network-detective

# Criar arquivo do script
cat > network_detective.sh << 'EOF'
#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
echo -e "${CYAN}"
echo "╔══════════════════════════════════════╗"
echo "║         NETWORK DETECTIVE 🕵️‍♂️       ║"
echo "║    Scanner de Rede Avançado          ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}[+] Este script está versionado no GitHub!${NC}"
echo -e "${GREEN}[+] Use sempre com permissão!${NC}"

# [RESTANTE DO SEU SCRIPT AQUI - COLE A PARTE QUE FALTA]
# Cole aqui o resto do código do network_detective.sh

EOF

# Criar README
cat > README.md << 'EOF'
# Network Detective 🕵️‍♂️

Scanner de rede avançado para Kali Linux.

## 🚀 Como usar:
```bash
cd network-detective
sudo ./network_detective.sh
