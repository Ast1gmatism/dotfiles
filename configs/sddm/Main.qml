import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "black"

    // ── Palette (Catppuccin Mocha) ────────────────────────
    readonly property color base:     "#1e1e2e"
    readonly property color crust:    "#11111b"
    readonly property color mantle:   "#181825"
    readonly property color text:     "#cdd6f4"
    readonly property color subtext0: "#a6adc8"
    readonly property color overlay0: "#6c7086"
    readonly property color overlay2: "#9399b2"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color surface2: "#585b70"
    readonly property color mauve:    "#cba6f7"
    readonly property color red:      "#f38ba8"
    readonly property color peach:    "#fab387"
    readonly property color blue:     "#89b4fa"
    readonly property color green:    "#a6e3a1"

    // ── Layout ────────────────────────────────────────────
    readonly property real   sc:       Math.min(width / 1920, height / 1080)
    readonly property string fontMain: "JetBrains Mono"
    readonly property string fontIcon: "JetBrains Mono Nerd Font"
    readonly property real   edgePad:  40 * sc

    // Именованные offsets вместо магических чисел
    readonly property real clockOffsetIdle:  -40 * sc
    readonly property real clockOffsetAuth: -120 * sc
    readonly property real authOffsetIdle:    40 * sc
    readonly property real authOffsetActive: -40 * sc

    // ── Animation durations ───────────────────────────────
    readonly property int durFast:  200
    readonly property int durMed:   300
    readonly property int durSlow:  600
    readonly property int durIntro: 550

    // ── UI Text ───────────────────────────────────────────
    readonly property var uiText: ({
        locked:        "ЗАБЛОКИРОВАН",
        wrongPassword: "ПАРОЛЬ НЕВЕРНЫЙ",
        checking:      "ПРОВЕРКА...",
        timeout:       "ТАЙМАУТ",
        menuTitle:     "СИСТЕМА",
        reboot:        "Перезагрузка",
        suspend:       "Режим сна",
        hibernate:     "Гибернация",
        powerOff:      "Выключение"
    })

    // ── State ─────────────────────────────────────────────
    property bool   isPlayingIntro:  true
    property bool   inputActive:     false
    property real   introState:      0.0

    property bool   authFailed:      false
    property bool   authenticating:  false
    property bool   powerMenuOpen:   false
    property bool   passwordVisible: false

    property bool   cursorRevealed:  false
    property real   lastMouseX:      -1
    property real   lastMouseY:      -1

    property string infoMessage:     ""

    // ── User / Session ────────────────────────────────────
    readonly property string currentUser: {
        const i = userModel.lastIndex
        if (i < 0 || i >= userModel.count) return "User"
        return userModel.data(userModel.index(i, 0), Qt.UserRole + 1) || "User"
    }

    readonly property int currentSession: Math.max(0, sessionModel.lastIndex)

    // ── Derived state ─────────────────────────────────────
    readonly property color statusAccentColor:
        authFailed     ? red   :
        authenticating ? peach : mauve

    readonly property color statusTextColor:
        authFailed     ? red   :
        authenticating ? peach : text

    readonly property string statusIconGlyph:
        authenticating ? "󰌿" : "󰌾"

    readonly property string statusLabel:
        authFailed     ? uiText.wrongPassword :
        authenticating ? uiText.checking      :
        infoMessage    ? infoMessage          : uiText.locked

    // ── Helpers ───────────────────────────────────────────
    function scaledBorder(value) {
        return Math.max(1, value * sc)
    }

    // ── Actions ───────────────────────────────────────────
    function beginLogin() {
        authFailed    = false
        authenticating = true
        infoMessage   = ""
        authTimeout.restart()
    }

    function failLogin() {
        authenticating = false
        authFailed     = true
        infoMessage    = ""
        passwordField.text = ""
        shakeAnim.restart()
        if (inputActive)
            passwordField.forceActiveFocus()
    }

    function clearStatusMessage() {
        if (!authenticating)
            infoMessage = ""
    }

    function resetAuthState() {
        authFailed     = false
        infoMessage    = ""
        authenticating = false
        authTimeout.stop()
    }

    // ── Timers ────────────────────────────────────────────
    Timer {
        id: authTimeout
        interval: 10000
        onTriggered: {
            if (root.authenticating) {
                root.authenticating = false
                root.infoMessage    = uiText.timeout
            }
        }
    }

    // ── Focus management ──────────────────────────────────
    onInputActiveChanged: {
        if (inputActive) {
            passwordField.forceActiveFocus()
        } else {
            passwordField.text = ""
            passwordField.focus = false
            root.forceActiveFocus()
            resetAuthState()
        }
    }

    // ── SDDM signals ──────────────────────────────────────
    Connections {
        target: sddm

        function onLoginSucceeded() {
            authTimeout.stop()
            root.authenticating = false
            root.authFailed     = false
            root.infoMessage    = ""
        }

        function onLoginFailed() {
            authTimeout.stop()
            root.failLogin()
        }

        function onInformationMessage(message) {
            if (!root.authenticating && !root.authFailed)
                root.infoMessage = message
        }
    }

    // ── Background ────────────────────────────────────────
    Image {
        anchors.fill: parent
        source: "assets/background.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: false
            blurEnabled: true
            blurMax: 32
            blur: root.inputActive ? 1.0 : 0.0

            Behavior on blur {
                NumberAnimation { duration: root.durSlow; easing.type: Easing.OutExpo }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.inputActive ? 0.4 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: root.durSlow; easing.type: Easing.OutExpo }
        }
    }

    // ── Cursor + global click ─────────────────────────────
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: (root.isPlayingIntro || !root.cursorRevealed)
                     ? Qt.BlankCursor
                     : Qt.ArrowCursor

        onPositionChanged: (mouse) => {
            if (root.lastMouseX < 0 || root.lastMouseY < 0) {
                root.lastMouseX = mouse.x
                root.lastMouseY = mouse.y
                return
            }
            if (!root.isPlayingIntro &&
                (mouse.x !== root.lastMouseX || mouse.y !== root.lastMouseY))
                root.cursorRevealed = true

            root.lastMouseX = mouse.x
            root.lastMouseY = mouse.y
        }

        onClicked: {
            if (root.isPlayingIntro) return

            if (root.powerMenuOpen) {
                root.powerMenuOpen = false
                if (!root.inputActive)
                    root.inputActive = true
                return
            }

            if (!root.inputActive)
                root.inputActive = true
            else
                passwordField.forceActiveFocus()
        }
    }

    // ── Main content ──────────────────────────────────────
    Item {
        anchors.fill: parent
        opacity: root.introState

        transform: Translate {
            y: (30 * root.sc) * (1.0 - root.introState)
        }

        // ── Clock ─────────────────────────────────────────
        ColumnLayout {
            id: clockModule
            anchors.centerIn: parent
            anchors.verticalCenterOffset: root.inputActive
                                          ? root.clockOffsetAuth
                                          : root.clockOffsetIdle
            spacing: -10 * root.sc
            opacity: root.inputActive ? 0.0 : 1.0
            scale:   root.inputActive ? 0.9 : 1.0
            visible: opacity > 0.01

            Behavior on anchors.verticalCenterOffset {
                NumberAnimation { duration: root.durSlow; easing.type: Easing.OutExpo }
            }
            Behavior on opacity {
                NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
            }
            Behavior on scale {
                NumberAnimation { duration: 500; easing.type: Easing.OutBack }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 0

                Text {
                    id: clockHours
                    font { family: root.fontMain; pixelSize: 140 * root.sc; weight: Font.Bold }
                    color: root.text
                }

                Text {
                    text: ":"
                    font { family: root.fontMain; pixelSize: 140 * root.sc; weight: Font.Bold }
                    color: root.text
                    opacity: 0.2

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: !root.inputActive
                        NumberAnimation { from: 0.2; to: 1.0; duration: 1500; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 1.0; to: 0.2; duration: 1500; easing.type: Easing.InOutQuad }
                    }
                }

                Text {
                    id: clockMinutes
                    font { family: root.fontMain; pixelSize: 140 * root.sc; weight: Font.Bold }
                    color: root.text
                }
            }

            Text {
                id: dateText
                Layout.alignment: Qt.AlignHCenter
                font { family: root.fontMain; pixelSize: 22 * root.sc; weight: Font.Bold }
                color: root.text
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true

                onTriggered: {
                    const d   = new Date()
                    clockHours.text   = Qt.formatDateTime(d, "hh")
                    clockMinutes.text = Qt.formatDateTime(d, "mm")
                    const raw = d.toLocaleDateString(Qt.locale("ru_RU"), "dddd, d MMMM")
                    dateText.text = raw.charAt(0).toUpperCase() + raw.slice(1)
                }
            }
        }

        // ── Auth ──────────────────────────────────────────
        RowLayout {
            id: authModule
            anchors.centerIn: parent
            anchors.verticalCenterOffset: root.inputActive
                                          ? root.authOffsetActive
                                          : root.authOffsetIdle
            spacing: 32 * root.sc
            opacity: root.inputActive ? 1.0 : 0.0
            scale:   root.inputActive ? 1.0 : 0.9
            visible: opacity > 0.01

            Behavior on anchors.verticalCenterOffset {
                NumberAnimation { duration: root.durSlow; easing.type: Easing.OutExpo }
            }
            Behavior on opacity {
                NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
            }
            Behavior on scale {
                NumberAnimation { duration: 500; easing.type: Easing.OutBack }
            }

            // Avatar
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 170 * root.sc
                height: width
                radius: height / 2
                color: Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.5)
                border.color: root.authFailed
                    ? root.red
                    : (root.authenticating
                       ? root.peach
                       : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.5))
                border.width: root.scaledBorder(3)

                Behavior on border.color { ColorAnimation { duration: root.durMed } }

                Text {
                    anchors.centerIn: parent
                    text: "󰄽"
                    font { family: root.fontIcon; pixelSize: 64 * root.sc }
                    color: root.subtext0
                }
            }

            // Input column
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 16 * root.sc

                // Username
                Text {
                    Layout.alignment: Qt.AlignLeft
                    text: root.currentUser
                    font { family: root.fontMain; pixelSize: 28 * root.sc; weight: Font.Bold }
                    color: root.text
                }

                // Status row
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    spacing: 12 * root.sc

                    Rectangle {
                        width: 36 * root.sc
                        height: width
                        radius: height / 2
                        color: root.authFailed
                            ? Qt.rgba(root.red.r,   root.red.g,   root.red.b,   0.2)
                            : (root.authenticating
                               ? Qt.rgba(root.peach.r, root.peach.g, root.peach.b, 0.2)
                               : Qt.rgba(root.mauve.r, root.mauve.g, root.mauve.b, 0.15))
                        border.color: root.statusAccentColor
                        border.width: root.scaledBorder(1)

                        Behavior on color        { ColorAnimation { duration: root.durMed } }
                        Behavior on border.color { ColorAnimation { duration: root.durMed } }

                        Text {
                            anchors.centerIn: parent
                            text: root.statusIconGlyph
                            font { family: root.fontIcon; pixelSize: 18 * root.sc }
                            color: root.statusAccentColor
                            Behavior on color { ColorAnimation { duration: root.durMed } }
                        }
                    }

                    Text {
                        font {
                            family:        root.fontMain
                            pixelSize:     14 * root.sc
                            weight:        Font.Medium
                            letterSpacing: 2.0
                        }
                        color: root.statusTextColor
                        text:  root.statusLabel
                        Behavior on color { ColorAnimation { duration: root.durMed } }
                    }
                }

                // Password pill
                Rectangle {
                    id: pinPill
                    Layout.alignment: Qt.AlignLeft
                    width: 280 * root.sc
                    height: 60 * root.sc
                    radius: height / 2
                    clip: true
                    color: root.authFailed
                        ? Qt.rgba(root.red.r, root.red.g, root.red.b, 0.1)
                        : Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.5)
                    border.width: root.scaledBorder(2)
                    border.color: root.authFailed
                        ? root.red
                        : (passwordField.text.length > 0
                           ? root.text
                           : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.08))
                    scale: root.authFailed ? 1.05 : 1.0

                    transform: Translate { id: shakeTranslate; x: 0 }

                    Behavior on color        { ColorAnimation  { duration: 250; easing.type: Easing.OutExpo } }
                    Behavior on border.color { ColorAnimation  { duration: 250; easing.type: Easing.OutExpo } }
                    Behavior on scale        { NumberAnimation { duration: root.durMed; easing.type: Easing.OutBack } }

                    SequentialAnimation {
                        id: shakeAnim
                        NumberAnimation { target: shakeTranslate; property: "x"; from: 0;            to: -8 * root.sc; duration: 120; easing.type: Easing.InOutSine }
                        NumberAnimation { target: shakeTranslate; property: "x"; from: -8 * root.sc; to:  8 * root.sc; duration: 120; easing.type: Easing.InOutSine }
                        NumberAnimation { target: shakeTranslate; property: "x"; from:  8 * root.sc; to:  0;           duration: 120; easing.type: Easing.InOutSine }
                    }

                    // Eye button
                    Rectangle {
                        id: eyeButton
                        anchors {
                            right: parent.right
                            rightMargin: 8 * root.sc
                            verticalCenter: parent.verticalCenter
                        }
                        width: 44 * root.sc
                        height: width
                        radius: height / 2
                        z: 10
                        color: eyeMa.containsMouse
                            ? Qt.rgba(root.overlay2.r, root.overlay2.g, root.overlay2.b, 0.3)
                            : "transparent"

                        Behavior on color { ColorAnimation { duration: root.durFast } }

                        Text {
                            anchors.centerIn: parent
                            text: root.passwordVisible ? "󰈈" : "󰈉"
                            font { family: root.fontIcon; pixelSize: 18 * root.sc }
                            color: eyeMa.containsMouse ? root.text : root.subtext0
                            Behavior on color { ColorAnimation { duration: root.durFast } }
                        }

                        MouseArea {
                            id: eyeMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.passwordVisible = !root.passwordVisible
                        }
                    }

                    TextField {
                        id: passwordField
                        anchors {
                            fill: parent
                            leftMargin:  20 * root.sc
                            rightMargin: 60 * root.sc
                        }
                        echoMode: root.passwordVisible
                                  ? TextInput.Normal
                                  : TextInput.Password
                        maximumLength: 128
                        font {
                            family: root.fontMain
                            pixelSize: 24 * root.sc
                            weight: Font.Bold
                        }
                        color: root.authFailed ? root.red : root.text
                        horizontalAlignment: TextInput.AlignHCenter
                        verticalAlignment:   TextInput.AlignVCenter
                        background: Item {}
                        enabled: !root.isPlayingIntro && !root.authenticating
                        z: 0

                        transform: Translate { x: 22 * root.sc }

                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Escape) {
                                root.powerMenuOpen = false
                                root.inputActive   = false
                                event.accepted     = true
                            } else if (!root.inputActive) {
                                root.inputActive = true
                            }
                        }

                        onTextChanged: {
                            if (text.length > 0) {
                                root.authFailed = false
                                root.clearStatusMessage()
                            }
                        }

                        onAccepted: {
                            if (text.length > 0 && !root.authenticating) {
                                root.beginLogin()
                                sddm.login(root.currentUser, text, root.currentSession)
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Power group ───────────────────────────────────────
    // Обёртка держит меню и кнопку вместе — anchors не пересекают siblings
    Item {
        id: powerGroup
        anchors {
            bottom: parent.bottom
            right:  parent.right
            margins: root.edgePad
        }
        // Размер подбирается под кнопку; меню выходит вверх
        width:  powerBtn.width
        height: powerBtn.height

        // ── Power menu ────────────────────────────────────
        Rectangle {
            id: powerMenu
            anchors {
                bottom: parent.top
                right:  parent.right
                bottomMargin: 15 * root.sc
            }
            width: 280 * root.sc
            // Анимируем высоту через implicitHeight цели
            height: root.powerMenuOpen ? (menuLayout.implicitHeight + 20 * root.sc) : 0
            radius: 18 * root.sc
            clip: true
            opacity: root.powerMenuOpen ? 1.0 : 0.0
            visible: opacity > 0.0
            color: Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.95)
            border.color: Qt.rgba(root.mauve.r, root.mauve.g, root.mauve.b, 0.25)
            border.width: root.scaledBorder(1)

            Behavior on height  { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

            // Поглощаем клики внутри меню — не даём дойти до глобального MouseArea
            MouseArea {
                anchors.fill: parent
                enabled: root.powerMenuOpen
                onClicked: {}
            }

            ColumnLayout {
                id: menuLayout
                anchors {
                    top: parent.top
                    topMargin: 10 * root.sc
                    left: parent.left
                    right: parent.right
                }
                spacing: 6 * root.sc

                Text {
                    text: root.uiText.menuTitle
                    font {
                        family:        root.fontMain
                        weight:        Font.Black
                        pixelSize:     12 * root.sc
                        letterSpacing: 1.5
                    }
                    color: root.mauve
                    Layout.leftMargin:   18 * root.sc
                    Layout.topMargin:     4 * root.sc
                    Layout.bottomMargin:  4 * root.sc
                }

                PowerItem {
                    visible: sddm.canReboot
                    icon: "󰜉"; label: root.uiText.reboot
                    accent: root.blue
                    onActivated: sddm.reboot()
                }
                PowerItem {
                    visible: sddm.canSuspend
                    icon: "󰒲"; label: root.uiText.suspend
                    accent: root.mauve
                    onActivated: sddm.suspend()
                }
                PowerItem {
                    visible: sddm.canHibernate
                    icon: "󰋊"; label: root.uiText.hibernate
                    accent: root.green
                    onActivated: sddm.hibernate()
                }
                PowerItem {
                    visible: sddm.canPowerOff
                    icon: "󰐥"; label: root.uiText.powerOff
                    accent: root.red
                    Layout.bottomMargin: 8 * root.sc
                    onActivated: sddm.powerOff()
                }
            }
        }

        // ── Power button ──────────────────────────────────
        Rectangle {
            id: powerBtn
            anchors.bottom: parent.bottom
            anchors.right:  parent.right
            width: 52 * root.sc
            height: width
            radius: height / 2
            opacity: root.introState
            color: root.powerMenuOpen
                ? root.surface2
                : (powerBtnMa.containsMouse
                   ? Qt.rgba(root.surface1.r, root.surface1.g, root.surface1.b, 0.8)
                   : Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.4))
            border.color: root.powerMenuOpen
                ? root.text
                : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.15)
            border.width: root.scaledBorder(1)
            scale: powerBtnMa.pressed
                   ? 0.9
                   : (powerBtnMa.containsMouse ? 1.08 : 1.0)

            Behavior on color        { ColorAnimation  { duration: root.durFast } }
            Behavior on border.color { ColorAnimation  { duration: root.durFast } }
            Behavior on scale        { NumberAnimation { duration: root.durMed;  easing.type: Easing.OutBack } }

            Text {
                anchors.centerIn: parent
                text: "󰐥"
                font { family: root.fontIcon; pixelSize: 22 * root.sc }
                color: root.powerMenuOpen
                    ? root.red
                    : (powerBtnMa.containsMouse ? root.text : root.subtext0)
                Behavior on color { ColorAnimation { duration: root.durFast } }
            }

            MouseArea {
                id: powerBtnMa
                anchors.fill: parent
                hoverEnabled: true
                enabled: !root.isPlayingIntro
                onClicked: root.powerMenuOpen = !root.powerMenuOpen
            }
        }
    }

    // ── Bottom info pills ─────────────────────────────────
    RowLayout {
        anchors {
            bottom: parent.bottom
            bottomMargin: 40 * root.sc
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 16 * root.sc
        opacity: root.introState
        visible: opacity > 0.01

        transform: Translate {
            y: (20 * root.sc) * (1.0 - root.introState)
        }

        // Keyboard layout pill
        Rectangle {
            id: kbPill
            readonly property bool interactive:
                !!keyboard.layouts && keyboard.layouts.length > 1

            Layout.preferredHeight: 48 * root.sc
            Layout.preferredWidth:  kbRow.implicitWidth + 36 * root.sc
            radius: height / 2
            color: (kbMa.containsMouse && interactive)
                ? Qt.rgba(root.surface1.r, root.surface1.g, root.surface1.b, 0.6)
                : Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.4)
            border.color: (kbMa.containsMouse && interactive)
                ? root.blue
                : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.08)
            border.width: root.scaledBorder(1)
            scale: (kbMa.containsMouse && interactive) ? 1.05 : 1.0

            Behavior on scale        { NumberAnimation { duration: root.durFast; easing.type: Easing.OutBack } }
            Behavior on color        { ColorAnimation  { duration: root.durFast } }
            Behavior on border.color { ColorAnimation  { duration: root.durFast } }

            RowLayout {
                id: kbRow
                anchors.centerIn: parent
                spacing: 8 * root.sc

                Text {
                    text: "󰌌"
                    font { family: root.fontIcon; pixelSize: 18 * root.sc }
                    color: (kbMa.containsMouse && kbPill.interactive)
                           ? root.blue : root.overlay2
                    Behavior on color { ColorAnimation { duration: root.durFast } }
                }

                Text {
                    id: kbLabel
                    text: {
                        if (!keyboard.layouts || keyboard.layouts.length === 0)
                            return "N/A"
                        const layout = keyboard.layouts[keyboard.currentLayout]
                        if (!layout) return "N/A"
                        const sn = (layout.shortName || layout.longName || "").toString()
                        return sn ? sn.toUpperCase() : "N/A"
                    }
                    font { family: root.fontMain; pixelSize: 14 * root.sc; weight: Font.Black }
                    color: root.text
                }
            }

            MouseArea {
                id: kbMa
                anchors.fill: parent
                hoverEnabled: true
                enabled: !root.isPlayingIntro && kbPill.interactive
                cursorShape: kbPill.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    const next = (keyboard.currentLayout + 1) % keyboard.layouts.length
                    keyboard.setCurrentLayout(next)
                }
            }
        }

        // Caps Lock pill
        Rectangle {
            Layout.preferredHeight: 48 * root.sc
            Layout.preferredWidth:  capsRow.implicitWidth + 36 * root.sc
            radius: height / 2
            color: keyboard.capsLock
                ? Qt.rgba(root.red.r, root.red.g, root.red.b, 0.2)
                : Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.4)
            border.color: keyboard.capsLock
                ? root.red
                : Qt.rgba(root.text.r, root.text.g, root.text.b, 0.08)
            border.width: root.scaledBorder(2)
            scale: capsMa.containsMouse ? 1.05 : 1.0

            Behavior on color        { ColorAnimation  { duration: root.durFast } }
            Behavior on border.color { ColorAnimation  { duration: root.durFast } }
            Behavior on scale        { NumberAnimation { duration: root.durFast; easing.type: Easing.OutBack } }

            RowLayout {
                id: capsRow
                anchors.centerIn: parent
                spacing: 8 * root.sc

                Text {
                    text: "󰘳"
                    font { family: root.fontIcon; pixelSize: 18 * root.sc }
                    color: keyboard.capsLock
                        ? root.red
                        : (capsMa.containsMouse ? root.text : root.overlay2)
                    Behavior on color { ColorAnimation { duration: root.durFast } }
                }

                Text {
                    text: "CAPS"
                    font { family: root.fontMain; pixelSize: 14 * root.sc; weight: Font.Black }
                    color: keyboard.capsLock
                        ? root.red
                        : (capsMa.containsMouse ? root.text : root.overlay2)
                    Behavior on color { ColorAnimation { duration: root.durFast } }
                }
            }

            MouseArea {
                id: capsMa
                anchors.fill: parent
                hoverEnabled: true
                enabled: !root.isPlayingIntro
                cursorShape: Qt.PointingHandCursor
                onClicked: keyboard.setCapsLockState(!keyboard.capsLock)
            }
        }
    }

    // ── PowerItem component ───────────────────────────────
    component PowerItem : Rectangle {
        id: pItem
        required property string icon
        required property string label
        required property color  accent
        signal activated()

        Layout.fillWidth: true
        Layout.preferredHeight: 48 * root.sc
        Layout.leftMargin:  10 * root.sc
        Layout.rightMargin: 10 * root.sc
        radius: 12 * root.sc
        color: pMa.containsMouse
               ? Qt.rgba(accent.r, accent.g, accent.b, 0.1)
               : "transparent"
        scale: pMa.pressed ? 0.95 : (pMa.containsMouse ? 1.02 : 1.0)

        Behavior on color { ColorAnimation  { duration: root.durFast } }
        Behavior on scale { NumberAnimation { duration: root.durFast; easing.type: Easing.OutBack } }

        RowLayout {
            anchors {
                fill: parent
                leftMargin:  16 * root.sc
                rightMargin: 16 * root.sc
            }

            Text {
                text: pItem.icon
                font { family: root.fontIcon; pixelSize: 18 * root.sc }
                color: pMa.containsMouse
                       ? pItem.accent
                       : Qt.rgba(pItem.accent.r, pItem.accent.g, pItem.accent.b, 0.6)
                Behavior on color { ColorAnimation { duration: root.durFast } }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: pItem.label
                font { family: root.fontMain; pixelSize: 15 * root.sc; weight: Font.Medium }
                color: pMa.containsMouse
                       ? pItem.accent
                       : Qt.rgba(pItem.accent.r, pItem.accent.g, pItem.accent.b, 0.6)
                Behavior on color { ColorAnimation { duration: root.durFast } }
            }
        }

        MouseArea {
            id: pMa
            anchors.fill: parent
            hoverEnabled: true
            onClicked: pItem.activated()
        }
    }

    // ── Intro overlay ─────────────────────────────────────
    Item {
        id: introOverlay
        anchors.fill: parent
        z: 999
        visible: opacity > 0

        Rectangle { anchors.fill: parent; color: "black" }

        Rectangle {
            id: ring3
            anchors.centerIn: parent
            width: 360 * root.sc; height: width
            radius: height / 2
            color: "transparent"
            border.color: root.mauve
            border.width: root.scaledBorder(1)
            scale: 0.5; opacity: 0.0
        }

        Rectangle {
            id: ring2
            anchors.centerIn: parent
            width: 300 * root.sc; height: width
            radius: height / 2
            color: "transparent"
            border.color: root.text
            border.width: root.scaledBorder(1)
            scale: 0.8; opacity: 0.0
        }

        Rectangle {
            id: ring1
            anchors.centerIn: parent
            width: 240 * root.sc; height: width
            radius: height / 2
            color: "transparent"
            border.color: root.text
            border.width: root.scaledBorder(2)
            scale: 0.8; opacity: 0.0
        }

        Item {
            id: introLockOrb
            anchors.centerIn: parent
            width: 170 * root.sc; height: width
            scale: 0.0; opacity: 0.0

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.9)
                border.color: root.text
                border.width: root.scaledBorder(2)
            }

            Image {
                anchors.centerIn: parent
                width: 64 * root.sc; height: width
                source: "assets/logo.svg"
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true
            }
        }

        SequentialAnimation {
            id: introSequence
            running: true

            ParallelAnimation {
                NumberAnimation { target: introLockOrb; property: "scale";   from: 0.0; to: 1.0; duration: 300; easing.type: Easing.OutCubic }
                NumberAnimation { target: introLockOrb; property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { target: ring1; property: "scale";   from: 0.8; to: 1.25; duration: 250; easing.type: Easing.OutCubic }
                NumberAnimation { target: ring1; property: "opacity"; from: 0.6; to: 0.0;  duration: 250; easing.type: Easing.OutCubic }
                NumberAnimation { target: ring2; property: "scale";   from: 0.8; to: 1.4;  duration: 300; easing.type: Easing.OutCubic }
                NumberAnimation { target: ring2; property: "opacity"; from: 0.4; to: 0.0;  duration: 300; easing.type: Easing.OutCubic }
                NumberAnimation { target: ring3; property: "scale";   from: 0.5; to: 1.5;  duration: 350; easing.type: Easing.OutCubic }
                NumberAnimation { target: ring3; property: "opacity"; from: 0.3; to: 0.0;  duration: 350; easing.type: Easing.OutCubic }
            }

            PauseAnimation { duration: 600 }

            ParallelAnimation {
                NumberAnimation { target: introOverlay; property: "opacity";    from: 1.0; to: 0.0; duration: root.durIntro; easing.type: Easing.InOutQuad }
                NumberAnimation { target: root;         property: "introState"; from: 0.0; to: 1.0; duration: root.durIntro; easing.type: Easing.OutCubic }
            }

            PropertyAction { target: root; property: "isPlayingIntro"; value: false }

            ScriptAction {
                script: {
                    passwordField.text = ""
                    passwordField.forceActiveFocus()
                }
            }
        }
    }
}