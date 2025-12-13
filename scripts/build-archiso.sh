#!/bin/bash

##################################################################################################################
# ArafLinux ISO Builder
# Modified: Enhanced version with improved structure and readability
#
# WARNING: DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
##################################################################################################################

set -e  # Exit on error
set -o pipefail  # Catch errors in pipes

##################################################################################################################
# CONFIGURATION
##################################################################################################################

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Desktop Configuration
readonly DESKTOP=""
readonly DM_DESKTOP=""
readonly ARAFLINUX_VERSION="$(date +%Y.%m.%d)"
readonly ISO_LABEL="ArafLinux_${ARAFLINUX_VERSION}_x86_64.iso"

# Version Requirements
readonly ARCHISO_REQUIRED_VERSION="archiso 83-1"

# Directory Configuration
readonly BUILD_FOLDER="${HOME}//BUILD/iso-build"
readonly OUT_FOLDER="${HOME}/BUILD/iso-out"
readonly ISO_SOURCE="${HOME}/BUILD/araflinux-iso/iso/cinneman-releng/"

# Repository Configuration
readonly PERSONAL_REPO=false

# Package Configuration
readonly PACKAGE_NAME="archiso"

# Color Codes
readonly COLOR_GREEN=2
readonly COLOR_RED=1
readonly COLOR_RESET=0

##################################################################################################################
# UTILITY FUNCTIONS
##################################################################################################################

# Print colored section header
print_header() {
    local phase=$1
    local title=$2
    echo
    echo "##################################################################"
    tput setaf ${COLOR_GREEN}
    echo "Phase ${phase}: ${title}"
    tput sgr0
    echo "##################################################################"
    echo
}

# Print error message
print_error() {
    local message=$1
    tput setaf ${COLOR_RED}
    echo "##################################################################"
    echo "ERROR: ${message}"
    echo "##################################################################"
    tput sgr0
}

# Print success message
print_success() {
    local message=$1
    tput setaf ${COLOR_GREEN}
    echo "##################################################################"
    echo "SUCCESS: ${message}"
    echo "##################################################################"
    tput sgr0
}

# Print info message
print_info() {
    local key=$1
    local value=$2
    printf "%-40s : %s\n" "${key}" "${value}"
}

# Check if package is installed
is_package_installed() {
    local package=$1
    pacman -Qi "${package}" &> /dev/null
}

# Install package if not present
ensure_package_installed() {
    local package=$1
    
    if is_package_installed "${package}"; then
        echo "✓ ${package} is already installed"
        return 0
    fi
    
    echo "Installing ${package}..."
    sudo pacman -S --noconfirm "${package}"
    
    if is_package_installed "${package}"; then
        print_success "${package} has been installed"
        return 0
    else
        print_error "${package} installation failed"
        exit 1
    fi
}

# Verify archiso version
verify_archiso_version() {
    local current_version=$(sudo pacman -Q archiso)
    
    if [ "${current_version}" == "${ARCHISO_REQUIRED_VERSION}" ]; then
        print_success "Archiso version is correct (${current_version})"
        return 0
    else
        echo "⚠ Warning: Archiso version mismatch"
        echo "Current version: ${current_version}"
        echo "Required version: ${ARCHISO_REQUIRED_VERSION}"
        echo "Continuing anyway... (Press Ctrl+C to cancel)"
        sleep 3
        return 0
    fi
}

# Clean directory safely
clean_directory() {
    local dir=$1
    if [ -d "${dir}" ]; then
        echo "Cleaning directory: ${dir}"
        sudo rm -rf "${dir}"
        echo "✓ Directory cleaned"
    fi
}

# Create directory if not exists
ensure_directory() {
    local dir=$1
    if [ ! -d "${dir}" ]; then
        mkdir -p "${dir}"
        echo "✓ Created directory: ${dir}"
    fi
}

##################################################################################################################
# PHASE FUNCTIONS
##################################################################################################################

phase1_display_configuration() {
    print_header "1" "Configuration Overview"
    
    local archiso_version=$(sudo pacman -Q archiso)
    
    echo "##################################################################"
    print_info "Desktop" "${DESKTOP}"
    print_info "Build Version" "${ARAFLINUX_VERSION}"
    print_info "ISO Label" "${ISO_LABEL}"
    print_info "Current Archiso Version" "${archiso_version}"
    print_info "Required Archiso Version" "${ARCHISO_REQUIRED_VERSION}"
    print_info "Build Folder" "${BUILD_FOLDER}"
    print_info "Output Folder" "${OUT_FOLDER}"
    print_info "ISO Source" "${ISO_SOURCE}"
    print_info "Personal Repository" "${PERSONAL_REPO}"
    echo "##################################################################"
    
    verify_archiso_version
}

