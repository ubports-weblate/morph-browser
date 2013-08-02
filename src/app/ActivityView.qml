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
import Ubuntu.Components 0.1

Tabs {
    id: activityView

    property alias tabsModel: timelineView.tabsModel
    property alias historyModel: timelineView.historyModel

    signal historyEntryRequested(url url)
    signal newTabRequested()
    signal switchToTabRequested(int index)
    signal closeTabRequested(int index)

    Tab {
        title: i18n.tr("Activity")
        page: Page {
            TimelineView {
                id: timelineView

                anchors.fill: parent

                onNewTabRequested: activityView.newTabRequested()
                onSwitchToTabRequested: activityView.switchToTabRequested(index)
                onCloseTabRequested: activityView.closeTabRequested(index)
                onHistoryEntryClicked: activityView.historyEntryRequested(url)
            }
        }
    }

    Component.onCompleted: timelineView.resetPositionRequested()
}
