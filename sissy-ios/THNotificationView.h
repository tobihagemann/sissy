//
//  THNotificationView.h
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "CSNotificationView.h"

@interface THNotificationView : CSNotificationView

+ (void)showSuccessInViewController:(UIViewController *)viewController message:(NSString *)message;
+ (void)showInfoInViewController:(UIViewController *)viewController message:(NSString *)message;
+ (void)showWarningInViewController:(UIViewController *)viewController message:(NSString *)message;
+ (void)showErrorInViewController:(UIViewController *)viewController message:(NSString *)message;

@end
