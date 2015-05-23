//
//  THNotificationView.m
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THNotificationView.h"

@implementation THNotificationView

+ (void)showSuccessInViewController:(UIViewController *)viewController message:(NSString *)message {
	[self showInViewController:viewController tintColor:[UIColor colorWithRed:0.21 green:0.72 blue:0.0 alpha:1.0] image:[UIImage imageNamed:@"1040-checkmark-selected"] message:message duration:2.0];
}

+ (void)showInfoInViewController:(UIViewController *)viewController message:(NSString *)message {
	[self showInViewController:viewController tintColor:[UIColor colorWithRed:0.0 green:0.6 blue:1.0 alpha:1.0] image:[UIImage imageNamed:@"724-info-selected"] message:message duration:2.0];
}

+ (void)showWarningInViewController:(UIViewController *)viewController message:(NSString *)message {
	[self showInViewController:viewController tintColor:[UIColor orangeColor] image:[UIImage imageNamed:@"791-warning-selected"] message:message duration:2.0];
}

+ (void)showErrorInViewController:(UIViewController *)viewController message:(NSString *)message {
	[self showInViewController:viewController tintColor:[UIColor redColor] image:[UIImage imageNamed:@"791-warning-selected"] message:message duration:2.0];
}

@end
