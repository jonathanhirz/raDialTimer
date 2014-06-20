
//  JHRotaryWheel.m
//  Timer
//
//  Created by Jonathan Hirz on 3/19/12.
//  Copyright (c) 2012 SuaveApps. All rights reserved.
//

#import "JHRotaryWheel.h"
#import <QuartzCore/QuartzCore.h>
#import "Flurry.h"

@interface JHRotaryWheel()
- (void)drawWheel;
- (void)setupTimer;
- (void)drawTimerDisplay;
- (float)calculateDistanceFromCenter:(CGPoint)point;
- (int)totalNumberOfSeconds:(NSDate *)date;
- (void)resetTimer;
- (void)showActionSheet:(id)sender;
- (void)adjustSpinnerAnimationAfterResuming;
- (void)animateTimeLeftLayerMask:(float)timeToSpin withStrokeEndFromValue:(float)strokeEndFromValue;
@end

NSDate *currentDate;
static float deltaAngle;
float timerDisplayAmount = 0;
int spinnerFinalSize = 265;
int spinnerFullSize = 285;
CALayer *timeLeftLayer;
CALayer *backgroundLayer;
CAShapeLayer *maskLayer;
NSDate *alarmFireDate;
UIActionSheet *resetTimer;
NSDate *timeRightNow;
UIButton *resetTimerButton;
CAAnimationGroup *animationGroupFlash;
UILocalNotification *timerDone;
float totalSeconds;

// - conditions -
// is timer counting down? (don't spin wheel if timer is running)
BOOL countdownHasStarted = NO;
BOOL animationsAreFinished = NO;
BOOL startButtonHasAlreadyBeenPressed = NO;

@implementation JHRotaryWheel

@synthesize delegate, container, startTransform, timerDisplay, startButton, pauseButton;

- (id)initWithFrame:(CGRect)frame andDelegate:(id)del {
    if ((self = [super initWithFrame:frame])) {
        self.delegate = del;
        [self drawBackground];
        [self drawTimeLeft];
        [self drawSetupTimeLeftLayerMask];
        [self drawWheel];
        [self drawTimerDisplay];
        [self drawStartButton];
        [self setupTimer];
    }
    return self;
}

#pragma mark - Animations

// animates bounds from 200 (hidden behind wheel) to full
- (CABasicAnimation *)growBoundsAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    [animation setFromValue:[NSValue valueWithCGRect:CGRectMake(100, 100, 200, 200)]];
    [animation setToValue:[NSValue valueWithCGRect:CGRectMake(100, 100, spinnerFullSize, spinnerFullSize)]];
    [animation setBeginTime:0.0];
    [animation setDuration:0.3];
    return animation;
}

// animates cornerRadius from hidden to full
- (CABasicAnimation *)growCornerRadiusAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    [animation setFromValue:[NSNumber numberWithInt:100]];
    [animation setToValue:[NSNumber numberWithInt:spinnerFullSize/2]];
    [animation setBeginTime:0.0];
    [animation setDuration:0.3];
    return animation;
}

// animates bounds from full to final (small bounce back)
- (CABasicAnimation *)bounceBoundsAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    [animation setFromValue:[NSValue valueWithCGRect:CGRectMake(100, 100, spinnerFullSize, spinnerFullSize)]];
    [animation setToValue:[NSValue valueWithCGRect:CGRectMake(100, 100, spinnerFinalSize, spinnerFinalSize)]];
    [animation setBeginTime:0.3];
    [animation setDuration:0.1];
    return animation;
}

// animates cornerRadius from full to final (small bounce back)
- (CABasicAnimation *)bounceCornerRadiusAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    [animation setFromValue:[NSNumber numberWithInt:spinnerFullSize/2]];
    [animation setToValue:[NSNumber numberWithInt:spinnerFinalSize/2]];
    [animation setBeginTime:0.3];
    [animation setDuration:0.1];
    return animation;
}

