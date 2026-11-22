import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "khudoydev.pomodoro"

  property string fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
  property color barForeground: root.bar ? root.bar.barForeground : Commons.Color.foreground
  property color urgentColor: root.bar ? root.bar.urgent : Commons.Color.urgent
  property color accentColor: Commons.Color.accent

  readonly property bool isVertical: root.bar ? (root.bar.vertical === true) : false

  readonly property int mainFontSize: Math.max(9, root.isVertical ? Style.font.caption - 1 : Style.font.caption)
  readonly property int subFontSize: Math.max(7, Style.font.caption - 2)

  property bool pressable: true
  property bool interactive: true

  property string phase: "work"
  property bool isRunning: false
  property string iconText: "󰏤"
  property string timeText: "25:00"
  property string dotsText: "○○○○"
  property int secondsLeft: 1500
  property int progressPct: 0

  // Presets and Sound states
  property string currentPreset: "25/5"
  property string currentPresetName: "Classic"
  property bool soundEnabled: true
  property int completedToday: 0
  property string focusTimeStr: "0m"
  property int weekCompleted: 0
  property string weekFocusStr: "0m"

  property string tooltipText: "󰏤 Focus (25:00 left) [Paused]\n─────────────────────────────\nProgress: [░░░░░░░░░░░░] 0%\nToday:    0 sessions (0m)\n─────────────────────────────\nLeft: Start/Pause • Right: Settings • Middle: Reset"

  // Settings Card modal state
  property bool cardOpen: false
  property bool onboardingDismissed: false

  // Adaptive geometry that smoothly resizes for any font scale and vertical/horizontal bars
  implicitWidth: root.isVertical ? root.barSize : Math.max(Style.space(80), contentRow.implicitWidth + Style.space(16))
  implicitHeight: root.isVertical ? Math.max(Style.space(76), contentCol.implicitHeight + Style.space(12)) : root.barSize

  signal pressed(int button)

  function formatTime(sec) {
    sec = Math.max(0, Math.floor(sec))
    var m = Math.floor(sec / 60)
    var s = sec % 60
    var mStr = (m < 10 ? "0" : "") + m
    var sStr = (s < 10 ? "0" : "") + s
    return mStr + ":" + sStr
  }

  function triggerPress(button) {
    if (button === Qt.RightButton) {
      root.cardOpen = !root.cardOpen
    } else if (button === Qt.MiddleButton) {
      root.runAction("reset")
    } else {
      root.runAction("toggle")
    }
  }

  function parseOutput(raw) {
    if (!raw) return
    var data
    try {
      data = JSON.parse(String(raw).trim())
    } catch (e) {
      return
    }

    root.phase = data.phase || "work"
    root.isRunning = data.running || false
    root.iconText = data.icon || (root.isRunning ? "󰄉" : "󰏤")

    if (data.sec_remaining !== undefined && data.sec_remaining !== null) {
      root.secondsLeft = data.sec_remaining
      root.timeText = root.formatTime(root.secondsLeft)
    } else if (data.time_str) {
      root.timeText = data.time_str
    }

    root.dotsText = data.dots || "○○○○"
    root.progressPct = data.pct || 0
    root.currentPreset = data.preset || "25/5"
    root.currentPresetName = data.preset_name || "Classic"
    root.soundEnabled = data.sound_enabled !== undefined ? data.sound_enabled : true
    root.completedToday = data.completed_today || 0
    root.focusTimeStr = data.focus_time_str || "0m"
    root.weekCompleted = data.week_completed || 0
    root.weekFocusStr = data.week_focus_str || "0m"
    root.tooltipText = data.tooltip || ""

    if (pomodoroMouseArea.containsMouse && root.bar) {
      root.bar.showTooltip(root, root.tooltipText)
    }
  }

  function runAction(act, arg) {
    // Instant optimistic UI feedback
    if (act === "toggle") {
      root.isRunning = !root.isRunning
      if (root.isRunning) {
        root.iconText = root.phase === "work" ? "󰄉" : (root.phase === "long_break" ? "󰒲" : "󰔄")
      } else {
        root.iconText = "󰏤"
      }
    } else if (act === "reset") {
      root.isRunning = false
      root.phase = "work"
      var dur = root.currentPreset === "50/10" ? 3000 : (root.currentPreset === "15/3" ? 900 : 1500)
      root.secondsLeft = dur
      root.timeText = root.formatTime(dur)
      root.iconText = "󰏤"
      root.progressPct = 0
    } else if (act === "skip") {
      root.isRunning = false
      if (root.phase === "work") {
        root.phase = "break"
        var bdur = root.currentPreset === "50/10" ? 600 : (root.currentPreset === "15/3" ? 180 : 300)
        root.secondsLeft = bdur
        root.timeText = root.formatTime(bdur)
        root.iconText = "󰔄"
      } else {
        root.phase = "work"
        var wdur = root.currentPreset === "50/10" ? 3000 : (root.currentPreset === "15/3" ? 900 : 1500)
        root.secondsLeft = wdur
        root.timeText = root.formatTime(wdur)
        root.iconText = "󰏤"
      }
    } else if (act === "set_preset") {
      root.currentPreset = arg
      root.isRunning = false
      root.phase = "work"
      var pdur = arg === "50/10" ? 3000 : (arg === "15/3" ? 900 : 1500)
      root.secondsLeft = pdur
      root.timeText = root.formatTime(pdur)
      root.dotsText = arg === "50/10" ? "○○○" : "○○○○"
    } else if (act === "toggle_sound") {
      root.soundEnabled = !root.soundEnabled
    } else if (act === "onboarding_done") {
      root.cardOpen = false
      root.onboardingDismissed = true
    }

    // Execute Python action immediately
    var cmd = ["python3", Qt.resolvedUrl("pomodoro.py").toString().replace("file://", ""), act]
    if (arg) cmd.push(arg)

    actionProc.running = false
    actionProc.command = cmd
    actionProc.running = true
  }

  // Dedicated process for user-triggered click actions
  Process {
    id: actionProc
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseOutput(text)
    }
  }

  // Dedicated process for background status polling
  Process {
    id: statusProc
    command: ["python3", Qt.resolvedUrl("pomodoro.py").toString().replace("file://", ""), "status"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.parseOutput(text)
    }
  }

  // 1-second continuous tick timer for fluid live countdown
  Timer {
    id: tickTimer
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (root.isRunning) {
        if (root.secondsLeft > 0) {
          root.secondsLeft = root.secondsLeft - 1
          root.timeText = root.formatTime(root.secondsLeft)
        }
      }

      // Keep in sync with Python backend state
      if (!statusProc.running && !actionProc.running) {
        statusProc.running = true
      }

      if (pomodoroMouseArea.containsMouse && root.bar) {
        root.bar.showTooltip(root, root.tooltipText)
      }
    }
  }

  Item {
    id: contentItem
    anchors.fill: parent

    // Tactile hover feedback that matches any background wallpaper & bar theme
    Rectangle {
      anchors.fill: parent
      anchors.margins: Style.space(2)
      radius: Style.space(4)
      color: root.barForeground
      opacity: pomodoroMouseArea.containsMouse ? 0.08 : 0.0

      Behavior on opacity {
        NumberAnimation { duration: 150 }
      }
    }

    // 1. HORIZONTAL BAR LAYOUT (Default top/bottom bar)
    Row {
      id: contentRow
      visible: !root.isVertical
      anchors.centerIn: parent
      spacing: Style.space(6)

      // Phase Icon
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.iconText
        font.family: root.fontFamily
        font.pixelSize: root.mainFontSize + 2
        color: root.phase !== "work" ? root.accentColor : root.barForeground
        opacity: root.isRunning ? 1.0 : 0.65
        renderType: Text.NativeRendering

        Behavior on opacity {
          NumberAnimation { duration: 180 }
        }
      }

      // Countdown Time
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.timeText
        font.family: root.fontFamily
        font.pixelSize: root.mainFontSize
        font.bold: root.isRunning
        color: root.phase !== "work" ? root.accentColor : root.barForeground
        opacity: root.isRunning ? 1.0 : 0.75
        renderType: Text.NativeRendering
      }

      // Session Dots (●●○○)
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.dotsText
        font.family: root.fontFamily
        font.pixelSize: root.subFontSize
        color: root.barForeground
        opacity: 0.50
        renderType: Text.NativeRendering
      }
    }

    // 2. VERTICAL BAR LAYOUT (For left/right side bars)
    Column {
      id: contentCol
      visible: root.isVertical
      anchors.centerIn: parent
      spacing: Style.space(2)

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.iconText
        font.family: root.fontFamily
        font.pixelSize: root.mainFontSize + 1
        color: root.phase !== "work" ? root.accentColor : root.barForeground
        opacity: root.isRunning ? 1.0 : 0.65
        renderType: Text.NativeRendering
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.timeText
        font.family: root.fontFamily
        font.pixelSize: root.subFontSize + 1
        font.bold: root.isRunning
        color: root.phase !== "work" ? root.accentColor : root.barForeground
        opacity: root.isRunning ? 1.0 : 0.75
        renderType: Text.NativeRendering
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.dotsText
        font.family: root.fontFamily
        font.pixelSize: root.subFontSize - 1
        color: root.barForeground
        opacity: 0.50
        renderType: Text.NativeRendering
      }
    }

    MouseArea {
      id: pomodoroMouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

      onEntered: {
        if (!statusProc.running && !actionProc.running) {
          statusProc.running = true
        }
        if (root.bar) root.bar.showTooltip(root, root.tooltipText)
      }

      onExited: {
        if (root.bar) root.bar.hideTooltip(root)
      }

      onClicked: (mouse) => {
        root.triggerPress(mouse.button)
      }
    }
  }

  // Interactive Settings, Presets & Controls Card
  Loader {
    id: cardLoader
    active: root.cardOpen && !!root.bar
    sourceComponent: Component {
      PopupCard {
        id: settingsPopup
        anchorItem: root
        bar: root.bar
        owner: root
        open: root.cardOpen
        margin: Style.gapsOut
        onOpenChanged: {
          if (!open) {
            root.cardOpen = false
            root.onboardingDismissed = true
            root.runAction("onboarding_done")
          }
        }
        contentWidth: Style.space(340)
        contentHeight: cardCol.implicitHeight + Style.space(28)

        Column {
          id: cardCol
          anchors.fill: parent
          spacing: Style.space(12)

          // 1. Header with icon, title, and close button (✕)
          Item {
            width: parent.width
            height: Math.max(headerRow.implicitHeight, closeBtn.height)

            Row {
              id: headerRow
              spacing: Style.space(10)
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter

              Text {
                text: "󰄉"
                font.family: root.fontFamily
                font.pixelSize: Style.font.title + 6
                color: root.accentColor
              }

              Column {
                Text {
                  text: "Pomodoro Focus Timer"
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.title
                  font.bold: true
                  color: root.barForeground
                }
                Text {
                  text: root.phase === "work" ? (root.isRunning ? "Focusing..." : "Paused") : "Break Time"
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption
                  color: root.phase !== "work" ? root.accentColor : root.barForeground
                  opacity: 0.75
                }
              }
            }

            Rectangle {
              id: closeBtn
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              width: Style.space(26)
              height: Style.space(26)
              radius: Style.space(13)
              color: closeHover.containsMouse ? Util.alpha(root.barForeground, 0.15) : "transparent"

              Text {
                anchors.centerIn: parent
                text: "✕"
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                color: root.barForeground
                opacity: closeHover.containsMouse ? 1.0 : 0.6
              }

              MouseArea {
                id: closeHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  root.cardOpen = false
                  root.onboardingDismissed = true
                  root.runAction("onboarding_done")
                }
              }
            }
          }

          Rectangle {
            width: parent.width
            height: 1
            color: root.barForeground
            opacity: 0.12
          }

          // 2. Presets Selector (Pill tabs)
          Column {
            width: parent.width
            spacing: Style.space(6)

            Text {
              text: "FOCUS MODE"
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption - 1
              font.bold: true
              color: root.barForeground
              opacity: 0.6
            }

            Row {
              width: parent.width
              spacing: Style.space(6)

              Repeater {
                model: [
                  { key: "25/5", label: "25/5 Classic" },
                  { key: "50/10", label: "50/10 Deep" },
                  { key: "15/3", label: "15/3 Sprint" }
                ]

                Rectangle {
                  required property int index
                  required property var modelData

                  readonly property bool activePreset: root.currentPreset === modelData.key

                  width: (parent.width - Style.space(12)) / 3
                  height: Style.space(30)
                  radius: Style.space(6)
                  color: activePreset ? Util.alpha(root.accentColor, 0.25) : (presetHover.containsMouse ? Util.alpha(root.barForeground, 0.08) : "transparent")
                  border.width: 1
                  border.color: activePreset ? root.accentColor : Util.alpha(root.barForeground, 0.18)

                  Text {
                    anchors.centerIn: parent
                    text: modelData.label
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption - 1
                    font.bold: activePreset
                    color: activePreset ? root.accentColor : root.barForeground
                  }

                  MouseArea {
                    id: presetHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                      root.runAction("set_preset", modelData.key)
                    }
                  }
                }
              }
            }
          }

          // 3. Sound Settings Toggle Row
          Rectangle {
            width: parent.width
            height: Style.space(38)
            radius: Style.space(6)
            color: Util.alpha(root.barForeground, 0.06)

            Row {
              anchors.left: parent.left
              anchors.leftMargin: Style.space(12)
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(8)

              Text {
                text: root.soundEnabled ? "🔔" : "🔕"
                font.pixelSize: Style.font.caption + 1
              }

              Text {
                text: "Audio Chime Alerts"
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                color: root.barForeground
              }
            }

            Row {
              anchors.right: parent.right
              anchors.rightMargin: Style.space(8)
              anchors.verticalCenter: parent.verticalCenter
              spacing: Style.space(6)

              // Test Sound Button (plays sample chime when enabled)
              Rectangle {
                visible: root.soundEnabled
                width: Style.space(48)
                height: Style.space(24)
                radius: Style.space(12)
                color: testHover.containsMouse ? Util.alpha(root.barForeground, 0.15) : Util.alpha(root.barForeground, 0.08)
                border.width: 1
                border.color: Util.alpha(root.barForeground, 0.2)

                Text {
                  anchors.centerIn: parent
                  text: "▶ Test"
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption - 2
                  color: root.barForeground
                }

                MouseArea {
                  id: testHover
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.runAction("test_sound")
                }
              }

              // Sound Toggle Button
              Rectangle {
                width: Style.space(68)
                height: Style.space(24)
                radius: Style.space(12)
                color: root.soundEnabled ? Util.alpha(root.accentColor, 0.25) : Util.alpha(root.barForeground, 0.12)
                border.width: 1
                border.color: root.soundEnabled ? root.accentColor : Util.alpha(root.barForeground, 0.2)

                Text {
                  anchors.centerIn: parent
                  text: root.soundEnabled ? "Enabled" : "Muted"
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.caption - 2
                  font.bold: true
                  color: root.soundEnabled ? root.accentColor : root.barForeground
                  opacity: root.soundEnabled ? 1.0 : 0.6
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: root.runAction("toggle_sound")
                }
              }
            }
          }

          // 4. Quick Action Controls (Start/Pause, Skip, Reset)
          Row {
            width: parent.width
            spacing: Style.space(6)

            // Primary Toggle
            Rectangle {
              width: (parent.width - Style.space(12)) * 0.44
              height: Style.space(34)
              radius: Style.space(6)
              color: toggleHover.containsMouse ? root.accentColor : Util.alpha(root.accentColor, 0.22)
              border.width: 1
              border.color: root.accentColor

              Text {
                anchors.centerIn: parent
                text: root.isRunning ? "󰏤 Pause" : "󰐊 Start"
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                color: toggleHover.containsMouse ? (root.bar ? root.bar.themeContrastForeground : "#101315") : root.accentColor
              }

              MouseArea {
                id: toggleHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                  root.runAction("toggle")
                  root.runAction("onboarding_done")
                }
              }
            }

            // Skip Button
            Rectangle {
              width: (parent.width - Style.space(12)) * 0.28
              height: Style.space(34)
              radius: Style.space(6)
              color: skipHover.containsMouse ? Util.alpha(root.barForeground, 0.12) : "transparent"
              border.width: 1
              border.color: Util.alpha(root.barForeground, 0.2)

              Text {
                anchors.centerIn: parent
                text: "󰒭 Skip"
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                color: root.barForeground
              }

              MouseArea {
                id: skipHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.runAction("skip")
              }
            }

            // Reset Button
            Rectangle {
              width: (parent.width - Style.space(12)) * 0.28
              height: Style.space(34)
              radius: Style.space(6)
              color: resetHover.containsMouse ? Util.alpha(root.barForeground, 0.12) : "transparent"
              border.width: 1
              border.color: Util.alpha(root.barForeground, 0.2)

              Text {
                anchors.centerIn: parent
                text: "󰦛 Reset"
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                color: root.barForeground
              }

              MouseArea {
                id: resetHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.runAction("reset")
              }
            }
          }

          Rectangle {
            width: parent.width
            height: 1
            color: root.barForeground
            opacity: 0.12
          }

          // 5. Productivity Stats Summary
          Item {
            width: parent.width
            height: Math.max(todayCol.implicitHeight, weekCol.implicitHeight)

            Column {
              id: todayCol
              anchors.left: parent.left
              anchors.verticalCenter: parent.verticalCenter
              spacing: 2
              Text {
                text: "TODAY"
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption - 2
                font.bold: true
                color: root.barForeground
                opacity: 0.55
              }
              Text {
                text: root.completedToday + " sessions (" + root.focusTimeStr + ")"
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                color: root.barForeground
              }
            }

            Column {
              id: weekCol
              anchors.right: parent.right
              anchors.verticalCenter: parent.verticalCenter
              spacing: 2
              Text {
                anchors.right: parent.right
                text: "7 DAYS"
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption - 2
                font.bold: true
                color: root.barForeground
                opacity: 0.55
              }
              Text {
                anchors.right: parent.right
                text: root.weekCompleted + " sessions (" + root.weekFocusStr + ")"
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: true
                color: root.accentColor
              }
            }
          }
        }
      }
    }
  }
}