phase2_setup_archiso() {
    print_header "2" "Archiso Setup"
    
    echo "→ Checking archiso installation..."
    ensure_package_installed "${PACKAGE_NAME}"
    
    echo
    echo "→ Saving archiso version to readme..."
    local archiso_version=$(sudo pacman -Q archiso)
    if [ -f "${PROJECT_ROOT}/archiso.readme" ]; then
        sudo sed -i "s/\(^archiso-version=\).*/\1${archiso_version}/" "${PROJECT_ROOT}/archiso.readme"
    else
        echo "archiso-version=${archiso_version}" > "${PROJECT_ROOT}/archiso.readme"
    fi
    
    echo
    echo "→ Making mkarchiso verbose..."
    sudo sed -i 's/quiet="y"/quiet="n"/g' /usr/bin/mkarchiso
    
    print_success "Archiso setup complete"
}

phase3_prepare_build_folder() {
    print_header "3" "Build Folder Preparation"
    
    echo "→ Cleaning old build folder..."
    clean_directory "${BUILD_FOLDER}"
    
    echo
    echo "→ Creating new build folder..."
    ensure_directory "${BUILD_FOLDER}"
    
    echo
    echo "→ Checking if custom ISO source exists..."
    if [ -d "${ISO_SOURCE}" ] && [ "$(ls -A ${ISO_SOURCE})" ]; then
        echo "✓ Custom ISO source found at: ${ISO_SOURCE}"
        echo "→ Copying custom ISO files to build folder..."
        cp -r "${ISO_SOURCE}"/* "${BUILD_FOLDER}/"
    else
        echo "⚠ Custom ISO source not found or empty"
        echo "→ Copying archiso releng profile as base..."
        cp -r /usr/share/archiso/configs/releng/* "${BUILD_FOLDER}/"
        echo "✓ Base archiso profile copied"
        echo ""
        echo "NOTE: You should customize the files in ${BUILD_FOLDER}/"
        echo "      or create your custom ISO structure in ${ISO_SOURCE}/"
    fi
    
    print_success "Build folder prepared"
}

phase4_configure_packages() {
    print_header "4" "Package Configuration"
    
    # Ensure airootfs structure exists
    ensure_directory "${BUILD_FOLDER}/airootfs/etc/skel"
    
    echo "→ Configuring .bashrc..."
    # Check if custom .bashrc exists
    if [ -f "${ISO_SOURCE}/airootfs/etc/skel/.bashrc" ]; then
        echo "  • Using custom .bashrc from ISO source"
        cp "${ISO_SOURCE}/airootfs/etc/skel/.bashrc" "${BUILD_FOLDER}/airootfs/etc/skel/.bashrc"
    elif [ -f "/etc/skel/.bashrc" ]; then
        echo "  • Using system default .bashrc"
        cp /etc/skel/.bashrc "${BUILD_FOLDER}/airootfs/etc/skel/.bashrc"
    else
        echo "  • Creating basic .bashrc"
        cat > "${BUILD_FOLDER}/airootfs/etc/skel/.bashrc" << 'EOF'
# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
EOF
    fi
    echo "✓ .bashrc configured"
    
    echo
    echo "→ Configuring packages.x86_64..."
    if [ -f "${ISO_SOURCE}/packages.x86_64" ]; then
        echo "  • Using custom package list"
        cp -f "${ISO_SOURCE}/packages.x86_64" "${BUILD_FOLDER}/packages.x86_64"
    else
        echo "  • Using default archiso package list"
        # The releng profile already has packages.x86_64
    fi
    
    if [ "${PERSONAL_REPO}" = true ]; then
        echo
        echo "→ Adding personal repository packages..."
        if [ -f "${ISO_SOURCE}/packages-personal-repo.x86_64" ]; then
            printf "\n" >> "${BUILD_FOLDER}/packages.x86_64"
            cat "${ISO_SOURCE}/packages-personal-repo.x86_64" >> "${BUILD_FOLDER}/packages.x86_64"
        fi
        
        echo "→ Configuring personal repository in pacman.conf..."
        if [ -f "${SCRIPT_DIR}/personal-repo" ]; then
            printf "\n" >> "${BUILD_FOLDER}/pacman.conf"
            printf "\n" >> "${BUILD_FOLDER}/airootfs/etc/pacman.conf"
            cat "${SCRIPT_DIR}/personal-repo" >> "${BUILD_FOLDER}/pacman.conf"
            cat "${SCRIPT_DIR}/personal-repo" >> "${BUILD_FOLDER}/airootfs/etc/pacman.conf"
        fi
    fi
    
    print_success "Package configuration complete"
}

phase5_update_metadata() {
    print_header "5" "Metadata Update"
    
    echo "→ Updating profiledef.sh..."
    if [ -f "${BUILD_FOLDER}/profiledef.sh" ]; then
        # Update ISO name
        sed -i 's/iso_name=.*/iso_name="araflinux"/' "${BUILD_FOLDER}/profiledef.sh"
        sed -i 's/iso_label=.*/iso_label="ARAFLINUX_$(date +%Y%m)"/' "${BUILD_FOLDER}/profiledef.sh"
        sed -i 's/iso_publisher=.*/iso_publisher="ArafLinux <https:\/\/araflinux.org>"/' "${BUILD_FOLDER}/profiledef.sh"
        sed -i 's/iso_application=.*/iso_application="ArafLinux Live\/Rescue CD"/' "${BUILD_FOLDER}/profiledef.sh"
        echo "✓ profiledef.sh updated"
    fi
    
    echo
    echo "→ Updating hostname..."
    ensure_directory "${BUILD_FOLDER}/airootfs/etc"
    echo "araflinux" > "${BUILD_FOLDER}/airootfs/etc/hostname"
    echo "✓ Hostname set to 'araflinux'"
    
    echo
    echo "→ Adding build timestamp..."
    local date_build=$(date)
    echo "Build timestamp: ${date_build}"
    
    # Create or update dev-rel file
    if [ -f "${BUILD_FOLDER}/airootfs/etc/dev-rel" ]; then
        if grep -q "^ISO_BUILD=" "${BUILD_FOLDER}/airootfs/etc/dev-rel"; then
            sed -i "s/^ISO_BUILD=.*/ISO_BUILD=\"${date_build}\"/" "${BUILD_FOLDER}/airootfs/etc/dev-rel"
        else
            echo "ISO_BUILD=\"${date_build}\"" >> "${BUILD_FOLDER}/airootfs/etc/dev-rel"
        fi
    else
        cat > "${BUILD_FOLDER}/airootfs/etc/dev-rel" << EOF
NAME="ArafLinux"
PRETTY_NAME="ArafLinux"
ID=araflinux
BUILD_ID=rolling
HOME_URL="https://araflinux.org/"
ISO_BUILD="${date_build}"
EOF
    fi
    
    print_success "Metadata updated"
}

