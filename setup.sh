
TARGET_USER="ubuntu"


# step 1: set up environment:

termux-setup-storage
pkg update -y
pkg upgrade -y
pkg install x11-repo -y
pkg install termux-x11-nightly -y
pkg install tur-repo -y
pkg install pulseaudio -y
pkg install proot-distro -y
pkg install wget git aapt2 -y
# aapt2 is needed for later replacement of native android studio aapt2

wget -O ~/startxfce4.sh https://raw.githubusercontent.com/omerakbu1t/android-studio-on-termux/main/startxfce4.sh
chmod +x ~/startxfce4.sh


# step 2: install & configure ubuntu

pd install ubuntu

pd login ubuntu -- bash -c "apt update && apt upgrade -y && apt install sudo adduser nano git wget -y && adduser --disabled-password --gecos \"\" $TARGET_USER && echo \"$TARGET_USER ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/$TARGET_USER && chmod 0440 /etc/sudoers.d/$TARGET_USER"
# step 3: install GUI and required dependencies

# step 3: bypass broken icon theme, then install GUI and required dependencies

pd login ubuntu --user $TARGET_USER -- bash -c "sudo wget -q http://ports.ubuntu.com/pool/universe/e/elementary-xfce/elementary-xfce-icon-theme_0.19-1_all.deb && sudo apt install ./elementary-xfce-icon-theme_0.19-1_all.deb -y && sudo apt-mark hold elementary-xfce-icon-theme && sudo apt install xfce4 adb openjdk-21-jdk tar -y"

# step 4: install android studio

pd login ubuntu --user $TARGET_USER -- bash -c 'mkdir ~/Android && wget -O studio.tar.gz https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.1.1.11/android-studio-2024.1.1.11-linux.tar.gz && tar -xvzf studio.tar.gz -C ~/Android/ && rm studio.tar.gz && sudo apt-get --fix-missing install -y && sudo apt --fix-broken install -y && sudo wget -O /usr/share/applications/android-studio.desktop https://raw.githubusercontent.com/omerakbu1t/android-studio-on-termux/main/android-studio.desktop'


# step 5: set up android studio

bash ~/startxfce4.sh
# open the android studio, install android 14 (api 34) SDK instead of 16,
# point the jdk 21 instead of studio's default oracle,
# add the gradle dependency app2

# at the gradle.properties:
# android.aapt2FromMavenOverride=/data/data/com.termux/files/usr/bin/aapt2


# step 6: replace adb:

# pd login ubuntu --user ubuntu -- bash -c 'mv ~/Android/Sdk/platform-tools/adb ~/Android/Sdk/platform-tools/adb_x86_backup && ln -s $(which adb) ~/Android/Sdk/platform-tools/adb'
# step 7: set up adb from phone:

# enable wireless debugging, tap pair with code, write to the proot terminal:
# adb pair ip:port,
# it will prompt the pairing code, enter it,
# after pairing, use the other ip:port connection thing at that menu to:
# adb connect ip:newport.
# everything is set up!
