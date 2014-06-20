//
//  JHViewControllerTutorial.m
//  raDial Timer
//
//  Created by Jonathan Hirz on 8/20/13.
//  Copyright (c) 2013 SuaveApps. All rights reserved.
//

#import "JHViewControllerTutorial.h"

@interface JHViewControllerTutorial ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *backgroundImage;
@property (strong, nonatomic) UILabel *subText;

@end

@implementation JHViewControllerTutorial

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Setup Title Label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, 320, 100)];
    self.titleLabel.text = @"Hi, my name is Jonathan. I made this.";
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica Light" size:18];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.numberOfLines = 0;
    [self.view addSubview:self.titleLabel];
    
    /*
    // Setup background image
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height == 480)
        {
            self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default@2x.png"]];
        }
        else
        {
            self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
        }
    }
    
    
    //self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568h@2x.png"]];
    self.backgroundImage.frame = self.view.frame;
    [self.view addSubview:self.backgroundImage];
    [self.view sendSubviewToBack:self.backgroundImage];
    */
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Setup sub Text
    self.subText = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, 320, 150)];
    //self.subText.backgroundColor = [UIColor blueColor];
    self.subText.font = [UIFont fontWithName:@"Helvetica Light" size:40];
    self.subText.lineBreakMode = NSLineBreakByWordWrapping;
    self.subText.numberOfLines = 0;
    self.subText.textAlignment = NSTextAlignmentCenter;
    
    self.subText.text = @"Your simple, beautiful timer";
    [self.view addSubview:self.subText];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
