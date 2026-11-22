# Contributing to Omarchy Pomodoro

Thank you for your interest in contributing to **Omarchy Pomodoro**! We welcome bug reports, feature suggestions, UI polish, and pull requests.

## 🛠 Local Development & Testing

1. **Clone the repository**:
   ```bash
   git clone https://github.com/khudoydev155/omarchy-pomodoro.git ~/.config/omarchy/plugins/khudoydev.pomodoro
   cd ~/.config/omarchy/plugins/khudoydev.pomodoro
   ```

2. **Test the backend Python script**:
   ```bash
   # Status check
   python3 pomodoro.py status

   # Waybar module output
   python3 pomodoro.py waybar

   # Terminal CLI dashboard
   python3 pomodoro.py cli

   # Audio chime output
   python3 pomodoro.py test_sound
   ```

3. **Reload Quickshell in Omarchy**:
   ```bash
   omarchy restart shell
   ```

4. **Inspect logs**:
   ```bash
   journalctl _PID=$(pgrep -n quickshell) --no-pager | tail -n 30
   ```

## 📋 Pull Request Guidelines

- Ensure `python3 -m py_compile pomodoro.py` and `bash -n install.sh` pass without errors.
- Keep UI text clean, minimal, and in international English.
- Avoid hardcoded paths (e.g. use `python3` instead of `/usr/bin/python3`).
- Wrap external system commands (`notify-send`, audio players) in safe checks with `shutil.which`.

## 📄 License
By contributing, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).
