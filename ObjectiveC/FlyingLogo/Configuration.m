//
//  Configuration.m
//  FlyingLogo
//
//  Created by Gergely Sánta on 26/09/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

#import "Configuration.h"
#import <ScreenSaver/ScreenSaver.h>

@interface Configuration() {
	NSUserDefaults *defaults;
}

@end

@implementation Configuration

+ (instancetype) shared
{
	static Configuration *configuration = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		configuration = [[self alloc] init];
	});
	return configuration;
}

- (instancetype) init
{
	if (self = [super init]) {
		NSString *identifier = [NSBundle bundleForClass:Configuration.class].bundleIdentifier;
		defaults = [ScreenSaverDefaults defaultsForModuleWithName:identifier];

		_sceneNames = @[ @"Space Fly", @"Horizontal Flow" ];
		_scenes = @{
			@"Space Fly":       [NSNumber numberWithInt:SceneTypeSpaceFly],
			@"Horizontal Flow": [NSNumber numberWithInt:SceneTypeHorizontalFlow]
		};
	}
	return self;
}

- (SceneType) sceneType
{
	return (SceneType)[defaults integerForKey:@"sceneType"];
}

- (void) setSceneType:(SceneType)sceneType
{
	[defaults setInteger:sceneType forKey:@"sceneType"];
	[defaults synchronize];
}

@end
