//
//  THMainViewController.m
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THMainViewController.h"

#import <SORelativeDateTransformer/SORelativeDateTransformer.h>
#import "NSString+THExtensions.h"
#import "THSettings.h"
#import "THLoginViewController.h"
#import "THGradeResultsViewController.h"

NSString *const kTHMainShowLoginSegueIdentifier = @"showLogin";

@interface THMainViewController ()
@property (nonatomic, weak) IBOutlet UILabel *lastFetchLabel;
@property (nonatomic, weak) IBOutlet UIButton *showGradeResultsButton;
@property (nonatomic, weak) IBOutlet UIButton *fetchNewGradeResultsSettingButton;
@property (nonatomic, weak) IBOutlet UIButton *signOutButton;
@property (nonatomic, weak) IBOutlet UILabel *loggedInLabel;
@end

@implementation THMainViewController

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[UIView performWithoutAnimation:^{
		[self updateLastFetchLabelWithDate:[THSettings sharedInstance].lastFetchDate];
		[self updateShowGradeResultsButtonWithLoggedIn:[THSettings sharedInstance].loggedIn];
		[self updateFetchNewGradeResultsSettingButtonWithOption:[THSettings sharedInstance].fetchNewGradeResultsSetting];
		[self updateSignOutButtonWithLoggedIn:[THSettings sharedInstance].loggedIn];
		[self updateLoggedInLabelWithUsername:[THSettings sharedInstance].username];
		
		// Workaround: layoutIfNeeded because performWithoutAnimation is insufficient on UIButtons.
		[self.showGradeResultsButton layoutIfNeeded];
		[self.fetchNewGradeResultsSettingButton layoutIfNeeded];
		[self.signOutButton layoutIfNeeded];
	}];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (![THSettings sharedInstance].loggedIn) {
		[self performSegueWithIdentifier:kTHMainShowLoginSegueIdentifier sender:self];
	}
}

- (void)updateLastFetchLabelWithDate:(NSDate *)date {
	NSString *relativeDateString;
	if (date) {
		relativeDateString = [[SORelativeDateTransformer registeredTransformer] transformedValue:date];
	} else {
		relativeDateString = NSLocalizedString(@"main.lastFetch.never", nil);
	}
	self.lastFetchLabel.text = [NSString stringWithFormat:NSLocalizedString(@"main.lastFetch", nil), relativeDateString];
}

- (void)updateShowGradeResultsButtonWithLoggedIn:(BOOL)loggedIn {
	if (loggedIn) {
		[self.showGradeResultsButton setTitle:NSLocalizedString(@"main.showGradeResults", nil) forState:UIControlStateNormal];
		self.showGradeResultsButton.enabled = YES;
	} else {
		[self.showGradeResultsButton setTitle:nil forState:UIControlStateNormal];
		self.showGradeResultsButton.enabled = NO;
	}
}

- (void)updateFetchNewGradeResultsSettingButtonWithOption:(THFetchNewGradeResultsOption)option {
	NSString *optionString;
	switch (option) {
		case THFetchNewGradeResultsEvery15Minutes:
			optionString = NSLocalizedString(@"main.fetchNewGradeResultsSetting.every15Minutes", nil);
			break;
		case THFetchNewGradeResultsEvery30Minutes:
			optionString = NSLocalizedString(@"main.fetchNewGradeResultsSetting.every30Minutes", nil);
			break;
		case THFetchNewGradeResultsHourly:
			optionString = NSLocalizedString(@"main.fetchNewGradeResultsSetting.hourly", nil);
			break;
	}
	[self.fetchNewGradeResultsSettingButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"main.fetchNewGradeResultsSetting", nil), optionString] forState:UIControlStateNormal];
}

- (void)updateSignOutButtonWithLoggedIn:(BOOL)loggedIn {
	if (loggedIn) {
		[self.signOutButton setTitle:NSLocalizedString(@"main.signOut", nil) forState:UIControlStateNormal];
		self.signOutButton.enabled = YES;
	} else {
		[self.signOutButton setTitle:nil forState:UIControlStateNormal];
		self.signOutButton.enabled = NO;
	}
}

