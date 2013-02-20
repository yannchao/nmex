package nmex;

class Notifications {

  private static var s_instance:Notifications;

  function new() {
  }

  public static function getInstance() : Notifications {
    if (s_instance == null) {
      s_instance = new Notifications();
    }
    return s_instance;
  }

  public function localNotification(secondsToFire:Int, bodyText:String, actionText:String,
      badgeNumber:Int=1, userInfo:Hash<String>=null) : Void {

    var userInfoJSON:String = userInfo != null ? haxe.Json.stringify(userInfo) : null;
    nmex_notifications_schedule_local(secondsToFire, bodyText, actionText, badgeNumber, userInfoJSON);
  }

  public function clearLocalNotifications() : Void {
    nmex_notifications_cancel();
  }

  public function setAppBadge(badgeNum:Int) : Void {
    nmex_notifications_set_app_badge(badgeNum);
  }

  private static var nmex_notifications_schedule_local = nme.Loader.load("nmex_notifications_schedule_local",5);
  private static var nmex_notifications_cancel = nme.Loader.load("nmex_notifications_cancel",0);
  private static var nmex_notifications_set_app_badge = nme.Loader.load("nmex_notifications_set_app_badge",1);
}