// animates bounds completely away (hidden behind wheel)
- (CABasicAnimation *)shrinkBoundsAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    [animation setFromValue:[NSValue valueWithCGRect:CGRectMake(100, 100, spinnerFinalSize, spinnerFinalSize)]];
    [animation setToValue:[NSValue valueWithCGRect:CGRectMake(100, 100, 200, 200)]];
    [animation setBeginTime:0.5];
    [animation setDuration:0.6];
    return animation;
}

// animates cornerRadius completely away (hidden behind wheel)
- (CABasicAnimation *)shrinkCornerRadiusAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    [animation setFromValue:[NSNumber numberWithInt:spinnerFinalSize/2]];
    [animation setToValue:[NSNumber numberWithInt:100]];
    [animation setBeginTime:0.5];
    [animation setDuration:0.6];
    return animation;
}

#pragma mark - Drawing Things

- (void)drawBackground {
    //self.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.png"]];
    //self.backgroundColor = UIColorFromRGB(0xffffff);
    backgroundLayer = [self layer];
    backgroundLayer.backgroundColor = [UIColor whiteColor].CGColor;
}


- (void)drawTimeLeft {
    
    timeLeftLayer = [CALayer layer];
    timeLeftLayer.bounds = CGRectMake(100, 100, 200, 200);
    timeLeftLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    timeLeftLayer.cornerRadius = 100.0;
    //timeLeftLayer.backgroundColor = [UIColor blackColor].CGColor;
    timeLeftLayer.backgroundColor = UIColorFromRGB(0x40677d).CGColor;
    [self.layer addSublayer:timeLeftLayer];
}

