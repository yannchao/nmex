#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#include <GANTracker.h>

namespace nmeExtensions {

//GA
void startTracker(const char *acountID,int dispatchPeriod){
	
	NSString *acount = [[NSString alloc] initWithUTF8String:acountID];
	[[GANTracker sharedTracker] startTrackerWithAccountID:acount
                                           dispatchPeriod:dispatchPeriod
                                               	 delegate:nil];
}

void trackPageView(const char *pageName){
	NSString *page = [[NSString alloc] initWithUTF8String:pageName];
	NSError *error;
	if (![[GANTracker sharedTracker] trackPageview:page
                                       withError:&error]) {
    NSLog (@"trackPage ERROR");
  }
}

void trackEvent(const char *category,const char *action,const char *label,int value){
	NSString *cate = [[NSString alloc] initWithUTF8String:category];
	NSString *act = [[NSString alloc] initWithUTF8String:action];
	NSString *lab = [[NSString alloc] initWithUTF8String:label];
	NSError *error;
	if (![[GANTracker sharedTracker] trackEvent:cate
	                                       action:act
	                                        label:lab
	                                        value:value
	                                    withError:&error]) {
			NSLog (@"trackEvent ERROR");
	  }
}

void dispatchTracker(){
	[[GANTracker sharedTracker] dispatch];
}

void stopTracker(){
	[[GANTracker sharedTracker] stopTracker];
}
//GA end


}
