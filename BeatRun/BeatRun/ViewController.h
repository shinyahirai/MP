//
//  ViewController.h
//  BeatRun
//
//  Created by Shinya Hirai on 2/27/14.
//  Copyright (c) 2014 Shinya Hirai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "EFCircularSlider.h"

@interface ViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;
@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *songPlayTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playAndPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *skipToPreviousButton;
@property (weak, nonatomic) IBOutlet UIButton *skipToNextButton;
@property (weak, nonatomic) IBOutlet UIImageView *artworkImage;
@property (weak, nonatomic) IBOutlet UIImageView *miniArtworkImage;
@property (weak, nonatomic) IBOutlet UIView *gradationView;

- (IBAction)playAndPause:(id)sender;
- (IBAction)skipToPrevious:(id)sender;
- (IBAction)skipToNext:(id)sender;

@end