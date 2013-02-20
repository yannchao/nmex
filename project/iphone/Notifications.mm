//  Notifications.m

#import <UIKit/UIKit.h>
#include "Notifications.h"

namespace nmeExtensions{

  void scheduleLocalNotification(int secondsToFire, const char *bodyText, const char *actionText, int badgeNumber,
      const char *userInfo) {
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil) {
      return;
    }

    NSDate *now = [NSDate date];
    localNotif.fireDate = [now dateByAddingTimeInterval:secondsToFire];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    localNotif.alertBody = [[NSString alloc] initWithUTF8String:bodyText];
    localNotif.alertAction = [[NSString alloc] initWithUTF8String:actionText];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = badgeNumber;

    if (userInfo) {
      NSError *e = nil;
      NSData *data = [[[NSString alloc] initWithUTF8String:userInfo] dataUsingEncoding:NSUTF8StringEncoding];
      NSDictionary *userInfoDict = [NSJSONSerialization JSONObjectWithData:data options:0 error: &e];
      if (!e) {
        localNotif.userInfo = userInfoDict;
      }
    }

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [localNotif release];
  }

  void cancelLocalNotifications() {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
  }

  void setAppIconBadge(int number) {
    NSLog(@"setting app badge to  = %d", number);
    [UIApplication sharedApplication].applicationIconBadgeNumber = number;
  }
}
