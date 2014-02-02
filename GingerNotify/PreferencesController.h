//
//  PreferencesControllerWindowController.h
//  GingerNotify
//
//  Created by Martin Mahner on 28.11.12.
//  Copyright (c) 2012 Lincoln Loop. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController

@property (strong) IBOutlet NSWindow *PreferencesWindow;
@property (weak) IBOutlet NSTextField *emailTextField;
@property (weak) IBOutlet NSTextField *tokenTextField;
@property (weak) IBOutlet NSProgressIndicator *saveCredentialsSpinner;
@property (weak) IBOutlet NSSlider *updateSlider;
@property (weak) IBOutlet NSTextField *updateSliderLabel;
@property (weak) IBOutlet NSButton *displayUnreadCountCheckbox;
@property (weak) IBOutlet NSButton *displayTeamNameCheckbox;
@property (weak) IBOutlet NSTextField *versionLabel;
@property (weak) IBOutlet NSButtonCell *changeDesktopNotificationSettingsButton;

- (IBAction)tokenHelpButtonClick:(id)sender;
- (IBAction)saveCredentialsClick:(NSButton *)sender;
- (IBAction)updateSliderChange:(NSSlider *)sender;
- (IBAction)displayUnreadCountCheckboxClick:(NSButton *)sender;
- (IBAction)displayTeamNameCheckboxClick:(NSButton *)sender;
- (IBAction)changeDesktopNotificationSettingsClick:(NSButton *)sender;

@end
