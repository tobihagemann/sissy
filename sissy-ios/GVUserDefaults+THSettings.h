//
//  GVUserDefaults+THSettings.h
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "GVUserDefaults.h"

@interface GVUserDefaults (THSettings)

@property (nonatomic, weak) NSDate *lastFetchDate;
@property (nonatomic, assign) NSInteger fetchMode;
@property (nonatomic, weak) NSString *username;
@property (nonatomic, weak) NSString *lastHashedResults;

@end
