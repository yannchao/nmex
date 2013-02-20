//
//  iRate.m
//  iRate
//
//  Created by Nick Lockwood on 26/01/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#include "iRate.h"


NSString * const iRateRatedVersionKey = @"iRateRatedVersionChecked";
NSString * const iRateDeclinedVersionKey = @"iRateDeclinedVersion";
NSString * const iRateLastRemindedKey = @"iRateLastReminded";
NSString * const iRateLastVersionUsedKey = @"iRateLastVersionUsed";

NSString * const iRateiOSAppStoreURLFormat = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%i";
static iRate *sharedInstance = nil;


@interface iRate()

@property (nonatomic, retain) NSString *applicationVersion;

@end


@implementation iRate

@synthesize appStoreID;
@synthesize applicationName;
@synthesize applicationVersion;
@synthesize messageTitle;
@synthesize message;
@synthesize cancelButtonLabel;
@synthesize remindButtonLabel;
@synthesize rateButtonLabel;
@synthesize ratingsURL;
@synthesize delegate;

#pragma mark -
#pragma mark Lifecycle methods

+ (iRate *)sharedInstance
{
	if (sharedInstance == nil)
	{
		sharedInstance = [[iRate alloc] init];
	}
	return sharedInstance;
}

- (iRate *)init
{
	if ((self = [super init]))
	{
		//application name and version
		self.applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
		self.applicationVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
		
		//message text, you may wish to customise these, e.g. for localisation
		self.messageTitle = nil; //set lazily so that appname can be included
		self.message = nil; //set lazily so that appname can be included
		self.cancelButtonLabel = @"No, Thanks";
		self.remindButtonLabel = @"Remind Me Later";
		self.rateButtonLabel = [NSString stringWithFormat:@"Rate %@", applicationName];
	}
	return self;
}

- (NSString *)messageTitle
{
	if (messageTitle)
	{
		return messageTitle;
	}
	return [NSString stringWithFormat:@"Thanks for playing. Please rate %@ now.", applicationName];
}

- (NSString *)message
{
	if (message)
	{
		return message;
	}
	return [NSString stringWithFormat:@"", applicationName];
}

- (NSURL *)ratingsURL
{
	if (ratingsURL)
	{
		return ratingsURL;
	}
	
	return [NSURL URLWithString:[NSString stringWithFormat:iRateiOSAppStoreURLFormat, appStoreID]];
}

- (NSDate *)lastReminded
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:iRateLastRemindedKey];
}

- (void)setLastReminded:(NSDate *)date
{
	[[NSUserDefaults standardUserDefaults] setObject:date forKey:iRateLastRemindedKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)declinedThisVersion
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:iRateDeclinedVersionKey] isEqualToString:applicationVersion];
}

- (void)setDeclinedThisVersion:(BOOL)declined
{
	[[NSUserDefaults standardUserDefaults] setObject:(declined? applicationVersion: nil) forKey:iRateDeclinedVersionKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)ratedThisVersion
{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:iRateRatedVersionKey] isEqualToString:applicationVersion];
}

- (void)setRatedThisVersion:(BOOL)rated
{
	[[NSUserDefaults standardUserDefaults] setObject:(rated? applicationVersion: nil) forKey:iRateRatedVersionKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[applicationName release];
	[applicationVersion release];
	[messageTitle release];
	[message release];
	[cancelButtonLabel release];
	[remindButtonLabel release];
	[rateButtonLabel release];
	[ratingsURL release];
	[super dealloc];
}

#pragma mark -
#pragma mark Methods

- (BOOL)shouldPromptForRating{	
	//check if we've rated this version
	if (self.ratedThisVersion){
		return NO;
	}else if (self.declinedThisVersion){
		return NO;
	}
	
	//lets prompt!
	return YES;
}

- (void)promptForRating
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.messageTitle
													message:self.message
												   delegate:self
										  cancelButtonTitle:remindButtonLabel
										  otherButtonTitles:rateButtonLabel, nil];
	if (remindButtonLabel) {
		[alert addButtonWithTitle:cancelButtonLabel];
	}
	[alert show];
	[alert release];
}

- (void)promptIfNetworkAvailable
{
	//test for app store connectivity the simplest, most reliable way - by accessing apple.com
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://apple.com"] 
											 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
										 timeoutInterval:10.0];
	//send request
	[[NSURLConnection connectionWithRequest:request delegate:self] start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	//good enough; don't download any more data
	[connection cancel];
	
	//confirm with delegate
	if ([(NSObject *)delegate respondsToSelector:@selector(iRateShouldShouldPromptForRating)])
	{
		if (![delegate iRateShouldShouldPromptForRating])
		{
			return;
		}
	}
	
	//prompt user
	[self promptForRating];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	//could not connect
	if ([(NSObject *)delegate respondsToSelector:@selector(iRateCouldNotConnectToAppStore:)])
	{
		[delegate iRateCouldNotConnectToAppStore:error];
	}
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)openRatingsPageInAppStore
{
	[[UIApplication sharedApplication] openURL:self.ratingsURL];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == alertView.cancelButtonIndex)
	{
		//remind later
		self.lastReminded = [NSDate date];
		
	}
	else if (buttonIndex == 2)
	{
		//ignore this version
		self.declinedThisVersion = YES;
	}
	else
	{
		//mark as rated
		self.ratedThisVersion = YES;
		
		//go to ratings page
		[self openRatingsPageInAppStore];
	}
}
@end