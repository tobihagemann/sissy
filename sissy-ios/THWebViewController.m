//
//  THWebViewController.m
//  sissy
//
//  Created by Tobias Hagemann on 23/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THWebViewController.h"

#import "UIColor+THColors.h"

@interface THWebViewController () <WKNavigationDelegate>
@end

@implementation THWebViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.tintColor = [UIColor th_primaryColor];
	self.view.backgroundColor = [UIColor whiteColor];

	self.navigationController.navigationBar.tintColor = [UIColor th_primaryColor];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissScreen:)];

	self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
	self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.webView.backgroundColor = [UIColor clearColor];
	self.webView.opaque = NO;
	self.webView.navigationDelegate = self;
	[self.view addSubview:self.webView];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
	if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
		[[UIApplication sharedApplication] openURL:navigationAction.request.URL];
	}
	decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - Actions

- (void)dismissScreen:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
