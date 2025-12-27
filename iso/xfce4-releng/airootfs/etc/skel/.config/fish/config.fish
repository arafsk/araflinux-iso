function fish_prompt -d "Write out the prompt"
    # This shows up as USER@HOST /home/user/ >, with the directory colored
    # $USER and $hostname are set by fish, so you can just use them
    # instead of using `whoami` and `hostname`
    printf '%s@%s %s%s%s > ' $USER $hostname \
        (set_color $fish_color_cwd) (prompt_pwd) (set_color normal)
end

if status is-interactive # Commands to run in interactive sessions can go here

    # No greeting
    set fish_greeting

    # Aliases
    alias pamcan pacman
    alias ls 'eza --icons'
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias q 'qs -c ii'
    alias l 'ls -lh'
    alias ll 'ls -lh'
    alias la 'ls -A'
    alias lm 'ls -m'
    alias lr 'ls -R'
    alias lg 'ls -l --group-directories-first'
    
    # git
    alias gcl 'git clone --depth 1'
    alias gi 'git init'
    alias ga 'git add -A'
    alias gc 'git commit -m "update"'
    alias gp 'git push -u origin main'
    alias gf 'git push --force origin main'
    alias git-clean 'git gc --aggressive --prune all'
    
    alias git-ssh 'ssh-keygen -t rsa -b 4096 -C "arafsos@protonmail.com"'
    
    ## Colorize the grep command output for ease of use (good for log files)##
    alias grep 'grep --color auto'
    alias egrep 'egrep --color auto'
    alias fgrep 'fgrep --color auto'
    
    #readable output
    alias df 'df -h'
    
    #setlocale
    alias setlocale "sudo localectl set-locale LANG en_US.UTF-8"
    alias setlocales "sudo localectl set-x11-keymap be && sudo localectl set-locale LANG en_US.UTF-8"
    
    #pacman unlock
    alias unlock "sudo rm /var/lib/pacman/db.lck"
    alias rmpacmanlock "sudo rm /var/lib/pacman/db.lck"
    
    #logout unlock
    alias rmlogoutlock "sudo rm /tmp/arcologout.lock"
    
    #which graphical card is working
    alias whichvga "~/.bin/which-vga"
    
    #grub update
    alias update-grub "sudo grub-mkconfig -o /boot/grub/grub.cfg"
    alias grub-update "sudo grub-mkconfig -o /boot/grub/grub.cfg"
    #grub issue 08/2022
    alias install-grub-efi "sudo grub-install --target x86_64-efi --efi-directory /boot/efi --bootloader-id ArafLinux"
    #Recent Installed Packages
    alias rip "expac --timefmt '%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
    alias riplong "expac --timefmt '%Y-%m-%d %T' '%l\t%n %v' | sort | tail -3000 | nl"
    #search content with ripgrep
    alias rg "rg --sort path"

    alias cd.. 'cd ..'
    alias pdw 'pwd'
    alias pacman "sudo pacman --color auto"
    alias udpate 'sudo pacman -Syyu'
    alias upate 'sudo pacman -Syyu'
    alias updte 'sudo pacman -Syyu'
    alias updqte 'sudo pacman -Syyu'
    
    alias src 'pkgsearch'
    alias src2 'searchpkg'
    alias treed 'tree -CAFd'
    alias mountedinfo 'df -hT'
    
    #enabling vmware services
    alias start-vmware "sudo systemctl enable --now vmtoolsd.service"
    alias vmware-start "sudo systemctl enable --now vmtoolsd.service"
    alias sv "sudo systemctl enable vmware-vmblock-fuse.service vmtoolsd.service"
    
    #alias tree 'tree -CAhF --dirsfirst'
    alias fix "sudo chown -R $USER:$USER"
    alias adduser 'useradd -m -G wheel -s'  # just do adduser /bin/bash username
    #switch between bash and zsh
    alias tobash "sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
    alias tozsh "sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"
    alias tofish "sudo chsh $USER -s /bin/fish && echo 'Now log out.'"
    #switch between displaymanager or bootsystem
    alias tolightdm "sudo pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings --noconfirm --needed ; sudo systemctl enable lightdm.service -f ; echo 'Lightm is active - reboot now'"
    alias tosddm "sudo pacman -S sddm --noconfirm --needed ; sudo systemctl enable sddm.service -f ; echo 'Sddm is active - reboot now'"
    alias toly "sudo pacman -S ly --noconfirm --needed ; sudo systemctl enable ly.service -f ; echo 'Ly is active - reboot now'"
    alias togdm "sudo pacman -S gdm --noconfirm --needed ; sudo systemctl enable gdm.service -f ; echo 'Gdm is active - reboot now'"
    alias tolxdm "sudo pacman -S lxdm --noconfirm --needed ; sudo systemctl enable lxdm.service -f ; echo 'Lxdm is active - reboot now'"
    alias toemptty "sudo pacman -S emptty --noconfirm --needed ; sudo systemctl enable emptty.service -f ; echo 'Emptty is active - reboot now'"
    alias ff "fastfetch"
    # bigger font in tty and regular font in tty
    alias bigfont "setfont ter-132b"
    alias regfont "setfont default8x16"
    alias catt 'batcat'
    alias rmd 'rm -rf'
    alias font 'sudo fc-cache -fv'
    alias ezsh 'nano ~/.zshrc'
    alias ebash 'nano ~/.bashrc'
    alias reload 'source ~/.zshrc'
    alias checklogs 'sudo journalctl -p 3 -xb'
    # System info
    alias cpuinfo 'lscpu'
    alias meminfo 'free -m -l -t'
    alias reboot 'sudo systemctl reboot'
    alias merge 'xrdb -merge ~/.Xresources'
    alias batinfo 'upower -i /org/freedesktop/UPower/devices/battery_BAT0'
    # Alias's to modified commands
    alias cpr 'cp -rfv'
    alias cpi 'cp -i'
    alias mvi 'mv -i'
    alias ping 'ping -c 4'
    alias less 'less -R'
    alias aria2 'aria2c -x 12 -s 12'
    alias iso1 'aria2c -x 12 -s 12'
    alias iso2 'wget -O'
    ## alias chmod commands
    alias 000 'chmod -R 000'
    alias 644 'chmod -R 644'
    alias 666 'chmod -R 666'
    alias 755 'chmod -R 755'
    alias 777 'chmod -R 777'
    alias rebootsafe 'sudo shutdown -r now'
    alias rebootforce 'sudo shutdown -r -n now'
    # Show all logs in /var/log
    alias clickpaste 'sleep 3; xdotool type "$(xclip -o -selection clipboard)"'
    # KITTY - alias to be able to use kitty features when connecting to remote servers(e.g use tmux on remote server)
    alias kssh "kitty +kitten ssh"
    alias hug "systemctl --user restart hugo"
    alias lanm "systemctl --user restart lan-mouse"
    #alias lms '~/.local~/.local/bin/lmstudio --no-sandbox &'
    alias chris 'curl -fsSL https://christitus.com/linux | sh'
    alias rsync 'sudo rsync -avh --partial --progress --info progress2'
    alias rsync2 'sudo rsync -aAXHv --info progress2'
    alias nvidia-smi 'nvidia-smi --query-gpu temperature.gpu,power.draw,utilization.gpu,utilization.memory --format csv -l 1'
    # check vulnerabilities microcode
    alias microcode 'grep . /sys/devices/system/cpu/vulnerabilities/*'
    #enabling vmware services
    alias vmtoolsd 'sudo systemctl enable --now vmtoolsd.service'
    alias vmdk-qcow2 'qemu-img convert -f vmdk -O qcow2'
    alias qcow2-vmdk 'qemu-img convert -f qcow2 "*.qcow2" -O vmdk "*.vmdk"'
    #Alias for yt-dlp
    alias yta-mp3 "yt-dlp --extract-audio --audio-format mp3 "
    alias yta-aac "yt-dlp --extract-audio --audio-format aac "
    alias yta-best "yt-dlp --extract-audio --audio-format best "
    alias yta-flac "yt-dlp --extract-audio --audio-format flac "
    alias ytdlp "yt-dlp -f 'bestvideo[ext mp4]+bestaudio[ext m4a]/bestvideo+bestaudio' --merge-output-format mp4 "
    #Alias for MPV
    alias playw 'mpv --ytdl-format "bestvideo[height< ?1440]+bestaudio/best" "$(wl-paste)"'
    alias playx 'mpv --ytdl-format "bestvideo[height< ?1440]+bestaudio/best" "$(xclip -o -selection clipboard)"'
    #nano for important configuration files
    #know what you do in these files
    alias nlxdm "sudo $EDITOR /etc/lxdm/lxdm.conf"
    alias nlightdm "sudo $EDITOR /etc/lightdm/lightdm.conf"
    alias npacman "sudo $EDITOR /etc/pacman.conf"
    alias ngrub "sudo $EDITOR /etc/default/grub"
    alias nconfgrub "sudo $EDITOR /boot/grub/grub.cfg"
    alias nmakepkg "sudo $EDITOR /etc/makepkg.conf"
    alias nmkinitcpio "sudo $EDITOR /etc/mkinitcpio.conf"
    alias nmirrorlist "sudo $EDITOR /etc/pacman.d/mirrorlist"
    alias nchaoticmirrorlist "sudo $EDITOR /etc/pacman.d/chaotic-mirrorlist"
    alias nsddm "sudo $EDITOR /etc/sddm.conf"
    alias nsddmk "sudo $EDITOR /etc/sddm.conf.d/kde_settings.conf"
    alias nsddmd "sudo $EDITOR /usr/lib/sddm/sddm.conf.d/default.conf"
    alias nfstab "sudo $EDITOR /etc/fstab"
    alias nnsswitch "sudo $EDITOR /etc/nsswitch.conf"
    alias nsamba "sudo $EDITOR /etc/samba/smb.conf"
    alias ngnupgconf "sudo $EDITOR /etc/pacman.d/gnupg/gpg.conf"
    alias nhosts "sudo $EDITOR /etc/hosts"
    alias nhostname "sudo $EDITOR /etc/hostname"
    alias nresolv "sudo $EDITOR /etc/resolv.conf"
    alias nb "$EDITOR ~/.bashrc"
    alias nz "$EDITOR ~/.zshrc"
    alias nf "$EDITOR ~/.config/fish/config.fish"
    alias nneofetch "$EDITOR ~/.config/neofetch/config.conf"
    alias nfastfetch "$EDITOR ~/.config/fastfetch/config.jsonc"
    alias nplymouth "sudo $EDITOR /etc/plymouth/plymouthd.conf"
    alias nvconsole "sudo $EDITOR /etc/vconsole.conf"
    alias nenvironment "sudo $EDITOR /etc/environment"
    alias nloader "sudo $EDITOR /boot/efi/loader/loader.conf"
    alias nrefind "sudo $EDITOR /boot/refind_linux.conf"
    alias nalacritty "nano /home/$USER/.config/alacritty/alacritty.toml"
    alias nemptty "sudo $EDITOR /etc/emptty/conf"
    alias nkitty "$EDITOR ~/.config/kitty/kitty.conf"
    alias npicom "$EDITOR ~/.config/dwm/picom/picom.conf"
    
    alias aptt 'sudo pacman -Sy --noconfirm'
    alias src 'sudo pacman -Ss'
    alias rmv 'sudo pacman -Rdd'
    alias update 'sudo pacman -Syu'
    alias upgrade 'sudo pacman -Syyu'
    alias orphan 'sudo pacman -Rns $(pacman -Qtdq)'
    alias yayf "yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window down:75% | xargs -ro yay -S"
    alias syse 'sudo systemctl enable'
    alias syss 'sudo systemctl start'
    
    alias chroot-arch "genfstab -U /mnt >> /mnt/etc/fstab && arch-chroot /mnt"
    alias mkchroot-arch "mkarchroot /home/araf/Documents/chroot/root base-devel"
    
    #backup contents of /etc/skel to hidden backup folder in home/user
    alias cpskel 'cp -Rf /etc/skel ~/.skel-backup-$(date +%Y.%m.%d-%H.%M.%S)'
    # get fastest mirrors
    alias reflector1 "sudo reflector -l 100 -f 50 --sort rate --threads 5 --verbose --save /tmp/mirrorlist.new && rankmirrors -n 0 /tmp/mirrorlist.new > /tmp/mirrorlist && sudo cp /tmp/mirrorlist /etc/pacman.d"
    alias reflector2 "sudo pacman -Sy reflector && sudo reflector --country Bangladesh --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist"
    alias mirrord "sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
    alias mirrors "sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
    alias mirrora "sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"
    #This will generate a list of explicitly installed packages without dependencies
    alias list "sudo pacman -Qqet"
    # AUR packages list
    alias aurlist "sudo pacman -Qqem"
    # add > list at the end to write to a file
    alias applist "sudo pacman -Qqe > packages.x86_64.txt"
    # install packages from list
    alias install "sudo pacman -S --needed - <"
    
    #maintenance
    alias big "expac -H M '%m\t%n' | sort -h | nl"
    alias sysfailed "systemctl list-units --failed"
    
    #give the list of all installed desktops - xsessions desktops
    alias xd "ls /usr/share/xsessions"
    alias xdw "ls /usr/share/wayland-sessions"
    alias kernel "ls /usr/lib/modules"
    alias kernels "ls /usr/lib/modules"
    alias rmgitcache "rm -r ~/.cache/git"
    #pacman unlock
    alias unlock "sudo rm /var/lib/pacman/db.lck"
    alias pamac-unlock "sudo rm /var/tmp/pamac/dbs/db.lock"
    
    #moving your personal files and folders from /personal to ~
    alias personal 'cp -arf /etc/skel/. ~'
    alias cpskel 'cp -Rf ~/.config ~/.config-backup-$(date +%Y.%m.%d-%H.%M.%S)'
    
end