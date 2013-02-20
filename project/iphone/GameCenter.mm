/**
 * Copyright (c) 2011 Milkman Games, LLC <http://www.milkmangames.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <GameKit/GameKit.h>
#include <ctype.h>
#include "Events.h"

namespace nme {
  void PauseAnimation();
  void ResumeAnimation();
}

/** ViewDelegate Objective-C Wrappers
 *
 * As far as I can tell it is not possible to let a vanilla c function
 * take a delegate callback, so we need to create these obj-c objects
 * to wrap the callbacks in.
 *
 */
typedef void (*FunctionType)();
typedef void (*MatchFunctionType)(GKMatch*);
typedef void (*MatchPlayerFunctionType)(GKMatch*, NSString*);
typedef void (*DataFunctionType)(NSString*, NSString*);

@interface GKViewDelegate : NSObject <GKAchievementViewControllerDelegate,GKLeaderboardViewControllerDelegate,GKMatchmakerViewControllerDelegate,GKMatchDelegate>{
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;
- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)viewController;
- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error;
- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;

@property (nonatomic) FunctionType onAchievementFinished;
@property (nonatomic) FunctionType onLeaderboardFinished;
@property (nonatomic) MatchFunctionType onPlayerConnectedToMatch;
@property (nonatomic) MatchPlayerFunctionType onPlayerDisconnectedFromMatch;
@property (nonatomic) MatchFunctionType onMatchmakingFinished;
@property (nonatomic) DataFunctionType onDataReceived;

@end
	
@implementation GKViewDelegate

@synthesize onAchievementFinished;
@synthesize onLeaderboardFinished;
@synthesize onMatchmakingFinished;
@synthesize onPlayerConnectedToMatch;
@synthesize onPlayerDisconnectedFromMatch;
@synthesize onDataReceived;

