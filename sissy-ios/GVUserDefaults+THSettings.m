//
//  GVUserDefaults+THSettings.m
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "GVUserDefaults+THSettings.h"

@implementation GVUserDefaults (THSettings)

@dynamic lastFetchDate;
@dynamic username;
@dynamic lastHashedResults;

- (NSString *)transformKey:(NSString *)key {
	key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[key substringToIndex:1].uppercaseString];
	return [NSString stringWithFormat:@"THUserDefault%@", key];
}

@end
