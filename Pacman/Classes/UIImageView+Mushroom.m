//
//  UIImageView+Mushroom.m
//  Pacman
//
//  Created by Артем Шляхтин on 03.03.13.
//  Copyright (c) 2013 Артем Шляхтин. All rights reserved.
//

#import "UIImageView+Mushroom.h"

@implementation UIImageView (Mushroom)

- (BOOL)isMushroom
{
    return ([self.image scale] == 3.5) ? YES : NO;
}

@end
