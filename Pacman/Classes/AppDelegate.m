//
//  AppDelegate.m
//  Pacman
//
//  Created by Артем Шляхтин on 18.02.13.
//  Copyright (c) 2013 Артем Шляхтин. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

@end
