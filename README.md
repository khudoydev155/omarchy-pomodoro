# Omarchy Pomodoro (`khudoydev.pomodoro`)

A lightweight, distraction-free Pomodoro focus timer widget built for **Omarchy Linux** (Hyprland + Quickshell).

---

## 📸 Preview

### Top Bar Appearance
```text
┌───────────────────────────────────────────────┐
│   [ Tray ]   [ Sysmon ]   [ 󰄉 25:00  ○○○○ ]   │
└───────────────────────────────────────────────┘
```

### Interactive Hover Tooltip
```text
󰄉 Focus Session (24:18 left)
─────────────────────────────
Progress: [██████░░░░░░] 50%
Today:    4 completed (1h 40m)
─────────────────────────────
Left: Start/Pause • Right: Skip • Middle: Reset
```

---

## 🚀 How It Works (Step-by-Step)

1. **Start Focusing (Left Click)**:
   - Click the widget with your **left mouse button**.
   - The countdown immediately begins ticking (`24:59`, `24:58`...) and turns bright/vibrant.
   - Click again anytime to pause.

2. **Take a Break (Right Click or Auto-Timer)**:
   - When the 25-minute session completes, a pleasant audio chime plays and a desktop alert notifies you.
   - You can also skip directly to a 5-minute break anytime with a **right click**.
   - The widget turns a soothing break accent color (`󰔄 05:00`).

3. **Reset Session (Middle Click)**:
   - Click with your **middle mouse button** (scroll wheel) to reset back to a fresh 25:00 focus state.

4. **First-Time Welcome Card**:
   - On the very first launch, a sleek interactive onboarding card pops down directly from the widget to introduce all actions.
   - Click **"Start Focusing 🚀"** to close it and start your timer.

---

## 📦 Installation

Install directly using the Omarchy plugin CLI:

```bash
omarchy plugin add https://github.com/khudoydev155/omarchy-pomodoro.git --enable
```

Or manually clone it into your plugins directory:

```bash
git clone https://github.com/khudoydev155/omarchy-pomodoro.git ~/.config/omarchy/plugins/khudoydev.pomodoro
```

Then add `"khudoydev.pomodoro"` to your bar layout in `~/.config/omarchy/shell.json`:

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

Reload the Omarchy shell to activate:

```bash
omarchy restart shell
```

---

## ⚙️ Features

- **Zero Clutter**: Clean monospaced digits with subtle phase glyph and discrete cycle dots (`●●○○`).
- **Fully Adaptive**: Automatically follows your Omarchy theme colors, dark/light modes, transparency, and vertical bars.
- **Persistent Progress**: Survives shell restarts and computer reboots without losing today's focus count.
- **Native Audio & Alerts**: Utilizes system sound chimes via PipeWire / PulseAudio and desktop notifications.

---

## 📄 License

MIT License. Created by [khudoydev](https://github.com/khudoydev155).
