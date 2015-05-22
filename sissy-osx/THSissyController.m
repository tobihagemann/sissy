//
//  THSissyController.m
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THSissyController.h"

#import "NSString+THExtensions.h"
#import "THSissyService.h"

@interface THSissyController ()
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *lastHashedResults;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation THSissyController

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

- (void)checkGradeResults {
	[THSissyService gradeResultsWithUsername:self.username password:self.password callback:^(NSString *gradeResults, NSError *error) {
		if (error) {
			NSLog(@"Dein Notenspiegel konnte nicht abgerufen werden: %@", error.localizedDescription);
			return;
		}
		
		NSString *hashedResults = [gradeResults th_sha1];
		if (self.lastHashedResults) {
			if (![hashedResults isEqualToString:self.lastHashedResults]) {
				NSLog(@"Es wurde eine Änderung in deinem Notenspiegel festgestellt.");
				[self notifyWithText:@"Dein Notenspiegel wurde aktualisiert."];
			} else {
				NSLog(@"Dein Notenspiegel hat sich nicht verändert.");
			}
		} else {
			NSLog(@"Dein Notenspiegel wurde erfolgreich geladen.");
		}
		self.lastHashedResults = hashedResults;
	}];
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
