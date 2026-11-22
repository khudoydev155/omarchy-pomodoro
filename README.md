<div align="center">

# 🍅 Omarchy Pomodoro (`khudoydev.pomodoro`)

**Production-grade, distraction-free Pomodoro focus timer widget for Linux bars.**

[![Release](https://img.shields.io/github/v/tag/khudoydev155/omarchy-pomodoro?label=version&color=3b82f6&style=for-the-badge)](https://github.com/khudoydev155/omarchy-pomodoro/releases)
[![CI Status](https://img.shields.io/github/actions/workflow/status/khudoydev155/omarchy-pomodoro/ci.yml?branch=main&label=CI&style=for-the-badge)](https://github.com/khudoydev155/omarchy-pomodoro/actions)
[![Distros](https://img.shields.io/badge/distros-Ubuntu%20%7C%20Debian%20%7C%20Fedora%20%7C%20Arch%20%7C%20openSUSE-ea580c?style=for-the-badge)](#-distribution-install-commands)
[![Desktop](https://img.shields.io/badge/desktop-Omarchy%20%7C%20Hyprland%20%7C%20Waybar-7aa2f7?style=for-the-badge)](#-bar-configuration)
[![License: MIT](https://img.shields.io/badge/license-MIT-10b981?style=for-the-badge)](LICENSE)

Designed for **[Omarchy Linux](https://github.com/basecamp/omarchy)** (Hyprland + Quickshell) and universally compatible with **GNOME Desktop (Fedora, Ubuntu, Debian)**, **Waybar**, and all major Linux distributions.

[Quick Install](#-1-line-universal-installation) • [Distro Setup](#-distribution-install-commands) • [Bar Setup](#-bar-configuration) • [CLI Usage](#-terminal--cli-usage) • [Contributing](#-contributing)

</div>

---

## 📸 Preview

### Top Bar Widget (Omarchy / GNOME / Waybar)
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

---

## ⚡ 1-Line Universal Installation

The fastest way to install on **any Linux distribution** (Arch, Fedora, Ubuntu, Debian, openSUSE):

```bash
curl -fsSL https://raw.githubusercontent.com/khudoydev155/omarchy-pomodoro/main/install.sh | bash
```

> **What the installer automatically does:**
> - 🏹 **Omarchy Shell**: Auto-registers in `~/.config/omarchy/shell.json` and reloads the bar immediately.
> - 🎩 **Fedora / Ubuntu GNOME**: Installs & enables the native GNOME Shell Extension (`omarchy-pomodoro@khudoydev.github.com`) on your top bar.
> - 🌊 **Waybar (Hyprland / Sway)**: Auto-configures `~/.config/waybar/config` and reloads Waybar.

---

## 📦 Distribution Install Commands

> 💡 **Two-step setup**:
> 1. Run the commands for your distribution below to install packages and download the plugin.
> 2. Then follow [🧩 Bar Configuration](#-bar-configuration) to enable it in **Omarchy Shell** or **Waybar**.

### 🏹 Arch Linux / Omarchy / Manjaro / EndeavourOS

#### Option A: Via Omarchy Plugin Manager
```bash
omarchy plugin add https://github.com/khudoydev155/omarchy-pomodoro.git --enable
```

#### Option B: Manual Installation (Pacman)
```bash
sudo pacman -S --needed python libnotify sound-theme-freedesktop git
git clone https://github.com/khudoydev155/omarchy-pomodoro.git ~/.config/omarchy/plugins/khudoydev.pomodoro
chmod +x ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py
```

---

### 🐧 Ubuntu / Debian / Linux Mint / Pop!_OS
```bash
sudo apt update && sudo apt install -y python3 libnotify-bin sound-theme-freedesktop git
git clone https://github.com/khudoydev155/omarchy-pomodoro.git ~/.config/omarchy/plugins/khudoydev.pomodoro
chmod +x ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py
```

---

### 🎩 Fedora / RHEL / CentOS / Rocky Linux / AlmaLinux
```bash
sudo dnf install -y python3 libnotify sound-theme-freedesktop git
git clone https://github.com/khudoydev155/omarchy-pomodoro.git ~/.config/omarchy/plugins/khudoydev.pomodoro
chmod +x ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py
```

---

### 🦎 openSUSE (Tumbleweed / Leap)
```bash
sudo zypper install -y python3 libnotify-tools sound-theme-freedesktop git
git clone https://github.com/khudoydev155/omarchy-pomodoro.git ~/.config/omarchy/plugins/khudoydev.pomodoro
chmod +x ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py
```

---

### 🏔️ Alpine Linux
```bash
sudo apk add python3 libnotify alsa-utils git
git clone https://github.com/khudoydev155/omarchy-pomodoro.git ~/.config/omarchy/plugins/khudoydev.pomodoro
chmod +x ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py
```

---

### ❄️ NixOS / Nix
Add to your `configuration.nix`:
```nix
environment.systemPackages = with pkgs; [
  python3
  libnotify
  sound-theme-freedesktop
  git
];
```

---

## 🧩 Bar Configuration

### 1. Omarchy Shell (Hyprland + Quickshell)

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

Reload the shell to activate immediately:
```bash
omarchy restart shell
```

---

### 2. GNOME Shell (Fedora, Ubuntu, Debian, Pop!_OS)

Our 1-line installer automatically installs and configures the native GNOME Topbar Extension.

To activate immediately or enable after first login on Fedora GNOME:
```bash
gsettings set org.gnome.shell disable-user-extensions false
gnome-extensions enable omarchy-pomodoro@khudoydev.github.com
```

> 💡 **Tip**: If just installed on Wayland, log out and log back in, then run the enable command above. Check status anytime with:
> `gnome-extensions info omarchy-pomodoro@khudoydev.github.com`

---

### 3. Waybar (Hyprland / Sway on Ubuntu, Debian, Fedora, Arch)

Add this module block to your `~/.config/waybar/config`:

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

Add this styling to `~/.config/waybar/style.css`:

```css
#custom-pomodoro {
    color: #89b4fa;
    padding: 0 10px;
    font-weight: bold;
}
#custom-pomodoro.break {
    color: #a6e3a1;
}
#custom-pomodoro.long_break {
    color: #f9e2af;
}
```

---

## 🖱️ Mouse Controls Cheat Sheet

| Trigger | Action | Behavior |
| :--- | :--- | :--- |
| **Left Click** | **Start / Pause** | Toggles countdown timer (25:00 / 50:00 / 15:00) |
| **Right Click** | **Settings & Stats** | Opens the interactive companion card (presets, sound, 7-day stats) |
| **Middle Click** | **Reset Timer** | Immediately resets the timer back to starting duration |

---

## ✨ Features

- **🎯 3 Built-in Focus Modes**:
  - **`25/5 Classic`**: Standard Pomodoro (25m Focus / 5m Break / 15m Long Break, 4 cycles).
  - **`50/10 Deep Work`**: Extended flow-state blocks for software engineering and deep writing.
  - **`15/3 Quick Sprint`**: Rapid sprints for task planning, email triage, and bug squashing.
- **🔔 Zero-Dependency Audio Chimes**:
  - Bundled standalone sound assets (`sounds/chime.oga`, `sounds/chime.wav`).
  - Seamless fallbacks: `canberra-gtk-play` → `pw-play` (PipeWire) → `paplay` (PulseAudio) → `aplay` (ALSA).
  - Interactive **▶ Test** button to audition the chime instantly.
- **📊 7-Day Productivity Tracking**:
  - Automatically records completed focus sessions and total focus time.
  - Saved locally in `~/.local/state/omarchy/pomodoro_history.json` (survives reboots).
- **🎨 100% Theme Adaptive**:
  - Matches Omarchy system colors, dark/light themes, transparency, and vertical bars.
- **🛡️ Rock-Solid Stability**:
  - Zero auto-popup interruptions, safe `shutil.which` checks, and full try/except handlers.

---

## 💻 Terminal / CLI Usage

You can control and query the timer directly from any terminal or script:

```bash
# Display terminal status dashboard
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py cli

# Start or Pause session
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py toggle

# Skip to Break or Work phase
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py skip

# Reset timer back to start
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py reset

# Switch preset: 25/5 | 50/10 | 15/3
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py set_preset 50/10

# Toggle audio chime alerts
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py toggle_sound

# Test audio chime output
python3 ~/.config/omarchy/plugins/khudoydev.pomodoro/pomodoro.py test_sound
```

---

## 📂 Project Structure

```text
omarchy-pomodoro/
├── .github/
│   └── workflows/
│       └── ci.yml          # GitHub Actions CI automated validation
├── sounds/
│   ├── chime.oga           # Bundled standalone Ogg audio chime (20 KB)
│   └── chime.wav           # Bundled standalone WAV fallback for ALSA (47 KB)
├── BarWidget.qml           # Quickshell interactive QML widget & companion card
├── pomodoro.py             # Python state machine, timers, Waybar & CLI backend
├── install.sh              # Universal cross-distro auto-installer
├── manifest.json           # Omarchy plugin descriptor
├── CONTRIBUTING.md         # Developer contribution guidelines
├── LICENSE                 # MIT License
└── README.md               # Comprehensive documentation
```

---

## 🤝 Contributing

Contributions are warmly welcomed! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) guide for details on local testing and pull request standards.

---

## 📄 License

Distributed under the [MIT License](LICENSE). Built with ❤️ by [Muhammad Xudayberganov (khudoydev155)](https://github.com/khudoydev155).
