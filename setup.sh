
TARGET_USER="ubuntu"
BASE_STUDIO_URL="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.1.1.11/android-studio-2024.1.1.11-linux.tar.gz"
TARGET_STUDIO_URL="https://edgedl.me.gvt1.com/android/studio/ide-zips/2025.3.1.6/android-studio-panda1-rc1-linux.tar.gz"

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

wget -O  ~/startxfce4.sh https://raw.githubusercontent.com/omerakbu1t/android-studio-on-termux/main/startxfce4.sh
chmod +x ~/startxfce4.sh

clear
echo "Installing Ubuntu..."
echo "--------------------"
sleep 3
# step 2: install & configure ubuntu

pd install ubuntu

pd login ubuntu -- bash -c "

apt update -y
apt upgrade -y 
apt install sudo adduser nano git wget -y 
adduser --disabled-password --gecos \"\" $TARGET_USER 
echo \"$TARGET_USER ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/$TARGET_USER
chmod 0440 /etc/sudoers.d/$TARGET_USER
"



# step 3: bypass broken icon theme, then install GUI and required dependencies
clear
echo "Installing GUI. This might take a while..."
echo "------------------------------------------"
sleep 3

pd login ubuntu --user $TARGET_USER -- bash -c '
sudo wget -q http://ports.ubuntu.com/pool/universe/e/elementary-xfce/elementary-xfce-icon-theme_0.19-1_all.deb
sudo apt install ./elementary-xfce-icon-theme_0.19-1_all.deb -y 
rm elementary-xfce-icon-theme_0.19-1_all.deb
sudo apt-mark hold elementary-xfce-icon-theme
sudo apt install xfce4 adb openjdk-21-jdk tar unzip mousepad -y
'


# step 4: install android studio, add shortcut, and create instructions
clear
echo "Downloading & Installing Studio"
echo "-------------------------------"


pd login ubuntu --user $TARGET_USER -- bash -c '
# 1. Download and extract Android Studio
mkdir -p /home/ubuntu/Android
wget -O studio.tar.gz '"$TARGET_STUDIO_URL"' --no-check-certificate
tar -xvzf studio.tar.gz -C /home/ubuntu/Android/
rm studio.tar.gz

# 2. Fix apt and download the .desktop file
sudo apt-get --fix-missing install -y
sudo apt --fix-broken install -y
sudo wget -O /usr/share/applications/android-studio.desktop https://raw.githubusercontent.com/omerakbu1t/android-studio-on-termux/main/android-studio.desktop

# 3. Replace the bundled JBR with the system JDK
mv /home/ubuntu/Android/android-studio/jbr /home/ubuntu/Android/android-studio/jbr_x86_backup
ln -s /usr/lib/jvm/java-21-openjdk-arm64 /home/ubuntu/Android/android-studio/jbr

# 4. Replace the bundled skiko with the system one (fixes rendering issues)
mkdir -p /home/ubuntu/Android/android-studio/lib/skiko-awt-runtime-all/

cd /home/ubuntu/Android/android-studio/lib/skiko-awt-runtime-all/
wget https://repo1.maven.org/maven2/org/jetbrains/skiko/skiko-awt-runtime-linux-arm64/0.9.47/skiko-awt-runtime-linux-arm64-0.9.47.jar
unzip -j skiko-awt-runtime-linux-arm64-0.9.47.jar "libskiko-linux-arm64.so"
rm skiko-awt-runtime-linux-arm64-0.9.47.jar

# disable chromium based rendering for better performance and stability (it will use software rendering instead, which is more compatible with ARM devices)
echo "-Dide.browser.jcef.enabled=false" >> /home/ubuntu/Android/android-studio/bin/studio64.vmoptions

# disable memory cleaner to prevent OOM errors, and disable opengl rendering which causes freezes and crashes on many devices
echo "-Dide.memory.cleaner=false" >> /home/ubuntu/Android/android-studio/bin/studio64.vmoptions
echo "-Dsun.java2d.opengl=false" >> /home/ubuntu/Android/android-studio/bin/studio64.vmoptions


