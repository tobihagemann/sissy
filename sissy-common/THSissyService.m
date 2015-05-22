//
//  THSissyService.m
//  sissy-common
//
//  Created by Tobias Hagemann on 10/03/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THSissyService.h"

#import <AFNetworking/AFNetworking.h>
#import <hpple/TFHpple.h>
#import "NSString+THExtensions.h"

NSString *const kTHSissyErrorDomain = @"SissyErrorDomain";

NSString *const kTHSissyBaseUrlString = @"https://dias.fh-bonn-rhein-sieg.de/";

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
	[manager POST:[kTHSissyBaseUrlString stringByAppendingString:@"d3/SISEgo.asp?formact=Login"] parameters:@{} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error;
		NSString *gradeResultsRelativePath = [THSissyService gradeResultsRelativePathFromHtmlData:responseObject error:&error];
		callback(gradeResultsRelativePath, error);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		callback(nil, error);
	}];
}

+ (NSString *)gradeResultsRelativePathFromHtmlData:(NSData *)htmlData error:(NSError **)error {
	NSParameterAssert(htmlData);
	TFHpple *document = [TFHpple hppleWithHTMLData:htmlData];
	NSArray *links = [document searchWithXPathQuery:@"//a/@href"];
	NSUInteger indexOfGradeResultsLink = [links indexOfObjectPassingTest:^BOOL(TFHppleElement *element, NSUInteger idx, BOOL *stop) {
		return [element.content containsString:@"Exc=28"];
	}];
	if (indexOfGradeResultsLink != NSNotFound) {
		TFHppleElement *element = links[indexOfGradeResultsLink];
		return element.content;
	} else if (error) {
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
	[manager GET:[kTHSissyBaseUrlString stringByAppendingString:relativePath] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error;
		NSString *gradeResults = [THSissyService gradeResultsFromHtmlData:responseObject error:&error];
		callback(gradeResults, error);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		callback(nil, error);
	}];
}

+ (NSString *)gradeResultsFromHtmlData:(NSData *)htmlData error:(NSError **)error {
	NSParameterAssert(htmlData);
	TFHpple *document = [TFHpple hppleWithHTMLData:htmlData];
	NSArray *tables = [document searchWithXPathQuery:@"//div[@id=\"inhalt\"]/table//table"];
	if (tables.count >= 2) {
		TFHppleElement *element = tables[1];
		return element.raw;
	} else if (error) {
		*error = [NSError errorWithDomain:kTHSissyErrorDomain code:THSissyErrorUnableToRetrieveGradeResultsTableContent userInfo:nil];
	}
	return nil;
}

@end