// animation group for showing the spinner, with bounce
- (void)animateGrowSpinner {
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    [animationGroup setAnimations:[NSArray arrayWithObjects:[self growBoundsAnimation], [self growCornerRadiusAnimation], [self bounceBoundsAnimation], [self bounceCornerRadiusAnimation], nil]];
    [animationGroup setDuration:0.4];
    [animationGroup setRemovedOnCompletion:NO];
    [animationGroup setFillMode:kCAFillModeForwards];
    [animationGroup setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [timeLeftLayer addAnimation:animationGroup forKey:nil];
    animationsAreFinished = YES;
}

// animation group for hiding the spinner behind wheel
- (void)animateShrinkSpinner {
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    [animationGroup setAnimations:[NSArray arrayWithObjects:[self shrinkBoundsAnimation], [self shrinkCornerRadiusAnimation], nil]];
    [animationGroup setDuration:0.6];
    [animationGroup setRemovedOnCompletion:NO];
    [animationGroup setFillMode:kCAFillModeForwards];
    [animationGroup setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [timeLeftLayer addAnimation:animationGroup forKey:nil];
}

- (void)drawSetupTimeLeftLayerMask {
    maskLayer = [CAShapeLayer layer];
    CGFloat maskHeight = timeLeftLayer.bounds.size.height+spinnerFinalSize;
    CGFloat maskWidth = timeLeftLayer.bounds.size.height+spinnerFinalSize;
    CGPoint centerPoint = CGPointMake(maskWidth/2, maskHeight/2);
    CGFloat radius = sqrtf(maskWidth * maskWidth + maskHeight * maskHeight)/2;
    maskLayer.fillColor = [[UIColor clearColor] CGColor];
    maskLayer.strokeColor = [[UIColor blackColor] CGColor];
    maskLayer.lineWidth = radius;
    CGMutablePathRef arcPath = CGPathCreateMutable();
    CGPathMoveToPoint(arcPath, nil, centerPoint.x, centerPoint.y-radius/2);
    CGPathAddArc(arcPath, nil, centerPoint.x, centerPoint.y, radius/2, 3*M_PI/2, -M_PI/2, NO);
    maskLayer.path = arcPath;
    maskLayer.strokeEnd = 1.0;
    CFRelease(arcPath);
    timeLeftLayer.mask = maskLayer;
    timeLeftLayer.mask.frame = self.bounds;
}

- (void)animateTimeLeftLayerMask:(float)timeToSpin withStrokeEndFromValue:(float)strokeEndFromValue {
    CABasicAnimation *sweep = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    // I love this little BOOL logic trick here...delay the spinner animation if countdown has started (before start press),
    // don't delay animation on reset. Love the reuse of BOOL variables, and the '!' negator for different answers/results.
    // Magical.
    sweep.beginTime = CACurrentMediaTime() + (!countdownHasStarted * 0.4);
    sweep.duration = timeToSpin - 0.4;
    sweep.delegate = self;
    sweep.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    sweep.fillMode = kCAFillModeForwards;
    sweep.autoreverses = NO;
    sweep.removedOnCompletion = NO;
    sweep.fromValue = [NSNumber numberWithFloat:strokeEndFromValue];
    // NSLog(@"%f",strokeEndFromValue);
    sweep.toValue = [NSNumber numberWithFloat:0.0];

    [maskLayer addAnimation:sweep forKey:@"strokeEnd"];
}

- (void)drawWheel {
    container = [[UIView alloc] initWithFrame:self.frame];
    UIImage *wheel = [UIImage imageNamed:@"wheel.png"];
    UIImageView *wheelView = [[UIImageView alloc] initWithImage:wheel];
    wheelView.layer.anchorPoint = CGPointMake(0.5f, 0.5f);
    wheelView.layer.position = CGPointMake(container.bounds.size.width/2.0, container.bounds.size.height/2.0);
    wheelView.clipsToBounds = NO;
    [container addSubview:wheelView];
    container.userInteractionEnabled = NO;
    [self addSubview:container];
}

- (void)drawTimerDisplay {
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if (result.height == 480)   //timer display for 3.5 inch
        {
            if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                timerDisplay = [[UILabel alloc] initWithFrame:CGRectMake(0,15,320,75)];  //ios 7
            }else{
                timerDisplay = [[UILabel alloc] initWithFrame:CGRectMake(0,25,320,75)];  //ios 6
            }

        }
        else    //timer display for 4 inch
        {
            if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                timerDisplay = [[UILabel alloc] initWithFrame:CGRectMake(0,35,320,75)]; //ios 7
            }else{
                timerDisplay = [[UILabel alloc] initWithFrame:CGRectMake(0,45,320,75)]; //ios 6
            }

        }
    }
    
    timerDisplay.textAlignment = NSTextAlignmentCenter;
    timerDisplay.backgroundColor = [UIColor clearColor];
    timerDisplay.textColor = UIColorFromRGB(0x272929);
    [timerDisplay setFont:[UIFont fontWithName:@"Helvetica-Bold" size:70.0]];
    timerDisplay.text = @"00:00:00";
    timerDisplay.tag = 1;
    [self addSubview:timerDisplay];
}

