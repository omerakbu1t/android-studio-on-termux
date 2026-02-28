
BASE_STUDIO_URL="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.1.1.11/android-studio-2024.1.1.11-linux.tar.gz"
TARGET_STUDIO_URL="https://edgedl.me.gvt1.com/android/studio/ide-zips/2025.3.1.6/android-studio-panda1-rc1-linux.tar.gz"




STUDIO_SOURCE="https://redirector.gvt1.com/android/studio/ide-zips/2025.3.1.6/android-studio-panda1-rc1-linux.tar.gz"
DISTRO="ubuntu"
PLATFORM_VERSION="36.1"
BUILD_TOOLS_VERSION="36.1.0"

clear
echo "STUDIO INSTALLER FOR TERMUX"
echo "--------------------------------"
echo "Welcome to the Android Studio on Termux setup script!"
echo "This script will set up a full xfce environment with Android Studio,"
echo "preconfigured and optimized for termux."
echo "If you encounter any issues, please report them to me:"
echo "https://github.com/omerakbu1t/android-studio-on-termux"
echo "--------------------------------"

echo "Select Studio Version to Install:"
echo "--------------------------------"
echo "1  |2025.3.3| Studio Panda 3 Canary 2"
echo "2. |2025.3.1| Studio Panda 1 RC 1 (default)"
echo "3. |2025.2.3| Studio Otter 3 Stable"
echo "4. |2024.1.1| Studio 2024.1.1.11"
echo "--------------------------------"

read -p "Enter your choice (1-5): " studio_choice

if [ "$studio_choice" = "1" ]; then
    STUDIO_SOURCE="https://edgedl.me.gvt1.com/android/studio/ide-zips/2025.3.3.2/android-studio-panda3-canary2-linux.tar.gz"
    PLATFORM_VERSION="36.1"
    BUILD_TOOLS_VERSION="36.1.0"
elif [ "$studio_choice" = "2" ]; then
    STUDIO_SOURCE="https://redirector.gvt1.com/android/studio/ide-zips/2025.3.1.6/android-studio-panda1-rc1-linux.tar.gz"
    PLATFORM_VERSION="36.1"
    BUILD_TOOLS_VERSION="36.1.0"
elif [ "$studio_choice" = "3" ]; then
    STUDIO_SOURCE="https://edgedl.me.gvt1.com/android/studio/ide-zips/2025.2.3.9/android-studio-2025.2.3.9-linux.tar.gz"
    PLATFORM_VERSION="36.1"
    BUILD_TOOLS_VERSION="36.1.0"
elif [ "$studio_choice" = "4" ]; then
    STUDIO_SOURCE="https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.1.1.11/android-studio-2024.1.1.11-linux.tar.gz"
    PLATFORM_VERSION="34"
    BUILD_TOOLS_VERSION="34.0.4"
else
    echo "Invalid option. Exiting."
    exit 1
fi



clear
echo "selected studio version: $STUDIO_SOURCE"
echo "[Ctrl + C to cancel]"
echo "--------------------------------"
echo "select Proot Distro to use:"
echo "1. Ubuntu (Recommended)"
echo "2. Debian"
echo "--------------------------------"
read -p "Enter your choice (1 or 2) (default: 1): " distro_choice


if [ "$distro_choice" = "2" ]; then
    DISTRO="debian"
else
    DISTRO="ubuntu"
fi

echo "selected $DISTRO."
sleep 3
clear



echo ""
echo "Final confirmation:"
echo "Studio Version: $STUDIO_SOURCE"
echo "Distro: $DISTRO"
echo "[Ctrl + C to cancel]"
echo "----------------------------------"
for i in {8..1}; do
    echo -ne "installation will start in $i seconds. [ctrl + C to cancel]\r"
    sleep 1
done


# step 1: set up environment:
echo "Setting up Termux..."
sleep 3
clear
pkg update -y
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
echo "Installing $DISTRO..."
echo "--------------------"
sleep 3
# step 2: install & configure ubuntu

pd install $DISTRO -y

pd login $DISTRO -- bash -c "

apt update -y
apt upgrade -y 
apt install sudo adduser nano git wget -y 
adduser --disabled-password --gecos \"\" $DISTRO
echo \"$DISTRO ALL=(ALL) NOPASSWD: ALL\" > /etc/sudoers.d/$DISTRO
chmod 0440 /etc/sudoers.d/$DISTRO
"



# step 3: bypass broken icon theme, then install GUI and required dependencies
clear
echo "Installing GUI. This might take a while..."
echo "------------------------------------------"
sleep 3

pd login $DISTRO --user $DISTRO -- bash -c '
sudo wget -q http://ports.ubuntu.com/pool/universe/e/elementary-xfce/elementary-xfce-icon-theme_0.19-1_all.deb
sudo apt install ./elementary-xfce-icon-theme_0.19-1_all.deb -y
rm elementary-xfce-icon-theme_0.19-1_all.deb
sudo apt-mark hold elementary-xfce-icon-theme
sudo apt install xfce4 openjdk-21-jdk tar unzip mousepad xfce4-terminal -y
'


