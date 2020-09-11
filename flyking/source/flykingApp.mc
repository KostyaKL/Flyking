using Toybox.Application;
using Toybox.Position;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.ActivityRecording as Record;
using Toybox.FitContributor as Fit;
using Toybox.Timer;
using Toybox.Sensor;

class flykingApp extends Application.AppBase {

	var global_vars = globalVars.getInstance();
	var seconds = 0;
	var minutes = 0;
	var hours = 0;
	var secTimer = null; // Main timer for updating UI, starting recording, etc.
	var recording = false;
	var saved = false;
	var session = null;

	var qnh_fit_field = null;
	var temp_fit_field = null;
	var speed_fit_field = null;
	var altitude_fit_field = null;
	var vs_fit_field = null;
	var hdg_fit_field = null;
	
	var temperature = 0;
	var qnh = 1013;
	var altitude = 0;
	var spd = 0;
	var vs = 0;
	var posHdg = 0;
	
	var posInfo = null;
	var sensInfo = null;
	
	var clockTime = null;
	var posTime = 0;
	var prevAlt = 0;
	var prevEpoch = 0;
	
	var flykingViews = [];
	
	
    function initialize() {
        AppBase.initialize();
        clockTime = Sys.getClockTime();
		posTime = clockTime.hour*3600 + clockTime.min*60 + clockTime.sec;
    	prevEpoch = posTime;
    }

    // onStart() is called on application start up
    function onStart(state) {
    	Position.enableLocationEvents({
        	:acquisitionType => Position.LOCATION_CONTINUOUS,
        	:constellations => [ Position.CONSTELLATION_GPS, Position.CONSTELLATION_GLONASS ],
        	:mode => Position.POSITIONING_MODE_AVIATION
    		}, method(:onPosition));
    	secTimer = new Timer.Timer();
		secTimer.start(method(:refresh), 1000, true);
		
		Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_TEMPERATURE]);
    	Sensor.enableSensorEvents(method(:onSensor));
    	
    	session = Record.createSession({:name=>"Flyking", :sport=>Record.SPORT_FLYING});
		qnh_fit_field = session.createField("qnh", 4, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>Fit.MESG_TYPE_RECORD, :units=>"mbar" });
		temp_fit_field = session.createField("temp", 3, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>Fit.MESG_TYPE_RECORD, :units=>"celsius" });
		speed_fit_field = session.createField("speed", 0, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>Fit.MESG_TYPE_RECORD, :units=>"knots" });
		altitude_fit_field = session.createField("altitude", 1, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>Fit.MESG_TYPE_RECORD, :units=>"feet" });
		vs_fit_field = session.createField("vs", 2, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>Fit.MESG_TYPE_RECORD, :units=>"feet/min" });
		hdg_fit_field = session.createField("hdg", 5, FitContributor.DATA_TYPE_FLOAT, { :mesgType=>Fit.MESG_TYPE_RECORD, :units=>"degrees" });
		
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    	secTimer.stop();
    	if( session != null && session.isRecording() ) {
			session.stop();
			session.save();
			session = null;
		}
    	Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    	System.println("exit");
    }

    // Return the initial view of your application here
    function getInitialView() {
    	flykingViews.add(new flykingView());
        return [ flykingViews[0], new flykingDelegate() ];
    }
    
    function refresh(){
    	Ui.requestUpdate();
    	var stat = 0;
		var gpsAccuracy = Position.getInfo().accuracy;
		if (gpsAccuracy == Position.QUALITY_GOOD){
			stat = 2;
		}
		else if (gpsAccuracy == Position.QUALITY_USABLE || gpsAccuracy == Position.QUALITY_POOR){
			stat = 1;
		}
		else{
			stat = 0;
		}
    	
    	flykingViews[0].gpsStat(stat);
    	
    	var ActivityInfo = Activity.getActivityInfo();  // ... we need *raw ambient* pressure
    	if(ActivityInfo has :rawAmbientPressure and ActivityInfo.rawAmbientPressure != null) {
//    		pressure = ActivityInfo.rawAmbientPressure/100;
//      	qnh = pressure + (altitude/30);
			qnh = ActivityInfo.meanSeaLevelPressure/100;
      		flykingViews[0].setQnh(qnh);
    	}
    		
    	var weatherInfo = Weather.getCurrentConditions();
    	if(weatherInfo has :temperature and weatherInfo != null){
    		temperature = weatherInfo.temperature;
    		flykingViews[0].setTemperature(temperature);
    	}
    	
  		
   		if (posInfo != null){
   			spd = posInfo.speed * 1.9438445;
			flykingViews[0].setSpeed(spd);
			
			altitude = posInfo.altitude * 3.28084;
			flykingViews[0].setAltitude(altitude);
				
			clockTime = Sys.getClockTime();
			posTime = clockTime.hour*3600 + clockTime.min*60 + clockTime.sec;
			if((posTime - prevEpoch) != 0){
   				vs = (altitude - prevAlt) / (posTime - prevEpoch);
				vs *= 60;
				prevAlt = altitude;
				prevEpoch = posTime;
			}
			flykingViews[0].setVs(vs);
				
			posHdg = posInfo.heading * (180 / Math.PI);
			if (posHdg < 0) { posHdg += 360; }
			flykingViews[0].setHdg(posHdg);
		}
    	
    	if(recording){
    		if (saved){
    			saved = false;
        		seconds = 0;
    			minutes = 0;
    			hours = 0;
    			flykingViews[0].setTimer("00:00");
    		}
    		
    		if(session.isRecording() == false){
				session.start();
			}
    		seconds++;
    		
    		if(seconds == 60){
    			minutes++;
    			seconds = 0;
    		}
    		if(minutes == 60){
    			hours++;
    			minutes = 0;
    		}
    		var timer = "00:00";
    		if(hours < 10){
    			if(minutes < 10){
    				timer = "0" + hours + ":0" + minutes;
    			}
    			else{
    				timer = "0" + hours + ":" + minutes;
    			}
    		}
    		else{
    			if(minutes < 10){
    				timer = hours + ":0" + minutes;
    			}
    			else{
    				timer = hours + ":" + minutes;
    			}
    		}
    		flykingViews[0].setTimer(timer);
    		
    		qnh_fit_field.setData(qnh);
    		temp_fit_field.setData(temperature);
    		speed_fit_field.setData(spd);
    		altitude_fit_field.setData(altitude);
			vs_fit_field.setData(vs);
			hdg_fit_field.setData(posHdg);
    	}
    }
    
    function buttonPress(){
    	if (recording){
    		recording = false;
			Ui.pushView(new Ui.Confirmation("Save Flight?"), new saveConfirmationDelegate(), WatchUi.SLIDE_IMMEDIATE);
    	}
    	else{
    		recording = true;
    	}
    	flykingViews[0].recording(recording);
    	Ui.requestUpdate();
    }
    
    function exitConfirm(){
			Ui.pushView(new Ui.Confirmation("Exit?"), new exitConfirmationDelegate(), WatchUi.SLIDE_IMMEDIATE);
    }
    
    function exitFunc(){
    	Sys.exit();
    }
    
    function saveFunc(){
    	if( session != null && session.isRecording() ) {
			session.stop();
			session.save();
			session = null;
			saved = true;
			Sys.exit();
		}
    }
    
	function onPosition(info){
		flykingViews[0].setPosition(info);
		posInfo = info;
	}
	
	function onSensor(sensorInfo) {
		flykingViews[0].setSensor(sensorInfo);
		sensInfo = sensorInfo;
	}
}
