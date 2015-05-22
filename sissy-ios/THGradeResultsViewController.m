//
//  THGradeResultsViewController.m
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THGradeResultsViewController.h"

#import <WebKit/WebKit.h>
#import "THSissyService.h"
#import "THSettings.h"
#import "UIColor+THColors.h"
#import "THNotificationView.h"

@interface THGradeResultsViewController ()
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation THGradeResultsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.tintColor = [UIColor th_primaryColor];
	self.view.backgroundColor = [UIColor whiteColor];
	
	self.navigationController.navigationBar.tintColor = [UIColor th_primaryColor];
	self.navigationItem.title = NSLocalizedString(@"gradeResults.title", nil);
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissScreen:)];
	
	self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.webView.backgroundColor = [UIColor clearColor];
	self.webView.opaque = NO;
	[self.view addSubview:self.webView];
	
	[self loadGradeResults];
}

- (void)loadGradeResults {
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
			[weakSelf showGradeResults:gradeResults];
		}
	}];
}

- (void)showGradeResults:(NSString *)gradeResults {
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

#pragma mark - Actions

- (void)dismissScreen:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
