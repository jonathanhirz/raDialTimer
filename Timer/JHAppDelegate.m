//
//  JHAppDelegate.m
//  Timer
//
//  Created by Jonathan Hirz on 3/19/12.
//  Copyright (c) 2012 SuaveApps. All rights reserved.
//

#import "JHAppDelegate.h"

#import "JHViewController.h"
#import "JHViewControllerTutorial.h"
#import "JHRotaryWheel.h"
#import "Flurry.h"

@implementation JHAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize viewControllerTutorial = _viewControllerTutorial;
JHRotaryWheel *wheel;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Flurry startSession:@"6Z4VJWZQMN26RY8424SP"];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    
    self.viewController = [[JHViewController alloc] initWithNibName:@"JHViewController" bundle:nil];
    self.viewControllerTutorial = [[JHViewControllerTutorial alloc] init];
    
    self.window.rootViewController = self.viewControllerTutorial;
    
    [self.window makeKeyAndVisible];
    [application setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

    // call method to put the current time in a variable
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // call method that gets current (resumed) time, calculates difference between paused and resumed time, and subtracts that from the running timer
    //NSLog(@"app resumed");
    //[[UIApplication sharedApplication] adjustSpinnerAnimationAfterResuming];
    //JHRotaryWheel* rotaryWheel = [JHRotaryWheel alloc];
    //[wheel adjustSpinnerAnimationAfterResuming];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // call method that gets current (resumed) time, calculates difference between paused and resumed time, and subtracts that from the running timer
    NSLog(@"app became active");
    [wheel adjustSpinnerAnimationAfterResuming];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // cancel all timers, clear everything, put it back to normal
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];

}

@end
