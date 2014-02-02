//
//  PreferencesControllerWindowController.m
//  GingerNotify
//
//  Created by Martin Mahner on 28.11.12.
//  Copyright (c) 2012 Lincoln Loop. All rights reserved.
//

#import "PreferencesController.h"
#import "AppDelegate.h"
#import "DDLog.h"
#import "ApiSync.h"
//#import "Sparkle/SUUpdater.h"

@implementation PreferencesController

@synthesize emailTextField;
@synthesize tokenTextField;
@synthesize saveCredentialsSpinner;
@synthesize updateSlider;
@synthesize updateSliderLabel;
@synthesize displayTeamNameCheckbox;
@synthesize displayUnreadCountCheckbox;
@synthesize versionLabel;
@synthesize changeDesktopNotificationSettingsButton;

/*
- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.

    }
    return self;
}
*/

- (void)windowDidLoad
{
    [super windowDidLoad];

    NSUserDefaults *userPrefs = [NSUserDefaults standardUserDefaults];

    NSString *email = [userPrefs stringForKey:@"gingerEmail"];
    NSString *token = [userPrefs stringForKey:@"gingerToken"];

    [emailTextField setStringValue:email ? email : @""];
    [tokenTextField setStringValue:token ? token : @""];

    [displayTeamNameCheckbox setIntegerValue:[userPrefs integerForKey:@"displayTeamName"]];
    [displayUnreadCountCheckbox setIntegerValue:[userPrefs integerForKey:@"displayUnreadCount"]];

    // Set the update interval. We might have never saved it, so default to 3
    long updateInterval = [userPrefs integerForKey:@"updateInterval"];
    updateInterval = updateInterval == 0 ? 3 : updateInterval;
    [updateSlider setIntegerValue:updateInterval];
    [updateSliderLabel setStringValue:[NSString stringWithFormat:@"%ld min", updateInterval]];

    // Hide the Desktop notification button on older MAC OC
    if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_7_2) {
        [changeDesktopNotificationSettingsButton setEnabled:NO];
    }

    // Set the version Label
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString *versionString = [[NSString alloc] initWithFormat:@"GingerNotify %@ (Build %@)",
                                [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                [mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"]];
    [versionLabel setStringValue:versionString];
}

- (IBAction)tokenHelpButtonClick:(id)sender {
    [AppDelegate openURLFromString:GINGER_GET_TOKEN_URL];
}

- (IBAction)saveCredentialsClick:(NSButton *)sender {
    // Testing the connection takes some time, show a spinner
    [saveCredentialsSpinner setHidden:NO];
    [saveCredentialsSpinner startAnimation:nil];

    NSString *gingerEmail = [[emailTextField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *gingerToken = [[tokenTextField stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];


    // Check that the credentials are OK, so we never save invalid credentials
    bool valid = [ApiSync testCredentialsWithUsername:gingerEmail token:gingerToken];

    // Done, hide the spinner
    [saveCredentialsSpinner setHidden:YES];
    [saveCredentialsSpinner stopAnimation:nil];

    if(!valid) {
        NSAlert *invalidAlert = [NSAlert alertWithMessageText:@"Could not connect to the Ginger API"
                                                defaultButton:@"OK"
                                              alternateButton:nil
                                                  otherButton:nil
                                    informativeTextWithFormat:@"%@", @"Please check your username and token and try again."];
        [invalidAlert setAlertStyle:NSCriticalAlertStyle];
        [invalidAlert runModal];

        // Remove credentials from settings, so we never save invalid credentials
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"gingerEmail"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"gingerToken"];

        return;
    }

    // Connection was OK, Save the credentials in teh user space
    [[NSUserDefaults standardUserDefaults] setObject:gingerEmail forKey:@"gingerEmail"];
    [[NSUserDefaults standardUserDefaults] setObject:gingerToken forKey:@"gingerToken"];

    // Load the discussions for the first time. Yeah.
    [AppDelegate fetchAndUpdateMenuInBackground];

    // Show a success modal
    NSAlert *successAlert = [NSAlert alertWithMessageText:@"Your credentials are valid"
                                            defaultButton:@"OK"
                                          alternateButton:nil
                                              otherButton:nil
                                informativeTextWithFormat:@"%@", @"You can now start Gingering."];
    [successAlert setAlertStyle:NSInformationalAlertStyle];
    [successAlert runModal];

}

- (IBAction)updateSliderChange:(NSSlider *)sender {
    // Update the label
    [updateSliderLabel setStringValue:[NSString stringWithFormat:@"%ld min", [sender integerValue]]];
    [[NSUserDefaults standardUserDefaults] setInteger:[sender integerValue] forKey:@"updateInterval"];
    [AppDelegate resetTimerAndFetchInBackground];
}

- (IBAction)displayUnreadCountCheckboxClick:(NSButton *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:[sender integerValue] forKey:@"displayUnreadCount"];
    [AppDelegate updateMenuWithDiscussions];
}

- (IBAction)displayTeamNameCheckboxClick:(NSButton *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:[sender integerValue] forKey:@"displayTeamName"];
    [AppDelegate updateMenuWithDiscussions];

}

- (IBAction)changeDesktopNotificationSettingsClick:(NSButton *)sender {
    [[NSWorkspace sharedWorkspace] openFile:@"/System/Library/PreferencePanes/Notifications.prefPane"];
}

@end
