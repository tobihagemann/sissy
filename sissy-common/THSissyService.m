//
//  THSissyService.m
//  sissy-common
//
//  Created by Tobias Hagemann on 10/03/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THSissyService.h"

#import <AFNetworking/AFNetworking.h>
#import "NSString+THExtensions.h"

NSString *const kTHSissyErrorDomain = @"SissyErrorDomain";

@implementation THSissyService

+ (void)checkGradeResultsWithUsername:(NSString *)username password:(NSString *)password callback:(THSissyCallback)callback {
	NSParameterAssert(username);
	NSParameterAssert(password);
	NSParameterAssert(callback);
	[THSissyService loginWithUsername:username password:password callback:^(NSString *gradeResultsRelativePath, NSError *error) {
		if (error) {
			callback(nil, error);
		} else {
			[THSissyService gradeResultsWithRelativePath:gradeResultsRelativePath callback:callback];
		}
	}];
}

#pragma mark - Login

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password callback:(THSissyCallback)callback {
	NSParameterAssert(username);
	NSParameterAssert(password);
	NSParameterAssert(callback);
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	[manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, id parameters, NSError *__autoreleasing *error) {
		// This is pretty hacky, because the parameters query HAS TO BE in the correct order. Otherwise the server would respond with "invalid command".
		// That's why the parameters query is hard-coded.
		return [NSString stringWithFormat:@"DokID=DiasSWeb&SID=&ADias2Dction=ExecLogin&UserAcc=Gast&NextAction=Basis&txtBName=%@&txtKennwort=%@", username, password];
	}];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	
	// Parameters has to be "something" so that the queryStringSerialization above will be triggered.
	[manager POST:@"https://dias.fh-bonn-rhein-sieg.de/d3/SISEgo.asp?formact=Login" parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString *responseBody = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		NSError *error;
		NSString *gradeResultsRelativePath = [THSissyService gradeResultsRelativePathFromResponseBody:responseBody error:&error];
		callback(gradeResultsRelativePath, error);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		callback(nil, error);
	}];
}

+ (NSString *)gradeResultsRelativePathFromResponseBody:(NSString *)responseBody error:(NSError **)error {
	NSParameterAssert(responseBody);
	NSRange range1 = [responseBody rangeOfString:@"d3/SISEgo.asp?UserAcc=Gast&DokID=DiasSWeb&Exc=28&"];
	NSRange range2 = [responseBody rangeOfString:@"\" Target=\"_blank\">Notenspiegel</a>"];
	if (range1.location != NSNotFound && range2.location != NSNotFound) {
		return [responseBody substringWithRange:NSMakeRange(range1.location, range2.location - range1.location)];
	}
	if (error) {
		*error = [NSError errorWithDomain:kTHSissyErrorDomain code:THSissyErrorUnableToRetrieveGradeResultsRelativePath userInfo:nil];
	}
	return nil;
}

#pragma mark - Grade Results

+ (void)gradeResultsWithRelativePath:(NSString *)relativePath callback:(THSissyCallback)callback {
	NSParameterAssert(relativePath);
	NSParameterAssert(callback);
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	[manager GET:[@"https://dias.fh-bonn-rhein-sieg.de/" stringByAppendingString:relativePath] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString *responseBody = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		NSError *error;
		NSString *gradeResultsTableContent = [THSissyService gradeResultsTableContentFromResponseBody:responseBody error:&error];
		callback(gradeResultsTableContent, error);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		callback(nil, error);
	}];
}

+ (NSString *)gradeResultsTableContentFromResponseBody:(NSString *)responseBody error:(NSError **)error {
	NSParameterAssert(responseBody);
	NSString *result = responseBody;
	NSRange range = [responseBody rangeOfString:@"<tr bgcolor=\"#d5e5ef\"><td colspan=\"4\"><b>Studiengang:"];
	if (range.location != NSNotFound) {
		result = [result substringFromIndex:range.location];
		range = [result rangeOfString:@"<table>"];
		if (range.location != NSNotFound) {
			return [result substringToIndex:range.location];
		}
	}
	if (error) {
		*error = [NSError errorWithDomain:kTHSissyErrorDomain code:THSissyErrorUnableToRetrieveGradeResultsTableContent userInfo:nil];
	}
	return nil;
}

@end
