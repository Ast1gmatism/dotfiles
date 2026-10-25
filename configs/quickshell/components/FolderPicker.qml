import QtQuick
import QtCore
import Qt.labs.folderlistmodel
import qs.theme
import qs.components

// Выбор папки внутри родительского окна.
//
// Отдельным окном такие вещи в оболочке делать нельзя: layer-shell поверхность
// с эксклюзивной клавиатурой перекрывает любой системный диалог, и тот получает
// ни кликов, ни клавиш. Поэтому панель живёт внутри того же слоя.
//
// Использование:
//     FolderPicker {
//         id: picker
//         startDir: "/home/user/Pictures"
//         onAccepted: (dir) => …
//         onCancelled: …
//     }
//     picker.open()
//
// Компонент ничего не знает о настройках: путь приходит в startDir, выбранный
// уходит в сигнал accepted.
Item {
    id: picker

    anchors.fill: parent
    visible: false
    z: 10

    // С какой папки начинать. Пусто — домашняя.
    property string startDir: ""

    // Заголовок панели.
    property string title: "Выбор папки"

    // Текущая просматриваемая папка (абсолютный путь).
    property string cwd: ""

    // Родителя считаем из строки, а не из FolderListModel: на корне его
    // parentFolder отдаёт пустой URL, и «Вверх» уезжал в путь "".
    readonly property string parentDir: {
        var p = cwd.replace(/\/+$/, "")          // "/home/" → "/home", "/" → ""
        var i = p.lastIndexOf("/")
        return i > 0 ? p.substring(0, i) : "/"
    }

    // Вверх можно, пока не стоим на корне.
    readonly property bool canGoUp: cwd !== "" && cwd !== "/"

    readonly property string homeDir: {
        var u = StandardPaths.writableLocation(StandardPaths.HomeLocation).toString()
        if (u.indexOf("file://") === 0) u = decodeURIComponent(u.substring(7))
        return u
    }

    signal accepted(string dir)
    signal cancelled()

    function open() {
        cwd = startDir !== "" && startDir !== undefined ? startDir : homeDir
        visible = true
        forceActiveFocus()
    }

    function accept() {
        // Пустой путь — это не «папка не выбрана», а сломанное состояние:
        // записать его нельзя, а неотличим он от «ничего не меняли».
        if (picker.cwd === "") return
        visible = false
        picker.accepted(picker.cwd)
    }

    function cancel() {
        visible = false
        picker.cancelled()
    }

    function goUp() {
        if (!canGoUp) return
        cwd = picker.parentDir
    }

    Keys.onEscapePressed: picker.cancel()

    // Глушим клики по тому, что лежит под панелью.
    MouseArea { anchors.fill: parent }

    FolderListModel {
        id: folders
        folder: picker.cwd === "" ? "" : "file://" + picker.cwd
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
        showHidden: false
        sortField: FolderListModel.Name
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: Math.min(560, parent.width - 80)
        height: Math.min(460, parent.height - 80)
        radius: Theme.radiusM
        color: Theme.glassGroup
        border.width: 1
        border.color: Theme.glassBorder

        Text {
            id: panelTitle
            anchors { top: parent.top; left: parent.left
                      topMargin: Theme.spacingM; leftMargin: Theme.spacingM }
            text: picker.title
            font.family: Theme.fontFamily
            font.pixelSize: Theme.textTitle
            color: Theme.foregroundColor
        }

        HoverSurface {
            anchors { top: panelTitle.top; right: parent.right
                      rightMargin: Theme.spacingM }
            implicitWidth: upLabel.implicitWidth + 28
            implicitHeight: Theme.widgetHeight
            radius: Theme.radiusM
            normalColor: Theme.subtleFillColor
            hoverColor: Theme.hoverFillColor
            interactive: picker.canGoUp
            onClicked: picker.goUp()

            Text {
                id: upLabel
                anchors.centerIn: parent
                text: "Вверх"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.textLabel
                color: picker.canGoUp ? Theme.foregroundColor : Theme.disabledTextColor
            }
        }

        Rectangle {
            id: pathRow
            anchors { top: panelTitle.bottom; left: parent.left; right: parent.right
                      topMargin: Theme.spacingS
                      leftMargin: Theme.spacingM; rightMargin: Theme.spacingM }
            height: Theme.widgetHeight
            radius: Theme.radiusM
            color: Theme.subtleFillColor

            Text {
                anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                verticalAlignment: Text.AlignVCenter
                text: picker.cwd
                font.family: Theme.fontFamily
                font.pixelSize: Theme.textBody
                color: Theme.mutedTextColor
                elide: Text.ElideLeft
            }
        }

        ListView {
            id: list
            clip: true
            model: folders
            anchors { top: pathRow.bottom; left: parent.left; right: parent.right
                      bottom: buttons.top
                      topMargin: Theme.spacingS; bottomMargin: Theme.spacingS
                      leftMargin: Theme.spacingM; rightMargin: Theme.spacingM }

            delegate: HoverSurface {
                id: row
                required property string fileName
                required property string filePath

                width: list.width
                height: Theme.widgetHeight
                radius: Theme.radiusS
                normalColor: "transparent"
                hoverColor: Theme.hoverFillColor
                onClicked: picker.cwd = row.filePath

                Text {
                    anchors { verticalCenter: parent.verticalCenter
                              left: parent.left; right: parent.right
                              leftMargin: 10; rightMargin: 10 }
                    text: row.fileName
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.textLabel
                    color: Theme.foregroundColor
                    elide: Text.ElideMiddle
                }
            }

            Text {
                anchors.centerIn: parent
                visible: list.count === 0
                text: "Вложенных папок нет"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.textBody
                color: Theme.mutedTextColor
            }
        }

        Row {
            id: buttons
            spacing: Theme.spacingS
            anchors { bottom: parent.bottom; right: parent.right
                      bottomMargin: Theme.spacingM; rightMargin: Theme.spacingM }

            HoverSurface {
                implicitWidth: cancelLabel.implicitWidth + 28
                implicitHeight: Theme.widgetHeight
                radius: Theme.radiusM
                normalColor: Theme.subtleFillColor
                hoverColor: Theme.hoverFillColor
                onClicked: picker.cancel()

                Text {
                    id: cancelLabel
                    anchors.centerIn: parent
                    text: "Отмена"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.textLabel
                    color: Theme.foregroundColor
                }
            }

            HoverSurface {
                implicitWidth: pickLabel.implicitWidth + 28
                implicitHeight: Theme.widgetHeight
                radius: Theme.radiusM
                normalColor: Theme.accentColor
                hoverColor: Theme.accentColor
                onClicked: picker.accept()

                Text {
                    id: pickLabel
                    anchors.centerIn: parent
                    text: "Выбрать эту папку"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.textLabel
                    color: Theme.onAccentColor
                }
            }
        }
    }
}
