using Toybox.WatchUi;
using Toybox.Time as Time;
using Toybox.System as Sys;

class flykingView extends WatchUi.View {

	var gps_stat = 0;
	var rec_stat = false;
	var timer = "00:00";
	var posnInfo = null;
	var sensInfo = null;
	
	var posAlt = 0;
	var posVs = 0;
	var posSpeed = 0;
	var sensTemp = 0;
	var sensQnh = 0;
	var posHdg = 0;
	
	var clockTime = null;
	var posTime = 0;
	var prevAlt = 0;
	var prevEpoch = 0;
	
    function initialize() {
    	clockTime = Sys.getClockTime();
		posTime = clockTime.hour*3600 + clockTime.min*60 + clockTime.sec;
    	prevEpoch = posTime;
    	gps_stat = 0;
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	// Get and show the current time
   		clockTime = Sys.getClockTime();
   		var timeString = Lang.format("$1$:$2$",[clockTime.hour, clockTime.min.format("%.2d")]);
   		var clock_lable = View.findDrawableById("clock");
   		clock_lable.setText(timeString);
   		
   		var gps_label = View.findDrawableById("gps");
   		if (gps_stat == 2){
    		gps_label.setColor(Graphics.COLOR_DK_GREEN);
    	}
    	else if (gps_stat == 1){
    		gps_label.setColor(Graphics.COLOR_YELLOW);
    	}
    	else{
    		gps_label.setColor(Graphics.COLOR_RED);
    	}
    	
    	var rec_label = View.findDrawableById("rec");
    	if(rec_stat){
    		rec_label.setColor(Graphics.COLOR_RED);
    	}
    	else{
    		rec_label.setColor(Graphics.COLOR_DK_GRAY);
    	}
    	
    	var timere_lable = View.findDrawableById("timer");
   		timere_lable.setText(timer);
   		
   		var speed_val = View.findDrawableById("speed_val");
		speed_val.setText(posSpeed.format("%1.0f"));
   		var hdg_val = View.findDrawableById("heading_val");
   		hdg_val.setText(posHdg.format("%03.0f"));
   		var alt_val = View.findDrawableById("altitude_val");
   		alt_val.setText(posAlt.format("%1.0f"));
   		var vs_val = View.findDrawableById("vs_val");
   		vs_val.setText(posVs.format("%5.0f"));
   		var qnh_val = View.findDrawableById("qnh_val");
   		qnh_val.setText(sensQnh.format("%1.0f"));
   		var temp_val = View.findDrawableById("temp_val");
   		temp_val.setText(sensTemp.format("%1.0f"));
   		
   			
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
    
    function gpsStat(stat){
    	gps_stat = stat;
    	
    }
    
    function recording(rec){
    	rec_stat = rec;
    }
    
    function setTimer(newTimer){
    	timer = newTimer;
    }
    
    function setPosition(info){
    	posnInfo = info;
    }
    
    function setSensor(sensor){
    	sensInfo = sensor;
    }
    
    function setSpeed(speed){
    	posSpeed = speed;
    }
    
    function setHdg(hdg){
    	posHdg = hdg;
    }
    
    function setAltitude(altitude){
    	posAlt = altitude;
    }
    
    function setVs(vs){
    	posVs = vs;
    }
    
    function setQnh(qnh){
    	sensQnh = qnh;
    }
    
    function setTemperature(temperature){
    	sensTemp = temperature;
    }

}
