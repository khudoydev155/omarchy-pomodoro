import QtQuick
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
  property int progressPct: 0
  property int secondsLeft: 1500
  property string tooltipText: "󰏤 Focus (25:00 left) [Paused]\n─────────────────────────────\nProgress: [░░░░░░░░░░░░] 0%\nToday:    0 completed (0m)\n─────────────────────────────\nLeft: Start/Pause • Right: Skip • Middle: Reset"

  // Adaptive geometry that smoothly resizes for any font scale and vertical/horizontal bars
  implicitWidth: root.isVertical ? root.barSize : Math.max(Style.space(80), contentRow.implicitWidth + Style.space(16))
  implicitHeight: root.isVertical ? Math.max(Style.space(76), contentCol.implicitHeight + Style.space(12)) : root.barSize

  signal pressed(int button)

  function triggerPress(button) {
    if (button === Qt.RightButton) {
      root.runAction("skip")
    } else if (button === Qt.MiddleButton) {
      root.runAction("reset")
    } else {
      root.runAction("toggle")
    }
  }

  function parseOutput(text) {
    if (!text) return
    var data
    try {
      data = JSON.parse(text.trim())
    } catch (e) {
      return
    }

    root.phase = data.phase || "work"
    root.isRunning = data.running || false
    root.iconText = data.icon || (root.isRunning ? "󰄉" : "󰏤")
    root.timeText = data.time_str || "25:00"
    root.dotsText = data.dots || "○○○○"
    root.progressPct = data.pct || 0
    root.tooltipText = data.tooltip || ""

    if (pomodoroMouseArea.containsMouse && root.bar) {
      root.bar.showTooltip(root, root.tooltipText)
    }
  }

  function runAction(act) {
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
      root.timeText = "25:00"
      root.iconText = "󰏤"
      root.progressPct = 0
    } else if (act === "skip") {
      root.isRunning = false
      if (root.phase === "work") {
        root.phase = "break"
        root.timeText = "05:00"
        root.iconText = "󰔄"
      } else {
        root.phase = "work"
        root.timeText = "25:00"
        root.iconText = "󰏤"
      }
    }

    // Execute Python action immediately
    actionProc.running = false
    actionProc.command = ["/usr/bin/python3", Qt.resolvedUrl("pomodoro.py").toString().replace("file://", ""), act]
    actionProc.running = true
  }

  // Dedicated process for user-triggered click actions
  Process {
    id: actionProc
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.parseOutput(text)
    }
  }

  // Dedicated process for background status polling
  Process {
    id: statusProc
    command: ["/usr/bin/python3", Qt.resolvedUrl("pomodoro.py").toString().replace("file://", ""), "status"]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: text => root.parseOutput(text)
    }
  }

  Timer {
    id: pollTimer
    interval: root.isRunning || pomodoroMouseArea.containsMouse ? 1000 : 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
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
}
