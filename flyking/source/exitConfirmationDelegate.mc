using Toybox.WatchUi;
using Toybox.System;
using Toybox.Application as App;

class exitConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_NO) {
            System.println("dont exit");
            //System.exit();
        } else {
            System.println("exit confirm");
            App.getApp().exitFunc();
        }
    }
}