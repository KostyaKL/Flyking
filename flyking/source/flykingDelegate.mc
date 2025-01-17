using Toybox.WatchUi;
using Toybox.Application as App;

class flykingDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new flykingMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
    
    function onKey( evt ){
    	if(evt.getKey() == 4){
        	App.getApp().buttonPress();
        }
        else if(evt.getKey() == 5){
        	App.getApp().exitConfirm();
        }
    	return true;
    }
}