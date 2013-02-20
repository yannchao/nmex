package nmex;

#if iphone
class Device{
	
	private static var contentScaleFactor:Int  = 0;
	private static var name:String = "";

	public static function uniqueId():String{
		return nmex_device_unique_id();
	}	
	
	public static function osName():String{
		return nmex_device_os();
	}
	
	public static function osVersion():String{
		return nmex_device_vervion();
	}
	
	public static function deviceName():String{
		if(name == ""){
			name = nmex_device_name();
		}
		return name;
	}
	
	public static function model():String{
		return nmex_device_model();
	}
	
	public static function networkAvailable():Bool{
		return nmex_device_network_available();
	}
	
	public static function vibrate(time:Float):Void{
		nmex_device_vibrate(time);
	}
	
	public static function isRetina():Bool{
		
		if(deviceName() == "iPad")	return true;
		
		return nmex_device_is_retina();
	}
	
	public static function scaleFactor():Float{
		
		if(contentScaleFactor == 0){
			if ( isRetina() ){
		    	contentScaleFactor = 2;
		    }else{
		    	contentScaleFactor = 1;
		    }
		}
		
		return contentScaleFactor;
	}
	
	public static function getDocPath():String{
		return nmex_deivce_get_doc_path();
	}
	
	public static function getRecPath():String{
		return nmex_deivce_get_rec_path();
	}
	
	static var nmex_deivce_get_doc_path = nme.Loader.load("nmex_device_get_doc_path",0);
	static var nmex_deivce_get_rec_path = nme.Loader.load("nmex_device_get_rec_path",0);
	static var nmex_device_unique_id = nme.Loader.load("nmex_device_unique_id",0);
	static var nmex_device_os = nme.Loader.load("nmex_device_os",0);
	static var nmex_device_vervion = nme.Loader.load("nmex_device_vervion",0);
	static var nmex_device_name = nme.Loader.load("nmex_device_name",0);
	static var nmex_device_model = nme.Loader.load("nmex_device_model",0);
	static var nmex_device_is_retina = nme.Loader.load("nmex_device_is_retina",0);
	static var nmex_device_network_available = nme.Loader.load("nmex_device_network_available",0);
	static var nmex_device_vibrate = nme.Loader.load("nmex_device_vibrate",1);

}

#else
class Device{
	
		private static var contentScaleFactor:Int  = 1;
		private static var forceRetina:Bool = false;

		public static function uniqueId():String{
			return null;
		}	

		public static function osName():String{
			return null;
		}

		public static function osVersion():String{
			return null;
		}

		public static function deviceName():String{
			return null;
		}

		public static function model():String{
			return null;
		}

		public static function networkAvailable():Bool{
			return null;
		}

		public static function vibrate(time:Float):Void{
		}

		public static function isRetina():Bool{
			return false;
		}

		public static function scaleFactor():Float{

			return contentScaleFactor;
		}

		public static function getDocPath():String{
			return null;
		}

		public static function getRecPath():String{
			return null;
		}

	}
#end


