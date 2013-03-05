//
//  Constants.h
//  Pacman
//
//  Created by Артем Шляхтин on 18.02.13.
//  Copyright (c) 2013 Артем Шляхтин. All rights reserved.
//

#ifndef Pacman_Constants_h
#define Pacman_Constants_h

#define Slope 0.0f
#define UpdateInterval 1.0/30.0
#define AccelerometerInterval 1.0/10.0

#define itemSize 20
#define personageSize 20
#define peaSize 15

#define speedPacman 50
#define speedGhost 40

#define ghostFear 5.0
#define relaxTime 7.0

#define scoreAmount 25

typedef enum{
    GameMoveLeft,
    GameMoveRight,
    GameMoveTop,
    GameMoveBottom,
    GameMoveNone
}GameMove;

typedef enum{
    GameItemWall,
    GameItemNone
}GameItem;

typedef struct {
    CGFloat speed;
    GameMove move;
} PacmanMove;

#endif
