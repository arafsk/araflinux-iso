#!/bin/bash

# Advanced System Cleaner Script
# Enhanced version with progress tracking, size reporting, and comprehensive cleanup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
TOTAL_SIZE_FREED=0
TOTAL_FILES_REMOVED=0
TOTAL_DIRS_REMOVED=0
DRY_RUN=false
VERBOSE=false
TARGET_DIR="."

# Function to display usage
usage() {
    echo -e "${CYAN}Advanced System Cleaner${NC}"
    echo "Usage: $0 [OPTIONS] [DIRECTORY]"
    echo ""
    echo "OPTIONS:"
    echo "  -d, --dry-run     Show what would be deleted without actually deleting"
    echo "  -v, --verbose     Show detailed output"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "DIRECTORY:"
    echo "  Target directory to clean (default: current directory)"
    echo ""
    echo "Example:"
    echo "  $0 -v ~/Downloads"
    echo "  $0 --dry-run /tmp"
}

# Function to convert bytes to human readable format
human_readable() {
    local bytes=$1
    if [ $bytes -ge 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1073741824" | bc)GB"
    elif [ $bytes -ge 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc)MB"
    elif [ $bytes -ge 1024 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc)KB"
    else
        echo "${bytes}B"
    fi
}

# Function to get file/directory size
get_size() {
    local path="$1"
    if [ -f "$path" ]; then
        stat -f%z "$path" 2>/dev/null || stat -c%s "$path" 2>/dev/null || echo 0
    elif [ -d "$path" ]; then
        du -sb "$path" 2>/dev/null | cut -f1 || echo 0
    else
        echo 0
    fi
}

# Function to show progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    printf "\r${BLUE}Progress: [${GREEN}"
    printf "%${filled}s" | tr ' ' '='
    printf "${NC}${BLUE}"
    printf "%${empty}s" | tr ' ' '-'
    printf "] ${percentage}%% (${current}/${total})${NC}"
}

# Function to log action
log_action() {
    local action="$1"
    local path="$2"
    local size="$3"
    
    if [ "$VERBOSE" = true ]; then
        echo -e "${GREEN}[$(date '+%H:%M:%S')] ${action}: ${path} (${size})${NC}"
    fi
}

