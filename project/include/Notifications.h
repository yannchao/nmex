#ifndef Notifications
#define Notifications

namespace nmeExtensions{
  void scheduleLocalNotification(int secondsToFire, const char *bodyText, const char *actionText, int badgeNumber,
      const char *userInfo);
  void cancelLocalNotifications();
  void setAppIconBadge(int number);
}

#endif
