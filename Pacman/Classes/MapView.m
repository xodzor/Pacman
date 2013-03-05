//
//  MapView.m
//  Pacman
//
//  Created by Артем Шляхтин on 22.02.13.
//  Copyright (c) 2013 Артем Шляхтин. All rights reserved.
//

#import "MapView.h"

#import "Constants.h"
#import "UIImageView+Mushroom.h"

@interface MapView ()

@property(nonatomic, retain)NSArray *map;
@property(nonatomic, retain)NSMutableArray *arrayPea;
@property(nonatomic, retain)NSMutableArray *arrayGhost;
@property(nonatomic, retain)NSMutableArray *arrayLife;
@property(nonatomic, retain)AVAudioPlayer *player;
@property(nonatomic, retain)AVAudioPlayer *eatPea;

- (void)initGame;
- (BOOL)canMove:(GameItem)item;
- (void)prepareSoundWithName:(NSString *)name ofType:(NSString *)type;

@end


#pragma mark -

@implementation MapView

@synthesize pacman, map, arrayGhost, arrayPea, arrayLife, player, delegate, eatPea;


#pragma mark - System Event

- (void)dealloc
{
    [self setDelegate:nil];
    
    [eatPea release];
    [pacman release];
    [map release];
    [arrayGhost release];
    [arrayPea release];
    [arrayLife release];
    [player release];
    
    [super dealloc];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initGame];
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect
{
    scores = 0;
    if ([delegate respondsToSelector:@selector(mapViewUpdateScores:)]) {
        [delegate mapViewUpdateScores:scores];
    }
    
    [arrayGhost removeAllObjects];
    [arrayPea removeAllObjects];
    [arrayLife removeAllObjects];
    
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (unsigned y = 0; y < [map count]; y++) {
        for (unsigned x = 0; x < [map[y] count]; x++) {
            NSInteger valueFromCoordinate = [map[y][x] integerValue];
            
            if (valueFromCoordinate == 1 || valueFromCoordinate == 5) {
                UIImageView * wall = [[UIImageView alloc] initWithFrame:CGRectMake(x * itemSize, y * itemSize, itemSize, itemSize)];
                wall.image = [UIImage imageNamed:@"rnd.png"];
                
                [self insertSubview:wall atIndex:0];
                [wall release];
                
                //CGRect wall = CGRectMake(x * itemSize, y * itemSize, itemSize, itemSize);
                //CGContextAddRect(context, wall);
            }
            
            if (valueFromCoordinate == 2 || valueFromCoordinate == 3 || valueFromCoordinate == 23) {
                UIImageView * pea = [[UIImageView alloc] initWithFrame:CGRectMake(x * itemSize, y * itemSize, itemSize, itemSize)];
                pea.contentMode = UIViewContentModeCenter;
                
                if (valueFromCoordinate == 23) {
                    UIImage *imageMushroom = [UIImage imageNamed:@"Mushroom.png"];
                    pea.image = [UIImage imageWithCGImage:imageMushroom.CGImage scale:3.5 orientation:UIImageOrientationUp];
                } else {
                    pea.image = [UIImage imageNamed:@"pea.png"];
                }
                
                [self insertSubview:pea atIndex:0];
                [arrayPea addObject:pea];
                [pea release];
            }
            
            if (valueFromCoordinate == 3) {
                Personage *ghost = [[Personage alloc] initWithFrame:CGRectMake(x * personageSize, y * personageSize, personageSize, personageSize)];
                ghost.image = [UIImage imageNamed:@"Ghost.png"];
                ghost.speed = speedGhost * UpdateInterval;
                
                ghost.startPoint = ghost.frame.origin;
                ghost.delegate = self;
                ghost.timeToRelax = (arc4random()%50);
                
                UIImageView *background = (UIImageView *)[self viewWithTag:200];
                [self insertSubview:ghost belowSubview:background];
                [arrayGhost addObject:ghost];
                
                [ghost release];
            }
            
            if (valueFromCoordinate == 4) {
                Personage *hero = [[Personage alloc] initWithFrame:CGRectMake(x * personageSize, y * personageSize, personageSize, personageSize)];
                hero.image = [UIImage imageNamed:@"PacmanEat.png"];
                hero.animationImages = @[hero.image, [UIImage imageNamed:@"Pacman"]];
                
                hero.speed = speedPacman * UpdateInterval;
                
                hero.startPoint = hero.frame.origin;
                hero.delegate = self;
                
                [self setPacman:hero];
                
                if (arrayGhost != nil) {
                    [self insertSubview:pacman belowSubview:[arrayGhost objectAtIndex:0]];
                } else {
                    UIImageView *background = (UIImageView *)[self viewWithTag:200];
                    [self insertSubview:pacman belowSubview:background];
                }
                
                [hero release];
            }
            
            if ((y == 0) & (x == 22 || x == 23)) {
                UIImageView * life = [[UIImageView alloc] initWithFrame:CGRectMake(x * itemSize, y * itemSize, itemSize, itemSize)];
                life.contentMode = UIViewContentModeCenter;
                life.image = [UIImage imageNamed:@"life.png"];
                
                UIImageView *background = (UIImageView *)[self viewWithTag:200];
                [self insertSubview:life belowSubview:background];
                [arrayLife addObject:life];
                
                [life release];
            }
        }
    }
    
    //CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
    //CGContextFillPath(context);
}