# Function to remove files with progress tracking
remove_files() {
    local pattern="$1"
    local description="$2"
    local find_args="$3"
    
    echo -e "\n${YELLOW}🔍 Scanning for ${description}...${NC}"
    
    # First, count files to establish progress
    local files_array=()
    while IFS= read -r -d '' file; do
        files_array+=("$file")
    done < <(find "$TARGET_DIR" $find_args -print0 2>/dev/null)
    
    local total_files=${#files_array[@]}
    
    if [ $total_files -eq 0 ]; then
        echo -e "${CYAN}✓ No ${description} found${NC}"
        return
    fi
    
    echo -e "${CYAN}Found ${total_files} ${description}${NC}"
    
    local current=0
    local category_size=0
    local category_files=0
    
    for file in "${files_array[@]}"; do
        current=$((current + 1))
        show_progress $current $total_files
        
        if [ -e "$file" ]; then
            local size=$(get_size "$file")
            category_size=$((category_size + size))
            category_files=$((category_files + 1))
            
            if [ "$DRY_RUN" = true ]; then
                log_action "WOULD DELETE" "$file" "$(human_readable $size)"
            else
                log_action "DELETING" "$file" "$(human_readable $size)"
                if [ -f "$file" ]; then
                    rm -f "$file" 2>/dev/null || true
                elif [ -d "$file" ]; then
                    rm -rf "$file" 2>/dev/null || true
                    TOTAL_DIRS_REMOVED=$((TOTAL_DIRS_REMOVED + 1))
                fi
            fi
        fi
    done
    
    echo -e "\n${GREEN}✓ ${description}: ${category_files} items, $(human_readable $category_size) freed${NC}"
    TOTAL_SIZE_FREED=$((TOTAL_SIZE_FREED + category_size))
    TOTAL_FILES_REMOVED=$((TOTAL_FILES_REMOVED + category_files))
}

# Function to clean broken symlinks
clean_broken_symlinks() {
    echo -e "\n${YELLOW}🔍 Scanning for broken symlinks...${NC}"
    
    local broken_links=()
    while IFS= read -r -d '' link; do
        if [ ! -e "$link" ]; then
            broken_links+=("$link")
        fi
    done < <(find "$TARGET_DIR" -type l -print0 2>/dev/null)
    
    if [ ${#broken_links[@]} -eq 0 ]; then
        echo -e "${CYAN}✓ No broken symlinks found${NC}"
        return
    fi
    
    echo -e "${CYAN}Found ${#broken_links[@]} broken symlinks${NC}"
    
    local current=0
    for link in "${broken_links[@]}"; do
        current=$((current + 1))
        show_progress $current ${#broken_links[@]}
        
        if [ "$DRY_RUN" = true ]; then
            log_action "WOULD DELETE" "$link" "0B"
        else
            log_action "DELETING" "$link" "0B"
            rm -f "$link" 2>/dev/null || true
        fi
    done
    
    echo -e "\n${GREEN}✓ Broken symlinks: ${#broken_links[@]} items removed${NC}"
    TOTAL_FILES_REMOVED=$((TOTAL_FILES_REMOVED + ${#broken_links[@]}))
}

# Function to show initial directory analysis
analyze_directory() {
    echo -e "${PURPLE}📊 Analyzing directory: ${TARGET_DIR}${NC}"
    
    local total_size=$(du -sb "$TARGET_DIR" 2>/dev/null | cut -f1 || echo 0)
    local file_count=$(find "$TARGET_DIR" -type f 2>/dev/null | wc -l)
    local dir_count=$(find "$TARGET_DIR" -type d 2>/dev/null | wc -l)
    
    echo -e "${CYAN}📁 Total size: $(human_readable $total_size)${NC}"
    echo -e "${CYAN}📄 Files: $file_count${NC}"
    echo -e "${CYAN}📂 Directories: $dir_count${NC}"
}

# Function to show final summary
show_summary() {
    echo -e "\n${PURPLE}==================== CLEANUP SUMMARY ====================${NC}"
    echo -e "${GREEN}✓ Files removed: ${TOTAL_FILES_REMOVED}${NC}"
    echo -e "${GREEN}✓ Directories removed: ${TOTAL_DIRS_REMOVED}${NC}"
    echo -e "${GREEN}✓ Total space freed: $(human_readable $TOTAL_SIZE_FREED)${NC}"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}⚠️  This was a DRY RUN - nothing was actually deleted${NC}"
    fi
    
    echo -e "${PURPLE}=========================================================${NC}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            if [ -d "$1" ]; then
                TARGET_DIR="$1"
            else
                echo -e "${RED}Error: Directory '$1' does not exist${NC}"
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if bc is available for calculations
if ! command -v bc &> /dev/null; then
    echo -e "${YELLOW}Warning: 'bc' command not found. Size calculations may be less precise.${NC}"
fi

# Main execution
echo -e "${CYAN}🧹 Advanced System Cleaner Starting...${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN MODE - No files will be deleted${NC}"
fi

analyze_directory

echo -e "\n${BLUE}Starting cleanup process...${NC}"

# Git and version control cleanup
remove_files "" "Git repositories (.git directories)" "-name '.git' -type d"
remove_files "" "GitHub workflows (.github directories)" "-name '.github' -type d"
remove_files "" "Git ignore files" "-name '.gitignore' -type f"
remove_files "" "Git modules files" "-name '.gitmodules' -type f"
remove_files "" "Git attributes files" "-name '.gitattributes' -type f"
remove_files "" "SVN directories" "-name '.svn' -type d"
remove_files "" "Mercurial directories" "-name '.hg' -type d"
remove_files "" "CVS directories" "-name 'CVS' -type d"

# Temporary files cleanup
remove_files "" "Temporary files (*.tmp)" "-name '*.tmp' -type f"
remove_files "" "Temporary files (*.temp)" "-name '*.temp' -type f"
remove_files "" "Backup files (*~)" "-name '*~' -type f"
remove_files "" "Backup files (*.bak)" "-name '*.bak' -type f"
remove_files "" "Backup files (*.backup)" "-name '*.backup' -type f"
remove_files "" "Swap files (*.swp)" "-name '*.swp' -type f"
remove_files "" "Auto-save files (#*#)" "-name '#*#' -type f"

# System files cleanup
remove_files "" "macOS .DS_Store files" "-name '.DS_Store' -type f"
remove_files "" "Windows Thumbs.db files" "-name 'Thumbs.db' -type f"
remove_files "" "Windows desktop.ini files" "-name 'desktop.ini' -type f"
remove_files "" "Icon files" "-name 'Icon?' -type f"

# Cache directories cleanup
remove_files "" "Python cache (__pycache__)" "-name '__pycache__' -type d"
remove_files "" "Generic cache directories" "-name '.cache' -type d"
remove_files "" "Cache directories" "-name 'cache' -type d"
remove_files "" "Node modules cache" "-name '.npm' -type d"
remove_files "" "Yarn cache" "-name '.yarn-cache' -type d"
remove_files "" "pip cache" "-name '.pip' -type d"

# Log files cleanup
remove_files "" "Log files (*.log)" "-name '*.log' -type f"
remove_files "" "Log directories" "-name 'log' -type d -o -name 'logs' -type d"

# History files cleanup (potentially sensitive)
remove_files "" "History files" "-name '.*_history' -type f"
remove_files "" "Shell history files" "-name '.bash_history' -type f -o -name '.zsh_history' -type f -o -name '.fish_history' -type f"

# Binary files cleanup
remove_files "" "Shared libraries (*.so)" "-name '*.so' -type f"
remove_files "" "macOS dynamic libraries (*.dylib)" "-name '*.dylib' -type f"
remove_files "" "Windows DLL files (*.dll)" "-name '*.dll' -type f"
remove_files "" "Object files (*.o)" "-name '*.o' -type f"
remove_files "" "Archive files (*.a)" "-name '*.a' -type f"

# Development files cleanup
remove_files "" "Core dump files" "-name 'core' -type f -o -name 'core.*' -type f"
remove_files "" "Editor backup files" "-name '*.orig' -type f"
remove_files "" "Patch reject files" "-name '*.rej' -type f"

# License and documentation cleanup
remove_files "" "License files" "-name 'LICENSE*' -type f"
remove_files "" "Copying files" "-name 'COPYING*' -type f"
remove_files "" "Copyright files" "-name 'COPYRIGHT*' -type f"
remove_files "" "Authors files" "-name 'AUTHORS*' -type f"
remove_files "" "Contributors files" "-name 'CONTRIBUTORS*' -type f"

# IDE and editor files cleanup
remove_files "" "Visual Studio Code settings" "-name '.vscode' -type d"
remove_files "" "IntelliJ IDEA files" "-name '.idea' -type d"
remove_files "" "Sublime Text files" "-name '*.sublime-*' -type f"
remove_files "" "Vim files" "-name '*.vim' -type f"
remove_files "" "Emacs files" "-name '*~' -type f"

# Build directories cleanup
remove_files "" "Build directories" "-name 'build' -type d"
remove_files "" "Distribution directories" "-name 'dist' -type d"
remove_files "" "Target directories (Maven/Gradle)" "-name 'target' -type d"
remove_files "" "Output directories" "-name 'out' -type d"

# Package manager files
remove_files "" "Node modules" "-name 'node_modules' -type d"
remove_files "" "Bower components" "-name 'bower_components' -type d"
remove_files "" "Composer vendor" "-name 'vendor' -type d"

# Clean broken symlinks last
clean_broken_symlinks

# Show final summary
show_summary

echo -e "\n${GREEN}🎉 Cleanup completed successfully!${NC}"