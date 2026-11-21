# Omarchy Pomodoro (`khudoydev.pomodoro`)

A lightweight, distraction-free Pomodoro focus timer widget for Omarchy Linux (Hyprland + Quickshell).

## Design & Philosophy

- **Clean & Minimalist**: Shows only what matters — current phase icon, remaining time, and completed session dots (`●●○○`).
- **Zero Friction**: 
  - **Left Click**: Start / Pause
  - **Right Click**: Skip to next phase (Focus ↔ Break)
  - **Middle Click**: Reset timer
- **Audio & Visual Alerts**: Plays a chime and delivers a desktop notification when a phase ends.
- **Daily Focus Tracking**: Keeps track of completed cycles and total focus time across shell restarts.

## Installation

```bash
omarchy plugin add https://github.com/khudoydev155/omarchy-pomodoro.git --enable
```

Or manually clone into plugins directory:

```bash
git clone https://github.com/khudoydev155/omarchy-pomodoro.git ~/.config/omarchy/plugins/khudoydev.pomodoro
```

Add `"khudoydev.pomodoro"` to your `~/.config/omarchy/shell.json` inside `"bar.layout.right"`:

```json
{
  "id": "khudoydev.pomodoro"
}
```

Then reload:

```bash
omarchy restart shell
```

## License

MIT License. Created by khudoydev.
