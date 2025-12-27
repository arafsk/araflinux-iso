# Remove git repositories and version control
find . -name ".github" -type d -exec rm -rf {} + 2>/dev/null
find . -name ".git" -type d -exec rm -rf {} + 2>/dev/null
find . -name ".gitignore" -type f -delete 2>/dev/null
find . -name ".gitmodules" -type f -delete 2>/dev/null
find . -name "LICENSE*" -type f -delete 2>/dev/null
find . -name "COPYING*" -type f -delete 2>/dev/null
find . -name "COPYRIGHT*" -type f -delete 2>/dev/null

# Remove temporary and cache files
find . -name "*.tmp" -type f -delete 2>/dev/null
find . -name "*.temp" -type f -delete 2>/dev/null
find . -name "*~" -type f -delete 2>/dev/null
find . -name "*.backup" -type f -delete 2>/dev/null
find . -name ".DS_Store" -type f -delete 2>/dev/null
find . -name "Thumbs.db" -type f -delete 2>/dev/null
find . -name "*.bak" -type f -delete 2>/dev/null

# Remove cache directories
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
find . -name ".cache" -type d -exec rm -rf {} + 2>/dev/null
find . -name "cache" -type d -exec rm -rf {} + 2>/dev/null

# Remove log files
find . -name "*.log" -type f -delete 2>/dev/null
find . -name "log" -type d -exec rm -rf {} + 2>/dev/null

# Remove broken symlinks
find . -type l ! -exec test -e {} \; -delete 2>/dev/null

# Remove large binary files that shouldn't be in git
find . -name "*.so" -type f -delete 2>/dev/null
find . -name "*.dylib" -type f -delete 2>/dev/null
find . -name "*.dll" -type f -delete 2>/dev/null
