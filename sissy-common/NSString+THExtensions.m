//
//  NSString+THExtensions.m
//  sissy-common
//
//  Created by Tobias Hagemann on 10/03/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "NSString+THExtensions.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (THExtensions)

- (NSString *)th_sha1 {
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
