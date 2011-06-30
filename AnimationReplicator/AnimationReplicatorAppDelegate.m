//
//  AnimationReplicatorAppDelegate.m
//  AnimationReplicator
//
//  Created by Ling Wang on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimationReplicatorAppDelegate.h"

#import "AnimationReplicatorViewController.h"

@implementation AnimationReplicatorAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.viewController = [[AnimationReplicatorViewController alloc] initWithNibName:@"AnimationReplicatorViewController" bundle:nil]; 
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
