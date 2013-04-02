//
//  DLLViewController.h
//  GCDDemo
//
//  Created by Dan Leehr on 4/1/13.
//  Copyright (c) 2013 Dan Leehr LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLLViewController : UIViewController

- (IBAction)dispatchButtonTapped:(id)sender;
- (IBAction)notificationButtonTapped:(id)sender;

@property (nonatomic, strong) IBOutlet UILabel *label;

@end
