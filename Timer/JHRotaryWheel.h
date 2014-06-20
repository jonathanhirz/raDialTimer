//
//  JHRotaryWheel.h
//  Timer
//
//  Created by Jonathan Hirz on 3/19/12.
//  Copyright (c) 2012 SuaveApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHRotaryWheelProtocol.h"
#import <AVFoundation/AVFoundation.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface JHRotaryWheel : UIControl <UIActionSheetDelegate> {
    UILabel *timerDisplay;
    NSTimer *stopWatchTimer;
    NSDate *currentDate;
    NSDateFormatter *dateFormatter;
    AVAudioPlayer *audioPlayer;
    

}

@property (weak) id <JHRotaryWheelProtocol> delegate;
@property (nonatomic, strong) UIView *container;
@property CGAffineTransform startTransform;
@property (nonatomic, retain) UILabel* timerDisplay;
@property (nonatomic, retain) UIButton* startButton;
@property (nonatomic, retain) UIButton* pauseButton;

- (id) initWithFrame:(CGRect)frame andDelegate:(id)del;
- (void) showActionSheet:(id)sender;
- (void) adjustSpinnerAnimationAfterResuming;
- (void)animateTimeLeftLayerMask:(float)timeToSpin withStrokeEndFromValue:(float)strokeEndFromValue;

@end
