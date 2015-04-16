//
//  ViewController.m
//  karaoke
//
//  Created by Kevin Holesh on 4/16/15.
//  Copyright (c) 2015 Broadway Lab. All rights reserved.
//

#import "ViewController.h"

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
    self.lineIndex = 0;
    self.wordIndex = 0;
    
    // Set up the player
    NSString *songFilePath = [NSBundle.mainBundle pathForResource:@"prettygirl" ofType:@"mp3"];
    self.songFileURL = [[NSURL alloc] initFileURLWithPath:songFilePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.songFileURL error:nil];
    
    [self updateSongProgress];
    
    self.songData = [LyricParser parseFromFile:[NSBundle.mainBundle pathForResource:@"prettygirl-midico" ofType:@"lrc"]];
    self.lines = self.songData[@"lines"];
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
            self.wordIndex++;
        }
    } else {
        self.lineIndex++;
        self.wordIndex = 0;
    }
}

@end
