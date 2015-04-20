//
//  ViewController.m
//  karaoke
//
//  Created by Kevin Holesh on 4/16/15.
//  Copyright (c) 2015 Broadway Lab. All rights reserved.
//

#import "ViewController.h"
#import "UILabel+Point.h"

@implementation ViewController

@synthesize songData = _songData,
            lines = _lines,
            player = _player,
            songFileURL = _songFileURL,
            nowLabel = _nowLabel,
            onDeckLabel = _onDeckLabel,
            lineIndex = _lineIndex,
            wordIndex = _wordIndex,
            songProgress = _songProgress,
            songProgressTimer = _songProgressTimer,
            playButton = _playButton,
            playing = _playing;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playing = NO;
    self.lineIndex = 1;
    self.wordIndex = 0;
    
    // Set up the player
    NSString *songFilePath = [NSBundle.mainBundle pathForResource:@"prettygirl" ofType:@"mp3"];
    self.songFileURL = [[NSURL alloc] initFileURLWithPath:songFilePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.songFileURL error:nil];
    
    self.songData = [LyricParser parseFromFile:[NSBundle.mainBundle pathForResource:@"prettygirl-midico" ofType:@"lrc"]];
    self.lines = self.songData[@"lines"];
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateCurrentLine];
    [self updateNextVerse];
    [self updateSongProgress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonPressed:(id)sender {
    if (self.playing)
        [self pauseSong];
    else
        [self playSong];
}

- (void)playSong {
    [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
    self.playing = YES;
    
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&activationError];

    [self.player prepareToPlay];
    self.player.volume = 1.0;
    [self.player play];
    
    self.songProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                                              target:self
                                                            selector:@selector(updateSongProgress)
                                                            userInfo:nil
                                                             repeats:YES];
}

- (void)pauseSong {
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    self.playing = NO;
    [self.player pause];
    
    [self.songProgressTimer invalidate];
    self.songProgressTimer = nil;
}

- (void)updateSongProgress {
    if (self.player) {
        self.songProgress.progress = self.player.currentTime / self.player.duration;
    } else {
        self.songProgress.progress = 0.0;
    }
    
    if (self.lineIndex >= self.lines.count)
        return;
    
    NSArray *currentLine = [self.lines objectAtIndex:self.lineIndex];
    if ([currentLine isEqualToArray:[NSArray array]]) {
        NSLog(@"--- blank line ---");
        self.lineIndex++;
    } else if (self.wordIndex < currentLine.count) {
        float time = [currentLine[self.wordIndex][0] floatValue];
        if (self.player.currentTime >= time) {
            NSLog(@"%@", currentLine[self.wordIndex][1]);
            [self updateCurrentLine];
            self.wordIndex++;
        }
    } else {
        self.lineIndex++;
        self.wordIndex = 0;
        [self updateNextVerse];
    }
}

- (void)updateCurrentLine {
    NSArray *currentLine = [self currentLine];
//    if (self.lineIndex == 0 && self.wordIndex == 0)
        self.nowLabel.text = [LyricParser humanReadableLine:currentLine];
//    else
//        self.nowLabel.attributedText = [LyricParser humanReadableLine:currentLine forIndex:self.wordIndex];
    
    
    NSLog(@"line starts at %f", [currentLine.firstObject[0] floatValue]);
    
    if (self.lineIndex+1 < self.lines.count) {
        NSArray *nextLine = [self.lines objectAtIndex:self.lineIndex+1];
        NSLog(@"next line starts at %f", [nextLine.firstObject[0] floatValue]);
    } else {
        NSLog(@"No next line");
    }
    
    NSLog(@"this word starts at %@ and the the next one starts at %@")
    
    
    
    CGFloat x = [self.nowLabel xForLetterAtIndex:0];
    self.nowLabel.textColor = [UIColor colorWithPatternImage:[self barGraphWithPercentage:(x/self.nowLabel.frame.size.width)]];;
}

- (NSArray *)currentLine {
    return [self.lines objectAtIndex:self.lineIndex];
}

- (NSArray *)currentTimestampedWord {
    NSArray *currentLine = [self currentLine];
    return currentLine[self.wordIndex];
}

- (NSArray *)nextTimestampedWord {
    NSArray *currentLine = [self currentLine];
    if (self.lineIndex+1 < self.lines.count) {
        NSArray *nextLine = [self.lines objectAtIndex:self.lineIndex+1];
        NSLog(@"next line starts at %f", [nextLine.firstObject[0] floatValue]);
    } else {
        NSLog(@"No next line");
    }
    
    return currentLine[self.wordIndex];
}

- (UIImage *)barGraphWithPercentage:(float)percentage {
    CGFloat labelWidth = self.nowLabel.frame.size.width;
    CGFloat labelHeight = self.nowLabel.frame.size.height;
    CGRect rect = CGRectMake(0.0f, 0.0f, labelWidth, labelHeight);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, UIColor.blackColor.CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, labelWidth, labelHeight));
    
    CGContextSetFillColorWithColor(context, UIColor.greenColor.CGColor);
    CGContextFillRect(context, CGRectMake(0.0f, 0.0f, (percentage * labelWidth), labelHeight));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)updateNextVerse {
    NSMutableArray *nextVerse = [NSMutableArray array];
    for (int i = self.lineIndex; i < self.lines.count; i++) {
        if (i >= self.lineIndex && nextVerse.count < 4) {
            NSArray *line = [self.lines objectAtIndex:i];
            [nextVerse addObject:[LyricParser humanReadableLine:line]];
        }
    }
    
    NSString *result = @"";
    for (NSString *line in nextVerse) {
        result = [result stringByAppendingFormat:@"%@\n", line];
    }
    self.onDeckLabel.text = result;
}

@end
