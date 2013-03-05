//
//  MapView.h
//  Pacman
//
//  Created by Артем Шляхтин on 22.02.13.
//  Copyright (c) 2013 Артем Шляхтин. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "Personage.h"

@protocol MapViewDelegate;

@interface MapView : UIView <PersonageDelegate, UIAccelerometerDelegate, AVAudioPlayerDelegate>
{
    NSArray *map;
    NSInteger scores;
    
    Personage *pacman;
    NSMutableArray *arrayGhost;
    NSMutableArray *arrayPea;
    NSMutableArray *arrayLife;
    
    GameMove pacmanMove;
    AVAudioPlayer *player;
    AVAudioPlayer *eatPea;
    
    CGFloat timeToFear;
}

@property(nonatomic, assign)id<MapViewDelegate> delegate;
@property(nonatomic, retain)Personage *pacman;

- (BOOL)canMoveTo:(CGPoint)center;
- (void)updateLifeCicle;
- (GameItem)gameItemFromPoint:(CGPoint)p;

@end

@protocol MapViewDelegate <NSObject>

@optional
- (void)mapViewGameStart;
- (void)mapViewGameEnd:(BOOL)win;
- (void)mapViewGamePause:(BOOL)state withShowMenu:(BOOL)showMenu;
- (void)mapViewUpdateScores:(NSInteger)scores;

@end