- (void)drawStartButton {
    startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(self.bounds.size.width/2-45, self.bounds.size.height/2-45, 90, 90);
    [[startButton layer] setCornerRadius:50.0f];
    
    // startButton shadow
    //startButton.clipsToBounds = YES;
    //startButton.layer.masksToBounds = NO;
    startButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    startButton.layer.shadowOpacity = 0.5;
    startButton.layer.shadowRadius = 2;
    startButton.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    //startButton.layer.borderColor = [UIColor blueColor].CGColor;
    //startButton.layer.borderWidth = 1.0;
    
    // startButton.title shadow
    [startButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    //startButton.titleLabel.layer.shadowColor = [UIColor blueColor].CGColor;
    //startButton.titleLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    //startButton.titleLabel.layer.shadowOpacity = 1.0;
    //startButton.titleLabel.layer.shadowRadius = 4.0;
    startButton.titleLabel.layer.masksToBounds = NO;
    
    [startButton addTarget:self action:@selector(startButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [startButton setBackgroundImage:[UIImage imageNamed:@"wheelButton.png"] forState:UIControlStateNormal];
    
    [self addSubview:startButton];
}


#pragma mark - Animation groups for end of timer flash


- (CABasicAnimation *)animateTimerFinishedFlashBackgroundWhiteToRed {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    [animation setFromValue:(id)UIColorFromRGB(0xFFFFFF).CGColor];
    [animation setToValue:(id)UIColorFromRGB(0xC03F3F).CGColor];
    [animation setBeginTime:0.0];
    [animation setDuration:0.5];
    return animation;
}
- (CABasicAnimation *)animateTimerFinishedFlashBackgroundRedToWhite {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    [animation setFromValue:(id)UIColorFromRGB(0xC03F3F).CGColor];
    [animation setToValue:(id)UIColorFromRGB(0xFFFFFF).CGColor];
    [animation setBeginTime:0.5];
    [animation setDuration:0.5];
    return animation;
}

- (void)animateTimerFinishedFlashBackground {
    // create a button the size of the whole screen
    // 'play alarm' until screen is touched (button pressed)
    // flash (animate) background color change a few times
    // play alarm sound
    
    resetTimerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetTimerButton.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    resetTimerButton.layer.opaque = NO;
    [resetTimerButton addTarget:self action:@selector(stopTheFlashing) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:resetTimerButton];
    
    
    animationGroupFlash = [CAAnimationGroup animation];
    [animationGroupFlash setAnimations:[NSArray arrayWithObjects:
                                        [self animateTimerFinishedFlashBackgroundWhiteToRed],
                                        [self animateTimerFinishedFlashBackgroundRedToWhite],nil]];
    [animationGroupFlash setDuration:1.0];
    [animationGroupFlash setRepeatCount:10.0];
    [animationGroupFlash setRemovedOnCompletion:NO];
    [animationGroupFlash setDelegate:self];
    [animationGroupFlash setFillMode:kCAFillModeForwards];
    [animationGroupFlash setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [backgroundLayer addAnimation:animationGroupFlash forKey:@"flash"];
    
    
    // create and play sound
    NSString *alarmSoundPath = [[NSBundle mainBundle] pathForResource:@"raDialTimerAlarmTrim" ofType:@"wav"];
    NSURL *alarmSoundURL = [NSURL fileURLWithPath:alarmSoundPath];
    NSError *error;
    
    if (audioPlayer == nil) {
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:alarmSoundURL error:&error];
    }
    if (audioPlayer) {
        [audioPlayer setNumberOfLoops:9];
        [audioPlayer prepareToPlay];
        [audioPlayer play];
    } else {
        NSLog(@"%@",error);
    }
    [Flurry logEvent:@"Finished Timer"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finishedAnimation{
    if(finishedAnimation) {
        if(anim == [backgroundLayer animationForKey:@"flash"]) {
            //NSLog(@"DOES THIS FUCKING WORK YET!?");
            [self stopTheFlashing];
        }
    }
    
}

- (void)stopTheFlashing {
    [resetTimerButton removeFromSuperview];
    [backgroundLayer removeAllAnimations];
    if (audioPlayer) {
        [audioPlayer stop];
        audioPlayer.currentTime = 0;
    }
    // STOP THE SOUND WHEN ITS IN THERE
    // NSLog(@"stopTheFlashing");
}

#pragma mark - Fix the spinner animation when resuming

- (void)adjustSpinnerAnimationAfterResuming {
    NSLog(@"spinner adjusted");
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [maskLayer removeAllAnimations];
    int timeToSpinNew = [self totalNumberOfSeconds:currentDate];
    float spinFromThisPercentage = ((float)timeToSpinNew / (float)totalSeconds);
    NSLog(@"timeToSpinNew:%i",timeToSpinNew);
    NSLog(@"spinFromThisPercentage:%f",spinFromThisPercentage);
    [self animateTimeLeftLayerMask:timeToSpinNew withStrokeEndFromValue:spinFromThisPercentage];
    //clear spinning animation
    //restart spinning animation with remaining time and remaining percentage of time for strokeEnd
    
}


#pragma mark - Timer Setup & Maintenence

// Initialize the timer, set the format, set display to 00:00:00
- (void)setupTimer {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    currentDate = [gregorian dateFromComponents:comps];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *timerString = [dateFormatter stringFromDate:currentDate];
    timerDisplay.text = timerString;
}

// Set display to currentDate
- (void)updateTimer {
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString *timerString = [dateFormatter stringFromDate:currentDate];
    timerDisplay.text = timerString;
}


// Function is called every second, after startButtonPressed
// Subtracts 1.0 seconds from currentDate, updates display, checks if we are at 0 (if so, resetTimer)
- (void)startCountdown {
    countdownHasStarted = YES;
    
    NSTimeInterval timeUntilAlertFires = [alarmFireDate timeIntervalSinceDate:[NSDate date]];
    [self setupTimer];
    currentDate = [currentDate dateByAddingTimeInterval:1.0];
    currentDate = [currentDate dateByAddingTimeInterval:timeUntilAlertFires]; //this adds a negative number, hence the countdown
    //currentDate = [NSDate dateWithTimeInterval:timeUntilAlertFires sinceDate:timeRightNow];
    //NSLog(@"timeUntilAlertFires:%f",timeUntilAlertFires);
    //NSLog(@"currentDate:%@",currentDate);
    //NSLog(@"timeRightNow:%@",timeRightNow);
    //NSLog(@"alarmFireDate:%@",alarmFireDate);
    [self updateTimer];
    if ([self totalNumberOfSeconds:currentDate] == 0) {
        [self resetTimer];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [self animateTimerFinishedFlashBackground];
    }
    if (timeUntilAlertFires < 0) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [self resetTimer];
    }
}

- (void)setupAlert {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    timerDone = [[UILocalNotification alloc] init];
    if (timerDone == nil)
        return;
    timerDone.fireDate = [[NSDate date] dateByAddingTimeInterval:[self totalNumberOfSeconds:currentDate]];
    alarmFireDate = timerDone.fireDate;
    timerDone.timeZone = [NSTimeZone defaultTimeZone];
    //timerDone.soundName = UILocalNotificationDefaultSoundName;
    timerDone.soundName = @"raDialTimerAlarmTrim.wav";
    
    NSArray *notificationTextArray = [NSArray arrayWithObjects:
                                      @"Timer done",
                                      @"Time is up",
                                      @"Time's up!",
                                      @"🔔 Ding Ding 🔔",
                                      @"🎵 Beep Beep 🎵",
                                      @"🎶 Ring Ring 🎶",
                                      @"Timer finished",
                                      nil];
    int notificationAlertIndex = (arc4random() % [notificationTextArray count] + 0);
    // NSLog(@"array count:%i",[notificationTextArray count]);
    // NSLog(@"notificationAlertIndex:%i",notificationAlertIndex);
    timerDone.alertBody = notificationTextArray[notificationAlertIndex];
    timerDone.hasAction = YES;
    timerDone.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:timerDone];
    
}


/*

 WHAT TO DO WHEN APP GETS CLOSED.
 need to keep time, and set off alarm if time is up, even if app is closed.
 best way is to set up a local notification to be fired when the timer is up, and make is fire whether the app is running or not (research how that works)
 when resuming, all that needs to be done is adjust the timer and the spinner to be at the right place
 
 1) local notifications: set up when start, cancel when reset. Fire at time up, whether app is open or closed
 2) adjust time display and spinner when resuming
 3) if app is completely closed, should the timer cancel? No. So, when first launching, app should check to see if there are any 'stray' timers running
    and use that timer's information to adjust. Fringe case, but needs to be addressed. Is there a 'global place' to store this timer-running data?
 4) Different situations for alert based on if app is running or not.
    Not running: sound, local alert with dismissal button
    Running: sound, maybe an animation of the wheel (pulsing, different color (red), etc)
 
*/

#pragma mark - Pressing Buttons

- (void)startButtonPressed {    
    if (countdownHasStarted == NO) {
        if (startButtonHasAlreadyBeenPressed == NO) {
            if ([self totalNumberOfSeconds:currentDate] > 0) {
                timeRightNow = [NSDate date];
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                  target:self
                                                                selector:@selector(startCountdown)
                                                                userInfo:nil
                                                                 repeats:YES];
                [startButton setTitle:@"Reset" forState:UIControlStateNormal];
                [self animateGrowSpinner];
                [self animateTimeLeftLayerMask:([self totalNumberOfSeconds:currentDate]) withStrokeEndFromValue:1.0];
                [self setupAlert];
                // NSLog(@"totalNumberOfSeconds:%i", [self totalNumberOfSeconds:currentDate]);
                startButtonHasAlreadyBeenPressed = YES;
                totalSeconds = [self totalNumberOfSeconds:currentDate];
                NSDictionary *timerParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInt:[self totalNumberOfSeconds:currentDate]], @"Number of Seconds", nil];
                [Flurry logEvent:@"Start a Timer" withParameters:timerParams];
                //NSLog(@"params:%@",[timerParams valueForKey:@"Total Seconds"]);
                //NSLog(@"paramsTest:%@",[NSNumber numberWithInt:[self totalNumberOfSeconds:currentDate]]);
                //NSLog(@"timerParams:%@",timerParams);
            }
        }
    }
    if (countdownHasStarted == YES) {
        // stop the timer
        
        // action sheet from bottom: Reset Timer? / Cancel
        [self showActionSheet:self];
        
        
        //[self animateTimeLeftLayerMask:0.8 withStrokeEndFromValue:[[maskLayer presentationLayer] strokeEnd]];
        //[self resetTimer];
    }
}


