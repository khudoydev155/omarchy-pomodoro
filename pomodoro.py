#!/usr/bin/env python3
import sys, os, json, time, subprocess
from datetime import date

WORK_SEC = 25 * 60
SHORT_BREAK_SEC = 5 * 60
LONG_BREAK_SEC = 15 * 60
CYCLES_BEFORE_LONG = 4

STATE_DIR = os.path.expanduser("~/.local/state/omarchy")
os.makedirs(STATE_DIR, exist_ok=True)
STATE_FILE = os.path.join(STATE_DIR, "pomodoro_state.json")

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

def play_chime():
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

def get_default_state():
    return {
        "date": str(date.today()),
        "phase": "work",
        "running": False,
        "remaining": WORK_SEC,
        "target_ts": None,
        "cycle": 0,
        "completed_today": 0,
        "focus_sec_today": 0
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
    if state["running"] and state.get("target_ts"):
        rem = int(state["target_ts"] - now)
        if rem <= 0:
            # Phase finished!
            play_chime()
            cur_phase = state["phase"]
            if cur_phase == "work":
                state["completed_today"] += 1
                state["focus_sec_today"] += WORK_SEC
                state["cycle"] = (state.get("cycle", 0) + 1) % CYCLES_BEFORE_LONG
                if state["cycle"] == 0:
                    state["phase"] = "long_break"
                    state["remaining"] = LONG_BREAK_SEC
                    send_notification("Pomodoro", "Work cycle complete! Take a 15-minute break ☕")
                else:
                    state["phase"] = "break"
                    state["remaining"] = SHORT_BREAK_SEC
                    send_notification("Pomodoro", "Focus session complete! Take a 5-minute break ☕")
            else:
                state["phase"] = "work"
                state["remaining"] = WORK_SEC
                send_notification("Pomodoro", "Break finished! Ready to focus? 🚀")

            state["running"] = False
            state["target_ts"] = None
        else:
            state["remaining"] = rem
    return state

def handle_toggle(state):
    state = tick(state)
    now = time.time()
    if state["running"]:
        # Pause
        if state.get("target_ts"):
            state["remaining"] = max(0, int(state["target_ts"] - now))
        state["running"] = False
        state["target_ts"] = None
    else:
        # Resume / Start
        if state["remaining"] <= 0:
            if state["phase"] == "work":
                state["remaining"] = WORK_SEC
            elif state["phase"] == "long_break":
                state["remaining"] = LONG_BREAK_SEC
            else:
                state["remaining"] = SHORT_BREAK_SEC
        state["running"] = True
        state["target_ts"] = now + state["remaining"]
    save_state(state)

def handle_skip(state):
    cur_phase = state["phase"]
    if cur_phase == "work":
        state["cycle"] = (state.get("cycle", 0) + 1) % CYCLES_BEFORE_LONG
        if state["cycle"] == 0:
            state["phase"] = "long_break"
            state["remaining"] = LONG_BREAK_SEC
        else:
            state["phase"] = "break"
            state["remaining"] = SHORT_BREAK_SEC
    else:
        state["phase"] = "work"
        state["remaining"] = WORK_SEC

    state["running"] = False
    state["target_ts"] = None
    save_state(state)

def handle_reset(state):
    state["phase"] = "work"
    state["remaining"] = WORK_SEC
    state["running"] = False
    state["target_ts"] = None
    save_state(state)

def get_status_payload(state):
    state = tick(state)
    save_state(state)

    phase = state["phase"]
    running = state["running"]
    rem = state["remaining"]

    if phase == "work":
        total_sec = WORK_SEC
        phase_label = "Focus"
    elif phase == "long_break":
        total_sec = LONG_BREAK_SEC
        phase_label = "Long Break"
    else:
        total_sec = SHORT_BREAK_SEC
        phase_label = "Break"

    elapsed = max(0, total_sec - rem)
    pct = int(min(100, max(0, round((elapsed / total_sec) * 100)))) if total_sec > 0 else 0

    # Clean dots for completed cycles in current block of 4
    cycle = state.get("cycle", 0)
    dots = "●" * cycle + "○" * (CYCLES_BEFORE_LONG - cycle)

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

    state_desc = f"{phase_label} ({fmt_time(rem)} left)"
    if not running:
        state_desc += " [Paused]"

    tooltip_lines = [
        f"{icon} {state_desc}",
        "─────────────────────────────",
        f"Progress: [{prog_bar}] {pct}%",
        f"Today:    {completed} completed ({focus_time_str})",
        "─────────────────────────────",
        "Left: Start/Pause • Right: Skip • Middle: Reset"
    ]

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
        "completed_today": completed,
        "focus_time_str": focus_time_str,
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

    payload = get_status_payload(state)
    print(json.dumps(payload))

if __name__ == "__main__":
    main()
