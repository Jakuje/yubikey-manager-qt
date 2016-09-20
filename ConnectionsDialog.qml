import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

DefaultDialog {
    property var device

    title: qsTr("Configure connections")

    onAccepted: {
        var enabled = get_enabled()
        device.set_mode(enabled, function (e) {
            if (e) {
                console.log('Error setting mode: ' + e)
            } else {
                ejectNow.open()
            }
        })
    }

    ColumnLayout {
        anchors.fill: parent

        Text {
            textFormat: Text.StyledText
            text: qsTr("<h2>Configure enabled connection protocols</h2>
<p>Set the enabled connection protocols for your YubiKey.</p>
<p>Once changed, you will need to unplug and re-insert your YubiKey for the settings to take effect.</p>")
        }

        RowLayout {
            Layout.fillWidth: true
            Repeater {
                id: connections
                model: device.connections

                CheckBox {
                    Layout.fillWidth: true
                    text: modelData
                    checked: device.enabled.indexOf(modelData) >= 0
                    enabled: modelData !== 'NFC'
                    onCheckedChanged: button_ok.enabled = check_acceptable()
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Button {
                id: button_ok
                text: qsTr("OK")
                onClicked: {
                    close()
                    accepted()
                }
            }
            Button {
                text: qsTr("Cancel")
                onClicked: {
                    close()
                    rejected()
                }
            }
        }
    }

    MessageDialog {
        id: ejectNow
        title: qsTr('Connections configured')
        icon: StandardIcon.Information
        text: qsTr('Connections are now configured. Remove and re-insert your YubiKey.')
        standardButtons: StandardButton.NoButton

        readonly property bool hasDevice: device.hasDevice
        onHasDeviceChanged: if (!hasDevice) ejectNow.close()
    }

    function get_enabled() {
        var enabled = []
        for (var i = 0; i < device.connections.length; i++) {
            var connection_checkbox = connections.itemAt(i)
            if (connection_checkbox.checked) {
                enabled.push(connection_checkbox.text)
            }
        }
        return enabled
    }

    function check_acceptable() {
        for (var i = 0; i < connections.count; i++) {
            var item = connections.itemAt(i)
            if(item) {
                if (item.text === 'NFC') {
                    continue
                }
                if (item.checked) {
                    return true
                }
            }
        }
        return false
    }
}