import Quickshell // for PanelWindow
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick // for Text
import QtQuick.Layouts
import Quickshell.Services.SystemTray // for SystemTray


PanelWindow {
    anchors {
        bottom: true
        left: true
        right: true
    }
    implicitHeight: 45
    color: "red"

    RowLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: 5
        
        Repeater {
            model: Hyprland.workspaces
            

            Rectangle {
                width: winlist.width + 10
                height: parent.height - 8
                border.width: 0
                color: "yellow"

                Row {
                    id: winlist
                    anchors.centerIn: parent
                    spacing: 2

                    Repeater {
                        model: Hyprland.toplevels.values.filter(t => t.workspace === modelData)

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: height
                            height: 20
                            color: "blue"

                        }
                    }
                }
            }
        }
    }
}