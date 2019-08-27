//
//  FlyingLogoView.m
//  FlyingLogo
//
//  Created by Gergely Sánta on 22/04/2018.
//  Copyright © 2018 TriKatz. All rights reserved.
//

#import "FlyingLogoView.h"
#import "SpaceFlyScene.h"
#import "HorizontalFlowScene.h"

@implementation FlyingLogoView
{
	ScreenSaverScene *scene;
}

- (instancetype) initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		// Create main Scene displaying additional layers (floating logos)
		scene = [SpaceFlyScene new];
		self.layer = scene;

		// As initially ScreenSaverView didn't have any backing CALayer, it have wantsLayer turned off
		// We just added backing layer and want to be used by our view, so we need to turn on wantsLayer property
		self.wantsLayer = YES;
	}
    return self;
}

- (void) viewDidMoveToWindow
{
	// Set layer size (fullscreen)
	scene.frame = self.frame;
}

- (void) startAnimation
{
    [super startAnimation];
	[scene start];
}

- (void) stopAnimation
{
    [super stopAnimation];
	[scene stop];
}

- (void) drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void) animateOneFrame
{
    return;
}

- (BOOL) hasConfigureSheet
{
    return NO;
}

- (NSWindow*) configureSheet
{
    return nil;
}

@end
