import Quickshell // for PanelWindow
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick // for Text
import QtQuick.Layouts
import Quickshell.Services.SystemTray // for SystemTray
import Quickshell.Services.UPower

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

            Row {
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
                        anchors.verticalCenter: parent.verticalCenter
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
    Row {
        height:parent.height
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5
        

        Rectangle {
            width: 80
            height: parent.height - 4
            anchors.verticalCenter: parent.verticalCenter
            
            Rectangle {
                height: parent.height - 8
                width: 18
                anchors.right: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: "cyan"

                Rectangle {
                    width: parent.width - 5
                    height: parent.height - 6
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "black" 

                    Rectangle {
                        width: parent.width - 2
                        height: (parent.height - 2) * UPower.displayDevice.percentage
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "green"
                    }
                }
            }
            
            Text {
                anchors.left: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: (UPower.displayDevice.percentage * 100) + "%"
                color: "black"
            }
        }

        Rectangle {
            width: 80
            height: parent.height - 4
            anchors.verticalCenter: parent.verticalCenter
            color: "orange"

            SystemClock {
                id: clock
                precision: SystemClock.Seconds
            }

            Text{
                anchors.centerIn: parent
                text: Qt.formatDateTime(clock.date, "hh:mm:ss\ndd/MM/yyyy")
                color: "black"
            }
        }
    }
}

