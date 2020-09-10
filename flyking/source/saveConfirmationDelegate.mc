using Toybox.WatchUi;
using Toybox.System;
using Toybox.Application as App;

class saveConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }

    function onResponse(response) {
    	System.println(response);
        if (response == WatchUi.CONFIRM_NO) {
            System.println("dont save");
            
        } else {
            System.println("save activity");
            App.getApp().saveFunc();
        }
    }
}