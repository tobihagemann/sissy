//
//  Sissy.m
//  sissy
//
//  Created by Tobias Hagemann on 10/03/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "Sissy.h"

#import <AFNetworking/AFNetworking.h>
#import "NSString+SissyExtensions.h"

NSString *const kSissyErrorDomain = @"SissyErrorDomain";

typedef void (^SissyCallback)(NSString *result, NSError *error);

@interface Sissy ()
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *lastResultHash;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation Sissy

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password {
	NSParameterAssert(username);
	NSParameterAssert(password);
	if (self = [super init]) {
		self.username = username;
		self.password = password;
	}
	return self;
}

- (void)runPeriodiciallyWithInterval:(NSTimeInterval)interval {
	if (self.timer) {
		[self.timer invalidate];
	}
	self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(checkGradeResults) userInfo:nil repeats:YES];
	[self checkGradeResults];
}

#pragma mark - Actions

- (void)checkGradeResults {
	[self gradeResultsOfUser:self.username withPassword:self.password callback:^(NSString *gradeResults, NSError *error) {
		if (!error) {
			NSString *resultHash = [gradeResults sha1];
			if (self.lastResultHash) {
				if (![resultHash isEqualToString:self.lastResultHash]) {
					NSLog(@"Es wurde eine Änderung im Notenspiegel festgestellt.");
					[self notifyWithText:@"Notenspiegel wurde aktualisiert."];
				} else {
					NSLog(@"Notenspiegel hat sich nicht verändert.");
				}
			} else {
				NSLog(@"Notenspiegel wurde erfolgreich geladen.");
			}
			self.lastResultHash = resultHash;
		} else {
			NSLog(@"Notenspiegel konnte nicht abgerufen werden.");
		}
	}];
}

- (void)gradeResultsOfUser:(NSString *)username withPassword:(NSString *)password callback:(SissyCallback)callback {
	NSParameterAssert(username);
	NSParameterAssert(password);
	NSParameterAssert(callback);
	__weak typeof(self) weakSelf = self;
	[self loginWithUsername:username password:password callback:^(NSString *gradeResultsRelativePath, NSError *error) {
		if (error) {
			callback(nil, error);
		} else {
			[weakSelf gradeResultsWithRelativePath:gradeResultsRelativePath callback:callback];
		}
	}];
}

#pragma mark - Login

- (void)loginWithUsername:(NSString *)username password:(NSString *)password callback:(SissyCallback)callback {
	NSParameterAssert(username);
	NSParameterAssert(password);
	NSParameterAssert(callback);
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	[manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, id parameters, NSError *__autoreleasing *error) {
		return [NSString formURLEncodeHTTP5Parameters:parameters];
	}];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	NSDictionary *parameters = @{
		@"DokID": @"DiasSWeb",
		@"SID": @"",
		@"ADias2Dction": @"ExecLogin",
		@"UserAcc": @"Gast",
		@"NextAction": @"Basis",
		@"txtBName": username,
		@"txtKennwort": password
	};
	[manager POST:@"https://dias.fh-bonn-rhein-sieg.de/d3/SISEgo.asp?formact=Login" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString *responseBody = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		NSError *error;
		NSString *gradeResultsRelativePath = [self gradeResultsRelativePathFromResponseBody:responseBody error:&error];
		callback(gradeResultsRelativePath, error);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		callback(nil, error);
	}];
}

- (NSString *)gradeResultsRelativePathFromResponseBody:(NSString *)responseBody error:(NSError **)error {
	NSParameterAssert(responseBody);
	NSRange range1 = [responseBody rangeOfString:@"d3/SISEgo.asp?UserAcc=Gast&DokID=DiasSWeb&Exc=28&"];
	NSRange range2 = [responseBody rangeOfString:@"\" Target=\"_blank\">Notenspiegel</a>"];
	if (range1.location != NSNotFound && range2.location != NSNotFound) {
		return [responseBody substringWithRange:NSMakeRange(range1.location, range2.location - range1.location)];
	}
	*error = [NSError errorWithDomain:kSissyErrorDomain code:SissyErrorUnableToRetrieveGradeResultsRelativePath userInfo:nil];
	return nil;
}

#pragma mark - Grade Results

- (void)gradeResultsWithRelativePath:(NSString *)relativePath callback:(SissyCallback)callback {
	NSParameterAssert(relativePath);
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
	manager.responseSerializer = [AFHTTPResponseSerializer serializer];
	[manager GET:[@"https://dias.fh-bonn-rhein-sieg.de/" stringByAppendingString:relativePath] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString *responseBody = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		NSError *error;
		NSString *gradeResultsTableContent = [self gradeResultsTableContentFromResponseBody:responseBody error:&error];
		callback(gradeResultsTableContent, error);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		callback(nil, error);
	}];
}

- (NSString *)gradeResultsTableContentFromResponseBody:(NSString *)responseBody error:(NSError **)error {
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
	*error = [NSError errorWithDomain:kSissyErrorDomain code:SissyErorrUnableToRetrieveGradeResultsTableContent userInfo:nil];
	return nil;
}

#pragma mark - Notification

- (void)notifyWithText:(NSString *)text {
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	notification.title = @"sissy";
	notification.informativeText = text;
	notification.soundName = NSUserNotificationDefaultSoundName;
	[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

@end
