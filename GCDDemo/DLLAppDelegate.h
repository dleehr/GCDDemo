//
//  DLLAppDelegate.h
//  GCDDemo
//
//  Created by Dan Leehr on 4/1/13.
//  Copyright (c) 2013 Dan Leehr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLLViewController;

@interface DLLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DLLViewController *viewController;

@end
