//
//  ViewController.h
//  karaoke
//
//  Created by Kevin Holesh on 4/16/15.
//  Copyright (c) 2015 Broadway Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LyricParser.h"


@interface ViewController : UIViewController

@property (strong, nonatomic) NSDictionary *songData;
@property (strong, nonatomic) NSArray *lines;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSURL *songFileURL;
@property (strong, nonatomic) IBOutlet UILabel *nowLabel;
@property (strong, nonatomic) IBOutlet UILabel *onDeckLabel;
@property (nonatomic) int lineIndex;
@property (nonatomic) int wordIndex;
@property (strong, nonatomic) IBOutlet UIProgressView *songProgress;
@property (strong, nonatomic) NSTimer *songProgressTimer;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic) BOOL playing;

- (IBAction)playButtonPressed:(id)sender;

@end

