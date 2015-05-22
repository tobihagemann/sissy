//
//  THSettings.h
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, THFetchNewGradeResultsOption) {
	THFetchNewGradeResultsEvery15Minutes,
	THFetchNewGradeResultsEvery30Minutes,
	THFetchNewGradeResultsHourly
};

@interface THSettings : NSObject

@property (nonatomic, weak) NSDate *lastFetchDate;
@property (nonatomic, assign) THFetchNewGradeResultsOption fetchNewGradeResultsSetting;
@property (nonatomic, weak) NSString *username;
@property (nonatomic, weak) NSString *password;
@property (nonatomic, weak) NSString *lastHashedResults;
@property (nonatomic, readonly, getter=loggedIn) BOOL loggedIn;

+ (instancetype)sharedInstance;
- (void)reset;

@end