- (void)updateLoggedInLabelWithUsername:(NSString *)username {
	if (username) {
		self.loggedInLabel.text = [NSString stringWithFormat:NSLocalizedString(@"main.loggedIn", nil), username];
	} else {
		self.loggedInLabel.text = nil;
	}
}

#pragma mark - Actions

- (IBAction)showGradeResults:(id)sender {
	THGradeResultsViewController *gradeResultsViewController = [[THGradeResultsViewController alloc] init];
	__weak typeof(self) weakSelf = self;
	gradeResultsViewController.callback = ^(NSString *gradeResults) {
		NSDate *fetchDate = [NSDate date];
		[THSettings sharedInstance].lastFetchDate = fetchDate;
		[THSettings sharedInstance].lastHashedResults = [gradeResults th_sha1];
		[weakSelf updateLastFetchLabelWithDate:fetchDate];
	};
	UINavigationController *gradeResultsNavigationController = [[UINavigationController alloc] initWithRootViewController:gradeResultsViewController];
	gradeResultsNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:gradeResultsNavigationController animated:YES completion:nil];
}

- (IBAction)showFetchNewGradeResultsSetting:(id)sender {
	UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *every15MinutesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"main.fetchNewGradeResultsSetting.every15Minutes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[THSettings sharedInstance].fetchNewGradeResultsSetting = THFetchNewGradeResultsEvery15Minutes;
		[self updateFetchNewGradeResultsSettingButtonWithOption:THFetchNewGradeResultsEvery15Minutes];
	}];
	[actionSheet addAction:every15MinutesAction];
	UIAlertAction *every30MinutesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"main.fetchNewGradeResultsSetting.every30Minutes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[THSettings sharedInstance].fetchNewGradeResultsSetting = THFetchNewGradeResultsEvery30Minutes;
		[self updateFetchNewGradeResultsSettingButtonWithOption:THFetchNewGradeResultsEvery30Minutes];
	}];
	[actionSheet addAction:every30MinutesAction];
	UIAlertAction *hourlyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"main.fetchNewGradeResultsSetting.hourly", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[THSettings sharedInstance].fetchNewGradeResultsSetting = THFetchNewGradeResultsHourly;
		[self updateFetchNewGradeResultsSettingButtonWithOption:THFetchNewGradeResultsHourly];
	}];
	[actionSheet addAction:hourlyAction];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.cancel", nil) style:UIAlertActionStyleCancel handler:nil];
	[actionSheet addAction:cancelAction];
	[self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)signOut:(id)sender {
	[[THSettings sharedInstance] reset];
	[self updateLastFetchLabelWithDate:nil];
	[self updateShowGradeResultsButtonWithLoggedIn:NO];
	[self updateSignOutButtonWithLoggedIn:NO];
	[self updateLoggedInLabelWithUsername:nil];
	[self performSegueWithIdentifier:kTHMainShowLoginSegueIdentifier sender:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:kTHMainShowLoginSegueIdentifier]) {
		THLoginViewController *loginViewController = segue.destinationViewController;
		__weak typeof(self) weakSelf = self;
		loginViewController.callback = ^(NSString *username, NSString *password, NSString *gradeResults) {
			NSDate *fetchDate = [NSDate date];
			[THSettings sharedInstance].lastFetchDate = fetchDate;
			[THSettings sharedInstance].username = username;
			[THSettings sharedInstance].password = password;
			[THSettings sharedInstance].lastHashedResults = [gradeResults th_sha1];
			[weakSelf updateLastFetchLabelWithDate:fetchDate];
			[weakSelf updateShowGradeResultsButtonWithLoggedIn:YES];
			[weakSelf updateSignOutButtonWithLoggedIn:YES];
			[weakSelf updateLoggedInLabelWithUsername:username];
		};
	}
}

#pragma mark - Notifications

- (void)applicationDidBecomeActive:(NSNotification *)notification {
	[self updateLastFetchLabelWithDate:[THSettings sharedInstance].lastFetchDate];
}

@end
