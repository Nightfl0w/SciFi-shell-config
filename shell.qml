import Quickshell // for PanelWindow
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick // for Text
import QtQuick.Layouts
import Quickshell.Services.SystemTray // for SystemTray


PanelWindow {
    id: bar
    anchors {
        bottom: true
        left: true
        right: true
    }
    implicitHeight: 45
    color: "red"

    Row {
        anchors.verticalCenter: bar.verticalCenter
        width: parent.width
        height: parent.height
        spacing: 5


        Rectangle {
            width: height
            height: parent.height
            anchors.verticalCenter: bar.verticalCenter

            Rectangle {
                anchors.centerIn: parent
                width: height
                height: parent.height - 8
                
                color: "purple"
                
            }
        }

        Rectangle {

            height: parent.height
            width: tasklist.width +4
            anchors.verticalCenter: parent.verticalCenter
            color: "green"

            RowLayout {
                id: tasklist
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 5
                
                Repeater {
                    anchors.centerIn: parent
                    model: Hyprland.workspaces
                    

                    Rectangle {
                        width: ((winlist.width + 10) >= height) ? (winlist.width + 10) : height
                        height: parent.height - 8
                        border.width: 0
                        color: "yellow"

                        Row {
                            id: winlist
                            anchors.centerIn: parent
                            spacing: 4

                            Repeater {
                                model: Hyprland.toplevels.values.filter(t => t.workspace === modelData)

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: height
                                    height: 25
                                    color: "blue"

                                }
                            }
                        }
                    }
                }
            }    
        }
        
    }
    Rectangle {
        width: 60
        height: parent.height - 4
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        color: "orange"
    }
}