//
//  main.m
//  sissy
//
//  Created by Tobias Hagemann on 10/03/15.
//  Copyright (c) 2015 tobiha.de. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <GBCli/GBCli.h>
#import "Sissy.h"

@implementation NSBundle (swizle)

- (NSString *)__bundleIdentifier {
	if (self == [NSBundle mainBundle]) {
		return @"com.apple.finder";
	} else {
		return [self __bundleIdentifier];
	}
}

@end

BOOL installNSBundleHook() {
	Class class = objc_getClass("NSBundle");
	if (class) {
		method_exchangeImplementations(class_getInstanceMethod(class, @selector(bundleIdentifier)), class_getInstanceMethod(class, @selector(__bundleIdentifier)));
		return YES;
	}
	return NO;
}

int main(int argc, char **argv) {
	@autoreleasepool {
		if (installNSBundleHook()) {
			GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
			[parser registerOption:@"username" shortcut:'u' requirement:GBValueRequired];
			[parser registerOption:@"password" shortcut:'p' requirement:GBValueRequired];

			GBSettings *settings = [GBSettings settingsWithName:@"CmdLine" parent:nil];
			[parser registerSettings:settings];
			if (![parser parseOptionsWithArguments:argv count:argc] || (![settings objectForKey:@"username"] && ![settings objectForKey:@"password"])) {
				NSLog(@"Invalid arguments. Specify username and password with: -u <username> -p <password>");
				return 1;
			}

			Sissy *sissy = [[Sissy alloc] initWithUsername:[settings objectForKey:@"username"] password:[settings objectForKey:@"password"]];
			[sissy runPeriodiciallyWithInterval:900];
			[[NSRunLoop currentRunLoop] run];
		}
	}
	return 0;
}
