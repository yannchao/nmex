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
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>
#import <MediaPlayer/MediaPlayer.h>
#include <ctype.h>
#include "Events.h"

namespace nmeExtensions {
	extern "C" void nme_extensions_send_event(Event &inEvent);
}

@interface HXAudioSession : NSObject
@end

@implementation HXAudioSession
  -(id) init {
    self = [super init];

    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
 
    [notificationCenter addObserver: self
                           selector: @selector (handle_PlaybackStateChanged:)
                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object: [MPMusicPlayerController iPodMusicPlayer]];
 
    [[MPMusicPlayerController iPodMusicPlayer] beginGeneratingPlaybackNotifications];
    return self;
  }

  - (void) handle_PlaybackStateChanged: (id) notification {
		Event evt(AUDIO_PLAYBACK_STATE_CHANGED);
		nmeExtensions::nme_extensions_send_event(evt);
  }

  -(void) dealloc {
    [super dealloc];
  }
@end


namespace nmeExtensions {

  HXAudioSession* session;
  void hxInitAudio() {
    session = [[HXAudioSession alloc] init];
  }

  int hxAudioGetMusicPlayerState() {
    return [MPMusicPlayerController iPodMusicPlayer].playbackState;
  }

  void hxAudioSetAudioSessionCategory(int category) {
    const NSString* avCat = AVAudioSessionCategoryAmbient;
    switch ( category ) {
    case 0: avCat = AVAudioSessionCategoryAmbient; break;
    case 1: avCat = AVAudioSessionCategorySoloAmbient; break;
    case 2: avCat = AVAudioSessionCategoryPlayback; break;
    case 3: avCat = AVAudioSessionCategoryRecord; break;
    case 4: avCat = AVAudioSessionCategoryPlayAndRecord; break;
    case 5: avCat = AVAudioSessionCategoryAudioProcessing; break;
    //case 6: avCat = AVAudioSessionCategoryMultiRoute; break; Commented out for iOS5 support
    }
    [[AVAudioSession sharedInstance] setCategory:avCat error:nil];
  }
}
