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

  readonly property int mainFontSize: Math.max(9, Style.font.caption)
  readonly property int subFontSize: Math.max(8, Style.font.caption - 1)

  property string phase: "work"
  property bool isRunning: false
  property string iconText: "󰄉"
  property string timeText: "25:00"
  property string dotsText: "○○○○"
  property int progressPct: 0
  property string tooltipText: "󰄉 Focus (25:00 left)\nLeft: Start/Pause • Right: Skip • Middle: Reset"

  implicitWidth: Style.space(92)
  implicitHeight: root.barSize

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
    root.iconText = data.icon || "󰄉"
    root.timeText = data.time_str || "25:00"
    root.dotsText = data.dots || "○○○○"
    root.progressPct = data.pct || 0
    root.tooltipText = data.tooltip || ""

    if (pomodoroMouseArea.containsMouse && root.bar) {
      root.bar.showTooltip(root, root.tooltipText)
    }
  }

  function runAction(act) {
    if (actionProc.running) return
    actionProc.command = ["/usr/bin/python3", Qt.resolvedUrl("pomodoro.py").toString().replace("file://", ""), act]
    actionProc.running = true
  }

  Process {
    id: actionProc
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
      if (!actionProc.running) {
        actionProc.command = ["/usr/bin/python3", Qt.resolvedUrl("pomodoro.py").toString().replace("file://", ""), "status"]
        actionProc.running = true
      }
      if (pomodoroMouseArea.containsMouse && root.bar) {
        root.bar.showTooltip(root, root.tooltipText)
      }
    }
  }

  Item {
    anchors.fill: parent

    Row {
      id: contentRow
      anchors.centerIn: parent
      spacing: Style.space(6)

      // 1. Pomodoro Icon
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.iconText
        font.family: root.fontFamily
        font.pixelSize: root.mainFontSize + 2
        color: root.phase !== "work" ? Commons.Color.accent : root.barForeground
        opacity: root.isRunning ? 1.0 : 0.65
        renderType: Text.NativeRendering
      }

      // 2. Countdown Time
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.timeText
        font.family: root.fontFamily
        font.pixelSize: root.mainFontSize
        font.bold: root.isRunning
        color: root.phase !== "work" ? Commons.Color.accent : root.barForeground
        opacity: root.isRunning ? 1.0 : 0.75
        renderType: Text.NativeRendering
      }

      // 3. Cycle Dots (Minimalist session indicators: ●●○○)
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.dotsText
        font.family: root.fontFamily
        font.pixelSize: root.subFontSize - 1
        color: root.barForeground
        opacity: 0.55
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
        if (!actionProc.running) {
          actionProc.command = ["/usr/bin/python3", Qt.resolvedUrl("pomodoro.py").toString().replace("file://", ""), "status"]
          actionProc.running = true
        }
        if (root.bar) root.bar.showTooltip(root, root.tooltipText)
      }

      onExited: {
        if (root.bar) root.bar.hideTooltip(root)
      }

      onClicked: (mouse) => {
        if (mouse.button === Qt.LeftButton) {
          root.runAction("toggle")
        } else if (mouse.button === Qt.RightButton) {
          root.runAction("skip")
        } else if (mouse.button === Qt.MiddleButton) {
          root.runAction("reset")
        }
      }
    }
  }
}
