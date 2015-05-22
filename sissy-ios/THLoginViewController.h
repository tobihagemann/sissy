//
//  THLoginViewController.h
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import <XLForm/XLForm.h>

typedef void (^THLoginCallback)(NSString *username, NSString *password, NSString *gradeResults);

@interface THLoginViewController : XLFormViewController

@property (nonatomic, strong) THLoginCallback callback;

@end
