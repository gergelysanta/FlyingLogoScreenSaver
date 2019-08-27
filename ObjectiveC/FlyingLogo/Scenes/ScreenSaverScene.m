//
//  SceenSaverScene.m
//  FlyingLogo
//
//  Created by Gergely Sánta on 14/08/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

#import "ScreenSaverScene.h"

@implementation ScreenSaverScene

- (instancetype) init
{
	self = [self initWithAnimationTimeInterval:1/60.0];
	return self;
}

- (instancetype) initWithAnimationTimeInterval:(NSTimeInterval)timeInterval
{
	if (self = [super init]) {
		_animationTimeInterval = timeInterval;
	}
	return self;
}

- (void) start
{
	// Override this method
}

- (void) stop
{
	// Override this method
}

- (NSImage*) loadImageWithName:(NSString*)imageName
{
	NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:imageName ofType:@"png"];
	if (path) {
		// File exists and found -> load it's contents to NSData
		NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
		if (imageData) {
			return [[NSImage alloc] initWithData:imageData];
		}
	}
	return nil;
}

@end
