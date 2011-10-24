//
//  OldSchoolBreakoutAppDelegate.h
//  OldSchoolBreakout
//
//  Created by Guilherme da Silva Mello on 10/24/11.
//  Copyright Guimello Tecnologia 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface OldSchoolBreakoutAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
