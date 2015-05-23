//
//  THLoginViewController.m
//  sissy
//
//  Created by Tobias Hagemann on 22/05/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import "THLoginViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <XLForm/UIView+XLFormAdditions.h>
#import "THSissyService.h"
#import "UIColor+THColors.h"
#import "THNotificationView.h"

NSString *const kTHLoginUsernameTag = @"username";
NSString *const kTHLoginPasswordTag = @"password";
NSString *const kTHLoginActionTag = @"login";

@interface THLoginViewController ()
@property (nonatomic, strong) XLFormRowDescriptor *usernameRow;
@property (nonatomic, strong) XLFormRowDescriptor *passwordRow;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation THLoginViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self initializeForm];
	}
	return self;
}

- (void)initializeForm {
	__weak typeof(self) weakSelf = self;

	XLFormDescriptor *form = [XLFormDescriptor formDescriptorWithTitle:NSLocalizedString(@"login.title", nil)];
	form.assignFirstResponderOnShow = YES;

	XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSection];
	[form addFormSection:section];

	self.usernameRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTHLoginUsernameTag rowType:XLFormRowDescriptorTypeAccount title:NSLocalizedString(@"login.username", nil)];
	self.usernameRow.cellConfigAtConfigure[@"textField.placeholder"] = self.usernameRow.title;
	self.usernameRow.cellConfigAtConfigure[@"imageView.image"] = [UIImage imageNamed:@"973-user"];
	self.usernameRow.cellConfig[@"textLabel.text"] = @"";
	self.usernameRow.required = YES;
	[section addFormRow:self.usernameRow];

	self.passwordRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTHLoginPasswordTag rowType:XLFormRowDescriptorTypePassword title:NSLocalizedString(@"login.password", nil)];
	self.passwordRow.cellConfigAtConfigure[@"textField.placeholder"] = self.passwordRow.title;
	self.passwordRow.cellConfigAtConfigure[@"imageView.image"] = [UIImage imageNamed:@"899-key"];
	self.passwordRow.cellConfig[@"textLabel.text"] = @"";
	self.passwordRow.required = YES;
	[section addFormRow:self.passwordRow];

	XLFormRowDescriptor *loginActionRow = [XLFormRowDescriptor formRowDescriptorWithTag:kTHLoginActionTag rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"login.action", nil)];
	loginActionRow.cellConfig[@"textLabel.textColor"] = [UIColor th_primaryColor];
	loginActionRow.action.formBlock = ^(XLFormRowDescriptor *row) {
		[weakSelf login];
		[weakSelf deselectFormRow:row];
	};
	[section addFormRow:loginActionRow];

	self.form = form;
}

- (NSString *)username {
	return self.usernameRow.value;
}

- (NSString *)password {
	return self.passwordRow.value;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([super textFieldShouldReturn:textField]) {
		UITableViewCell<XLFormDescriptorCell> *cell = [textField formDescriptorCell];
		if ([cell.rowDescriptor.tag isEqualToString:kTHLoginPasswordTag]) {
			[self login];
		}
		return YES;
	}
	return NO;
}

#pragma mark - Actions

- (void)login {
	NSArray *validationErrors = [self formValidationErrors];
	if (validationErrors.count > 0) {
		NSError *validationError = validationErrors.firstObject;
		[THNotificationView showWarningInViewController:self message:validationError.localizedDescription];
		[self firstInvalidRowBecomeFirstResponder];
		return;
	}

	[SVProgressHUD showWithStatus:nil maskType:SVProgressHUDMaskTypeBlack];
	NSString *username = self.username;
	NSString *password = self.password;
	__weak typeof(self) weakSelf = self;
	[THSissyService gradeResultsWithUsername:username password:password callback:^(NSString *gradeResults, NSError *error) {
		if (error) {
			[SVProgressHUD dismiss];
			[THNotificationView showErrorInViewController:weakSelf message:error.localizedDescription];
			[weakSelf resetPasswordRowAndBecomeFirstResponder];
		} else {
			[SVProgressHUD showSuccessWithStatus:nil];
			if (weakSelf.callback) {
				weakSelf.callback(username, password, gradeResults);
			}
			[weakSelf dismissViewControllerAnimated:YES completion:nil];
		}
	}];
}

- (void)firstInvalidRowBecomeFirstResponder {
	for (XLFormSectionDescriptor *section in self.form.formSections) {
		for (XLFormRowDescriptor *row in section.formRows) {
			XLFormValidationStatus *status = [row doValidation];
			if (status && !status.isValid) {
				UITableViewCell<XLFormDescriptorCell> *cell = [row cellForFormController:self];
				if ([cell formDescriptorCellCanBecomeFirstResponder]) {
					[cell formDescriptorCellBecomeFirstResponder];
					break;
				}
			}
		}
	}
}

- (void)resetPasswordRowAndBecomeFirstResponder {
	self.passwordRow.value = nil;
	[self updateFormRow:self.passwordRow];
	UITableViewCell<XLFormDescriptorCell> *cell = [self.passwordRow cellForFormController:self];
	if ([cell formDescriptorCellCanBecomeFirstResponder]) {
		[cell formDescriptorCellBecomeFirstResponder];
	}
}

@end
