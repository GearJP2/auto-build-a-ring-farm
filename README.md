# 🚜 Roblox: Build A Ring Multi-Farm Tool (GUI Version)

> **Automate your farming loops seamlessly.** This repository contains an integrated, high-performance AutoHotkey (AHK) v2 macro system with a modern Graphical User Interface (GUI). Toggle between tasks, track automation status, and safeguard your account with simple hotkeys.

---

## 🛠️ Key Features
* **All-in-One GUI:** No more managing separate files. Choose your task right from the interface.
* **State Machine Logic:** The seed loop runs on a non-blocking step-by-step state engine for high stability.
* **Robust Fail-safes:** Auto-clears stuck keys (`W`, `A`, `S`, `D`, `E`) upon pausing or closing.
* **Audio Feedback:** Distinct high/low beeps tell you when the macro starts or pauses without needing to look at the app.

---

## 📦 Installation & Requirements

1. **Download AutoHotkey v2:** Make sure you have the modern [AutoHotkey v2.0 Installer](https://www.autohotkey.com/download/ahk-v2.exe) installed on your PC.
2. **Download the Macro:** Grab the `BuildARing_Combo.ahk` file from this repository.
3. **Run as Administrator:** Right-click the script and select **"Run as Administrator"** (Crucial for Roblox to accept virtual inputs).

---

## 🎮 Setup & Gameplay Instructions

Launch the GUI, click the radio button for your desired script, and position your character inside Roblox:

### 🌾 Mode 1: Auto-Buy Seeds (State Machine)
* **Setup Position:** Stand directly behind the lever. Step as close to it as possible.
* **Camera Angle:** Look directly, vertically down at the floor.
* **How it works:** Pulls the lever $\rightarrow$ waits 10 seconds $\rightarrow$ sweeps across all 3 front platforms $\rightarrow$ sweeps across all 3 back platforms $\rightarrow$ walks back to the lever and resets.

### 🥚 Mode 2: Auto-Buy Eggs (15-Loop Sequence)
* **Setup Position:** Walk inside the buying shelf and align your character flat against the corner boundary wall of either side.
* **Camera Angle:** Look straight ahead, then tilt your camera down slightly until the first egg purchase interaction prompt is clearly visible.
* **How it works:** Interacts with the shelf for 1 second $\rightarrow$ executes a 15-cycle micro-step and purchase routine $\rightarrow$ runs backward for 10 seconds to reset position $\rightarrow$ repeats.

---

## ⌨️ Controls & Hotkeys

| Hotkey | Action | Description |
| :---: | :--- | :--- |
| **`F1`** | **Start / Pause** | Toggles the active macro loop on or off. Safely updates the GUI status display. |
| **`F4`** | **Emergency Exit** | Instantly stops all inputs, un-jams stuck keys, and shuts down the application. |

---

## 📋 GUI Status States

* <span style="color:red">**STATUS: IDLE**</span> - The app is loaded and waiting for you to press `F1`.
* <span style="color:green">**STATUS: RUNNING (Seeds/Eggs)**</span> - The macro is actively controlling your character.
* <span style="color:orange">**EXITING...**</span> - The tool is shutting down and clearing keyboard buffers.

---

> 💡 **Troubleshooting Tip:** If your GUI opens properly but nothing happens when you press `F1` in-game, close the macro entirely. Right-click the `.ahk` file and select **Run as Administrator**. Roblox's security client prevents non-admin software from feeding virtual keystrokes to the player window.
