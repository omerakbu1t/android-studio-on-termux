# Android Studio on Termux (PRoot + Ubuntu, no Root)

A fully automated deployment script to install and run a native Linux instance of Android Studio directly on an ARM-based Android device using Termux, PRoot, and XFCE4. 

This environment provides a full, on-device desktop IDE. Whether you are compiling native Android projects on the go or quickly editing backend logic, this setup bypasses architectural limitations to give you a seamless mobile development workstation.

## ✨ Features
* **End-to-End Automation:** Configures Termux, installs Ubuntu via `proot-distro`, sets up user permissions, downloads the IDE, and prepopulates the Android SDK in one run.
* **Native ARM64 Optimization:** Automatically bypasses Android Studio's bundled x86 runtime by linking native `openjdk-21-jdk`, fixing JNA/Skiko rendering issues, and disabling Chromium/OpenGL overhead to prevent OOM crashes.
* **Automated Build-Tools Fix:** Automatically creates a global `aapt2` override in your Gradle properties so you can compile without architecture mismatch errors.
* **Native GUI:** Boots a clean XFCE4 desktop environment via Termux-X11.
* **Audio Support:** Pre-configured PulseAudio routing so emulator and system sounds work natively.

## 🚀 Getting Started

### Prerequisites
1. An Android device with **Termux** and **Termux-X11** installed.
2. At least **10-15GB** of free internal storage.
3. Wireless Debugging enabled in your device's Android Developer Options.

### Installation
Run the setup script directly from your Termux terminal. It will automatically handle repository updates, package installations, environment bridging, and SDK setup.

```bash
# Download and execute the automated setup script
curl -sL [https://raw.githubusercontent.com/omerakbu1t/android-studio-on-termux/main/setup.sh](https://raw.githubusercontent.com/omerakbu1t/android-studio-on-termux/main/setup.sh) | bash
```

> **Note:** The script will automatically launch the XFCE4 desktop via `startxfce4.sh` when the core installation is complete.

## 🛠️ Post-Installation: Connecting Your Device

Because the script now handles the SDK downloads, Java runtime fixes, and AAPT2 configurations automatically, the *only* thing left to do is connect your device via Wireless Debugging so you can deploy your apps! 

*(A handy `ADB Connection.txt` file is also generated on your Ubuntu Desktop with these steps for easy reference).*

1. Enable **Wireless Debugging** on your phone (`Developer Options` > `Wireless Debugging`).
2. Tap **"Pair device with pairing code"**.
3. Note the IP, Port, and Pairing Code in the popup.
4. Open a terminal inside your new Ubuntu desktop and type: 
   ```bash
   adb pair <IP>:<PORT>
   ```
5. Enter the code when prompted. It will say "Successfully paired".
6. Look back at the main Wireless Debugging screen on your phone for the new, persistent IP and Port.
7. In the terminal, type: 
   ```bash
   adb connect <IP>:<NEW_PORT>
   ```

That's it! Your device will now show up in the Android Studio drop-down menu, ready for deployment. Happy building!
