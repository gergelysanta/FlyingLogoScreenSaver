//
//  HorizontalFlowScene.m
//  FlyingLogo
//
//  Created by Gergely Sánta on 27/08/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

#import "HorizontalFlowScene.h"

@implementation HorizontalFlowScene
{
	BOOL rightToLeft;

	NSImage *logoImage;

	NSMutableArray *logoArray;
	NSUInteger maximumNumberOfLogos;

	LogoLayer *mainLogo;

	NSTimer *logoGeneratingTimer;
	NSTimer *mainLogoGeneratingTimer;

	CGFloat logoMinimumHeight;
	CGFloat logoMaximumHeight;
	CGFloat mainLogoHeight;
}

- (instancetype) init
{
	if (self = [super initWithAnimationTimeInterval:1/30.0])
	{
		rightToLeft = YES;

		maximumNumberOfLogos = 20;
		logoArray = [NSMutableArray arrayWithCapacity:maximumNumberOfLogos];

		mainLogo = nil;

		logoMinimumHeight = 0;
		logoMaximumHeight = 0;
		mainLogoHeight = 0;

		// Set background to black
		self.backgroundColor = [NSColor blackColor].CGColor;

		// Load logo images from bundle
		logoImage = [self loadImageWithName:@"SimpleLogoFull"];
	}
	return self;
}

- (void) setFrame:(CGRect)frame
{
	[super setFrame:frame];

	logoMinimumHeight = self.frame.size.height / 30.0;
	logoMaximumHeight = self.frame.size.height / 10.0;
	mainLogoHeight = self.frame.size.height / 3.0;
}

- (NSTimeInterval) randomTimeInterval
{
	// Return random time between 0.6s and 1.5s
	NSTimeInterval interval = arc4random_uniform(600) + 900;
	return interval / 1000;
}

- (NSTimeInterval) randomMainLogoTimeInterval
{
	// Return random time etween 6s and 10s
	NSTimeInterval interval = arc4random_uniform(6000) + 4000;
	return interval / 1000;
}

- (CGFloat) randomHeight
{
	return logoMinimumHeight + arc4random_uniform(logoMaximumHeight - logoMinimumHeight);
}

/////////////////////////////////////////////////////////////////////////
// MARK: - ScreenSaverView overrided methods

- (void) start
{
	if (logoGeneratingTimer == nil) {
		logoGeneratingTimer = [NSTimer scheduledTimerWithTimeInterval:[self randomTimeInterval]
															   target:self
															 selector:@selector(randomizeNewLogo)
															 userInfo:nil
															  repeats:NO];
	}
	if (mainLogoGeneratingTimer == nil) {
		mainLogoGeneratingTimer = [NSTimer scheduledTimerWithTimeInterval:[self randomMainLogoTimeInterval]
																   target:self
																 selector:@selector(generateMainLogo)
																 userInfo:nil
																  repeats:NO];
	}
}

- (void) stop
{
	[logoGeneratingTimer invalidate];
	logoGeneratingTimer = nil;

	[mainLogoGeneratingTimer invalidate];
	mainLogoGeneratingTimer = nil;

	for (LogoLayer *logo in logoArray) {
		[logo removeAllAnimations];
	}
}

#pragma mark - Logo management

- (void) randomizeNewLogo
{
	if (logoArray.count < maximumNumberOfLogos) {

		// Create new logo
		LogoLayer *logo = [self generateFlowingLogoWithImage:logoImage height:self.randomHeight];
		if (!logo) {
			NSLog(@"ERROR: Couldn't generate flowing logo");
			return;
		}

		[logoArray addObject:logo];
#if DEBUG
		NSLog(@"DEBUG: %lu logos", (unsigned long)logoArray.count);
#endif
	}

	// Tick timer
	logoGeneratingTimer = [NSTimer scheduledTimerWithTimeInterval:[self randomTimeInterval]
														   target:self
														 selector:@selector(randomizeNewLogo)
														 userInfo:nil
														  repeats:NO];
}

- (void) generateMainLogo
{
	// Remove old main logo if still exists
	[mainLogo removeFromSuperlayer];

	// Create new logo
	mainLogo = [self generateFlowingLogoWithImage:logoImage
										   height:mainLogoHeight
								animationDuration:15.0];
	if (!mainLogo) {
		NSLog(@"ERROR: Couldn't generate full logo");
		return;
	}

	mainLogo.zPosition = 10.0;
}

- (LogoLayer*) generateFlowingLogoWithImage:(NSImage*)logoImage height:(CGFloat)height
{
	return [self generateFlowingLogoWithImage:logoImage height:height animationDuration:0];
}

- (LogoLayer*) generateFlowingLogoWithImage:(NSImage*)logoImage height:(CGFloat)height animationDuration:(CGFloat)animationDuration
{
	if (!logoImage) { return nil; }

	CGFloat scale = height / logoImage.size.height;
	CGFloat xOffset = (logoImage.size.width * scale) / 2;

	// Generate random position for logo
	CGPoint startPosition = CGPointMake(rightToLeft ? self.frame.size.width + xOffset : -xOffset,
										(arc4random() % (uint32_t)(self.frame.size.height - logoImage.size.height)) + logoImage.size.height/2);
	CGPoint endPosition = CGPointMake(rightToLeft ? -xOffset : self.frame.size.width + xOffset,
									  startPosition.y);

	// Create new logo
	LogoLayer *newLogo = [[LogoLayer alloc] initWithImage:logoImage];

	// Add layer for making logo darker
	CALayer *darkLayer = [CALayer new];
	{
		NSRect frame = darkLayer.frame;
		frame.size = newLogo.frame.size;
		darkLayer.frame = frame;
	}
	darkLayer.backgroundColor = NSColor.blackColor.CGColor;
	if (height <= logoMinimumHeight) {
		darkLayer.opacity = 1.0;
	}
	else if (height >= logoMaximumHeight) {
		darkLayer.opacity = 0.0;
	}
	else {
		darkLayer.opacity = 1.0 - (((height - logoMinimumHeight) / logoMaximumHeight) * 0.8);
	}
	darkLayer.mask = [[LogoLayer alloc] initWithImage:logoImage];
	[newLogo addSublayer:darkLayer];

	// Setup logo layer
	newLogo.position = startPosition;
	newLogo.zPosition = scale * 10;
	newLogo.transform = CATransform3DMakeScale(scale, scale, 1);
	if (animationDuration > 0.0) {
		newLogo.animationDuration = animationDuration;
	}
	else {
		newLogo.animationDuration /= scale;
	}

	[newLogo setMovementAnimationFromPosition:startPosition toPosition:endPosition timing:kCAMediaTimingFunctionLinear];

	// Add to layer and start animating
	[self addSublayer:newLogo];

	newLogo.logoDelegate = self;
	[newLogo animate];

	return newLogo;
}

#pragma mark - LogoLayer delegate method

- (void) logoShouldBeRemoved:(LogoLayer *)logo
{
	[logoArray removeObject:logo];
	[logo removeFromSuperlayer];

	if (logo == mainLogo) {
		// Set timer for starting new main logo
		mainLogoGeneratingTimer = [NSTimer scheduledTimerWithTimeInterval:[self randomMainLogoTimeInterval]
																   target:self
																 selector:@selector(generateMainLogo)
																 userInfo:nil
																  repeats:NO];
	}
}

@end
