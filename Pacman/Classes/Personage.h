//
//  Hero.h
//  Pacman
//
//  Created by Артем Шляхтин on 18.02.13.
//  Copyright (c) 2013 Артем Шляхтин. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@protocol PersonageDelegate;

@interface Personage : UIImageView <UIAccelerometerDelegate>
{
    CGFloat speed;
    CGFloat timeToRelax;
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    GameMove lastMove;
    BOOL isBusy;
}

@property (nonatomic) CGFloat speed;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGFloat timeToRelax;
@property (nonatomic, assign) id<PersonageDelegate> delegate;

- (void)moveToPoint;
- (void)moveTo:(GameMove)personageMove;
- (void)respam;
- (void)stopMove;

@end



@protocol PersonageDelegate <NSObject>

@end