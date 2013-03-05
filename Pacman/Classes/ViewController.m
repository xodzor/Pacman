//
//  ViewController.m
//  Pacman
//
//  Created by Артем Шляхтин on 18.02.13.
//  Copyright (c) 2013 Артем Шляхтин. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property(nonatomic, retain)AVAudioPlayer *player;

- (void)prepareSoundWithName:(NSString *)name ofType:(NSString *)type;
- (void)playingSoundInBackground;

- (void)startGame;
- (void)stopGame;
- (void)updateGame;
- (void)gestureTapPause;

@end


#pragma mark -

@implementation ViewController

@synthesize startButton, statusGame, player, scoresGame;


#pragma mark - System Event

- (void)dealloc
{
    [startButton release];
    [statusGame release];
    [player release];
    [scoresGame release];
    
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isEndGame = YES;
    
    MapView *mapView = (MapView *)self.view;
    mapView.delegate = self;
    
    if ([UIScreen mainScreen].bounds.size.height == 568) {
        startButton.hidden = YES;
        statusGame.hidden = NO;
        statusGame.text = @"iPhone 5 будет поддерживаться позже =)";
    } else {
        UIImage *buttonImage = [UIImage imageNamed:@"buttonWhite.png"];
        UIEdgeInsets insets = UIEdgeInsetsMake(0, ceilf(buttonImage.size.width / 2), 0, ceilf(buttonImage.size.width / 2));
        [startButton setBackgroundImage:[buttonImage resizableImageWithCapInsets:insets] forState:UIControlStateNormal];
    }
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTapPause)];
    [self.view addGestureRecognizer:gesture];
    [gesture release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gestureTapPause) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidEnterBackgroundNotification];
    
    [super viewWillDisappear:animated];
}


#pragma mark - Actions

- (void)gameStartStop:(id)sender
{
    UIImageView *background = (UIImageView *)[self.view viewWithTag:200];
    
    if (!isPlaying) {
        if (![statusGame isHidden]) { [statusGame setHidden:YES]; }
        
        [UIView animateWithDuration:0.25 animations:^{
            [startButton setHidden:YES];
            background.alpha = 0;
        } completion:^(BOOL finished) {
            [startButton setHidden:YES];
            [background setHidden: YES];
        }];
        
        if (isEndGame) {
            isEndGame = NO;
            
            [startButton setTitle:@"Продолжить" forState:UIControlStateNormal];
            
            [self prepareSoundWithName:@"intro" ofType:@"wav"];
            [self playingSoundInBackground];
        } else {
            [self startGame];
        }
        
    } else {
        
        [UIView animateWithDuration:0.25 animations:^{
            [startButton setHidden:NO];
            [background setHidden: NO];
            background.alpha = 1.0;
        }];
        
        [self stopGame];
    }
}


#pragma mark - Private


- (void)prepareSoundWithName:(NSString *)name ofType:(NSString *)type
{
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSURL *file = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
    newPlayer.delegate = self;
    self.player = newPlayer;
    
    [file release];
    [newPlayer release];
}


- (void)playingSoundInBackground
{
    dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dispatchQueue, ^{
        [player prepareToPlay];
        [player play];
    });
}


- (void)startGame
{
    isPlaying = YES;
    
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:UpdateInterval target:self selector:@selector(updateGame) userInfo:nil repeats:YES];
}


- (void)stopGame
{
    isPlaying = NO;
    
    MapView *mapView = (MapView *)self.view;
    [mapView.pacman stopAnimating];
    
    if (gameTimer) {
        [gameTimer invalidate];
        gameTimer = nil;
    }
}


- (void)updateGame
{
    MapView *mapView = (MapView *)self.view;
    [mapView updateLifeCicle];
}


#pragma mark - Audio Player Delegate


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //Звук воспроизводится в фоне, вызов должен происходить от главного потока
    if (!isEndGame) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startGame];
        });
    }
}


#pragma mark - Map Delegate


- (void)mapViewGamePause:(BOOL)state withShowMenu:(BOOL)showMenu
{
    if (showMenu) {
        [self gameStartStop:nil];
    } else {
        if (state) {
            [self stopGame];
        } else {
            [self startGame];
        }
    }
}


- (void)gestureTapPause
{
    if (isPlaying) {
        [self mapViewGamePause:YES withShowMenu:YES];
    }
}


- (void)mapViewUpdateScores:(NSInteger)scores
{
    NSString *format = [[NSString alloc] initWithFormat:@"Очки: %u",scores];
    [scoresGame setText:format];
    [format release];
}


-(void)mapViewGameEnd:(BOOL)win;
{
    isEndGame = YES;
    
    if (win) {
        [self prepareSoundWithName:@"Complete" ofType:@"mp3"];
        [statusGame setText:@"Вы выиграли"];
    } else {
        [self prepareSoundWithName:@"Die" ofType:@"mp3"];
        [statusGame setText:@"Вас загробастали приведения 👻"];
    }
    [player setVolume:0.4f];
    [self playingSoundInBackground];
    
    [statusGame setHidden:NO];
    [startButton setTitle:@"Повторить" forState:UIControlStateNormal];
    
    [self mapViewGamePause:YES withShowMenu:YES];
    
    UIImageView *background = (UIImageView *)[self.view viewWithTag:200];
    for (UIView *item in self.view.subviews) {
        if (![item isKindOfClass:[UILabel class]] && ![item isKindOfClass:[UIButton class]] && ![item isEqual:background]) {
            [item removeFromSuperview];
        }
    }
    
    [self.view setNeedsDisplay];
}


@end
