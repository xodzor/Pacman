//
//  ViewController.h
//  Pacman
//
//  Created by Артем Шляхтин on 18.02.13.
//  Copyright (c) 2013 Артем Шляхтин. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapView.h"

@interface ViewController : UIViewController <MapViewDelegate, AVAudioPlayerDelegate>
{
    NSTimer *gameTimer;
    BOOL isPlaying;
    BOOL isEndGame;
    
    UIButton *startButton;
    UILabel *statusGame;
    UILabel *scoresGame;
    
    AVAudioPlayer *player;
}

@property (nonatomic, retain) IBOutlet UIButton *startButton;
@property (nonatomic, retain) IBOutlet UILabel *statusGame;
@property (nonatomic, retain) IBOutlet UILabel *scoresGame;

- (IBAction)gameStartStop:(id)sender;

@end