# 5. Link the native JNA library to fix the "Failed to load the jnidispatch library" error
sudo apt install libjna-jni -y
# Backup the original just in case
mv /home/ubuntu/Android/android-studio/lib/jna/amd64/libjnidispatch.so /home/ubuntu/Android/android-studio/lib/jna/amd64/libjnidispatch.so.bak 2>/dev/null

# Link the native Ubuntu ARM64 JNA into the amd64 folder
ln -sf /usr/lib/aarch64-linux-gnu/jni/libjnidispatch.so /home/ubuntu/Android/android-studio/lib/jna/amd64/libjnidispatch.so

# Also link it to an aarch64 folder, just to be safe if Studio gets smart later
mkdir -p /home/ubuntu/Android/android-studio/lib/jna/aarch64
ln -sf /usr/lib/aarch64-linux-gnu/jni/libjnidispatch.so /home/ubuntu/Android/android-studio/lib/jna/aarch64/libjnidispatch.so



cd /home/ubuntu
wget https://github.com/HomuHomu833/android-sdk-custom/releases/download/36.0.0/android-sdk-aarch64-linux-musl.tar.xz
tar -xf android-sdk-aarch64-linux-musl.tar.xz
rm android-sdk-aarch64-linux-musl.tar.xz
mkdir -p /home/ubuntu/Android/Sdk/cmdline-tools/latest
mv /home/ubuntu/android-sdk/cmdline-tools/* /home/ubuntu/Android/Sdk/cmdline-tools/latest/

# prepopulate sdk for to avoid rewrite
/home/ubuntu/Android/Sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-36" "build-tools;36.1.0" "platform-tools" --verbose
rm -rf /home/ubuntu/Android/Sdk/platform-tools
rm -rf /home/ubuntu/Android/Sdk/build-tools
# Move the native ARM64 platform-tools into the SDK
mv /home/ubuntu/android-sdk/platform-tools /home/ubuntu/Android/Sdk/
mv /home/ubuntu/android-sdk/build-tools /home/ubuntu/Android/Sdk/
rm -rf /home/ubuntu/android-sdk

mkdir -p /home/ubuntu/.gradle
echo "android.aapt2FromMavenOverride=/home/ubuntu/Android/Sdk/build-tools/36.1.0/aapt2" >> /home/ubuntu/.gradle/gradle.properties

# 3. Create the Desktop shortcut
mkdir -p /home/ubuntu/Desktop
cp /usr/share/applications/android-studio.desktop /home/ubuntu/Desktop/
chmod +x /home/ubuntu/Desktop/android-studio.desktop


# 4. Generate the "Next Steps" text file on the Desktop
cat << "EOF" > /home/ubuntu/Desktop/NEXT_STEPS.txt
=== STEP 5: Set up Android Studio ===
1. Open Android Studio from your new desktop shortcut.
2. Install Android 14 (API 34) SDK instead of the default 16.
3. IMPORTANT: when you create a project, stop the first gradle build. then:
5. Add this to your project gradle.properties:
   android.aapt2FromMavenOverride=/data/data/com.termux/files/usr/bin/aapt2

Open a terminal in Ubuntu and copy-paste these 2 lines.:
mv /home/ubuntu/Android/Sdk/platform-tools/adb /home/ubuntu/Android/Sdk/platform-tools/adb_x86_backup
ln -s $(which adb) /home/ubuntu/Android/Sdk/platform-tools/adb

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


clear
echo "-------------------------------"
echo "Terminal setup complete!" 
echo "IMPORTANT:Please check the NEXT_STEPS.txt file on your Desktop for further instructions. "
echo "IDE WONT WORK PROPERLY UNLESS YOU FOLLOW THEM CAREFULLY."
echo "-------------------------------"

sleep 3
for i in {5..1}; do
    echo -ne "Launching in $i seconds...\r"
    sleep 1
done
echo -e "\nLaunching now!"

./startxfce4.sh