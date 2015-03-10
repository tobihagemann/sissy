//
//  NSString+SissyExtensions.h
//  sissy
//
//  Created by Tobias Hagemann on 10/03/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SissyExtensions)

+ (NSString *)formURLEncodeHTTP5Parameters:(NSDictionary *)parameters;
- (NSString *)sha1;

@end
