//
//  SYPlayVC.m
//  KLIANSLiveDemo
//
//  Created by KLIANS on 16/12/5.
//  Copyright © 2016年 KLIAN. All rights reserved.
//

#import "SYPlayVC.h"
#import <IJKMediaFramework/IJKMediaFramework.h>



@interface SYPlayVC ()

@property (atomic, retain) id <IJKMediaPlayback> player;
@property (weak, nonatomic) UIView *PlayerView;


//礼物冒泡
@property (strong,nonatomic) NSTimer *bubblingTime;
@property (strong,nonatomic) NSArray *images;

@end

@implementation SYPlayVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //直播视频
    _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:nil];
    
    UIView *playerView = [self.player view];
    
    UIView *displayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.PlayerView = displayView;
    self.PlayerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.PlayerView];
    
    playerView.frame = self.PlayerView.bounds;
    playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.PlayerView insertSubview:playerView atIndex:1];
    [_player setScalingMode:IJKMPMovieScalingModeAspectFill];
    [self installMovieNotificationObservers];
    
    
    UIButton *playAndStopBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-40, self.view.frame.size.height-80, 80, 30)];
    playAndStopBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [playAndStopBtn setTitle:@"播放/暂停" forState:(UIControlStateNormal)];
    [playAndStopBtn addTarget:self action:@selector(playOrStop) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:playAndStopBtn];
    
    
    //礼物冒泡
    _images = @[@"ic_menu_bluepig",
                @"ic_menu_bluepig2",
                @"ic_menu_greenpig",
                @"ic_menu_greenpig2",
                @"ic_menu_pinkpig",
                @"ic_menu_pinkpig2",
                @"ic_menu_purplepig",
                @"ic_menu_purplepig2",
                @"ic_menu_yellowpig",
                @"ic_menu_yellowpig2"];
    
    self.bubblingTime =  [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(bubbingLove) userInfo:nil repeats:YES]; ;
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.player pause];
    self.player = nil;
    
    [self.bubblingTime invalidate];
    self.bubblingTime = nil;
}

-(void)bubbingLove{
    [[Bubbling new] bubbingImage:[UIImage imageNamed:@"love"] View:self.view];
    [[Bubbling new] bubbingImages:_images View:self.view];
}

//播放/暂停
-(void)playOrStop{
    if (![self.player isPlaying]) {
        [self.player play];
    }else{
        [self.player pause];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    if (![self.player isPlaying]) {
        [self.player prepareToPlay];
    }
}


- (void)loadStateDidChange:(NSNotification*)notification {
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"LoadStateDidChange: IJKMovieLoadStatePlayThroughOK: %d\n",(int)loadState);
    }else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackFinish:(NSNotification*)notification {
    int reason =[[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification {
    NSLog(@"mediaIsPrepareToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    switch (_player.playbackState) {
        case IJKMPMoviePlaybackStateStopped:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePlaying:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStatePaused:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
            
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
            
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma Install Notifiacation

- (void)installMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
}

- (void)removeMovieNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:_player];
    
}

-(void)dealloc{
    [self.player pause];
    self.player = nil;
    
    [self.bubblingTime invalidate];
    self.bubblingTime = nil;
}


@end