phase6_clean_cache() {
    print_header "6" "Cache Cleaning"
    
    echo "→ Cleaning pacman cache..."
    yes | sudo pacman -Scc 2>/dev/null || true
    
    print_success "Cache cleaned"
}

phase7_build_iso() {
    print_header "7" "ISO Building (This may take a while)"
    
    ensure_directory "${OUT_FOLDER}"
    
    echo "→ Starting ISO build process..."
    echo "  Build folder: ${BUILD_FOLDER}"
    echo "  Output folder: ${OUT_FOLDER}"
    echo
    
    cd "${BUILD_FOLDER}/"
    
    # Run mkarchiso with proper options
    sudo mkarchiso -v -w "${BUILD_FOLDER}/work" -o "${OUT_FOLDER}" "${BUILD_FOLDER}"
    
    print_success "ISO build complete"
}

phase8_create_checksums() {
    print_header "8" "Checksum Generation"
    
    cd "${OUT_FOLDER}"
    
    # Find the generated ISO file
    ISO_FILE=$(ls -t araflinux-*.iso 2>/dev/null | head -n1)
    
    if [ -z "$ISO_FILE" ]; then
        print_error "No ISO file found in ${OUT_FOLDER}"
        return 1
    fi
    
    echo "→ Generating checksums for: ${ISO_FILE}"
    echo
    
    echo "  • MD5 checksum..."
    md5sum "${ISO_FILE}" | tee "${ISO_FILE}.md5" > /dev/null
    
    echo "  • SHA1 checksum..."
    sha1sum "${ISO_FILE}" | tee "${ISO_FILE}.sha1" > /dev/null
    
    echo "  • SHA256 checksum..."
    sha256sum "${ISO_FILE}" | tee "${ISO_FILE}.sha256" > /dev/null
    
    echo "  • SHA512 checksum..."
    sha512sum "${ISO_FILE}" | tee "${ISO_FILE}.sha512" > /dev/null
    
    echo
    echo "→ Copying package list..."
    if [ -f "${BUILD_FOLDER}/work/iso/arch/pkglist.x86_64.txt" ]; then
        cp "${BUILD_FOLDER}/work/iso/arch/pkglist.x86_64.txt" "${OUT_FOLDER}/${ISO_FILE}.pkglist.txt"
        echo "✓ Package list copied"
    else
        echo "⚠ Package list not found"
    fi
    
    print_success "Checksums created"
}

phase9_cleanup() {
    print_header "9" "Final Cleanup"
    
    echo "→ Removing build folder..."
    clean_directory "${BUILD_FOLDER}"
    
    print_success "Cleanup complete"
}


##################################################################################################################
# MAIN EXECUTION
##################################################################################################################

main() {
    echo
    echo "##################################################################"
    echo "#                                                                #"
    echo "#              ARAFLINUX ISO BUILD SCRIPT                        #"
    echo "#                                                                #"
    echo "##################################################################"
    
    # Execute all phases
    phase1_display_configuration
    phase2_setup_archiso
    phase3_prepare_build_folder
    phase4_configure_packages
    phase5_update_metadata
    phase6_clean_cache
    phase7_build_iso
    phase8_create_checksums
    phase9_cleanup
    
    # Final summary
    echo
    echo "##################################################################"
    tput setaf ${COLOR_GREEN}
    echo "#                                                                #"
    echo "#                      BUILD COMPLETE!                           #"
    echo "#                                                                #"
    echo "##################################################################"
    echo
    echo "Output Location: ${OUT_FOLDER}"
    echo "ISO File: ${ISO_LABEL}"
    echo
    tput sgr0
    echo "##################################################################"
    echo
}

# Run main function
main "$@"
