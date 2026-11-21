#!/usr/bin/env python3
import sys, os, json, time, subprocess, datetime
from datetime import date

PRESETS = {
    "25/5": {"name": "Classic", "work": 25 * 60, "break": 5 * 60, "long_break": 15 * 60, "cycles": 4},
    "50/10": {"name": "Deep Work", "work": 50 * 60, "break": 10 * 60, "long_break": 20 * 60, "cycles": 3},
    "15/3": {"name": "Sprint", "work": 15 * 60, "break": 3 * 60, "long_break": 10 * 60, "cycles": 4}
}

STATE_DIR = os.path.expanduser("~/.local/state/omarchy")
os.makedirs(STATE_DIR, exist_ok=True)
STATE_FILE = os.path.join(STATE_DIR, "pomodoro_state.json")
HISTORY_FILE = os.path.join(STATE_DIR, "pomodoro_history.json")

def fmt_time(sec):
    sec = max(0, int(sec))
    m = sec // 60
    s = sec % 60
    return f"{m:02d}:{s:02d}"

def fmt_duration(sec):
    sec = max(0, int(sec))
    m = sec // 60
    if m < 60:
        return f"{m}m"
    h = m // 60
    rem_m = m % 60
    return f"{h}h {rem_m}m" if rem_m > 0 else f"{h}h"

def load_history():
    if os.path.exists(HISTORY_FILE):
        try:
            with open(HISTORY_FILE, "r") as f:
                return json.load(f)
        except Exception:
            pass
    return {}

def record_session(sec_spent):
    history = load_history()
    today_str = str(date.today())
    if today_str not in history:
        history[today_str] = {"completed": 0, "focus_sec": 0}
    history[today_str]["completed"] += 1
    history[today_str]["focus_sec"] += sec_spent
    try:
        tmp = HISTORY_FILE + ".tmp"
        with open(tmp, "w") as f:
            json.dump(history, f, indent=2)
        os.replace(tmp, HISTORY_FILE)
    except Exception:
        pass

def get_weekly_stats():
    history = load_history()
    today = date.today()
    week_completed = 0
    week_sec = 0
    for i in range(7):
        d_str = str(today - datetime.timedelta(days=i))
        if d_str in history:
            week_completed += history[d_str].get("completed", 0)
            week_sec += history[d_str].get("focus_sec", 0)
    return week_completed, week_sec

