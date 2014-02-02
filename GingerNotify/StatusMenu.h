//
//  StatusMenu.h
//  GingerNotify
//
//  Created by Martin Mahner on 28.11.12.
//  Copyright (c) 2012 Lincoln Loop. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusMenu : NSMenu 

- (void) updateMenuWithDiscussons:(NSMutableArray *)discussions;
- (void) simpleFastMenu;

@end

