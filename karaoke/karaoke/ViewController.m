//
//  ViewController.m
//  karaoke
//
//  Created by Kevin Holesh on 4/16/15.
//  Copyright (c) 2015 Broadway Lab. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

@synthesize player = _player,
            songFileURL = _songFileURL,
            nowLabel = _nowLabel,
            onDeckLabel = _onDeckLabel,
            songProgress = _songProgress,
            songProgressTimer = _songProgressTimer,
            playButton = _playButton,
            playing = _playing;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playing = NO;
    
    // Set up the player
    NSString *songFilePath = [NSBundle.mainBundle pathForResource:@"prettygirl" ofType:@"mp3"];
    self.songFileURL = [[NSURL alloc] initFileURLWithPath:songFilePath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.songFileURL error:nil];
    
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
    
    self.songProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
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
}

@end
