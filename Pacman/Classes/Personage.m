//
//  Hero.m
//  Pacman
//
//  Created by Артем Шляхтин on 18.02.13.
//  Copyright (c) 2013 Артем Шляхтин. All rights reserved.
//

#import "Personage.h"
#import "MapView.h"

@interface Personage ()

@end


#pragma mark -

@implementation Personage

@synthesize startPoint;
@synthesize endPoint;
@synthesize timeToRelax;
@synthesize delegate;
@synthesize speed;


#pragma mark - System Event

- (void)dealloc
{
    [self setDelegate:nil];
    
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.animationDuration = .4;
        lastMove = GameMoveNone;
        isBusy = NO;
    }
    return self;
}


#pragma mark - Actions

- (void)moveToPoint
{
    if (lastMove == GameMoveNone) { lastMove = GameMoveTop; }
    
    CGPoint center = self.center;
    MapView *mapView = (MapView *)self.delegate;
    BOOL canMove = NO;
    GameMove currentMove = lastMove;
    float currentSpeed = (currentMove == GameMoveTop || currentMove == GameMoveLeft) ? -speed : speed;
    
    
    if (currentMove == GameMoveTop || currentMove == GameMoveBottom) {
        if (roundf(center.x) != roundf(endPoint.x) || roundf(center.y) != roundf(endPoint.y)) {
        
            BOOL moveToForward = [mapView canMoveTo:CGPointMake(center.x, center.y + currentSpeed)];
        
            if (center.x != endPoint.x || !moveToForward) {
                if (center.x < endPoint.x ) {
                    //Вправо
                    center.x += speed;
                    if (center.x > endPoint.x) { center.x = endPoint.x; }
                
                    lastMove = GameMoveRight;
                } else {
                    //Влево
                    center.x -= speed;
                    if (center.x < endPoint.x) { center.x = endPoint.x; }
                
                    lastMove = GameMoveLeft;
                }
            
                canMove = [mapView canMoveTo:center];
            }
            
            if (!canMove) {
                center.x = self.center.x;
                lastMove = (currentMove == GameMoveTop) ? GameMoveTop : GameMoveBottom;
            
                if (!moveToForward) {
                    lastMove = (currentMove == GameMoveTop) ? GameMoveBottom : GameMoveTop;
                } else {
                    center.y += currentSpeed;
                }
            }
        } else {
            isBusy = NO;
        }
    }
    
    
    if (currentMove == GameMoveLeft || currentMove == GameMoveRight) {
        if (roundf(center.x) != roundf(endPoint.x) || roundf(center.y) != roundf(endPoint.y)) {
        
            BOOL moveToForward = [mapView canMoveTo:CGPointMake(center.x + currentSpeed, center.y)];
        
            if (center.y != endPoint.y || !moveToForward) {
                if (center.y < endPoint.y) {
                    //Вниз
                    center.y += speed;
                    if (center.y > endPoint.y) { center.y = endPoint.y; }
                
                    lastMove = GameMoveBottom;
                } else {
                    //Вверх
                    center.y -= speed;
                    if (center.y < endPoint.y) { center.y = endPoint.y; }
                
                    lastMove = GameMoveTop;
                }
            
                canMove = [mapView canMoveTo:center];
            }
        
            if (!canMove) {
                center.y = self.center.y;
                lastMove = (currentMove == GameMoveLeft) ? GameMoveLeft : GameMoveRight;
            
                if (!moveToForward) {
                    lastMove = (currentMove == GameMoveLeft) ? GameMoveRight : GameMoveLeft;
                } else {
                    center.x += currentSpeed;
                }
            }
            
        } else {
            isBusy = NO;
        }
    }
    
    self.center = center;
    return;
}


- (void)moveTo:(GameMove)personageMove
{
    if (!isBusy) {
    
    
        if (personageMove == GameMoveNone) {
            if ([self isAnimating]) { [self stopAnimating]; }
            return;
        }
    
        CGAffineTransform rotate = CGAffineTransformIdentity;
        CGPoint center = [self center];
        CGPoint middle = CGPointZero;
        
        CGFloat half = self.frame.size.width / 2;
        CGSize sizeApp = [[UIScreen mainScreen] applicationFrame].size;
        
        lastMove = personageMove;
        NSInteger correctX = 0;
        NSInteger correctY = 0;
    
        switch (personageMove) {
            case GameMoveLeft:
                center.x -= speed;
                middle = CGPointMake(center.x - half, center.y);
                rotate = CGAffineTransformMakeScale(-1, 1);
                correctX = 1;
            break;
            
            case GameMoveRight:
                center.x += speed;
                middle = CGPointMake(center.x + half, center.y);
                rotate = CGAffineTransformMakeScale(1, 1);
                correctX = -1;
            break;
            
            case GameMoveTop:
                center.y -= speed;
                middle = CGPointMake(center.x, center.y - half);
                rotate = CGAffineTransformMakeRotation(-M_PI/2);
                correctY = 1;
            break;
            
            case GameMoveBottom:
                center.y += speed;
                middle = CGPointMake(center.x, center.y + half);
                rotate = CGAffineTransformMakeRotation(M_PI/2);
                correctY = -1;
            break;
            
            default:
                break;
        }
    
        if (center.x < 0 + half) {
            center.x = sizeApp.height - half;
        } else if (center.x > sizeApp.height - half){
            center.x = half;
        } else if (center.y < half) {
            center.y = sizeApp.width - half;
        } else if (center.y > sizeApp.width - half) {
            center.y = half;
        }
    
        MapView *mapView = (MapView *)self.delegate;
        BOOL canMove = [mapView canMoveTo:center];
    
        if (canMove) {
            if (![self isAnimating]) { [self startAnimating]; }
            [self setTransform:rotate];
        
            self.center = center;
            [self setNeedsDisplay];
        } else {
        
            BOOL wall = ([mapView gameItemFromPoint:middle] != GameItemWall) ? YES : NO;
        
            if (wall) {
                NSInteger x = floorf(middle.x / itemSize) + correctX;
                NSInteger y = floorf(middle.y / itemSize) + correctY;
            
                CGPoint turn = CGPointMake(x * itemSize + half, y * itemSize + half);
                self.endPoint = turn;
            
                [self setTransform:rotate];
                [self moveToPoint];
                isBusy = YES;
            } else {
                if ([self isAnimating]) { [self stopAnimating]; }
            }
        }
    } else {
        [self moveToPoint];
    }
}

- (void)respam
{
    isBusy = NO;
    
    CGRect frame = [self frame];
    frame.origin = startPoint;
    self.frame = frame;
    
    CGAffineTransform rotate = CGAffineTransformMakeScale(1, 1);
    [self setTransform:rotate];
    
    lastMove = GameMoveNone;
}

- (void)stopMove
{
    lastMove = GameMoveNone;
}


@end
