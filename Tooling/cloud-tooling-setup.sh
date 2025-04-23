#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Base directories
TOOLS_DIR="$HOME/tools"
VENV_DIR="/opt/venv"
AZ_PWN_DIR="$TOOLS_DIR/az-pwn"

# Create base directories
echo -e "${GREEN}Creating base directories...${NC}"
mkdir -p "$TOOLS_DIR"
mkdir -p "$VENV_DIR"

# Function to clone and setup a tool
setup_tool() {
    local tool_name=$1
    local repo_url=$2
    local tool_dir="$TOOLS_DIR/$tool_name"
    
    echo -e "${YELLOW}Setting up $tool_name...${NC}"
    
    # Clone the repository
    if [ ! -d "$tool_dir" ]; then
        git clone "$repo_url" "$tool_dir"
    else
        echo -e "${YELLOW}$tool_name already exists, updating...${NC}"
        cd "$tool_dir"
        git pull
    fi
    
    # Create virtual environment
    if [ ! -d "$tool_dir/.venv" ]; then
        python3 -m venv "$tool_dir/.venv"
    fi
    
    # Activate virtual environment and install dependencies
    source "$tool_dir/.venv/bin/activate"
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install common dependencies
    pip install requests dnspython colorama
    
    # Install tool-specific dependencies
    if [ -f "$tool_dir/requirements.txt" ]; then
        pip install -r "$tool_dir/requirements.txt"
    fi
    
    deactivate
}

# Function to create a tool launcher
create_launcher() {
    local tool_name=$1
    local launcher_dir="$AZ_PWN_DIR/launchers"
    local launcher_file="$launcher_dir/$tool_name.sh"
    
    mkdir -p "$launcher_dir"
    
    cat > "$launcher_file" << EOF
#!/bin/bash
cd "$TOOLS_DIR/$tool_name"
source .venv/bin/activate
python3 $tool_name.py "\$@"
EOF
    
    chmod +x "$launcher_file"
}

# Create az-pwn directory structure
echo -e "${GREEN}Creating az-pwn directory structure...${NC}"
mkdir -p "$AZ_PWN_DIR/launchers"
mkdir -p "$AZ_PWN_DIR/scripts"

# Setup Python tools
echo -e "${GREEN}Setting up Python tools...${NC}"
setup_tool "azsubenum" "https://github.com/yuyudhn/AzSubEnum.git"
setup_tool "oh365userfinder" "https://github.com/dievus/Oh365UserFinder.git"
setup_tool "basicblobfinder" "https://github.com/joswr1ght/basicblobfinder.git"
setup_tool "omnispray" "https://github.com/0xZDH/Omnispray.git"

# Setup Ruby tools
echo -e "${GREEN}Setting up Ruby tools...${NC}"
setup_tool "username-anarchy" "https://github.com/urbanadventurer/username-anarchy.git"

# Create launchers
echo -e "${GREEN}Creating tool launchers...${NC}"
create_launcher "azsubenum"
create_launcher "oh365userfinder"
create_launcher "basicblobfinder"
create_launcher "omnispray"
create_launcher "username-anarchy"

# Create main launcher script
echo -e "${GREEN}Creating main launcher script...${NC}"
cat > "$AZ_PWN_DIR/az-pwn" << EOF
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to show help
show_help() {
    echo -e "${GREEN}Available tools:${NC}"
    echo "  azsubenum        - Azure subdomain enumeration"
    echo "  oh365userfinder  - Microsoft 365 user enumeration"
    echo "  basicblobfinder  - Azure Blob Storage enumeration"
    echo "  omnispray        - Modular spraying framework"
    echo "  username-anarchy - Username permutation generation"
    echo ""
    echo "Usage: az-pwn <tool-name> [arguments]"
}

# Check if tool name is provided
if [ -z "\$1" ]; then
    show_help
    exit 1
fi

# Get tool name and shift arguments
TOOL_NAME="\$1"
shift

# Check if tool exists
if [ ! -f "$AZ_PWN_DIR/launchers/\$TOOL_NAME.sh" ]; then
    echo -e "${RED}Error: Tool '\$TOOL_NAME' not found${NC}"
    show_help
    exit 1
fi

# Launch the tool
"$AZ_PWN_DIR/launchers/\$TOOL_NAME.sh" "\$@"
EOF

chmod +x "$AZ_PWN_DIR/az-pwn"

# Create symlink to az-pwn
echo -e "${GREEN}Creating symlink to az-pwn...${NC}"
sudo ln -sf "$AZ_PWN_DIR/az-pwn" /usr/local/bin/az-pwn

echo -e "${GREEN}Setup complete! You can now use 'az-pwn <tool-name>' to launch tools.${NC}"
echo -e "${YELLOW}Example: az-pwn azsubenum -b domain.com -t 10 -p 5${NC}" 