- (id)init {
    self = [super init];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController{
    [viewController dismissModalViewControllerAnimated:YES];
	[viewController.view.superview removeFromSuperview];
	[viewController release];
	onAchievementFinished();
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
    [viewController dismissModalViewControllerAnimated:YES];
	[viewController.view.superview removeFromSuperview];
	[viewController release];
	onLeaderboardFinished();
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)viewController {
  printf("matchmakerViewController wasCancelled!\n");
  [viewController dismissViewControllerAnimated:YES completion:nil];
	[viewController release];
  nme::ResumeAnimation();
  onMatchmakingFinished(nil);
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
  printf("matchmakerViewController didFailWithError: %s\n", [[error localizedDescription] UTF8String]);
  [viewController dismissViewControllerAnimated:YES completion:nil];
	[viewController release];
  nme::ResumeAnimation();
  onMatchmakingFinished(nil);
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
  printf("matchmakerViewController didFindMatch\n");
  [viewController dismissViewControllerAnimated:YES completion:nil];
  match.delegate = self;
  nme::ResumeAnimation();
  onMatchmakingFinished(match);
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
  switch ( state ) {
  case GKPlayerStateConnected:
    printf("GKPlayerStateConnected\n");
    onPlayerConnectedToMatch(match);
  break;

  case GKPlayerStateDisconnected:
    printf("GKPlayerStateDisconnected\n");
    onPlayerDisconnectedFromMatch(match, playerID);
  break;
  }
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
  NSString *string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
  onDataReceived(playerID, string);
}

@end

namespace nmeExtensions{
	
	bool hxInitGameKit();
	bool hxIsGameCenterAvailable();
	bool hxIsUserAuthenticated();
	void hxAuthenticateLocalUser();
	void registerForAuthenticationNotification();
	void hxShowAchievements();
	void hxResetAchievements();
	void hxReportScoreForCategory(int score, const char *category);
	void hxReportAchievement(const char *achievementId, float percent);
	void hxShowLeaderBoardForCategory(const char *category);
  void hxShowMatchmakingUI();
  void hxBroadcastMatchData(const char* data);
  bool hxIsMatchStarted();
  bool hxInMatch();
  void hxGetPlayerID(char* output, int maxLen);
  void hxDisconnectMatch();
  int hxGetNumMatchPlayers();
  bool hxGetMatchPlayerID(int index, char* output, int maxLen);


	static void authenticationChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
	void achievementViewDismissed();
	void leaderboardViewDismissed();
  void matchmakingFinished(GKMatch* match);
  void playerConnectToMatch(GKMatch* match);
  void playerDisconnectFromMatch(GKMatch* match, NSString* player);
  void matchDataReceived(NSString* player, NSString* data);
	void dispatchHaxeEvent(EventType eventId);
	extern "C" void nme_extensions_send_event(Event &inEvent);
	
	//
	// Variables
	//
	
	/** Initialization State */
	static int isInitialized=0;
	
	/** View Delegate */
	GKViewDelegate *ViewDelegate;
	
  GKMatch* currentMatch;
  bool currentMatchStarted = false;
	
	//
	// Public Methods
	//
	
	/** Initialize Haxe GK.  Return true if success, false otherwise. */
	bool hxInitGameKit(){
		// don't create twice.
		if(isInitialized==1){
			return false;
		}
		
		if (hxIsGameCenterAvailable()){
			// create the GameCenter object, and get user.
			ViewDelegate=[[GKViewDelegate alloc] init];
			ViewDelegate.onAchievementFinished=&achievementViewDismissed;
			ViewDelegate.onLeaderboardFinished=&leaderboardViewDismissed;
      ViewDelegate.onMatchmakingFinished=&matchmakingFinished;
      ViewDelegate.onPlayerConnectedToMatch=&playerConnectToMatch;
      ViewDelegate.onPlayerDisconnectedFromMatch=&playerDisconnectFromMatch;
      ViewDelegate.onDataReceived=&matchDataReceived;

      [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {
        // Insert game-specific code here to clean up any game in progress.
        if (acceptedInvite)
        {
          GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithInvite:acceptedInvite];
          mmvc.matchmakerDelegate = ViewDelegate;

          NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
          UIViewController* glView2;
          UIWindow* window = [UIApplication sharedApplication].keyWindow;
          if([[[UIDevice currentDevice] localizedModel] isEqualToString:@"iPad"]){
            glView2 = [window rootViewController];
          } else {
            glView2 = [[UIViewController alloc] init];
            [window addSubview: glView2.view];
          }
          [glView2 presentModalViewController: mmvc animated:YES];
          [pool drain];
        }
        else if (playersToInvite)
        {
          hxShowMatchmakingUI();
        }
      };
			isInitialized=1;
			return true;
		}
		
		return false;
	}
	
	/** Check if Game Center is available on this device. */
	bool hxIsGameCenterAvailable(){
		// Check for presence of GKLocalPlayer API.   
		Class gcClass = (NSClassFromString(@"GKLocalPlayer"));   
		
		// The device must be running running iOS 4.1 or later.   
		NSString *reqSysVer = @"4.1";   
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];   
		BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);   
		
		return (gcClass && osVersionSupported);
	}

	/** Attempt Authentication of the Player */
	void hxAuthenticateLocalUser() {
		printf("CPP HxgK: Auth user\n");
		if(!hxIsGameCenterAvailable()){
			return;
		}
		
		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {      
			if (error == nil){
				registerForAuthenticationNotification();
				dispatchHaxeEvent(AUTH_SUCCEEDED);
			}else{
				NSLog(@"  %@", [error userInfo]);
				dispatchHaxeEvent(AUTH_FAILED);
			}
		}];
	}
	
	/** Return true if the local player is logged in */
	bool hxIsUserAuthenticated(){
		if ([GKLocalPlayer localPlayer].isAuthenticated){      
			return true;
		}
		return false;
	}
	
  void hxGetPlayerID(char* output, int maxLen) {
    [[GKLocalPlayer localPlayer].playerID getCString:output maxLength:maxLen encoding:NSUTF8StringEncoding];
  }
	
	/** Report a score to the server for a given category. */
	void hxReportScoreForCategory(int score, const char *category){
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSString *strCategory = [[NSString alloc] initWithUTF8String:category];
		
		GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:strCategory] autorelease];
		if(scoreReporter){
			scoreReporter.value = score;
			
			[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {   
				if (error != nil){
					printf("CPP Hxgk: Error occurred reporting score-\n");
					NSLog(@"  %@", [error userInfo]);
					dispatchHaxeEvent(SCORE_REPORT_FAILED);
				}else{
					printf("CPP Hxgk: Score was successfully sent\n");
					dispatchHaxeEvent(SCORE_REPORT_SUCCEEDED);
				}
			}];   
		}
		[strCategory release];
		[pool drain];
	}
	
  /** Show the Default iOS matchmaking interface */
  void hxShowMatchmakingUI() {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    GKMatchRequest* request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 2;

    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.matchmakerDelegate = ViewDelegate;

    nme::PauseAnimation();
    [[window rootViewController] presentModalViewController: mmvc animated:NO];
    [pool drain];
  }
	
	/** Show the Default iOS UI Leaderboard for a given category. */
	void hxShowLeaderBoardForCategory(const char *category){
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSString *strCategory = [[NSString alloc] initWithUTF8String:category];
		
		UIWindow* window = [UIApplication sharedApplication].keyWindow;
		GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];  
		if (leaderboardController != nil) {
			leaderboardController.category=strCategory;
			leaderboardController.leaderboardDelegate = ViewDelegate;
			
			UIViewController *glView2;
			if([[[UIDevice currentDevice] localizedModel] isEqualToString:@"iPad"]){
				glView2 = [[[UIApplication sharedApplication] keyWindow] rootViewController];
			}else{
				glView2 = [[UIViewController alloc] init];
				[window addSubview: glView2.view];
			}
			
			[glView2 presentModalViewController: leaderboardController animated: YES];
		}
		
		[strCategory release];
		[pool drain];
	}
	
	/** Report achievement progress to the server */
	void hxReportAchievement(const char *achievementId, float percent){
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSString *strAchievement = [[NSString alloc] initWithUTF8String:achievementId];
		
		GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: strAchievement] autorelease];   
		if (achievement){      
			achievement.percentComplete = percent;    
			[achievement reportAchievementWithCompletionHandler:^(NSError *error){
				if (error != nil){
					printf("CPP Hxgk: Error occurred reporting achievement-\n");
					NSLog(@"  %@", [error userInfo]);
					dispatchHaxeEvent(ACHIEVEMENT_REPORT_FAILED);
				}else{
					printf("CPP Hxgk: Achievement report successfully sent\n");
					dispatchHaxeEvent(ACHIEVEMENT_REPORT_SUCCEEDED);
				}

			}];
		}else {
			//TODO: making this callback before function end means it is possible to get in a bad state if you're doing nested calls
			dispatchHaxeEvent(ACHIEVEMENT_REPORT_FAILED);
		}

		
		[strAchievement release];
		[pool drain];
	}
	
	/** Get the available achievements */
	void hxGetAchievements(){
		// TODO: will need to alloc and populate a list in a haxe format and return via another callback
	}
	
  bool hxInMatch() {
    return ( currentMatch != nil );
  }

  int hxGetNumMatchPlayers() {
    if ( currentMatch == nil ) {
      return 0;
    }

    return [currentMatch.playerIDs count];
  }

  bool hxGetMatchPlayerID(int index, char* output, int maxLen) {
    if ( currentMatch != nil && index < [currentMatch.playerIDs count] ) {
      [[currentMatch.playerIDs objectAtIndex:index] getCString:output maxLength:maxLen encoding:NSUTF8StringEncoding];
      return true;
    }
    return false;
  }

  bool hxIsMatchStarted() {
    return currentMatchStarted;
  }

  void hxBroadcastMatchData(const char* data) {
    if ( currentMatchStarted ) {
      printf("Sending match data: %s\n", data);
      NSError* error;
      NSData* packet = [NSData dataWithBytes:data length:strlen(data)];
      [currentMatch sendDataToAllPlayers:packet withDataMode:GKMatchSendDataReliable error:&error];
      if ( error != nil ) {
        // handle the error
      }
    }
  }

  void hxDisconnectMatch() {
    if ( currentMatch != nil ) {
      [currentMatch disconnect];
      [currentMatch release];
      currentMatch = nil;
    }
  }

	/** Show Achievements with Default UI */
	void hxShowAchievements(){
		UIWindow* window = [UIApplication sharedApplication].keyWindow;
		GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];   
		if (achievements != nil){
			achievements.achievementDelegate = ViewDelegate;
			//UIViewController *glView2 = [[UIViewController alloc] init];
			//[window addSubview: glView2.view];
			UIViewController *glView2 = [[[UIApplication sharedApplication] keyWindow] rootViewController];
			[glView2 presentModalViewController: achievements animated: YES];
			// TODO: can we get the delegate to invoke a method properly timed for this event?
			dispatchHaxeEvent(ACHIEVEMENTS_VIEW_OPENED);
		}
	}
	
	/** Reset achievements */
	void hxResetAchievements(){
		[GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error){
			 if (error != nil){
				 NSLog(@"  %@", [error userInfo]);
				 dispatchHaxeEvent(ACHIEVEMENT_RESET_FAILED);
			 }else{
				 dispatchHaxeEvent(ACHIEVEMENT_RESET_SUCCEEDED);
			 }
			 
		 }];
	}
	
	
	//
	// Implementation
	//
	
	/** Listen for Authentication Callback */
	void registerForAuthenticationNotification(){
		// TODO: need to REMOVE OBSERVER on dispose
		CFNotificationCenterAddObserver
		(
			CFNotificationCenterGetLocalCenter(),
			NULL,
			&authenticationChanged,
			(CFStringRef)GKPlayerAuthenticationDidChangeNotificationName,
			NULL,
			CFNotificationSuspensionBehaviorDeliverImmediately
		 );
	}
	
	/** Notify haXe of an Event */
	void dispatchHaxeEvent(EventType eventId){
		Event evt(eventId);
		nme_extensions_send_event(evt);
	}
	
	//
	// Callbacks
	//
	
	/** Callback When Achievement View is Closed */
	void achievementViewDismissed(){
		dispatchHaxeEvent(ACHIEVEMENTS_VIEW_CLOSED);
	}
	
	/** Callback When Leaderboard View is Closed */
	void leaderboardViewDismissed(){
		dispatchHaxeEvent(LEADERBOARD_VIEW_CLOSED);
	}
	
  void matchmakingFinished(GKMatch* match){
    printf("matchmakingFinished\n");
    if ( currentMatch != nil ) {
      [currentMatch release];
    }
    currentMatch = match;      
    currentMatchStarted = false;
    if ( currentMatch != nil ) {
      [currentMatch retain];
    }
    dispatchHaxeEvent(MATCHMAKING_VIEW_CLOSED);

    if ( !currentMatchStarted && match.expectedPlayerCount == 0 ) {
      printf("Sending match started event\n");
      currentMatchStarted = true;
      dispatchHaxeEvent(MATCH_STARTED);
    }
  }

  void playerConnectToMatch(GKMatch* match) {
    if ( match == currentMatch ) {
      if ( !currentMatchStarted && match.expectedPlayerCount == 0 ) {
        currentMatchStarted = true;
        dispatchHaxeEvent(MATCH_STARTED);
      }
    }
  }

  void playerDisconnectFromMatch(GKMatch* match, NSString* player){
    if ( match == currentMatch ) {
      Event evt(MATCH_PLAYER_DISCONNECTED);
      evt.data = [player cStringUsingEncoding:NSUTF8StringEncoding];
      nme_extensions_send_event(evt); 
    }
  }

  void matchDataReceived(NSString* player, NSString* data) {
		const char* str = [data cStringUsingEncoding:NSUTF8StringEncoding];
    Event evt(MATCH_DATA_RECEIVED);
    evt.data = str;
    nme_extensions_send_event(evt); 
  }

	/** Callback When Authentication Status Has Changed */
	void authenticationChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
		if(!hxIsGameCenterAvailable()){
			return;
		}
		
		if ([GKLocalPlayer localPlayer].isAuthenticated){      
			printf("CPP Hxgk: You are logged in to game center:onAuthChanged \n");
		}else{
			printf("CPP Hxgk: You are NOT logged in to game center!:onAuthChanged \n");
		}
	}
	
}


