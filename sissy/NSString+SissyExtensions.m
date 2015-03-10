//
//  NSString+SissyExtensions.m
//  sissy
//
//  Created by Tobias Hagemann on 10/03/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "NSString+SissyExtensions.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (SissyExtensions)

+ (NSString *)formURLEncodeHTTP5Parameters:(NSDictionary *)parameters {
	NSMutableString *result = [[NSMutableString alloc] init];
	BOOL isFirst = YES;
	for (NSString *name in parameters) {
		if (!isFirst) {
			[result appendString:@"&"];
		}
		isFirst = NO;
		assert([name isKindOfClass:[NSString class]]);
		NSString *value = parameters[name];
		assert([value isKindOfClass:[NSString class]]);

		NSString *encodedName = [name formURLEncodeHTTP5String];
		NSString *encodedValue = [value formURLEncodeHTTP5String];

		[result appendString:encodedName];
		[result appendString:@"="];
		[result appendString:encodedValue];
	}
	return [result copy];
}

- (NSString *)formURLEncodeHTTP5String {
	CFStringRef charactersToLeaveUnescaped = CFSTR(" ");
	CFStringRef legalURLCharactersToBeEscaped = CFSTR("!$&'()+,/:;=?@~");

	NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, charactersToLeaveUnescaped, legalURLCharactersToBeEscaped, kCFStringEncodingUTF8));
	return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (NSString *)sha1 {
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
		[output appendFormat:@"%02x", digest[i]];
	}
	return output;
}

@end
