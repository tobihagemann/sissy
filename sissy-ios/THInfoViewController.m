//
//  THInfoViewController.m
//  sissy
//
//  Created by Tobias Hagemann on 23/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THInfoViewController.h"

#import "THNotificationView.h"

@implementation THInfoViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"info.title", nil), version, build];

	[self loadInfo];
}

- (void)loadInfo {
	NSError *error;
	NSURL *htmlUrl = [[NSBundle mainBundle] URLForResource:@"info" withExtension:@"html"];
	NSString *htmlString = [NSString stringWithContentsOfURL:htmlUrl encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		[THNotificationView showErrorInViewController:self message:error.localizedDescription];
	} else {
		[self.webView loadHTMLString:htmlString baseURL:[NSBundle mainBundle].bundleURL];
	}
}

@end
