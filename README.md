# Omarchy Pomodoro (`khudoydev.pomodoro`)

<div align="center">

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg?style=for-the-badge)](https://github.com/khudoydev155/omarchy-pomodoro)
[![Platform](https://img.shields.io/badge/platform-Omarchy%20%7C%20Hyprland-7aa2f7.svg?style=for-the-badge)](https://github.com/basecamp/omarchy)
[![Technology](https://img.shields.io/badge/tech-Quickshell%20%E2%80%A2%20QML%20%E2%80%A2%20Python%203-10b981.svg?style=for-the-badge)](#features)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

A production-grade, distraction-free Pomodoro focus timer widget crafted for **[Omarchy Linux](https://github.com/basecamp/omarchy)** (Hyprland + Quickshell).

Displays real-time focus sessions, cycle progress dots, and delivers desktop notifications with sound chimes, presets, and productivity history.

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
│ 🔔 Audio Chime Alerts            [ Enabled ] │
├──────────────────────────────────────────────┤
│ [ 󰏤 Pause ]      [ 󰒭 Skip ]      [ 󰦛 Reset ] │
├──────────────────────────────────────────────┤
│ TODAY: 4 sessions (1h 40m)                   │
│ 7 DAYS: 18 sessions (7h 30m)                 │
└──────────────────────────────────────────────┘
```

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
- **🔔 Audio Alerts & Mute Toggle**:
  - System sound chimes (`pw-play` / `paplay`) when sessions end.
  - Toggle audio on or mute anytime from the settings card.
- **📊 Productivity Tracking**:
  - Keeps local daily and 7-day focus statistics in `~/.local/state/omarchy/pomodoro_history.json`.
  - Survives reboots and shell restarts.
- **🎨 100% Theme & Wallpaper Adaptive**:
  - Dynamically adopts Omarchy theme colors, dark/light modes, transparency, and vertical bars.

---

## 🚀 Installation

Install via the Omarchy plugin CLI:

```bash
omarchy plugin add https://github.com/khudoydev155/omarchy-pomodoro.git --enable
```

Or manually clone it into your plugins directory:

```bash
git clone https://github.com/khudoydev155/omarchy-pomodoro.git ~/.config/omarchy/plugins/khudoydev.pomodoro
```

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

## 📄 License

MIT License. Created by [khudoydev](https://github.com/khudoydev155).
