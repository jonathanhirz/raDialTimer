//
//  JHAppDelegate.h
//  Timer
//
//  Created by Jonathan Hirz on 3/19/12.
//  Copyright (c) 2012 SuaveApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JHViewController;

@class JHViewControllerTutorial;

@interface JHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) JHViewController *viewController;

@property (strong, nonatomic) JHViewControllerTutorial *viewControllerTutorial;

@end
