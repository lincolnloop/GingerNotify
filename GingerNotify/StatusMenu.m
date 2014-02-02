//
//  StatusMenu.m
//  GingerNotify
//
//  Created by Martin Mahner on 28.11.12.
//  Copyright (c) 2012 Lincoln Loop. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusMenu.h"
#import "ApiSync.h"


@implementation StatusMenu

- (void) showDiscussionNotification:(NSDictionary *)discussion{
    
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:[discussion objectForKey:@"title"]];
    [notification setInformativeText:[discussion objectForKey:@"team"]];
    [notification setSoundName:@"Purr"];
    [notification setHasActionButton:YES];
    [notification setActionButtonTitle:@"Open"];
    [notification setUserInfo:discussion];
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
     
    // Couldn't figure out how to pass a sound to the notification, so play the
    // sound manually, the notification will have no sound.
    /*
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"NotificationSound" ofType:@"mp3"];
    NSSound *sound = [[NSSound alloc] initWithContentsOfFile:resourcePath byReference:YES];
    [sound setVolume:0.8];
    [sound play];
     */
 }

/*
 * Create an empty Menu with one item: "Loading..."
 */
- (void)simpleFastMenu {
    /*
    NSDictionary *test = [[NSMutableDictionary alloc] init];
    [test setValue:@"A test item" forKey:@"title"];
    [test setValue:@"The A Team" forKey:@"team"];
    [test setValue:@"http://www.mahner.org/" forKey:@"permalink"];
    [self showDiscussionNotification:test];
    */
    
    NSMenuItem *openAll = [[NSMenuItem alloc] initWithTitle:@"Loading discussions ..."
                                                     action:nil
                                              keyEquivalent:@""];
    
    [openAll setEnabled:NO];
    [self insertItem:openAll atIndex:0];
    [self insertItem:[NSMenuItem separatorItem] atIndex:1];
    [self addPermanentItemsAndStartWithIndex:2];
}


- (void) updateMenuWithDiscussons:(NSMutableArray *)discussions {       
    // ----- Clean start and add items for each discussion in the list
    [self removeAllItems];
    
    NSLog(@"updateMenuWithDiscussons %@", discussions);
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSDate *latestDiscussionTimestamp = [prefs objectForKey:@"latestDiscussionTimestamp"];
    NSDate *newLatestDiscussionTimestamp = latestDiscussionTimestamp;
    
    int keyNum = 0;
    int keyboardIndex = 0;
    
    for(NSDictionary *discussion in discussions) {
        NSString *key = keyboardIndex < 9 ? [NSString stringWithFormat:@"%d", keyboardIndex+=1] : @"";
        NSString *title;
        
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"displayTeamName"] == 1) {
            title = [[NSString alloc] initWithFormat:@"%@: %@ (%@)",
                            [discussion objectForKey:@"team_name"],
                            [discussion objectForKey:@"title"],
                            [discussion objectForKey:@"unread_count"]];
            
        } else {            
            title = [discussion objectForKey:@"title"];
        }
        
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title
                                                      action:@selector(openURLfromMenuItem:)
                                               keyEquivalent:key];
        
        [item setRepresentedObject:discussion];
        [item setTarget:self];
        [item setEnabled:YES];
        [self insertItem:item atIndex:keyNum++];
        
        // ----- Display a Desktop notification
        NSDate *timestamp = [discussion objectForKey:@"timestamp"];        
                
        if(!latestDiscussionTimestamp ||
           !newLatestDiscussionTimestamp ||
           [timestamp isGreaterThan:newLatestDiscussionTimestamp] ||
           [timestamp isGreaterThan:latestDiscussionTimestamp]
        ) {
            NSLog(@"Show notification: discussion%@ is older than %@", timestamp, latestDiscussionTimestamp);
            //[self showDiscussionNotification:discussion];
            [self performSelectorInBackground:@selector(showDiscussionNotification:) withObject:discussion];
            
            // Save the newest of these timestamps here so we can later have it as
            // initial prefs value
            if(!newLatestDiscussionTimestamp || [timestamp isGreaterThan:newLatestDiscussionTimestamp]) {
                NSLog(@"New latest: discussion %@ is larger than latest %@", timestamp, latestDiscussionTimestamp);
                newLatestDiscussionTimestamp = timestamp;
            }
        } else {
            NSLog(@"Skip notification: discussion %@ is lower than prefs %@ or latest %@",
                  timestamp, latestDiscussionTimestamp, newLatestDiscussionTimestamp);
        }
    }
    
    if(newLatestDiscussionTimestamp) {        
        [prefs setObject:newLatestDiscussionTimestamp forKey:@"latestDiscussionTimestamp"];
        NSLog(@"Set new latest item %@", newLatestDiscussionTimestamp);
    }
    
   
    if (keyNum > 0) {
        // ----- Separator Items, only display if we have unread items
        [self insertItem:[NSMenuItem separatorItem] atIndex:keyNum++];
        
        
        // ----- Separator Items, only display if we have unread items
        
        // Open all items
        NSMenuItem *item  = [[NSMenuItem alloc] initWithTitle:@"Open all ..."
                                                       action:@selector(openAllDiscussionURLs:)
                                                keyEquivalent:@"a"];
        [item setRepresentedObject:discussions];
        [item setTarget:self];
        [item setHidden:NO];
        [self insertItem:item atIndex:keyNum++];
        
        /*
         =====================================================================
         TODO: Need API call for this
         =====================================================================
         
        // Alternate: Mark all as read
        item  = [[NSMenuItem alloc] initWithTitle:@"Mark all as read"
                                           action:nil
                                    keyEquivalent:@"a"];
        [item setTarget:self];
        [item setKeyEquivalentModifierMask:(NSAlternateKeyMask | NSCommandKeyMask)];
        [item setAlternate:YES];
        [item setHidden:NO];
        [self insertItem:item atIndex:keyNum++];
         */
        
    }
    
    // ----- Prefs and Quit button
    [self addPermanentItemsAndStartWithIndex:keyNum];
    
}



