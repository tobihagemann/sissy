//
//  THMainViewController.m
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THMainViewController.h"

#import <SIAlertView/SIAlertView.h>
#import <SORelativeDateTransformer/SORelativeDateTransformer.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "NSString+THExtensions.h"
#import "THSissyService.h"
#import "THSettings.h"
#import "THLoginViewController.h"
#import "THGradesOverviewViewController.h"
#import "THInfoViewController.h"
#import "UIColor+THColors.h"
#import "THNotificationView.h"

NSString *const kTHMainShowLoginSegueIdentifier = @"showLogin";

@interface THMainViewController ()
@property (nonatomic, weak) IBOutlet UILabel *lastFetchLabel;
@property (nonatomic, weak) IBOutlet UIButton *fetchNowButton;
@property (nonatomic, weak) IBOutlet UIButton *showGradesOverviewButton;
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
		[self updateSignOutButtonWithLoggedIn:[THSettings sharedInstance].loggedIn];
		[self updateLoggedInLabelWithUsername:[THSettings sharedInstance].username];
		
		// Workaround: layoutIfNeeded because performWithoutAnimation is insufficient on UIButtons.
		[self.showGradesOverviewButton layoutIfNeeded];
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

- (void)updateGradeResults:(NSString *)gradeResults {
	NSDate *fetchDate = [NSDate date];
	[THSettings sharedInstance].lastFetchDate = fetchDate;
	[self updateLastFetchLabelWithDate:fetchDate];
	BOOL gradeResultsHaveChanged = [self detectChangeInGradeResults:gradeResults];
	[THSettings sharedInstance].lastHashedResults = [gradeResults th_sha1];

	SIAlertView *alert;
	if (gradeResultsHaveChanged) {
		alert = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.changeDetected.title", nil) andMessage:NSLocalizedString(@"alert.changeDetected.message", nil)];
		__weak typeof(self) weakSelf = self;
		[alert addButtonWithTitle:NSLocalizedString(@"alert.changeDetected.showGradesOverview", nil) type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
			[weakSelf showGradesOverviewWithGradeResults:gradeResults];
		}];
		[alert addButtonWithTitle:NSLocalizedString(@"alert.changeDetected.cancel", nil) type:SIAlertViewButtonTypeCancel handler:nil];
	} else {
		alert = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.noChangeDetected.title", nil) andMessage:NSLocalizedString(@"alert.noChangeDetected.message", nil)];
		[alert addButtonWithTitle:NSLocalizedString(@"alert.noChangeDetected.cancel", nil) type:SIAlertViewButtonTypeCancel handler:nil];
	}
	alert.transitionStyle = SIAlertViewTransitionStyleBounce;
	alert.backgroundStyle = SIAlertViewBackgroundStyleSolid;
	alert.buttonsListStyle = SIAlertViewButtonsListStyleRows;
	alert.titleColor = [UIColor th_primaryColor];
	[alert show];
}

- (BOOL)detectChangeInGradeResults:(NSString *)gradeResults {
	NSString *lastHashedResults = [THSettings sharedInstance].lastHashedResults;
	NSString *hashedResults = [gradeResults th_sha1];
	return ![hashedResults isEqualToString:lastHashedResults];
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
			[weakSelf updateGradeResults:gradeResults];
		}
	}];
}

- (IBAction)showGradesOverview:(id)sender {
	[self showGradesOverviewWithGradeResults:nil];
}

- (void)showGradesOverviewWithGradeResults:(NSString *)gradeResults {
	THGradesOverviewViewController *gradesOverviewViewController = [[THGradesOverviewViewController alloc] init];
	__weak typeof(self) weakSelf = self;
	gradesOverviewViewController.callback = ^(NSString *gradeResults) {
		[weakSelf updateGradeResults:gradeResults];
	};
	gradesOverviewViewController.gradeResults = gradeResults;
	UINavigationController *gradesOverviewNavigationController = [[UINavigationController alloc] initWithRootViewController:gradesOverviewViewController];
	gradesOverviewNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:gradesOverviewNavigationController animated:YES completion:nil];
}

- (IBAction)signOut:(id)sender {
	[[THSettings sharedInstance] reset];
	[self updateLastFetchLabelWithDate:nil];
	[self updateFetchNowButtonWithLoggedIn:NO];
	[self updateShowGradesOverviewButtonWithLoggedIn:NO];
	[self updateSignOutButtonWithLoggedIn:NO];
	[self updateLoggedInLabelWithUsername:nil];
	[self performSegueWithIdentifier:kTHMainShowLoginSegueIdentifier sender:nil];
}

- (IBAction)showInfo:(id)sender {
	THInfoViewController *infoViewController = [[THInfoViewController alloc] init];
	UINavigationController *infoNavigationController = [[UINavigationController alloc] initWithRootViewController:infoViewController];
	infoNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:infoNavigationController animated:YES completion:nil];
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
