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
#import "GBSettings+THSettings.h"
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
			GBSettings *factoryDefaults = [GBSettings settingsWithName:@"Factory" parent:nil];
			[factoryDefaults setFloat:900.0 forKey:@"interval"];
			GBSettings *settings = [GBSettings settingsWithName:@"CmdLine" parent:factoryDefaults];

			GBOptionsHelper *options = [[GBOptionsHelper alloc] init];
			[options registerOption:'u' long:@"username" description:@"Username" flags:GBOptionRequiredValue];
			[options registerOption:'p' long:@"password" description:@"Password" flags:GBOptionRequiredValue];
			[options registerOption:'i' long:@"interval" description:@"Interval in seconds (default: 900 [15 minutes])" flags:GBOptionRequiredValue];
			[options registerOption:'?' long:@"help" description:@"Display this help and exit" flags:GBOptionNoValue | GBOptionNoPrint];

			GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
			[parser registerOption:@"username" shortcut:'u' requirement:GBValueRequired];
			[parser registerOption:@"password" shortcut:'p' requirement:GBValueRequired];
			[parser registerOption:@"interval" shortcut:'i' requirement:GBValueRequired];

			[parser registerSettings:settings];
			[parser registerOptions:options];
			if (![parser parseOptionsWithArguments:argv count:argc]) {
				gbprintln(@"Errors in command line parameters!");
				[options printHelp];
				return EXIT_FAILURE;
			} else if (settings.printHelp || argc == 1) {
				[options printHelp];
				return EXIT_SUCCESS;
			} else if (![settings objectForKey:@"username"] || ![settings objectForKey:@"password"]) {
				gbprintln(@"You have to set a username and password.");
				[options printHelp];
				return EXIT_FAILURE;
			}

			THSissyController *sissyController = [[THSissyController alloc] initWithUsername:[settings objectForKey:@"username"] password:[settings objectForKey:@"password"]];
			[sissyController runPeriodiciallyWithInterval:[settings floatForKey:@"interval"]];
			[[NSRunLoop currentRunLoop] run];
		}
	}
	return EXIT_SUCCESS;
}
