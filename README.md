# Android Studio on Termux (PRoot + Ubuntu, no Root)

A fully automated deployment script to install and run a native Linux instance of Android Studio directly on an ARM-based Android device using Termux, PRoot, and XFCE4. 

This environment provides a full, on-device desktop IDE. Whether you are compiling native Android projects like Chordbook on the go, or quickly editing Node.js backend logic for your Quack & Compile Telegram bots, this setup bypasses architectural limitations to give you a seamless mobile development workstation.

## ✨ Features
* **Single-Run Automation:** Configures Termux, installs Ubuntu via `proot-distro`, sets up user permissions, and downloads the IDE in one script.
* **Native GUI:** Boots a clean XFCE4 desktop environment via Termux-X11.
* **Audio Support:** Pre-configured PulseAudio routing so emulator and system sounds work natively.
* **ARM64 Optimized:** Bypasses Android Studio's bundled x86 runtime by forcing native `openjdk-21-jdk` integration.
* **Cable-Free Testing:** Built-in workflow for pairing Termux's ADB daemon to your device's wireless debugging port for local, on-device app installation.

## 🚀 Getting Started

### Prerequisites
1. An Android device with **Termux** and **Termux-X11** installed.
2. At least **10-15GB** of free internal storage.
3. Wireless Debugging enabled in your device's Android Developer Options.

### Installation
Run the setup script directly from your Termux terminal. It will automatically handle repository updates, package installations, and environment bridging.

```bash
# Download and execute the automated setup script
curl -sL https://raw.githubusercontent.com/omerakbu1t/android-studio-on-termux/main/setup.sh | bash
```

> **Note:** The script will automatically start the XFCE4 desktop via `startxfce4.sh` when the core installation is complete.

## 🛠️ Post-Installation Setup

Because Android Studio requires some initial GUI configuration, the final steps must be completed manually once the XFCE4 desktop is running.

### 1. Configure Android Studio
* Launch Android Studio from your XFCE application menu.
* Go through the initial setup wizard. 
* **Crucial:** Ensure you download the **Android 14 (API 34)** SDK.
* Verify the IDE is pointing to the native Java 21 environment (`/usr/lib/jvm/java-21-openjdk-arm64`) instead of the bundled JetBrains Runtime.

### 2. The `aapt2` Architecture Workaround
Ubuntu runs on the `glibc` C library, but Termux uses Android's `Bionic` library. To allow Gradle to build resources successfully, you must override the native `aapt2` binary.

Open your project and add the following line to your `gradle.properties` file:
```properties
android.aapt2FromMavenOverride=/data/data/com.termux/files/usr/bin/aapt2
```

### 3. Link Local ADB & Connect Wireless Debugging
To deploy apps directly to the device you are coding on, you need to link the Ubuntu ADB to the Android Studio SDK, and pair it.

**Inside the PRoot Ubuntu terminal**, run:
```bash
# Backup the x86 adb and symlink the native one
mv ~/Android/Sdk/platform-tools/adb ~/Android/Sdk/platform-tools/adb_x86_backup
ln -s $(which adb) ~/Android/Sdk/platform-tools/adb
```

**Connect to your device:**
1. Open your phone's Developer Options -> Wireless Debugging -> "Pair device with pairing code".
2. Note the IP, Port, and Pairing Code.
3. In your PRoot Ubuntu terminal, run:
   ```bash
   adb pair <IP>:<PORT>
   # Enter pairing code when prompted
   adb connect <IP>:<NEW_PORT>
   ```
Your device will now show up in the Android Studio drop-down menu, ready for deployment!
