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
#import "THSissyController.h"

@implementation NSBundle (THSwizzle)

- (NSString *)th_bundleIdentifier {
	if (self == [NSBundle mainBundle]) {
		return @"com.apple.finder"; // fake bundle identifier
	} else {
		return self.bundleIdentifier;
	}
}

@end

BOOL installNSBundleHook() {
	Class class = objc_getClass("NSBundle");
	if (class) {
		method_exchangeImplementations(class_getInstanceMethod(class, @selector(bundleIdentifier)), class_getInstanceMethod(class, @selector(th_bundleIdentifier)));
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

			THSissyController *sissyController = [[THSissyController alloc] initWithUsername:[settings objectForKey:@"username"] password:[settings objectForKey:@"password"]];
			[sissyController runPeriodiciallyWithInterval:900];
			[[NSRunLoop currentRunLoop] run];
		}
	}
	return 0;
}
