//
//  ApiSync.h
//  GingerNotify
//
//  Created by Martin Mahner on 28.11.12.
//  Copyright (c) 2012 Lincoln Loop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiSync : NSObject

+ (NSMutableArray *)getUnreadDiscussionArray;
+ (bool) testCredentialsWithUsername:(NSString *)username token:(NSString *)token;

@end