pd login $DISTRO --user $DISTRO -- bash -c '

HOME_DIR='"/home/$DISTRO"'

clear
echo "Downloading & Installing Studio"
echo "-------------------------------"
sleep 3
# 1. Download and extract Android Studio
mkdir -p $HOME_DIR/Android
wget -O studio.tar.gz '"$STUDIO_SOURCE"' --no-check-certificate
tar -xvzf studio.tar.gz -C $HOME_DIR/Android/
rm studio.tar.gz
sudo ln -s $HOME_DIR/Android/android-studio/bin/studio.sh /usr/local/bin/studio


clear
echo "Creating Desktop Shortcut"
echo "-------------------------------"
sleep 3
# 2. Fix apt and download the .desktop file
sudo apt-get --fix-missing install -y
sudo apt --fix-broken install -y
sudo wget -O /usr/share/applications/android-studio.desktop https://raw.githubusercontent.com/omerakbu1t/android-studio-on-termux/main/android-studio.desktop



clear
echo "Fixing Dependency Issues"
echo "-------------------------------"
sleep 3
# 3. Replace the bundled JBR with the system JDK
mv $HOME_DIR/Android/android-studio/jbr $HOME_DIR/Android/android-studio/jbr_x86_backup
ln -s /usr/lib/jvm/java-21-openjdk-arm64 $HOME_DIR/Android/android-studio/jbr

# 4. Replace the bundled skiko with the system one (fixes rendering issues)
mkdir -p $HOME_DIR/Android/android-studio/lib/skiko-awt-runtime-all/

cd $HOME_DIR/Android/android-studio/lib/skiko-awt-runtime-all/
wget https://repo1.maven.org/maven2/org/jetbrains/skiko/skiko-awt-runtime-linux-arm64/0.9.47/skiko-awt-runtime-linux-arm64-0.9.47.jar
unzip -j skiko-awt-runtime-linux-arm64-0.9.47.jar "libskiko-linux-arm64.so"
rm skiko-awt-runtime-linux-arm64-0.9.47.jar

# 5. Link the native JNA library to fix the "Failed to load the jnidispatch library" error
sudo apt install libjna-jni -y
# Backup the original just in case
mv $HOME_DIR/Android/android-studio/lib/jna/amd64/libjnidispatch.so $HOME_DIR/Android/android-studio/lib/jna/amd64/libjnidispatch.so.bak 2>/dev/null

clear
echo "Fixing Performance and Stability Issues"
echo "-------------------------------"
sleep 3
# disable chromium based rendering for better performance and stability (it will use software rendering instead, which is more compatible with ARM devices)
echo "-Dide.browser.jcef.enabled=false" >> $HOME_DIR/Android/android-studio/bin/studio64.vmoptions

# disable memory cleaner to prevent OOM errors, and disable opengl rendering which causes freezes and crashes on many devices
echo "-Dide.memory.cleaner=false" >> $HOME_DIR/Android/android-studio/bin/studio64.vmoptions
echo "-Dsun.java2d.opengl=false" >> $HOME_DIR/Android/android-studio/bin/studio64.vmoptions
echo "-Djna.nounpack=true" >> $HOME_DIR/Android/android-studio/bin/studio64.vmoptions

# Link the native Ubuntu ARM64 JNA into the amd64 folder
ln -sf /usr/lib/aarch64-linux-gnu/jni/libjnidispatch.system.so $HOME_DIR/Android/android-studio/lib/jna/amd64/libjnidispatch.so

# Also link it to an aarch64 folder, just to be safe if Studio gets smart later
mkdir -p $HOME_DIR/Android/android-studio/lib/jna/aarch64
ln -sf /usr/lib/aarch64-linux-gnu/jni/libjnidispatch.system.so $HOME_DIR/Android/android-studio/lib/jna/aarch64/libjnidispatch.so


PROPERTIES_FILE="$HOME_DIR/Android/android-studio/bin/idea.properties"
echo "" >> "$PROPERTIES_FILE"
echo "ide.native.launcher=false" >> "$PROPERTIES_FILE"
echo "idea.no.jre.check=true" >> "$PROPERTIES_FILE"
echo "idea.filewatcher.disabled=true" >> "$PROPERTIES_FILE"








clear
echo "Fixing & Prepopulating Android SDK"
echo "-------------------------------"
sleep 3
SDK_URL=""
cd $HOME_DIR
if [ '"$PLATFORM_VERSION"' = "34" ]; then
    SDK_URL="https://github.com/omerakbu1t/android-studio-on-termux/releases/download/34.0.4/android-sdk-aarch64-34.0.4.tar.xz"
elif [ '"$PLATFORM_VERSION"' = "36.1" ]; then
    SDK_URL="https://github.com/HomuHomu833/android-sdk-custom/releases/download/36.0.0/android-sdk-aarch64-linux-musl.tar.xz"
else
    SDK_URL="https://github.com/HomuHomu833/android-sdk-custom/releases/download/36.0.0/android-sdk-aarch64-linux-musl.tar.xz"