#pragma mark - Private

- (void)initGame
{
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"eat" ofType:@"wav"];
    NSURL *file = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
    self.eatPea = newPlayer;
    
    [file release];
    [newPlayer release];
    
    
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"level1" ofType:@"map"]];
    self.map = array;
    [array release];
    
    NSMutableArray *ghosts = [[NSMutableArray alloc] init];
    self.arrayGhost = ghosts;
    [ghosts release];
    
    NSMutableArray *peas = [[NSMutableArray alloc] init];
    self.arrayPea = peas;
    [peas release];
    
    NSMutableArray *lifes = [[NSMutableArray alloc] init];
    self.arrayLife = lifes;
    [lifes release];
    
    UIAccelerometer *accelerometr = [UIAccelerometer sharedAccelerometer];
    accelerometr.updateInterval = AccelerometerInterval;
    accelerometr.delegate = self;
    
    timeToFear = 0.0;
}


- (void)respamUnit
{
    for (Personage *ghost in arrayGhost) { [ghost respam]; }
    [pacman respam];
}


- (void)prepareSoundWithName:(NSString *)name ofType:(NSString *)type
{
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSURL *file = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    
    AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
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


- (BOOL)canMove:(GameItem)item
{
    switch (item) {
        case GameItemWall:
            return NO;
            break;
            
        default:
            break;
    }
    
    return YES;
}


- (GameItem)gameItemFromPoint:(CGPoint)p
{
    NSInteger x = floorf(p.x / itemSize);
    NSInteger y = floorf(p.y / itemSize);
    
    NSInteger item = [map[y][x] integerValue];
    
    switch (item) {
        case 1:
            return GameItemWall;
            break;
            
        default:
            break;
    }
    
    return GameItemNone;
}


#pragma mark - Actions


- (BOOL)canMoveTo:(CGPoint)center
{
    CGFloat half = personageSize / 2;
    
    CGSize sizeApp = [[UIScreen mainScreen] applicationFrame].size;
    
    if (center.x < half || center.x > sizeApp.height - half) {
        return NO;
    }
    
    if (center.y < half || center.y > sizeApp.width - half) {
        return NO;
    }
    
    NSInteger indent = 1;
    
    GameItem topLeft = [self gameItemFromPoint:CGPointMake(center.x - half + indent, center.y - half + indent)];
    GameItem topRight = [self gameItemFromPoint:CGPointMake(center.x + half - indent, center.y - half + indent)];
    GameItem bottomLeft = [self gameItemFromPoint:CGPointMake(center.x - half + indent, center.y + half - indent)];
    GameItem bottomRight = [self gameItemFromPoint:CGPointMake(center.x + half - indent, center.y + half - indent)];
    
    if (![self canMove:topLeft] || ![self canMove:topRight] || ![self canMove:bottomLeft] || ![self canMove:bottomRight]) {
        return NO;
    }
    
    return YES;
}


- (void)updateLifeCicle
{
    [pacman moveTo:pacmanMove];
    
    CGRect framePacman = pacman.frame;
    
    NSMutableArray *deleteObjects = [[NSMutableArray alloc] init];
    
    for (UIImageView *pea in arrayPea) {
        CGRect framePea = CGRectMake(pea.center.x - 1, pea.center.y - 1, 2, 2);
        
        if (CGRectIntersectsRect(framePacman, framePea)) {
            
            if ([pea isMushroom]) {
                
                [self prepareSoundWithName:@"eyes" ofType:@"wav"];
                [player setVolume:0.4];
                [self playingSoundInBackground];
                
                timeToFear = ghostFear;
                
                pacman.image = [UIImage imageNamed:@"AngryPacmanEat.png"];
                pacman.animationImages = @[pacman.image, [UIImage imageNamed:@"AngryPacman"]];
                
                [self playingSoundInBackground];
                
                for (Personage *ghost in arrayGhost) {
                    [ghost stopMove];
                    [ghost setSpeed:speedPacman * UpdateInterval];
                }
                
                //NSLog(@"Глюки от гриба!");
            } else {
                dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(dispatchQueue, ^{
                    [eatPea prepareToPlay];
                    [eatPea play];
                });
            }
            
            scores += scoreAmount;
            if ([delegate respondsToSelector:@selector(mapViewUpdateScores:)]) {
                [delegate mapViewUpdateScores:scores];
            }
            
            [pea removeFromSuperview];
            [deleteObjects addObject:pea];
            
//            #warning Обратить внимание!
//            [arrayPea removeObject:pea];
        }
    }
    
    [arrayPea removeObjectsInArray:deleteObjects];
    
    if (![arrayPea count]) {
        
        if ([delegate respondsToSelector:@selector(mapViewGameEnd:)]) {
            [delegate mapViewGameEnd:YES];
        }
    }
    
    [deleteObjects removeAllObjects];
    
    for (Personage *ghost in arrayGhost) {
        CGRect frameGhost = CGRectMake(ghost.center.x - 1, ghost.center.y - 1, 2, 2);
        
        if (CGRectIntersectsRect(framePacman, frameGhost)) {
            //Если персонажа скушали
            if (timeToFear <= 0) {
                
                if (![arrayLife count]) {
                    if ([delegate respondsToSelector:@selector(mapViewGameEnd:)]) {
                        [delegate mapViewGameEnd:NO];
                    }
                } else {
                    UIImageView *life = [arrayLife objectAtIndex:0];
                    [life removeFromSuperview];
                    [arrayLife removeObject:life];
                
                    if ([delegate respondsToSelector:@selector(mapViewGamePause:withShowMenu:)]) {
                        [delegate mapViewGamePause:YES withShowMenu:NO];
                    }
                
                    [self prepareSoundWithName:@"Die" ofType:@"mp3"];
                    [player setDelegate:self];
                    [player setVolume:0.4];
                    [self playingSoundInBackground];
                    [self performSelector:@selector(respamUnit) withObject:nil afterDelay:1.0];
                }
            } else {
                scores += scoreAmount;
                
                [self prepareSoundWithName:@"eatghost" ofType:@"wav"];
                [player setVolume:0.4];
                [self playingSoundInBackground];
                
                if ([delegate respondsToSelector:@selector(mapViewUpdateScores:)]) {
                    [delegate mapViewUpdateScores:scores];
                }
                
                [ghost removeFromSuperview];
                [deleteObjects addObject:ghost];
            }
        }
        
        if (timeToFear <= 0.0) {
        
            if (ghost.timeToRelax > relaxTime) {
                [ghost setEndPoint:pacman.center];
            } else if (ghost.timeToRelax > 0) {
                [ghost setEndPoint:ghost.startPoint];
            } else {
                //Сбрасываем таймер
                ghost.timeToRelax = (arc4random()%50);
            }
        
            ghost.timeToRelax -= UpdateInterval;
            [ghost moveToPoint];
            
        } else {
            
            NSInteger x = floorf(ghost.center.x / itemSize);
            NSInteger y = floorf(ghost.center.y / itemSize);
            
            if (ghost.frame.origin.x >= pacman.frame.origin.x) {
                x += 1;
            } else if (ghost.frame.origin.x < pacman.frame.origin.x) {
                x -= 1;
            }
            
            if (ghost.frame.origin.y >= pacman.frame.origin.y) {
                y += 1;
            } else if (ghost.frame.origin.y < pacman.frame.origin.y) {
                y -= 1;
            }
            
            CGFloat half = ghost.frame.size.width / 2;
            [ghost setEndPoint:CGPointMake(x * itemSize + half, y * itemSize + half)];
            [ghost moveToPoint];
        }
    }
    
    [arrayGhost removeObjectsInArray:deleteObjects];
    [deleteObjects release];
    
    if (timeToFear > 0) {
        timeToFear -= UpdateInterval;
        
        if (timeToFear <= 0) {
            //Вернуть Пакмена в нормальное состояние
            
            for (Personage *ghost in arrayGhost) { ghost.speed = speedGhost * UpdateInterval; }
            
            pacman.image = [UIImage imageNamed:@"PacmanEat.png"];
            pacman.animationImages = @[pacman.image, [UIImage imageNamed:@"Pacman"]];
            
            [self prepareSoundWithName:@"eyes" ofType:@"wav"];
            [player setVolume:0.4];
            [self playingSoundInBackground];
        }
    }
}


#pragma mark - Accelerometer Delegate


- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    GameMove move = GameMoveNone;
    
    if (fabs(acceleration.x) > fabs(acceleration.y)) {
        if (acceleration.x > Slope) { move = GameMoveBottom; }
        else if (acceleration.x < -Slope) { move = GameMoveTop; }
    } else {
        
        if (acceleration.y > Slope) { move = GameMoveRight; }
        else if (acceleration.y < -Slope) { move = GameMoveLeft; }
    }

    pacmanMove = move;
}


#pragma mark - Audio Player Delegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [delegate mapViewGamePause:NO withShowMenu:NO];
    });
}

@end
