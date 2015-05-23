//
//  THMainViewController.m
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THMainViewController.h"

#import <SORelativeDateTransformer/SORelativeDateTransformer.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "NSString+THExtensions.h"
#import "THSissyService.h"
#import "THSettings.h"
#import "THLoginViewController.h"
#import "THGradesOverviewViewController.h"
#import "UIColor+THColors.h"
#import "THNotificationView.h"

NSString *const kTHMainShowLoginSegueIdentifier = @"showLogin";

@interface THMainViewController ()
@property (nonatomic, weak) IBOutlet UILabel *lastFetchLabel;
@property (nonatomic, weak) IBOutlet UIButton *fetchNowButton;
@property (nonatomic, weak) IBOutlet UIButton *showGradesOverviewButton;
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
		[self updateFetchNowButtonWithLoggedIn:[THSettings sharedInstance].loggedIn];
		[self updateShowGradesOverviewButtonWithLoggedIn:[THSettings sharedInstance].loggedIn];
		[self updateFetchNewGradeResultsSettingButtonWithOption:[THSettings sharedInstance].fetchNewGradeResultsSetting];
		[self updateSignOutButtonWithLoggedIn:[THSettings sharedInstance].loggedIn];
		[self updateLoggedInLabelWithUsername:[THSettings sharedInstance].username];
		
		// Workaround: layoutIfNeeded because performWithoutAnimation is insufficient on UIButtons.
		[self.showGradesOverviewButton layoutIfNeeded];
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

- (void)updateFetchNowButtonWithLoggedIn:(BOOL)loggedIn {
	if (loggedIn) {
		[self.fetchNowButton setTitle:NSLocalizedString(@"main.fetchNow", nil) forState:UIControlStateNormal];
		self.fetchNowButton.enabled = YES;
	} else {
		[self.fetchNowButton setTitle:nil forState:UIControlStateNormal];
		self.fetchNowButton.enabled = NO;
	}
}

