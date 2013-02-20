#include <AD.h>
#import <UIKit/UIKit.h>
#import "GADBannerView.h"


namespace nmeExtensions {
	
    static GADBannerView *bannerView_;
	UIViewController *root;
    
	void initAd(const char *ID,int x, int y, int sizeType=0){
		
		root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
		
		NSString *GADID = [[NSString alloc] initWithUTF8String:ID];
		
		bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait
													 origin:CGPointMake(x,y)];
		bannerView_.adUnitID = GADID;
        
		
		bannerView_.rootViewController = root;
		[bannerView_ loadRequest:[GADRequest request]];
	}
    
    void showAd(){
		[root.view addSubview:bannerView_];
    }
    
    void hideAd(){
		[bannerView_ removeFromSuperview];
    }
    
	void refreshAd(){
		[bannerView_ loadRequest:[GADRequest request]];
	}
}
