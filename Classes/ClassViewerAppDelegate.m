//
//  ClassViewerAppDelegate.m
//  ClassViewer
//
//  Created by mtakagi on 10/10/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ClassViewerAppDelegate.h"
#import "ClassRootViewController.h"
#import "ProtocolRootViewController.h"

@implementation ClassViewerAppDelegate

@synthesize window;
@synthesize tabBarController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // View Controller とそれぞれの Navigation Controller を作成。
	ClassRootViewController *classViewController = [[ClassRootViewController alloc] initWithNibName:nil bundle:nil];
	ProtocolRootViewController *protocolViewController = [[ProtocolRootViewController alloc] initWithNibName:nil bundle:nil];
	UINavigationController *classNavigationController = [[UINavigationController alloc] initWithRootViewController:classViewController];
	UINavigationController *protocolNavigationController = [[UINavigationController alloc] initWithRootViewController:protocolViewController];
	NSArray *array = [NSArray arrayWithObjects:classNavigationController, protocolNavigationController, nil];
	
	// Tab Bar の作成と設定。
	UITabBarItem *classTabItem = [[UITabBarItem alloc] initWithTitle:@"Class" image:nil tag:0];
	UITabBarItem *protocolTabItem = [[UITabBarItem alloc] initWithTitle:@"Protocol" image:nil tag:1];
	
	classNavigationController.tabBarItem = classTabItem;
	protocolNavigationController.tabBarItem = protocolTabItem;
	
	// Navigation Bar のスタイルを設定。
	classNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	protocolNavigationController.navigationBar.barStyle = UIBarStyleBlack;
	
	// Tab Bar Controller を作成し View Controllers を追加。
	tabBarController = [[UITabBarController alloc] init];
	tabBarController.viewControllers = array;
	
	// Window の作成と View を追加し Window の表示。
	window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = tabBarController;
    [window makeKeyAndVisible];
	
	// 開放。
	[classViewController release];
	[protocolViewController release];
	[classNavigationController release];
	[protocolNavigationController release];
	[classTabItem release];
	[protocolTabItem release];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[tabBarController release];
	[window release];
	[super dealloc];
}


@end

