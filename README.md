# Omarchy Pomodoro (`khudoydev.pomodoro`)

<div align="center">

[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg?style=for-the-badge)](https://github.com/khudoydev155/omarchy-pomodoro)
[![CI](https://img.shields.io/github/actions/workflow/status/khudoydev155/omarchy-pomodoro/ci.yml?branch=main&label=CI&style=for-the-badge)](https://github.com/khudoydev155/omarchy-pomodoro/actions)
[![Distros](https://img.shields.io/badge/distros-Ubuntu%20%7C%20Debian%20%7C%20Fedora%20%7C%20Arch-orange.svg?style=for-the-badge)](#-cross-distribution-support)
[![Platform](https://img.shields.io/badge/platform-Omarchy%20%7C%20Hyprland%20%7C%20Waybar-7aa2f7.svg?style=for-the-badge)](https://github.com/basecamp/omarchy)
[![Technology](https://img.shields.io/badge/tech-Quickshell%20%E2%80%A2%20QML%20%E2%80%A2%20Python%203-10b981.svg?style=for-the-badge)](#features)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

A production-grade, distraction-free Pomodoro focus timer widget crafted for **[Omarchy Linux](https://github.com/basecamp/omarchy)** (Hyprland + Quickshell) and universally compatible with **Ubuntu, Debian, Fedora, Arch Linux**, and **Waybar**.

Displays real-time focus sessions, cycle progress dots, and delivers desktop notifications with self-contained audio chimes, presets, and 7-day productivity history.

</div>

---

## 📸 Preview

### Top Bar Widget
```text
┌──────────────────────────────────────────────┐
│  [ Tray ]   [ Sysmon ]   [ 󰄉 25:00  ○○○○ ]   │
└──────────────────────────────────────────────┘
```

### Companion Settings & Stats Card (Right Click)
```text
┌──────────────────────────────────────────────┐
│ 󰄉 Pomodoro Focus Timer                    ✕  │
│ Focusing...                                  │
├──────────────────────────────────────────────┤
│ FOCUS MODE                                   │
│ [ 25/5 Classic ] [ 50/10 Deep ] [ 15/3 Fast] │
├──────────────────────────────────────────────┤
│ 🔔 Audio Chime Alerts  [ ▶ Test ] [ Enabled] │
├──────────────────────────────────────────────┤
│ [ 󰏤 Pause ]      [ 󰒭 Skip ]      [ 󰦛 Reset ] │
├──────────────────────────────────────────────┤
│ TODAY: 4 sessions (1h 40m)                   │
│ 7 DAYS: 18 sessions (7h 30m)                 │
└──────────────────────────────────────────────┘
```

### 🖱️ Mouse Controls Cheat Sheet

| Trigger | Action | Behavior |
| :--- | :--- | :--- |
| **Left Click** | **Start / Pause** | Toggles countdown timer (25:00 / 50:00 / 15:00) |
| **Right Click** | **Settings & Stats** | Opens the interactive companion card (presets, sound, 7-day stats) |
| **Middle Click** | **Reset Timer** | Immediately resets the timer back to starting duration |

---

## ✨ Features

- **⚡ Instant Mouse Controls**:
  - **Left Click**: Start / Pause the current session.
  - **Right Click**: Opens the interactive **Settings & Presets Card**.
  - **Middle Click**: Instantly resets the timer back to 25:00.
- **🎯 3 Focus Modes / Presets**:
  - **25/5 Classic**: Standard Pomodoro (25m Focus / 5m Break / 15m Long Break).
  - **50/10 Deep Work**: Extended flow-state sessions for programming and engineering.
  - **15/3 Quick Sprint**: Rapid sprints for task planning and bug squashing.
- **🔔 Zero-Dependency Audio Alerts & Mute Toggle**:
  - Bundled standalone sound assets (`sounds/chime.oga`, `sounds/chime.wav`).
  - Native fallbacks across PipeWire (`pw-play`), PulseAudio (`paplay`), ALSA (`aplay`), and Freedesktop Canberra (`canberra-gtk-play`).
  - Interactive **▶ Test** button to test sound immediately.
- **📊 7-Day Productivity Tracking**:
  - Keeps local daily and 7-day focus statistics in `~/.local/state/omarchy/pomodoro_history.json`.
  - Survives reboots and shell restarts.
- **🎨 100% Theme & Wallpaper Adaptive**:
  - Dynamically adopts Omarchy theme colors, dark/light modes, transparency, and vertical bars.
- **🌐 Cross-Distro & Waybar Ready**:
  - Runs natively on Omarchy/Quickshell, Waybar, or pure Terminal/CLI.

---

## 🐧 Cross-Distribution Support

Omarchy Pomodoro is engineered to run seamlessly across all major Linux distributions without runtime errors or missing dependency crashes:

| Distribution Family | Package Manager Command |
| :--- | :--- |
| **Ubuntu / Debian / Linux Mint / Pop!_OS** | `sudo apt update && sudo apt install -y python3 libnotify-bin sound-theme-freedesktop` |
| **Fedora / RHEL / CentOS / Rocky** | `sudo dnf install -y python3 libnotify sound-theme-freedesktop` |
| **Arch Linux / Omarchy / Manjaro** | `sudo pacman -S --needed python libnotify sound-theme-freedesktop` |
| **openSUSE / SUSE** | `sudo zypper install -y python3 libnotify-tools sound-theme-freedesktop` |

---

## 🚀 One-Line Universal Installation

Run the universal installer in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/khudoydev155/omarchy-pomodoro/main/install.sh | bash
```

The script automatically detects your distribution, verifies dependencies, tests the backend, and registers the plugin.

---

## 📦 Manual Installation

### 1. Clone into Plugins Directory
```bash
git clone https://github.com/khudoydev155/omarchy-pomodoro.git ~/.config/omarchy/plugins/khudoydev.pomodoro
chmod +x ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py
```

### 2. Enable in Omarchy Shell
Add `"khudoydev.pomodoro"` to your `~/.config/omarchy/shell.json` inside `"bar.layout.right"`:

```json
{
  "bar": {
    "layout": {
      "right": [
        { "id": "khudoydev.pomodoro" }
      ]
    }
  }
}
```

Reload the shell:
```bash
omarchy restart shell
```

---

## 🧭 Waybar Configuration (Hyprland / Sway)

For users running **Waybar** on Ubuntu, Debian, Fedora, or Arch Linux, add this to `~/.config/waybar/config`:

```json
"custom/pomodoro": {
    "exec": "python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py waybar",
    "return-type": "json",
    "interval": 1,
    "on-click": "python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py toggle",
    "on-click-right": "python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py skip",
    "on-click-middle": "python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py reset"
}
```

And style in `~/.config/waybar/style.css`:
```css
#custom-pomodoro {
    color: #89b4fa;
    padding: 0 10px;
}
#custom-pomodoro.break {
    color: #a6e3a1;
}
```

---

## 💻 Terminal / CLI Usage

You can also control the timer directly from any terminal or script:

```bash
# View terminal status dashboard
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py cli

# Start or Pause
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py toggle

# Skip to Break or Work
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py skip

# Reset timer
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py reset

# Switch mode: 25/5 | 50/10 | 15/3
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py set_preset 50/10

# Test audio output
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py test_sound
```

---

## 📂 Project Structure

```text
omarchy-pomodoro/
├── .github/
│   └── workflows/
│       └── ci.yml          # GitHub Actions CI workflow (syntax & self-test)
├── sounds/
│   ├── chime.oga           # Bundled standalone Ogg audio chime (20 KB)
│   └── chime.wav           # Bundled standalone WAV fallback for ALSA (47 KB)
├── BarWidget.qml           # Quickshell interactive QML widget & companion card
├── pomodoro.py             # Python state machine, timers, Waybar & CLI backend
├── install.sh              # Universal cross-distro auto-installer
├── manifest.json           # Omarchy plugin descriptor
├── CONTRIBUTING.md         # Developer contribution guidelines
├── LICENSE                 # MIT License
└── README.md               # Documentation & guides
```

---

## 📄 License

MIT © [Muhammad Xudayberganov (khudoydev155)](https://github.com/khudoydev155)
