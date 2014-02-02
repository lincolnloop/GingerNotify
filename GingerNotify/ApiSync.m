//
//  ApiSync.m
//  GingerNotify
//
//  Created by Martin Mahner on 28.11.12.
//  Copyright (c) 2012 Lincoln Loop. All rights reserved.
//

#import "AppDelegate.h"
#import "ApiSync.h"
#include "NSDictionary_JSONExtensions.h"

@implementation ApiSync

NSMutableArray *unreadDiscussions;

/*
 * Retrieve the discussion list JSON string
 */
+ (NSString *) getContentFromURL:(NSString *)urlString andToken:(NSString *)token {
    NSError *error                 = nil;
    NSHTTPURLResponse* urlResponse = nil;
    NSString *tokenToken = [NSString stringWithFormat:@"Token %@", token];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:15];
                                    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:tokenToken forHTTPHeaderField:@"Authorization"];
        
    NSData *result = [NSURLConnection sendSynchronousRequest:request
                                           returningResponse:&urlResponse
                                                       error:&error];
    
    NSString *data = [[NSString alloc] initWithData:result
                                           encoding:NSUTF8StringEncoding];
    
    NSLog(@"URL: %@ DATA: %@", urlString, data);
        
    if (error || !data) {
        NSLog(@"Failed to load discussions: %@", error);
    }
    return data;
}



/*
 * Load and filter all unread discussions from the API and store a subset of the data
 * in self.unreadDiscussions
 */
- (void) loadUnreadDiscussions {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *urlString = GINGER_DISCUSSIONS;
    NSString *data               = [ApiSync getContentFromURL:urlString andToken:[prefs stringForKey:@"gingerToken"]];
    NSDictionary *discussionDict = [NSDictionary dictionaryWithJSONString:data error:nil];
    NSArray *messageList         = [discussionDict objectForKey:@"results"];
      
    unreadDiscussions =  [[NSMutableArray alloc] init];
    
    for(NSDictionary *obj in messageList) {
        // Create a new simple dict out of title and path and append it
        // to the unreadDiscussions array
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        [item setObject:[obj objectForKey:@"title"] forKey:@"title"];
        [item setObject:[obj objectForKey:@"permalink"] forKey:@"permalink"];
        [item setObject:[obj objectForKey:@"team_name"] forKey:@"team_name"];
        [item setObject:[obj objectForKey:@"unread_count"] forKey:@"unread_count"];
        
        // Parse the ISO date and attach to dict as a NSDict object
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"]; // 2013-02-11T17:30:26.790
        NSDate *timestamp = [dateFormatter dateFromString:[obj objectForKey:@"timestamp"]];
        [item setObject:timestamp forKey:@"timestamp"];
        
        NSLog(@"Item to add %@", item);
        NSLog(@"Current unreadDiscussions %@", unreadDiscussions);
        
        [unreadDiscussions addObject:item];
    }
    
    NSLog(@"Final unreadDiscussions %@", unreadDiscussions);
}

/*
 * Public func to easily trigger the fetch of new discussions
 */
+ (NSMutableArray *)getUnreadDiscussionArray {
    [[self alloc] loadUnreadDiscussions];
    return unreadDiscussions;
}

+ (bool) testCredentialsWithUsername:(NSString *)username token:(NSString *)token {
    NSError *error = nil;
    NSHTTPURLResponse* urlResponse = nil;
    NSString *urlString = [NSString stringWithFormat:@"%@", GINGER_DISCUSSIONS];
    NSString *tokenToken = [NSString stringWithFormat:@"Token %@", token];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:15];

    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:tokenToken forHTTPHeaderField:@"Authorization"];
    
    NSLog(@"%@", [request valueForHTTPHeaderField:@"Authorization"]);
    
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&urlResponse
                                      error:&error];
    
    // Only 200 is a good url response
    long statusCode = [urlResponse statusCode];
    if(statusCode == 200) {
        return YES;
    }
    
    NSLog(@"testCredentials failed with status code %ld and error %@", statusCode, error);
    return NO;
}

-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
    NSLog(@"String sent from server %@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
    
}

@end
