#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Cleaning up Azure red team tooling environment...${NC}"

# Remove tool directories
echo -e "${YELLOW}Removing tool directories...${NC}"
rm -rf ~/tools/az-pwn
rm -rf ~/tools/azsubenum
rm -rf ~/tools/oh365userfinder
rm -rf ~/tools/basicblobfinder
rm -rf ~/tools/omnispray
rm -rf ~/tools/username-anarchy

# Remove symlink
echo -e "${YELLOW}Removing symlink...${NC}"
sudo rm -f /usr/local/bin/az-pwn

# Remove virtual environments
echo -e "${YELLOW}Removing virtual environments...${NC}"
rm -rf ~/tools/*/.venv

# Remove tools directory if empty
if [ -z "$(ls -A ~/tools)" ]; then
    echo -e "${YELLOW}Removing empty tools directory...${NC}"
    rm -rf ~/tools
fi

echo -e "${GREEN}Cleanup complete! You can now run azure-cloud-tooling-setup.sh for a fresh installation.${NC}" 
