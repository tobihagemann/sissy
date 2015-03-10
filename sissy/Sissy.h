//
//  Sissy.h
//  sissy
//
//  Created by Tobias Hagemann on 10/03/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kSissyErrorDomain;

typedef NS_ENUM(NSInteger, SissyErorr) {
	SissyErrorUnableToRetrieveGradeResultsRelativePath,
	SissyErorrUnableToRetrieveGradeResultsTableContent
};

@interface Sissy : NSObject

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password;
- (void)runPeriodiciallyWithInterval:(NSTimeInterval)interval;

@end
