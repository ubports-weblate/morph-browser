/*
 * Copyright 2013 Canonical Ltd.
 *
 * This file is part of webbrowser-app.
 *
 * webbrowser-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * webbrowser-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtQuick.Window 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Extras.Browser 0.1
import webcontainer.private 0.1

Window {
    id: root

    property bool developerExtrasEnabled: false

    property bool backForwardButtonsVisible: false
    property bool addressBarVisible: false

    property string webappName: ""
    property string webappModelSearchPath: ""
    property string webappUrlPatterns: ""

    property string applicationName: Qt.application.name
    property string url: ""

    property string webappTitle

    property string accountProvider: ""

    width: 800
    height: 600

    title: {
        if (typeof(webappName) === 'string' && webappName.length !== 0) {
            return webappName
        } else if (root.webappTitle && root.webappTitle.length !== 0) {
            // TRANSLATORS: %1 refers to the current page’s title
            return i18n.tr("%1 - Ubuntu Web Application").arg(root.webappTitle)
        } else {
            return i18n.tr("Ubuntu Web Application")
        }
    }

    Loader {
        id: webappPageComponentLoader
        anchors.fill: parent
    }
    Component {
        id: webappPageComponent

        Page {
            id: webappPage

            visible: false
            anchors.fill: parent

            WebApp {
                id: browser

                anchors.fill: parent
                url: root.url
                onTitleChanged: root.title = title

                property int screenOrientation: Screen.orientation
                onScreenOrientationChanged: root.contentOrientation = screenOrientation

                chromeless: !backForwardButtonsVisible && !addressBarVisible
                webbrowserWindow: webbrowserWindowProxy

                Component.onCompleted: i18n.domain = "webbrowser-app"

                developerExtrasEnabled: root.developerExtrasEnabled
                backForwardButtonsVisible: root.backForwardButtonsVisible
                addressBarVisible: root.addressBarVisible
                webappName: root.webappName
                webappModelSearchPath: root.webappModelSearchPath
                webappUrlPatterns: root.webappUrlPatterns
            }
        }
    }

    Loader {
        id: accountsPageComponentLoader
        anchors.fill: parent
        onStatusChanged: {
            if (status == Loader.Error) {
                // Happens on the desktop, if Ubuntu.OnlineAccounts.Client
                // can't be imported
                loadWebAppView()
            } else if (status == Loader.Ready) {
                item.visible = true
            }
        }
    }

    Connections {
        target: accountsPageComponentLoader.item
        onDone: loadWebAppView()
    }

    SqliteCookieStore {
        id: webappCookieStore
        dbPath: dataLocation + "/.QtWebKit/cookies.db"
    }

    Component.onCompleted: updateCurrentView()

    onAccountProviderChanged: {
        updateCurrentView();
    }

    function updateCurrentView() {
        // check if we are to display the OS login view
        // or directly switch to the webapp view
        if (accountProvider.length !== 0) {
            loadLoginView();
        }
        else {
            loadWebAppView();
        }
    }

    function loadLoginView() {
        accountsPageComponentLoader.setSource("AccountsPage.qml", {
            "accountProvider": root.accountProvider,
            "applicationName": root.applicationName,
            "webappCookieStore": webappCookieStore,
        })
    }

    function loadWebAppView() {
        webappPageComponentLoader.sourceComponent = webappPageComponent;
        if (accountsPageComponentLoader.item)
            accountsPageComponentLoader.item.visible = false;
        webappPageComponentLoader.item.visible = true;
    }
}