- (void)updateShowGradesOverviewButtonWithLoggedIn:(BOOL)loggedIn {
	if (loggedIn) {
		[self.showGradesOverviewButton setTitle:NSLocalizedString(@"main.showGradesOverview", nil) forState:UIControlStateNormal];
		self.showGradesOverviewButton.enabled = YES;
	} else {
		[self.showGradesOverviewButton setTitle:nil forState:UIControlStateNormal];
		self.showGradesOverviewButton.enabled = NO;
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

- (void)updateGradeResults:(NSString *)gradeResults fromViewController:(UIViewController *)viewController {
	NSDate *fetchDate = [NSDate date];
	[THSettings sharedInstance].lastFetchDate = fetchDate;
	[self updateLastFetchLabelWithDate:fetchDate];
	[self detectChangeInGradeResults:gradeResults fromViewController:viewController];
	[THSettings sharedInstance].lastHashedResults = [gradeResults th_sha1];
}

- (void)detectChangeInGradeResults:(NSString *)gradeResults fromViewController:(UIViewController *)viewController {
	NSString *lastHashedResults = [THSettings sharedInstance].lastHashedResults;
	NSString *hashedResults = [gradeResults th_sha1];
	if ([hashedResults isEqualToString:lastHashedResults]) {
		[THNotificationView showInfoInViewController:viewController message:NSLocalizedString(@"main.fetchNow.notification.noChangeDetected", nil)];
	} else {
		[THNotificationView showSuccessInViewController:viewController message:NSLocalizedString(@"main.fetchNow.notification.changeDetected", nil)];
	}
}

#pragma mark - Actions

- (IBAction)fetchNow:(id)sender {
	if (![THSettings sharedInstance].loggedIn) {
		[self signOut:sender];
		return;
	}
	[SVProgressHUD showWithStatus:nil maskType:SVProgressHUDMaskTypeBlack];
	NSString *username = [THSettings sharedInstance].username;
	NSString *password = [THSettings sharedInstance].password;
	__weak typeof(self) weakSelf = self;
	[THSissyService gradeResultsWithUsername:username password:password callback:^(NSString *gradeResults, NSError *error) {
		[SVProgressHUD dismiss];
		if (error) {
			[THNotificationView showErrorInViewController:weakSelf message:error.localizedDescription];
		} else {
			[weakSelf updateGradeResults:gradeResults fromViewController:weakSelf];
		}
	}];
}

- (IBAction)showGradesOverview:(id)sender {
	THGradesOverviewViewController *gradesOverviewViewController = [[THGradesOverviewViewController alloc] init];
	__weak THGradesOverviewViewController *weakGradesOverviewViewController = gradesOverviewViewController;
	__weak typeof(self) weakSelf = self;
	gradesOverviewViewController.callback = ^(NSString *gradeResults) {
		[weakSelf updateGradeResults:gradeResults fromViewController:weakGradesOverviewViewController];
	};
	UINavigationController *gradesOverviewNavigationController = [[UINavigationController alloc] initWithRootViewController:gradesOverviewViewController];
	gradesOverviewNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:gradesOverviewNavigationController animated:YES completion:nil];
}

- (IBAction)showFetchNewGradeResultsSetting:(id)sender {
	UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	actionSheet.view.tintColor = [UIColor th_primaryColor];
	void (^actionCallback)(THFetchNewGradeResultsOption) = ^(THFetchNewGradeResultsOption option) {
		[THSettings sharedInstance].fetchNewGradeResultsSetting = option;
		[self updateFetchNewGradeResultsSettingButtonWithOption:option];
		[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:[THSettings sharedInstance].fetchNewGradeResultsTimeInterval];
	};
	UIAlertAction *every15MinutesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"main.fetchNewGradeResultsSetting.every15Minutes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		actionCallback(THFetchNewGradeResultsEvery15Minutes);
	}];
	[actionSheet addAction:every15MinutesAction];
	UIAlertAction *every30MinutesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"main.fetchNewGradeResultsSetting.every30Minutes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		actionCallback(THFetchNewGradeResultsEvery30Minutes);
	}];
	[actionSheet addAction:every30MinutesAction];
	UIAlertAction *hourlyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"main.fetchNewGradeResultsSetting.hourly", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		actionCallback(THFetchNewGradeResultsHourly);
	}];
	[actionSheet addAction:hourlyAction];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.cancel", nil) style:UIAlertActionStyleCancel handler:nil];
	[actionSheet addAction:cancelAction];
	UIPopoverPresentationController *popver = actionSheet.popoverPresentationController;
	if (popver) {
		popver.sourceView = self.fetchNewGradeResultsSettingButton;
		popver.sourceRect = self.fetchNewGradeResultsSettingButton.bounds;
	}
	[self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)signOut:(id)sender {
	[[THSettings sharedInstance] reset];
	[self updateLastFetchLabelWithDate:nil];
	[self updateFetchNowButtonWithLoggedIn:NO];
	[self updateShowGradesOverviewButtonWithLoggedIn:NO];
	[self updateSignOutButtonWithLoggedIn:NO];
	[self updateLoggedInLabelWithUsername:nil];
	[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
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
			[weakSelf updateFetchNowButtonWithLoggedIn:YES];
			[weakSelf updateShowGradesOverviewButtonWithLoggedIn:YES];
			[weakSelf updateSignOutButtonWithLoggedIn:YES];
			[weakSelf updateLoggedInLabelWithUsername:username];
			[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:[THSettings sharedInstance].fetchNewGradeResultsTimeInterval];
			if ([[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone) {
				[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
			}
		};
	}
}

#pragma mark - Notifications

- (void)applicationDidBecomeActive:(NSNotification *)notification {
	[self updateLastFetchLabelWithDate:[THSettings sharedInstance].lastFetchDate];
}

@end
