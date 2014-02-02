//
//  AppDelegate.h
//  GingerNotify
//
//  Created by Martin Mahner on 28.11.12.
//  Copyright (c) 2012 Lincoln Loop. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDLog.h"
#import "StatusMenu.h"

#define GINGER_BASE_URL @"https://gingerhq.com"
#define GINGER_GET_TOKEN_URL @"https://gingerhq.com/developers/request-access/"
#define GINGER_DISCUSSIONS @"https://gingerhq.com/api/v2/discussion/?unread&notifications"

#define APP_LOG_LEVEL LOG_LEVEL_VERBOSE

@class PreferencesController;
@class ApiSync;

PreferencesController *preferenceController;
ApiSync *apiSync;


@interface AppDelegate : NSObject <NSUserNotificationCenterDelegate, NSApplicationDelegate>

@property (nonatomic, retain) NSTimer * timer;
@property NSMutableArray *discussions;
@property NSStatusItem *statusMenuIcon;
@property StatusMenu *statusMenu;

+ (void) displayPreferencesWindow:(id)sender;
+ (void) openURLFromString:(NSString *)url;
+ (void) updateMenuWithDiscussions;
+ (void) fetchAndUpdateMenuInBackground;
+ (void) resetTimerAndFetchInBackground;

@end

