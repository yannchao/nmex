/**
*  
*  if you want to use AD, you must change nme to set keyWindows.rootViewController
*  
*  */
package nmex;

class AD{
	#if android
	//android
	private static var _showAd_func:Dynamic;
	public static function showAd(id:String, x:Int=0, y:Int=0, size:Int=0, preLoad:Int=0):Void{
		if (_showAd_func == null)
			_showAd_func = nme.JNI.createStaticMethod("org.haxe.nme.GameActivity", "showAd", "(Ljava/lang/String;IIII)V", true);
		var a = new Array<Dynamic>();
		a.push(id);
		a.push(x);
		a.push(y);
		a.push(size);
		a.push(preLoad);
		_showAd_func(a);
	}
    
	private static var _hideAd_func:Dynamic;
	public static function hideAd():Void{
		if (_hideAd_func == null)
			_hideAd_func = nme.JNI.createStaticMethod("org.haxe.nme.GameActivity", "hideAd", "()V", true);
		var a = new Array<Dynamic>();
		_hideAd_func(a);
	}
	
	#else
	// iphone
	private static var running:Bool = false;
	private static var isInit:Bool = false;
	
	public static function init(id:String = "",x:Int = 0,y:Int = 0, sizeType:Int=0):Void{
		nmex_ad_init(id,x,y,sizeType);
		isInit = true;
	}

	public static function show():Void{
		if(isInit && !running){
			nmex_ad_show();
			running = true;
		}
	}	
	
	public static function hide():Void{
		if(isInit && running){
			nmex_ad_hide();
			running = false;
		}
	}
	
	public static function refresh():Void{
		if(isInit){
			nmex_ad_refresh();
		}
	}
	
	static var nmex_ad_init = nme.Loader.load("nmex_ad_init",4);
	static var nmex_ad_show = nme.Loader.load("nmex_ad_show",0);
	static var nmex_ad_hide = nme.Loader.load("nmex_ad_hide",0);
	static var nmex_ad_refresh = nme.Loader.load("nmex_ad_refresh",0);
	#end
}