package nmex;

class Tracker{
	
	
	private static var init:Bool = false;
	
	private static function assertInit():Void{
		if(!init)	throw "Please startTracker() first.";
	}
	
	#if android
	
	private static var _startTracker_func:Dynamic;
	public static function startTracker(acountID:String, disPatchPeriod:Int = -1):Void{
		if (_startTracker_func == null)
			_startTracker_func = nme.JNI.createStaticMethod("org.haxe.nme.GameActivity", "startTracker", "(Ljava/lang/String;I)V", true);
		var a = new Array<Dynamic>();
		a.push(acountID);
		a.push(disPatchPeriod);
		_startTracker_func(a);
		
		init = true;
	}
    
    
	private static var _trackEvent_func:Dynamic;
	public static function trackEvent(category:String, action:String, label:String, value:Int):Void{
		assertInit();
		if (_trackEvent_func == null)
			_trackEvent_func = nme.JNI.createStaticMethod("org.haxe.nme.GameActivity", "trackEvent", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V", true);
		var a = new Array<Dynamic>();
		a.push(category);
		a.push(action);
		a.push(label);
		a.push(value);
		_trackEvent_func(a);
	}
    
    
	private static var _trackPage_func:Dynamic;
	public static function trackPage(pageName:String):Void{
		assertInit();
		if (_trackPage_func == null)
			_trackPage_func = nme.JNI.createStaticMethod("org.haxe.nme.GameActivity", "trackPage", "(Ljava/lang/String;)V", true);
		var a = new Array<Dynamic>();
		a.push(pageName);
		_trackPage_func(a);
	}
    
    
	private static var _dispatchTracker_func:Dynamic;
	public static function dispatchTracker():Void{
		assertInit();
		if (_dispatchTracker_func == null)
			_dispatchTracker_func = nme.JNI.createStaticMethod("org.haxe.nme.GameActivity", "dispatchTracker", "()V", true);
		var a = new Array<Dynamic>();
		_dispatchTracker_func(a);
	}
    
    
	private static var _stopTracker_func:Dynamic;
	public static function stopTracker():Void{
		assertInit();
		if (_stopTracker_func == null)
			_stopTracker_func = nme.JNI.createStaticMethod("org.haxe.nme.GameActivity", "stopTracker", "()V", true);
		var a = new Array<Dynamic>();
		_stopTracker_func(a);
		init = false;
	}
	
	
	#else

	/**
	 *  startTracker
	 */
	public static function startTracker(acountID:String,disPatchPeriod:Int = -1):Void{
		nmex_tracker_start_tracker(acountID,disPatchPeriod);
		init = true;
	}
	/**
 	*  trackEvent
 	*/
	public static function trackEvent(category:String,action:String,label:String,value:Int):Void{
		assertInit();
		nmex_tracker_track_event(category,action,label,value);
	}

	/**
 	*  trackPage
 	*/	
	public static function trackPage(pageName:String):Void{
		assertInit();
		nmex_tracker_track_page(pageName);
	}

	/**
 	*  dispatchTracker
 	*/
	public static function dispatchTracker():Void{
		assertInit();
		nmex_tracker_dispatch_tracker();
	}
	
	/**
 	*  stopTracker
 	*/
	public static function stopTracker():Void{
		assertInit();
		nmex_tracker_stop_tracker();
		init = false;
	}
	
	static var nmex_tracker_start_tracker = nme.Loader.load("nmex_tracker_start_tracker",2);
	static var nmex_tracker_track_event = nme.Loader.load("nmex_tracker_track_event",4);
	static var nmex_tracker_track_page = nme.Loader.load("nmex_tracker_track_page",1);
	static var nmex_tracker_dispatch_tracker = nme.Loader.load("nmex_tracker_dispatch_tracker",0);
	static var nmex_tracker_stop_tracker = nme.Loader.load("nmex_tracker_stop_tracker",0);
	
	#end
	
}

