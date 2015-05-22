//
//  THSissyService.h
//  sissy-common
//
//  Created by Tobias Hagemann on 10/03/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kTHSissyErrorDomain;

typedef NS_ENUM(NSInteger, SissyErorr) {
	THSissyErrorUnableToRetrieveGradeResultsRelativePath,
	THSissyErrorUnableToRetrieveGradeResultsTableContent
};

typedef void (^THSissyCallback)(NSString *result, NSError *error);

@interface THSissyService : NSObject

+ (void)gradeResultsWithUsername:(NSString *)username password:(NSString *)password callback:(THSissyCallback)callback;

@end
