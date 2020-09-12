using Toybox.WatchUi;
using Toybox.System;
using Toybox.Application as App;

class saveConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_NO) {
                        
        } else {
            System.println("save activity");
            App.getApp().saveFunc();
        }
    }
}