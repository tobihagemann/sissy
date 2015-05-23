//
//  THGradesOverviewViewController.m
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THGradesOverviewViewController.h"

#import "THSissyService.h"
#import "THSettings.h"
#import "THNotificationView.h"

@implementation THGradesOverviewViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.title = NSLocalizedString(@"gradesOverview.title", nil);

	[self loadGradeResults];
}

- (void)loadGradeResults {
	if (![THSettings sharedInstance].loggedIn) {
		return;
	}
	NSString *username = [THSettings sharedInstance].username;
	NSString *password = [THSettings sharedInstance].password;
	__weak typeof(self) weakSelf = self;
	[THSissyService gradeResultsWithUsername:username password:password callback:^(NSString *gradeResults, NSError *error) {
		if (error) {
			[THNotificationView showErrorInViewController:weakSelf message:error.localizedDescription];
		} else {
			if (weakSelf.callback) {
				weakSelf.callback(gradeResults);
			}
			[weakSelf loadGradesOverviewWithGradeResults:gradeResults];
		}
	}];
}

- (void)loadGradesOverviewWithGradeResults:(NSString *)gradeResults {
	NSError *error;
	NSURL *htmlUrl = [[NSBundle mainBundle] URLForResource:@"graderesults" withExtension:@"html"];
	NSString *htmlTemplate = [NSString stringWithContentsOfURL:htmlUrl encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		[THNotificationView showErrorInViewController:self message:error.localizedDescription];
	} else {
		NSString *htmlString = [NSString stringWithFormat:htmlTemplate, gradeResults];
		[self.webView loadHTMLString:htmlString baseURL:[NSBundle mainBundle].bundleURL];
	}
}

@end
