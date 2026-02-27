
TARGET_USER="ubuntu"
BASE_STUDIO_URL="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.1.1.11/android-studio-2024.1.1.11-linux.tar.gz"
TARGET_STUDIO_URL="https://edgedl.me.gvt1.com/android/studio/ide-zips/2025.2.3.9/android-studio-2025.2.3.9-linux.tar.gz"

# step 1: set up environment:
echo "Setting up Termux..."
sleep 3
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

clear
echo "Installing Ubuntu..."
echo "--------------------"
sleep 3
# step 2: install & configure ubuntu

pd install ubuntu

pd login ubuntu -- bash -c "apt update && apt upgrade -y && apt install sudo adduser nano git wget -y && adduser --disabled-password --gecos \"\" $TARGET_USER && echo \"$TARGET_USER ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/$TARGET_USER && chmod 0440 /etc/sudoers.d/$TARGET_USER"

clear
echo "Installing GUI. This might take a while..."
echo "------------------------------------------"
sleep 3
# step 3: bypass broken icon theme, then install GUI and required dependencies

pd login ubuntu --user $TARGET_USER -- bash -c "sudo wget -q http://ports.ubuntu.com/pool/universe/e/elementary-xfce/elementary-xfce-icon-theme_0.19-1_all.deb && sudo apt install ./elementary-xfce-icon-theme_0.19-1_all.deb -y && sudo apt-mark hold elementary-xfce-icon-theme && sudo apt install xfce4 adb openjdk-21-jdk tar mousepad -y"

clear
echo "Downloading & Installing Studio"
echo "-------------------------------"
# step 4: install android studio

# step 4: install android studio, add shortcut, and create instructions

pd login ubuntu --user $TARGET_USER -- bash -c '
# 1. Download and extract Android Studio
mkdir -p ~/Android
wget -O studio.tar.gz '"$TARGET_STUDIO_URL"' --no-check-certificate
tar -xvzf studio.tar.gz -C ~/Android/
rm studio.tar.gz

# 2. Fix apt and download the .desktop file
sudo apt-get --fix-missing install -y
sudo apt --fix-broken install -y
sudo wget -O /usr/share/applications/android-studio.desktop https://raw.githubusercontent.com/omerakbu1t/android-studio-on-termux/main/android-studio.desktop

# 3. Create the Desktop shortcut
mkdir -p ~/Desktop
cp /usr/share/applications/android-studio.desktop ~/Desktop/
chmod +x ~/Desktop/android-studio.desktop

~/startxfce4.sh
# 4. Generate the "Next Steps" text file on the Desktop
cat << "EOF" > ~/Desktop/NEXT_STEPS.txt
=== STEP 5: Set up Android Studio ===
1. Open Android Studio from your new desktop shortcut.
2. Install Android 14 (API 34) SDK instead of the default 16.
3. IMPORTANT: when you create a project, stop the first gradle build. then:
4. go to File > Settings > Build > Build Tools > Gradle and change the wrapper to openjdk-21-jdk-arm64.
5. Add this to your project gradle.properties:
   android.aapt2FromMavenOverride=/data/data/com.termux/files/usr/bin/aapt2

Open a terminal in Ubuntu and copy-paste these 2 lines.:
mv ~/Android/Sdk/platform-tools/adb ~/Android/Sdk/platform-tools/adb_x86_backup
ln -s $(which adb) ~/Android/Sdk/platform-tools/adb

=== STEP 7: Wireless Debugging ===
1. Enable Wireless Debugging on your phone.
2. Tap "Pair device with pairing code" at Developer Settings.
3. note the ip, port, pairing code at that popup (this port is different than actual connection port)
4. open a new terminal at ubuntu and type "adb pair <ip>:<port>"
5. it will return a "succesfully paired" message. but our work is not done. go back to settings, and get the actual ip and port at that screen.
6. at ubuntu terminal, type "adb connect <same ip>:<new port>" and connect

thats all, have fun! MAKE SURE YOU DONT UPDATE VERSIONS UNLESS YOU KNOW WHAT URE DOING.
EOF
'