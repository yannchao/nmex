#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol iRateDelegate

@optional
- (void)iRateCouldNotConnectToAppStore:(NSError *)error;
- (BOOL)iRateShouldShouldPromptForRating;

@end

@interface iRate : NSObject<UIAlertViewDelegate>{
	NSUInteger appStoreID;
	NSString *applicationVersion;
	NSString *applicationName;
	NSString *messageTitle;
	NSString *message;
	NSString *cancelButtonLabel;
	NSString *remindButtonLabel;
	NSString *rateButtonLabel;
	NSURL *ratingsURL;
	BOOL declinedThisVersion;
	BOOL ratedThisVersion;
	id<iRateDelegate> delegate;
}


+ (iRate *)sharedInstance;

//app-store id - always set this
@property (nonatomic, assign) NSUInteger appStoreID;

//application name - this is set automatically
@property (nonatomic, retain) NSString *applicationName;

//message text, you may wish to customise these, e.g. for localisation
@property (nonatomic, retain) NSString *messageTitle;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *cancelButtonLabel;
@property (nonatomic, retain) NSString *remindButtonLabel;
@property (nonatomic, retain) NSString *rateButtonLabel;

//advanced properties for implementing custom behaviour
@property (nonatomic, retain) NSURL *ratingsURL;
@property (nonatomic, assign) BOOL declinedThisVersion;
@property (nonatomic, assign) BOOL ratedThisVersion;
@property (nonatomic, assign) id<iRateDelegate> delegate;

//manually control behaviour
- (BOOL)shouldPromptForRating;
- (void)promptForRating;
- (void)promptIfNetworkAvailable;
- (void)openRatingsPageInAppStore;
@end