def play_chime(sound_enabled=True):
    if not sound_enabled:
        return

    sound_files = [
        "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga",
        "/usr/share/sounds/freedesktop/stereo/complete.oga",
        "/usr/share/sounds/freedesktop/stereo/bell.oga",
        "/usr/share/sounds/freedesktop/stereo/message.oga",
        "/usr/share/sounds/freedesktop/stereo/dialog-information.oga"
    ]
    target_sound = None
    for sf in sound_files:
        if os.path.exists(sf):
            target_sound = sf
            break
    if not target_sound:
        return

    for player in ["pw-play", "paplay", "aplay"]:
        try:
            subprocess.Popen([player, target_sound], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            break
        except Exception:
            continue

def send_notification(title, message):
    try:
        subprocess.Popen(
            ["notify-send", title, message, "-i", "alarm-symbolic", "-u", "normal"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except Exception:
        pass

def get_preset_config(preset_key):
    return PRESETS.get(preset_key, PRESETS["25/5"])

def get_default_state():
    cfg = get_preset_config("25/5")
    return {
        "date": str(date.today()),
        "phase": "work",
        "running": False,
        "remaining": cfg["work"],
        "target_ts": None,
        "cycle": 0,
        "completed_today": 0,
        "focus_sec_today": 0,
        "preset": "25/5",
        "sound_enabled": True,
        "onboarding_done": False
    }

def load_state():
    today_str = str(date.today())
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                state = json.load(f)
            # Daily reset
            if state.get("date") != today_str:
                state["date"] = today_str
                state["completed_today"] = 0
                state["focus_sec_today"] = 0
                state["cycle"] = 0
            if "preset" not in state:
                state["preset"] = "25/5"
            if "sound_enabled" not in state:
                state["sound_enabled"] = True
            return state
        except Exception:
            pass
    return get_default_state()

def save_state(state):
    try:
        tmp_file = STATE_FILE + ".tmp"
        with open(tmp_file, "w") as f:
            json.dump(state, f, indent=2)
        os.replace(tmp_file, STATE_FILE)
    except Exception:
        pass

def make_progress_bar(pct, length=12):
    filled = int(round(length * (pct / 100.0)))
    filled = max(0, min(length, filled))
    return "█" * filled + "░" * (length - filled)

def tick(state):
    now = time.time()
    cfg = get_preset_config(state.get("preset", "25/5"))
    sound_enabled = state.get("sound_enabled", True)

    if state["running"] and state.get("target_ts"):
        rem = int(state["target_ts"] - now)
        if rem <= 0:
            # Phase finished!
            play_chime(sound_enabled)
            cur_phase = state["phase"]
            if cur_phase == "work":
                state["completed_today"] += 1
                state["focus_sec_today"] += cfg["work"]
                record_session(cfg["work"])
                state["cycle"] = (state.get("cycle", 0) + 1) % cfg["cycles"]
                if state["cycle"] == 0:
                    state["phase"] = "long_break"
                    state["remaining"] = cfg["long_break"]
                    send_notification("Pomodoro", f"Focus cycle complete! Take a {cfg['long_break'] // 60}-minute break ☕")
                else:
                    state["phase"] = "break"
                    state["remaining"] = cfg["break"]
                    send_notification("Pomodoro", f"Focus session complete! Take a {cfg['break'] // 60}-minute break ☕")
            else:
                state["phase"] = "work"
                state["remaining"] = cfg["work"]
                send_notification("Pomodoro", "Break finished! Ready to focus? 🚀")

            state["running"] = False
            state["target_ts"] = None
        else:
            state["remaining"] = rem
    return state

def handle_toggle(state):
    state = tick(state)
    now = time.time()
    cfg = get_preset_config(state.get("preset", "25/5"))

    if state["running"]:
        # Pause
        if state.get("target_ts"):
            state["remaining"] = max(0, int(state["target_ts"] - now))
        state["running"] = False
        state["target_ts"] = None
    else:
        # Resume / Start
        if state.get("remaining", 0) <= 0:
            if state["phase"] == "work":
                state["remaining"] = cfg["work"]
            elif state["phase"] == "long_break":
                state["remaining"] = cfg["long_break"]
            else:
                state["remaining"] = cfg["break"]
        state["running"] = True
        state["target_ts"] = now + state["remaining"]
    save_state(state)

def handle_skip(state):
    cfg = get_preset_config(state.get("preset", "25/5"))
    cur_phase = state["phase"]
    if cur_phase == "work":
        state["cycle"] = (state.get("cycle", 0) + 1) % cfg["cycles"]
        if state["cycle"] == 0:
            state["phase"] = "long_break"
            state["remaining"] = cfg["long_break"]
        else:
            state["phase"] = "break"
            state["remaining"] = cfg["break"]
    else:
        state["phase"] = "work"
        state["remaining"] = cfg["work"]

    state["running"] = False
    state["target_ts"] = None
    save_state(state)

def handle_reset(state):
    cfg = get_preset_config(state.get("preset", "25/5"))
    state["phase"] = "work"
    state["remaining"] = cfg["work"]
    state["running"] = False
    state["target_ts"] = None
    save_state(state)

def handle_set_preset(state, preset_key):
    if preset_key not in PRESETS:
        return
    state["preset"] = preset_key
    cfg = PRESETS[preset_key]
    state["running"] = False
    state["target_ts"] = None
    state["phase"] = "work"
    state["remaining"] = cfg["work"]
    state["cycle"] = 0
    save_state(state)

def handle_toggle_sound(state):
    state["sound_enabled"] = not state.get("sound_enabled", True)
    save_state(state)

def get_status_payload(state):
    state = tick(state)
    save_state(state)

    preset_key = state.get("preset", "25/5")
    cfg = get_preset_config(preset_key)
    phase = state["phase"]
    running = state["running"]
    rem = state["remaining"]
    sound_enabled = state.get("sound_enabled", True)

    if phase == "work":
        total_sec = cfg["work"]
        phase_label = "Focus"
    elif phase == "long_break":
        total_sec = cfg["long_break"]
        phase_label = "Long Break"
    else:
        total_sec = cfg["break"]
        phase_label = "Break"

    elapsed = max(0, total_sec - rem)
    pct = int(min(100, max(0, round((elapsed / total_sec) * 100)))) if total_sec > 0 else 0

    # Clean dots for completed cycles in current block
    cycle = state.get("cycle", 0)
    max_cycles = cfg["cycles"]
    dots = "●" * cycle + "○" * max(0, max_cycles - cycle)

    # Clean icon
    if phase == "work":
        icon = "󰄉" if running else "󰏤"
    elif phase == "long_break":
        icon = "󰒲"
    else:
        icon = "󰔄"

    # Minimal clean tooltip
    prog_bar = make_progress_bar(pct, 12)
    completed = state.get("completed_today", 0)
    focus_time_str = fmt_duration(state.get("focus_sec_today", 0))

    week_completed, week_sec = get_weekly_stats()
    week_focus_str = fmt_duration(week_sec)

    state_desc = f"{phase_label} ({fmt_time(rem)} left)"
    if not running:
        state_desc += " [Paused]"

    sound_str = "🔔 On" if sound_enabled else "🔕 Muted"

    tooltip_lines = [
        f"{icon} {state_desc}   [{cfg['name']} {preset_key}]",
        "─────────────────────────────",
        f"Progress: [{prog_bar}] {pct}%",
        f"Today:    {completed} sessions ({focus_time_str})",
        f"7 Days:   {week_completed} sessions ({week_focus_str})",
        f"Sound:    {sound_str}",
        "─────────────────────────────",
        "Left: Start/Pause • Right: Settings • Middle: Reset"
    ]

    # First time install notification (Option B)
    if not state.get("onboarding_done", False) and not state.get("onboarding_notif_sent", False):
        send_notification("Pomodoro Timer 󰄉", "Ready to focus! Left click to start, Right click for settings & presets.")
        state["onboarding_notif_sent"] = True
        save_state(state)

    return {
        "phase": phase,
        "phase_label": phase_label,
        "running": running,
        "icon": icon,
        "time_str": fmt_time(rem),
        "sec_remaining": rem,
        "total_sec": total_sec,
        "dots": dots,
        "pct": pct,
        "preset": preset_key,
        "preset_name": cfg["name"],
        "sound_enabled": sound_enabled,
        "completed_today": completed,
        "focus_time_str": focus_time_str,
        "week_completed": week_completed,
        "week_focus_str": week_focus_str,
        "onboarding_done": state.get("onboarding_done", False),
        "tooltip": "\n".join(tooltip_lines)
    }

def main():
    state = load_state()
    action = sys.argv[1] if len(sys.argv) > 1 else "status"

    if action == "toggle":
        handle_toggle(state)
    elif action == "skip":
        handle_skip(state)
    elif action == "reset":
        handle_reset(state)
    elif action == "set_preset":
        preset_arg = sys.argv[2] if len(sys.argv) > 2 else "25/5"
        handle_set_preset(state, preset_arg)
    elif action == "toggle_sound":
        handle_toggle_sound(state)
    elif action == "test_sound":
        play_chime(True)
    elif action == "onboarding_done":
        state["onboarding_done"] = True
        save_state(state)

    payload = get_status_payload(state)
    print(json.dumps(payload))

if __name__ == "__main__":
    main()
