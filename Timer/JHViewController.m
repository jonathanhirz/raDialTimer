//
//  JHViewController.m
//  Timer
//
//  Created by Jonathan Hirz on 3/19/12.
//  Copyright (c) 2012 SuaveApps. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JHViewController.h"
#import "JHRotaryWheel.h"
#import <AudioToolbox/AudioServices.h>


@interface JHViewController ()


@end

@implementation JHViewController

JHRotaryWheel *wheel;



- (void)viewDidLoad
{
    [super viewDidLoad];
    //add some flair
    //self.view.layer.backgroundColor	 = [UIColor darkGrayColor].CGColor;
    self.view.layer.cornerRadius = 0.0;
    // self.view.tintColor = [UIColor redColor];
    
    /* we don't need no fancy sublayer here
    CALayer *sublayer = [CALayer layer];
    sublayer.backgroundColor = [UIColor grayColor].CGColor;
    sublayer.shadowOffset = CGSizeMake(0, 3);
    sublayer.shadowRadius = 5.0;
    sublayer.shadowColor = [UIColor blackColor].CGColor;
    sublayer.shadowOpacity = 0.8;
    sublayer.frame = CGRectMake(self.view.frame.size.width/2 - 105, self.view.frame.size.height/2 - 95, 210, 210);
    sublayer.borderColor = [UIColor blackColor].CGColor;
    sublayer.borderWidth = 2.0;
    [self.view.layer addSublayer:sublayer];
    */

    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height == 480)
        {
            wheel = [[JHRotaryWheel alloc] initWithFrame:CGRectMake(0, 0, 320, 480) andDelegate:self];
        }
        else
        {
            wheel = [[JHRotaryWheel alloc] initWithFrame:CGRectMake(0, 0, 320, 568) andDelegate:self];
        }
    }
    
    
    //NSLog(@"%f",[[UIScreen mainScreen] bounds].size.height);
    [self.view addSubview:wheel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}


@end
