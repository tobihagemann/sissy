//
//  THAppDelegate.m
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THAppDelegate.h"

#import "NSString+THExtensions.h"
#import "THSissyService.h"
#import "THSettings.h"
#import "THMainViewController.h"

@implementation THAppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
	if (![THSettings sharedInstance].loggedIn) {
		[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
		completionHandler(UIBackgroundFetchResultFailed);
		return;
	}
	NSString *username = [THSettings sharedInstance].username;
	NSString *password = [THSettings sharedInstance].password;
	__weak typeof(self) weakSelf = self;
	[THSissyService gradeResultsWithUsername:username password:password callback:^(NSString *gradeResults, NSError *error) {
		if (error) {
			completionHandler(UIBackgroundFetchResultFailed);
		} else {
			NSDate *fetchDate = [NSDate date];
			[THSettings sharedInstance].lastFetchDate = fetchDate;
			NSString *lastHashedResults = [THSettings sharedInstance].lastHashedResults;
			NSString *hashedResults = [gradeResults th_sha1];
			if ([hashedResults isEqualToString:lastHashedResults]) {
				completionHandler(UIBackgroundFetchResultNoData);
			} else {
				[THSettings sharedInstance].lastHashedResults = hashedResults;
				[weakSelf showGradeResultsUpdatedNotification];
				completionHandler(UIBackgroundFetchResultNewData);
			}
		}
	}];
}

- (void)showGradeResultsUpdatedNotification {
	UILocalNotification *localNotification = [[UILocalNotification alloc] init];
	localNotification.alertBody = NSLocalizedString(@"notification.gradeResultsUpdated", nil);
	localNotification.soundName = UILocalNotificationDefaultSoundName;
	localNotification.applicationIconBadgeNumber = 1;
	[[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

@end