/*
 * The Preference and Quit item in the menu.
 */
- (void) addPermanentItemsAndStartWithIndex:(int)keyNum {   
    // ----- Open Ginger
    NSMenuItem *openGinger = [[NSMenuItem alloc]
                              initWithTitle:@"Open Ginger ..."
                              action:@selector(openURLFromRepresentedObject:)
                              keyEquivalent:@"g"];
    [openGinger setTarget:self];
    [openGinger setEnabled:YES];
    [openGinger setRepresentedObject:GINGER_BASE_URL];
    [self insertItem:openGinger atIndex:keyNum++];
    
    
    // ----- Seperator
    [self insertItem:[NSMenuItem separatorItem] atIndex:keyNum++];
    
    // ----- Preferences Items
    NSMenuItem *pref = [[NSMenuItem alloc]
                        initWithTitle:@"Preferences ..."
                        action:@selector(openPreferences:)
                        keyEquivalent:@","];
    
    [pref setTarget:self];
    [pref setEnabled:YES];
    [self insertItem:pref atIndex:keyNum++];
    
    // ----- Quit Items
    NSMenuItem *quit = [[NSMenuItem alloc]
                        initWithTitle:@"Quit"
                        action:@selector(terminate:)
                        keyEquivalent:@"q"];
    [quit setEnabled:YES];
    [self insertItem:quit atIndex:keyNum++];
}


- (void) openURLFromRepresentedObject:(id) sender {
    NSString *url = [sender representedObject];
    [AppDelegate openURLFromString:url];
}

- (void) openURLfromMenuItem:(id) sender {
    NSDictionary *discussion = [sender representedObject];
    NSString *url = [NSString stringWithFormat:@"%@%@", GINGER_BASE_URL, [discussion objectForKey:@"permalink"]];
    [AppDelegate openURLFromString:url];   
}


- (void) openAllDiscussionURLs:(id) sender {
    NSDictionary *discussions = [sender representedObject];
    for(NSDictionary *discussion in discussions) {
        NSString *url = [NSString stringWithFormat:@"%@%@", GINGER_BASE_URL, [discussion objectForKey:@"permalink"]];
        [AppDelegate openURLFromString:url];
    }
}


- (void) openPreferences:(id) sender {
    [AppDelegate displayPreferencesWindow:self];
}

@end