- (void)pauseButtonPressed {
    if (countdownHasStarted == YES) {
        // NSLog(@"Timer Paused");
        // pause the timer
    }
}

-(void)showActionSheet:(id)sender {
    resetTimer = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reset Timer?" otherButtonTitles:nil, nil];
    resetTimer.actionSheetStyle = UIActionSheetStyleAutomatic;
    [resetTimer showInView:self];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self animateTimeLeftLayerMask:0.8 withStrokeEndFromValue:[[maskLayer presentationLayer] strokeEnd]];
        [self resetTimer];
        [Flurry logEvent:@"Reset Timer"];
        NSLog(@"button 0 pushed"); //reset
    } else if (buttonIndex == 1) {
        NSLog(@"button 1 pushed"); //cancel
    }
    
}

#pragma mark - Touch Controls

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint touchPoint = [touch locationInView:self];
    float dist = [self calculateDistanceFromCenter:touchPoint];
    if (dist < 30 || dist > 100) {
        // NSLog(@"Ignoring tap (%f, %f)", touchPoint.x, touchPoint.y);
        return  NO;
    }
    float dx = touchPoint.x - container.center.x;
    float dy = touchPoint.y - container.center.y;
    deltaAngle = atan2(dy, dx);
    startTransform = container.transform;
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pt = [touch locationInView:self];
    CGPoint previousPt = [touch previousLocationInView:self];
    float dist = [self calculateDistanceFromCenter:pt];
    if (dist < 30) {
        // NSLog(@"Movement cancelled, too close to center");
        return NO;
    }
    float dx = pt.x - container.center.x;
    float dy = pt.y - container.center.y;
    float ang = atan2(dy,dx);
    float angleDifference = deltaAngle - ang;
    

    if (countdownHasStarted == NO) {

        container.transform = CGAffineTransformRotate(startTransform, -angleDifference);
        
        //figure out angle of just-previous touch during movement
        float preDx = previousPt.x - container.center.x;
        float preDy = previousPt.y - container.center.y;
        float preAng = atan2(preDy, preDx);
        
        // ================================================================================================================
        // This lovely block of code here is not exactly what I want, but it works (for now)
        // check the distance between the current touch point and the (just) previous touch point
        // first, make sure we aren't at the 9 o'clock position, where the 'ang' variable makes a huge jump from 0 to 2M_PI
        // Then check if the wheel is spinning clockwise or counterclockwise
        // The distance between ang and preAng determines how much we add to the currentDate timer
        // some quick and dirty fixes for subtracting 10 when the timer is less than 10
        //      (prevents looping back to 23:59:59, etc)
        // ================================================================================================================
        
        if (fabsf(ang-preAng) < 1) {
            if (ang > preAng) {
                if (ang - preAng < 0.05) {
                    [self addValue:0.1];
                    // NSLog(@"addValue:0.1");
                }
                if (ang - preAng > 0.05 && ang - preAng < 0.2) {
                    [self addValue:5.0];
                    // NSLog(@"addValue:5.0");
                }
                if (ang - preAng > 0.2) {
                    [self addValue:10.0];
                    // NSLog(@"addValue:10.0");
                }
            }
            if (ang < preAng) {
                if (preAng - ang < 0.05) {
                    [self subValue:0.1];
                    // NSLog(@"subValue:0.1");
                }
                if (preAng - ang > 0.05 && preAng - ang < 0.2) {
                    if ([self totalNumberOfSeconds:currentDate] > 5) {
                        [self subValue:5.0];
                        // NSLog(@"subValue:5.0");
                    }else {
                        [self subValue:1.0];
                        // NSLog(@"subValue:1.0(2.2)");
                    }
                }
                if (preAng - ang > 0.2) {
                    if ([self totalNumberOfSeconds:currentDate] > 10) {     // putting out fires...
                        [self subValue:10.0];
                        // NSLog(@"subValue:10.0");
                    }else {
                        [self subValue:1.0];
                        // NSLog(@"subValue:1.0(2)");
                    }
                }
            }
        }

    }
    return YES;
    // 4/1/2012
    // add some code in here to track the number of completed rotations
    // after a certain number of successive rotations, add MORE to the clock on each turn
    // this makes adding a lot of time easier, you don't have to spin as much
    
    // should also normalize the added time somehow (one full rotation adds a minute, etc)
    // also need to fix the bug at the left side of wheel (9 o'clock) where it will add/sub weirdly
}

