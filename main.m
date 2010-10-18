//
//  main.m
//  ClassViewer
//
//  Created by mtakagi on 10/10/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	// MainWindow.nib を持っていないので Application の delegate を指定している。
    int retVal = UIApplicationMain(argc, argv, nil, @"ClassViewerAppDelegate");
    [pool release];
    return retVal;
}
