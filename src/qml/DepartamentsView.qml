import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import Snapd 1.0

import org.nx.softwarecenter 1.0


Item {
    id: departamentsRoot
    property var departamentsListModel

    property string currentDepartamentSlug: ""

    ScrollView {
        anchors.fill: parent
        ListView {
            model: departamentsListModel
            delegate: departamentDelegate
        }
    }

    Component {
        id: departamentDelegate
        Item {
            id: delegateRoot
            width: departamentsRoot.width
            height: 280
            property bool expanded: false

            Image {
                anchors.fill: parent
                source: "file:///usr/share/nx_software_center/departaments_background/"
                        + model.slug + ".png"
                fillMode: Image.PreserveAspectCrop
                opacity: 0.6
            }

            Rectangle {
                anchors.fill: parent
                color: "black" // Utils.stringToColor(model.slug)
                opacity: 0.20
            }
            Text {
                id: sectionTitle
                x: delegateRoot.expanded ? 12 : delegateRoot.width / 2 - width / 2
                y: delegateRoot.expanded ? 12 : delegateRoot.height / 2 - height - 12

                text: model.name
                color: "white"
                font.pointSize: 24
            }

            DropShadow {
                anchors.fill: sectionTitle
                radius: 4
                samples: 9
                color: "black"
                source: sectionTitle
            }

            Button {
                height: 40
                width: 90
                anchors.top: parent.verticalCenter
                anchors.topMargin: 12
                anchors.horizontalCenter: parent.horizontalCenter

                text: i18n("View")

                onClicked: {
                    delegateRoot.expanded = true
                    currentDepartamentSlug = model.slug
                    departamentSnapsLoader.sourceComponent = departamentSnaps
                }

                visible: !delegateRoot.expanded

                style: ButtonStyle {
                    background: Rectangle {
                        radius: 2
                        border.width: 1.2
                        border.color: control.hovered ? "#9ED2ED" : "white"
                        color: control.pressed ? "#9ED2ED" : "transparent"
                    }
                    label: Item {
                        Label {
                            id: labelText
                            anchors.fill: parent
                            color: "white"
                            text: control.text
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        DropShadow {
                            anchors.fill: labelText
                            radius: 4
                            samples: 9
                            color: "black"
                            source: labelText
                        }
                    }
                }
            }

            Loader {
                id: departamentSnapsLoader
                anchors.fill: parent
                anchors.margins: 12
                anchors.topMargin: 38
            }

            Button {
                height: 40
                width: 90
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 6
                anchors.right: parent.right
                anchors.rightMargin: 24

                visible: delegateRoot.expanded
                text: i18n("Hide")
                onClicked: {
                    delegateRoot.expanded = false
                    departamentSnapsLoader.sourceComponent = undefined
                }

                style: ButtonStyle {
                    background: Rectangle {
                        radius: 2
                        border.width: 1.2
                        border.color: control.hovered ? "#9ED2ED" : "white"
                        color: control.pressed ? "#9ED2ED" : "transparent"
                    }
                    label: Item {
                        Label {
                            id: labelText
                            anchors.fill: parent
                            color: "white"
                            text: control.text
                            font.pointSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        DropShadow {
                            anchors.fill: labelText
                            radius: 4
                            samples: 9
                            color: "black"
                            source: labelText
                        }
                    }
                }
            }
        }
    }

    Component {
        id: departamentSnaps
        ListView {
            orientation: ListView.Horizontal
            model: SnapsModel {
                id: storeSnapsModel

                property var snaps
                onSelectedItemsChanged: {
                    refreshActions()
                }

                fetchSnapsFunc: function () {
                    var request = SnapStore.getDepartment(
                                currentDepartamentSlug)

                    request.runSync()

                    var pkgs = []
                    for (var i = 0; i < request.packagesCount(); i++) {
                        var pkg = request.package(i)
                        pkgs.push(pkg)
                        //                            storeSnapsModel.append(pkg)
                    }

                    //                        contentLoader.sourceComponent = snapsView
                    return pkgs
                }

                function _indexOf(name) {
                    return UtilsJs.binaryIndexOf(name, function (a, b) {
                        return a.package_name.localeCompare(b)
                    }, function () {
                        return count
                    }, function (i) {
                        return get(i)
                    })
                }

                function refreshActions() {
                    var keys = Object.keys(selectedItems)
                    if (keys.length > 0) {
                        var installAction = {
                            icon: "package-install",
                            text: textConstants.actionInstallTitle,
                            action: function () {
                                var targets_names = Object.keys(
                                            storeSnapsModel.selectedItems)
                                var targets = []
                                for (var i in targets_names) {
                                    var model = storeSnapsModel.getByName(
                                                targets_names[i])
                                    targets.push({
                                                     name: model.package_name,
                                                     channel: model.channel
                                                 })
                                }

                                installSnapInteractor.targets = targets
                                installSnapInteractor.finished.connect(
                                            refreshActions)

                                installSnapInteractor.start()
                            }
                        }

                        var actions = [installAction]
                        statusArea.updateContext("documentinfo",
                                                 textConstants.availableActionsNotice,
                                                 actions)
                    } else
                        statusArea.clearContext()
                }
            }
            delegate: SnapElementDelegate {
                snap_name: title
                snap_version: version
                onSelectedChanged: {
                    if (selected)
                        storeSnapsModel.selectedItems[package_name] = "true"
                    else
                        delete storeSnapsModel.selectedItems[package_name]

                    storeSnapsModel.refreshActions()
                }
                onClicked: {
                    contentLoader.push({
                                           item: Qt.resolvedUrl(
                                                     "SnapDetailsView.qml"),
                                           properties: {
                                               package_name: package_name,
                                               dismissCallback: function () {
                                                   contentLoader.pop()
                                                   storeSnapsModel.refreshActions()
                                               }
                                           }
                                       })
                }
            }
        }
    }

    Component.onCompleted: statusArea.clearContext()
}