//
//  THSissyController.h
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface THSissyController : NSObject

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password;
- (void)runPeriodiciallyWithInterval:(NSTimeInterval)interval;

@end
