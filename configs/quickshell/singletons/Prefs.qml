pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Пользовательские настройки оболочки (Prefs).
//
// Хранятся в settings.json рядом с shell.qml. Файл игнорируется git — это
// состояние конкретной машины, а не часть репозитория.
//
// Имя Prefs, а не Settings: QtCore экспортирует QML-тип Settings, и при
// совпадении имён выигрывал он — у типа нет свойств, чтение давало undefined,
// присваивание уходило в пустоту.
//
// Читаем тем же способом, что и theme/Colors.qml: FileView + onLoaded + JSON.parse.
//
// Наружу — Prefs.captureDir и Prefs.captureMode.
//
// Файла может не быть — это нормальное состояние, а не ошибка:
//   * нет файла            → живём на умолчаниях, файл создастся при первом изменении;
//   * пустой файл          → то же самое;
//   * файл удалили на ходу → возвращаемся к умолчаниям, обратно не записываем;
//   * битый JSON           → ругаемся в лог и держим умолчания, файл не трогаем;
//   * нет прав на запись   → ругаемся в лог, настройка живёт только в памяти.

Singleton {
    id: root

    readonly property string path: Quickshell.shellDir + "/settings.json"

    // "" — папка не выбрана, capture.sh возьмёт умолчание из XDG.
    property string captureDir: ""

    // clipboard | file | both
    property string captureMode: "clipboard"

    // Пока применяем то, что пришло с диска, менять свойства может только load():
    // иначе эхо файла записывалось бы обратно (и воскрешало удалённый файл).
    property bool reading: false

    FileView {
        id: file
        path: root.path
        watchChanges: true

        // Отсутствие файла — штатная ситуация, а не повод писать в лог при каждом
        // старте. Настоящие ошибки разбираем сами в loadFailed/saveFailed.
        printErrors: false

        onFileChanged: reload()
        onLoaded: root.load(text())
        onLoadFailed: (error) => root.loadFailed(error)
        onSaveFailed: (error) => root.saveFailed(error)
    }

    // Приводим свойства к тому, что лежит в data. Пустые данные = умолчания.
    function load(data) {
        root.reading = true

        let settings = null
        if (data !== "") {
            try {
                settings = JSON.parse(data)
            } catch (e) {
                console.error("Prefs:", root.path, "— разбор не удался:", e)
            }
        }

        root.captureDir = settings && typeof settings.captureDir === "string"
                          ? settings.captureDir : ""
        root.captureMode = settings && typeof settings.captureMode === "string"
                           ? settings.captureMode : "clipboard"

        root.reading = false
    }

    function loadFailed(error) {
        if (error === FileViewError.FileNotFound) {
            // Файла нет: работаем на умолчаниях. Записывать его здесь нельзя —
            // он должен появиться только после реального изменения.
            root.load("")
            return
        }

        // Файл есть, но прочитать нельзя (права, это каталог). Значения в памяти
        // не трогаем: лучше старое значение, чем тихо потерянное.
        console.error("Prefs:", root.path, "— чтение не удалось:",
                      FileViewError.toString(error))
    }

    function saveFailed(error) {
        console.error("Prefs:", root.path, "— запись не удалась:",
                      FileViewError.toString(error))
    }

    function save() {
        if (root.reading) return

        // setText создаёт файл, если его нет (родительские каталоги тоже), и
        // ничего не делает, если на диске уже ровно этот текст.
        file.setText(JSON.stringify({
            version: 1,
            captureDir: root.captureDir,
            captureMode: root.captureMode
        }, null, 4) + "\n")
    }

    onCaptureDirChanged: save()
    onCaptureModeChanged: save()
}
