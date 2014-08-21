//
//  VoteAppDelegate.m
//  Vote
//
//  Created by 丁 一 on 14-2-24.
//  Copyright (c) 2014年 Ding Yi. All rights reserved.
//

#import "VoteAppDelegate.h"
#import "CoreDataHelper.h"
#import "VoteHomeViewController.h"

@implementation VoteAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0; 
    if (launchOptions != nil) {
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSLog(@"Launched from push notification: %@", userInfo);
        if ( userInfo != nil )
        {
            [self application:application handleRemoteNotification:userInfo updateUI:NO];
        }
    }

    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    NSString *deviceTokenStr = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"%@", deviceTokenStr);
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:deviceTokenStr forKey:DEVICE_TOKEN];
    [ud synchronize];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self application:application handleRemoteNotification:userInfo updateUI:YES];
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application handleRemoteNotification:(NSDictionary *)userInfo updateUI:(BOOL)updateUI
{
    NSLog(@"Received notification: %@", userInfo);
    if (updateUI) {
        NSDictionary *aps = [userInfo objectForKey:@"aps"];
        NSString *prompt = [[aps objectForKey:@"alert"] objectForKey:@"loc-key"];
        NSNumber *badge = [aps objectForKey:@"badge"];
        VoteHomeViewController *rootVC = (VoteHomeViewController *)self.window.rootViewController;
        if ([prompt isEqualToString:SERVER_ADD_FRIEND_REQ] || [prompt isEqualToString:SERVER_AGREE_FRIEND_RESP] || [prompt isEqualToString:SERVER_REFUSE_FRIEND_RESP]) {
            [[[[rootVC viewControllers] objectAtIndex:1] tabBarItem] setBadgeValue:[badge stringValue]];
        }
        
    } else {
        
    }

}

@end