#pragma mark - Helper Functions

- (float)calculateDistanceFromCenter:(CGPoint)point {
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    //// NSLog(@"CENTER is at (%f, %f)", center.x, center.y);
    float dx = point.x - center.x;
    float dy = point.y - center.y;
    return sqrt(dx*dx + dy*dy);
}

- (int)totalNumberOfSeconds:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    int hours = [comps hour];
    int minutes = [comps minute];
    int seconds = [comps second];
    int allSeconds = seconds + 60*minutes + 60*60*hours;
    if (allSeconds < 1) allSeconds = 0;
    return allSeconds;
}

- (void)addValue:(float)value{
    // could set a max time here, check the same way as subValue
    currentDate = [currentDate dateByAddingTimeInterval:value];
    // NSLog(@"currentDate:%i",[self totalNumberOfSeconds:currentDate]);
    [self updateTimer];
}

- (void)subValue:(float)value{
    if ([self totalNumberOfSeconds:currentDate] > 0.0) {
        currentDate = [currentDate dateByAddingTimeInterval:-value];
        // NSLog(@"currentDate:%i",[self totalNumberOfSeconds:currentDate]);
        [self updateTimer];
    }
}
- (void)resetCountdown {
    [stopWatchTimer invalidate];
    stopWatchTimer = nil;
    
}

- (void)resetTimer{
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [stopWatchTimer invalidate];
    stopWatchTimer = nil;
    if (countdownHasStarted == YES) {
        [self animateShrinkSpinner];
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    countdownHasStarted = NO;
    animationsAreFinished = NO;
    startButtonHasAlreadyBeenPressed = NO;
    container.transform = CGAffineTransformIdentity;
    [resetTimer dismissWithClickedButtonIndex:1 animated:YES];
    [self setupTimer];
    [self updateTimer];
}


@end
