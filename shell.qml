import Quickshell // for PanelWindow
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
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
                    model: Hyprland.workspaces.values
                    

                    Rectangle {
                        id: workspaceBox
                        height: parent.height - 8
                        property bool workspaceBool: true
                        property bool listLock: true
                        width: {
                            let targetWidth = 31; 
                            
                            // KORREKTUR 2: Nutzt das stabile "anyAppHovered"-Signal für die Apps!
                            let isWorkspaceHovered = yellowHoverDetector.containsMouse || 
                                                    orangeHoverDetector.containsMouse || 
                                                    workspaceBox.listLock || 
                                                    winlist.anyAppHovered;
                            if (isWorkspaceHovered) {
                                let appCount = modelData.toplevels.values.length;
                                let baseAppsWidth = ( appCount * (25 + 4) ) + ( (height - 20) / 2 );
                                let extraHoverWidth = (winlist.activeHoverIndex !== -1) ? 115 : 0;
                                
                                targetWidth += baseAppsWidth + extraHoverWidth;
                            }
                            
                            return (targetWidth >= height) ? targetWidth : height;
                        }
                        
                        anchors.verticalCenter: parent.verticalCenter
                        border.width: (listLock) ? 2 : 0
                        border.color: "black"
                        color: "yellow"
                        clip: true
                        Behavior on width {
                            SpringAnimation {
                                id: widthSpring 
                                spring: 15        // Bestimmt, wie schnell und "elastisch" die Box reagiert
                                damping: 1.2      // Verhindert zu starkes Nachfedern am Ende
                                epsilon: 0.01      // Erlaubt das sofortige Abbrechen und Umkehren der Bewegung
                            }
                        }
                        
                        MouseArea {
                            id: yellowHoverDetector
                            anchors.fill: parent
                            hoverEnabled: true
                            
                        }

                        Row {
                            id: winlist
                            anchors.left: parent.left
                            anchors.leftMargin: (workspaceBox.height - desktopNumberBox.height) / 2 // Kleiner schicker Abstand zum linken gelben Rand
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.rightMargin: (workspaceBox.height - dekstopNumberBox.height) / 2
                            spacing: 4
                            property int activeHoverIndex: -1
                            property bool anyAppHovered: activeHoverIndex !== -1
                            property bool anyChildHovered: desktopNumDetector.containsMouse || activeHoverIndex !== -1
                            
                            Rectangle {
                                id: desktopNumberBox
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent
                                
                                width: 20
                                height: 20
                                color: "orange" // Farbe kannst du frei wählen
                                radius: 3
                                MouseArea {
                                    id: orangeHoverDetector
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton
                                    onClicked: (
                                        workspaceBox.listLock = !workspaceBox.listLock

                                    )
                                }
                                // WICHTIG: Damit dieses Element nicht mit den Fenster-Indizes 
                                // kollidiert, geben wir ihm einen ungültigen Nachbar-Index
                                property int myIndex: -999 

                                Text {
                                    anchors.centerIn: parent
                                    // modelData ist im äußeren Repeater das Hyprland-Workspace-Objekt.
                                    // .id liefert die echte Nummer des Desktops (1, 2, 3...)
                                    text: modelData ? modelData.id : ""
                                    color: "black"
                                    font.bold: true
                                    font.pixelSize: 11
                                }
                            }
                            
                            Repeater {
                                model: modelData.toplevels.values

                                Rectangle {
                                    id: windowItem
                                    property var toplevelData: modelData
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: {
                                        // KORREKTUR 3: Auch hier die stabilisierte Bedingung einsetzen
                                        let isWorkspaceHovered = yellowHoverDetector.containsMouse || 
                                                                orangeHoverDetector.containsMouse || 
                                                                workspaceBox.listLock || 
                                                                winlist.anyAppHovered;
                                        
                                        if (!isWorkspaceHovered) return 0;
                                        
                                        if (mouseDetector.containsMouse) return 140;
                                        
                                        return height;
                                    }
                                    height: 25
                                    color: "blue"
                                    clip: true
                                    property int myIndex: index
                                    
                                    Behavior on width {
                                        SpringAnimation {
                                            id: widthSpring 
                                            spring: 15        // Bestimmt, wie schnell und "elastisch" die Box reagiert
                                            damping: 1.2      // Verhindert zu starkes Nachfedern am Ende
                                            epsilon: 0.01      // Erlaubt das sofortige Abbrechen und Umkehren der Bewegung
                                        }
                                    }
                                    

                                    Row {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        spacing: 6

                                        // ÄNDERUNG 4: Blendet den gesamten Inhalt (Icon + Text) komplett aus, 
                                        // sobald die blaue Box zusammengestaucht wird
                                        opacity: parent.width > 0 ? 1.0 : 0.0
                                        Behavior on opacity { NumberAnimation { duration: 80 } }
                                    
                                        IconImage {
                                            // FEHLERKORREKTUR 1: Feste Breite und Höhe erzwingen.
                                            // Wenn diese Werte fehlen oder implizit (0) sind, führt QML den source-Code gar nicht aus!
                                            width: 24
                                            height: 24
                                            
                                            // FEHLERKORREKTUR 2: Gültiger Anker (parent statt parent.center)
                                            anchors.verticalCenter: parent.verticalCenter

                                            source: {
                                                let win = windowItem.toplevelData;
                                                if (!win) return Quickshell.iconPath("system-run");

                                                // NEU & KORREKT: Unter Wayland/Hyprland liegen die Klassen-Strings 
                                                // tiefer im '.wayland'-Unterobjekt vergraben!
                                                let appClass = "";
                                                if (win.wayland) {
                                                    appClass = win.wayland.className || win.wayland.appId || "";
                                                }
                                                
                                                // Falls das fehlschlägt, nutzen wir den Fenstertitel als Notnagel
                                                if (appClass === "") appClass = win.title || "";
                                                
                                                appClass = appClass.toLowerCase();
                                                
                                                console.log("=== CORE FIX TEST ===");
                                                console.log("Echt ausgelesene App-Klasse: " + appClass);

                                                if (appClass === "") return Quickshell.iconPath("system-run");
                                                
                                                let entry = DesktopEntries.heuristicLookup(appClass);
                                                let iconName = entry ? entry.icon : appClass;
                                                
                                                let finalPath = Quickshell.iconPath(iconName, "system-run");
                                                console.log("Generierter Pfad: " + finalPath);
                                                
                                                return finalPath;
                                            }
                                        }

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: windowItem.toplevelData ? windowItem.toplevelData.title : ""
                                            color: "white"
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                            width: 105
                                            
                                            // Blendet sich passend zur Box weich ein/aus
                                            opacity: mouseDetector.containsMouse ? 1.0 : 0.0
                                            Behavior on opacity { NumberAnimation { duration: 120 } }
                                        }
                                    }
                                    // ÄNDERUNG 6: Erkennt die Mausbewegungen über dem blauen Kästchen
                                    MouseArea {
                                        id: mouseDetector
                                        anchors.fill: parent
                                        hoverEnabled: true

                                        // ÄNDERUNG 2: Oben und Unten fest an die eigene Box binden
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom

                                        // Linke Seite: Wenn der linke Nachbar aktiv ist, docke an ihn an. Sonst an die eigene Box.
                                        anchors.left: (winlist.activeHoverIndex !== -1 && winlist.activeHoverIndex === index - 1) 
                                                    ? findNeighbor(index - 1).right 
                                                    : parent.left

                                        // Rechte Seite: Wenn der rechte Nachbar aktiv ist, docke an ihn an. Sonst an die eigene Box.
                                        anchors.right: (winlist.activeHoverIndex !== -1 && winlist.activeHoverIndex === index + 1) 
                                                        ? findNeighbor(index + 1).left 
                                                        : parent.right

                                        // Hilfsfunktion, um das Nachbar-Rechteck in der winlist-Reihe zu finden
                                        function findNeighbor(targetIndex) {
                                            // Fall A: Wir sind am linken Rand (Niedrigster Index) und suchen nach links
                                            if (targetIndex < 0) {
                                                // Docke an das übergeordnete Workspace-Layout an
                                                return tasklist; 
                                            }
                                            
                                            // Fall B: Wir sind am rechten Rand (Höchster Index)
                                            // winlist.children.length - 1 entspricht dem höchsten Fenster-Index
                                            if (targetIndex >= winlist.children.length) {
                                                return tasklist;
                                            }
                                            // Wir durchsuchen die Kinder der winlist-Reihe nach dem passenden Index
                                            for (let i = 0; i < winlist.children.length; i++) {
                                                if (winlist.children[i].myIndex === targetIndex) {
                                                    return winlist.children[i];
                                                }
                                            }
                                            return parent; // Fallback, falls kein Nachbar existiert
                                        }
                                        onContainsMouseChanged: {
                                            if (containsMouse) {
                                                // Maus kommt rein -> Dieses Icon aktivieren
                                                winlist.activeHoverIndex = index;
                                            } else {
                                                // Maus geht echt raus -> Nur zurücksetzen, wenn dieses Icon das aktive war
                                                if (winlist.activeHoverIndex === index) {
                                                    winlist.activeHoverIndex = -1;
                                                }
                                            }
                                        }
                                    }
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
            width: 60
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