fi
wget -O androidsdk.tar.xz "$SDK_URL"
tar -xf androidsdk.tar.xz
rm androidsdk.tar.xz
mkdir -p $HOME_DIR/Android/Sdk/cmdline-tools/latest
mv $HOME_DIR/android-sdk/cmdline-tools/* $HOME_DIR/Android/Sdk/cmdline-tools/latest/

# 2. Accept licenses automatically
yes | $HOME_DIR/Android/Sdk/cmdline-tools/latest/bin/sdkmanager --licenses

# 3. Pre-populate SDK
yes | $HOME_DIR/Android/Sdk/cmdline-tools/latest/bin/sdkmanager "platforms;android-'"$PLATFORM_VERSION"'" "sources;android-'"$PLATFORM_VERSION"'" "build-tools;'"$BUILD_TOOLS_VERSION"'" "platform-tools"  --verbose

# 1. Surgically overwrite platform-tools (leaves package.xml intact!)
cp -rf $HOME_DIR/android-sdk/platform-tools/* $HOME_DIR/Android/Sdk/platform-tools/
cp -rf $HOME_DIR/android-sdk/build-tools/'"$BUILD_TOOLS_VERSION"'/* $HOME_DIR/Android/Sdk/build-tools/'"$BUILD_TOOLS_VERSION"'/

# 3. Clean up the leftover downloaded archive folder
rm -rf $HOME_DIR/android-sdk

# Set the adb symlink
sudo ln -s $HOME_DIR/Android/Sdk/platform-tools/adb /usr/local/bin/adb



# 4. Set the SDK path in Android Studios config to avoid the error on first launch. We have to do this manually because the bundled JBR doesnt work with the sdkmanager tool, so we cant set it up through the normal command line way.

CONFIG_DIR="$HOME_DIR/.config/Google/AndroidStudio2025.3.1/options"
mkdir -p "$CONFIG_DIR"
cat << "EOF" > "$CONFIG_DIR/android.sdk.path.xml"
<application>

  <component name="AndroidSdkPathStore">

    <option name="androidSdkAbsolutePath" value="$USER_HOME$/Android/Sdk" />

  </component>

</application>

EOF


cat <<EOF > "$CONFIG_DIR/security.xml"
<application>
  <component name="PasswordSafe">
    <option name="PROVIDER" value="KEEPASS" />
  </component>
</application>
EOF


cat <<EOF > "$CONFIG_DIR/other.xml"
<application>
  <component name="FileEditorProviderManager">{}</component>
  <component name="NotRoamableUiSettings">
    <option name="fontSize" value="13.0" />
    <option name="presentationModeIdeScale" value="1.75" />
  </component>
  <component name="PropertyService"><![CDATA[{
  "keyToString": {
    "Notification.DisplayName-DoNotAsk-File Watcher Messages": "File system synchronization issues detected",
    "Notification.DisplayName-DoNotAsk-System Health": "System health issue detected",
    "Notification.DisplayName-DoNotAsk-bundled.jre.version.message": "",
    "Notification.DoNotAsk-File Watcher Messages": "true",
    "Notification.DoNotAsk-System Health": "true",
    "Notification.DoNotAsk-bundled.jre.version.message": "true"
  },
  "keyToStringList": {
    "fileTypeDetectors": [
    ]
  }
}]]></component>
</application>

EOF

cat <<EOF > "$CONFIG_DIR/updates.xml"

<application>
  <component name="UpdatesConfigurable">
    <option name="CHECK_NEEDED" value="false" />
  </component>
</application>

EOF

mkdir -p $HOME_DIR/.gradle
echo "android.aapt2FromMavenOverride=$HOME_DIR/Android/Sdk/build-tools/36.1.0/aapt2" >> $HOME_DIR/.gradle/gradle.properties

# 3. Create the Desktop shortcut
mkdir -p $HOME_DIR/Desktop
cp /usr/share/applications/android-studio.desktop $HOME_DIR/Desktop/
chmod +x $HOME_DIR/Desktop/android-studio.desktop

cat << "EOF" > $HOME_DIR/Desktop/ADBConnection.txt

Wireless Debugging
1. Enable Wireless Debugging on your phone. (Developer Options > Wireless Debugging)
2. Tap "Pair device with pairing code" in Developer Settings.
3. Note the IP, Port, and Pairing Code in that popup.
4. Open an Ubuntu terminal and type: $HOME_DIR/Android/Sdk/platform-tools/adb pair ip:port
5. Enter the code. It will say "Successfully paired".
6. Look at the main Wireless Debugging screen for the new, persistent IP and Port.
7. In the terminal, type: $HOME_DIR/Android/Sdk/platform-tools/adb pair ip:newport

Thats it! The device will show up in Android Studio. Have fun building!
EOF
'

clear
echo "-------------------------------"
echo "Terminal setup complete!" 
echo "x11 will launch in a minute."
echo "if you see any issues, report me: https://github.com/omerakbu1t"
echo "-------------------------------"

sleep 3
for i in {5..1}; do
    echo -ne "Launching in $i seconds...\r"
    sleep 1
done
echo -e "\nLaunching now!"

./startxfce4.sh
