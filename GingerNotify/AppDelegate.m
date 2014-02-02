//
//  AppDelegate.m
//  GingerNotify
//
//  Created by Martin Mahner on 28.11.12.
//  Copyright (c) 2012 Lincoln Loop. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferencesController.h"
#import "ApiSync.h"
#import "StatusMenu.h"

#import "DDTTYLogger.h"
#import "DDASLLogger.h"

static const int ddLogLevel = APP_LOG_LEVEL;


@implementation AppDelegate

@synthesize timer;
@synthesize statusMenu;
@synthesize discussions;
@synthesize statusMenuIcon;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center setDelegate:self];
 }

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    NSDictionary *discussion = [notification userInfo];
    NSString *url = [NSString stringWithFormat:@"%@%@", GINGER_BASE_URL, [discussion objectForKey:@"permalink"]];
    [AppDelegate openURLFromString:url];
}

- (void) awakeFromNib {
       
    // Create the menu icon and attach the menu to it
    NSBundle *bundle = [NSBundle mainBundle];
    NSImage *statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"menuIcon" ofType:@"png"]];
    NSImage *statusImageAlternate = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"menuIconInverted" ofType:@"png"]];
    
    statusMenuIcon = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusMenuIcon setImage:statusImage];
    [statusMenuIcon setAlternateImage:statusImageAlternate];
    [statusMenuIcon setHighlightMode:YES];
    
    // Create the menu and attach it.
    statusMenu = [[StatusMenu alloc] init];
    [statusMenu simpleFastMenu];
    [statusMenuIcon setMenu:statusMenu];
    
    // In case dont have an email or token saved, display the prefs window right away
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"gingerEmail"] ||
       ![[NSUserDefaults standardUserDefaults] objectForKey:@"gingerToken"]) {
        [AppDelegate displayPreferencesWindow:self];
        return;
    }
    
    
    // Fetch latest discussions and update menu. Also add a timer to do this all the time.
    [self fetchAndUpdateMenuInBackground:nil];
    [self timedFetchAndUpdateMenuInBackground];
}


- (void) updateMenuWithDiscussions {
    // Update menu items
    NSLog(@"updateMenuWithDiscussions %@", discussions);
    [statusMenu updateMenuWithDiscussons:discussions];
    
    // Set a icon title if in prefs
    if ([discussions count] > 0 && [[NSUserDefaults standardUserDefaults] integerForKey:@"displayUnreadCount"] == 1) {
        [statusMenuIcon setTitle:[NSString stringWithFormat:@"%ld", [discussions count]]];
    } else {
        [statusMenuIcon setTitle:@""];
    }
    
}

- (void) fetchAndUpdateMenu {
    // All the initializing happened, now fetch latest messages and rebuild menu
    discussions = [ApiSync getUnreadDiscussionArray];
    [self updateMenuWithDiscussions];
}

- (void) fetchAndUpdateMenuInBackground:(NSTimer *)theTimer {
    [self performSelectorInBackground:@selector(fetchAndUpdateMenu) withObject:nil];
}

- (void) timedFetchAndUpdateMenuInBackground {
    
    // Start the timer, which rebuilds the menu every x minutes
    long minutes = [[NSUserDefaults standardUserDefaults] integerForKey:@"updateInterval"];
    long interval = minutes * 60;
    
    // If for some reason the interval is < 60, set it to 5 minutes
    if(interval < 60) {
        NSLog(@"Interval is too low: %ld, overriding to 5mins", interval);
        interval = 60 * 5;
    }
    
    NSLog(@"Started timed updated, %ld", interval);
    
    timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                             target:self
                                           selector:@selector(fetchAndUpdateMenuInBackground:)
                                           userInfo:nil
                                            repeats:YES];
}


+ (void) fetchAndUpdateMenuInBackground {
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate fetchAndUpdateMenuInBackground:nil];
}

+ (void) updateMenuWithDiscussions {
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate updateMenuWithDiscussions];
}


+ (void) resetTimerAndFetchInBackground {    
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [appDelegate timedFetchAndUpdateMenuInBackground];
}



// ---------------------------------------------------------------------------------------------

# pragma mark Utils

+ (void) displayPreferencesWindow:(id) sender {
    // Prefs window is not yet initialized
    if(!preferenceController) {
        preferenceController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
        [preferenceController showWindow:sender];
    }
    
    // Its initialized but hidden
    if (![[preferenceController window] isVisible]) {
        [[preferenceController window] makeKeyAndOrderFront:self];
    }
    
    // Make the app active so the window gets active so it gets to front
    [NSApp activateIgnoringOtherApps:YES];

    // Move it to front
    [[preferenceController window] setOrderedIndex:0];
}


+ (void) openURLFromString:(NSString *)url {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
}

@end
