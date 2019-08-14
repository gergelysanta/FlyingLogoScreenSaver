//
//  FlyingLogoView.m
//  FlyingLogo
//
//  Created by Gergely Sánta on 22/04/2018.
//  Copyright © 2018 TriKatz. All rights reserved.
//

#import "FlyingLogoView.h"
#import "LogoLayer.h"

@implementation FlyingLogoView
{
	NSImage *logoImage;
	NSImage *logoImageFull;

	NSMutableArray *logoArray;
	NSUInteger maximumNumberOfLogos;

	CGPoint screenCenterPosition;

	CGRect logoStartSmallFrame;
	CGRect logoStartBigFrame;

	CGFloat spreadFactor;

	CGFloat logoStartingSizeMultiplier;
	CGFloat logoEndingSizeMultiplier;
}

- (instancetype) initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		logoArray = [NSMutableArray arrayWithCapacity:maximumNumberOfLogos];
		maximumNumberOfLogos = 70;

		spreadFactor = 0.15;

		logoStartingSizeMultiplier = 0.1;
		logoEndingSizeMultiplier = 0.8;

        [self setAnimationTimeInterval:1/30.0];

		// Load logo images from bundle
		logoImage = [self loadImageWithName:@"AvastLogo"];
		logoImageFull = [self loadImageWithName:@"AvastLogoFull"];
	}
    return self;
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

- (void) viewDidMoveToWindow
{
	// Create main CALayer displaying additional layers (floating logos)
	CALayer *mainLayer = [CALayer layer];
	self.layer = mainLayer;

	// As initially ScreenSaverView didn't have any backing CALayer, it have wantsLayer turned off
	// We just added backing layer and want to be used by our view, so we need to turn on wantsLayer property
	self.wantsLayer = YES;

	// Set background to black
	mainLayer.backgroundColor = [NSColor blackColor].CGColor;

	// Set layer size (fullscreen)
	mainLayer.frame = self.frame;

	// Set starting and ending scale factors for logos
	if (logoImage) {
		CGFloat neededStartWidth = self.frame.size.width / 100.0;
		CGFloat neededEndWidth = self.frame.size.width / 7.0;

		logoStartingSizeMultiplier = neededStartWidth / logoImage.size.width;
		logoEndingSizeMultiplier = neededEndWidth / logoImage.size.width;
	}

	screenCenterPosition = CGPointMake(self.frame.origin.x + self.frame.size.width/2,
									   self.frame.origin.y + self.frame.size.height/2);

	// Count small frame in the middle of the sceen (big logo will start from here)
	CGSize startFrameSize = CGSizeMake(self.frame.size.width * 0.1, self.frame.size.height * 0.1);
	logoStartSmallFrame = CGRectMake((self.frame.size.width - startFrameSize.width) / 2,
									 (self.frame.size.height - startFrameSize.height) / 2,
									 startFrameSize.width,
									 startFrameSize.height);

	// Count bigger frame in the middle of the sceen (small logos will start from here)
	logoStartBigFrame = CGRectMake(self.frame.size.width * 0.25,
								   self.frame.size.height * 0.25,
								   self.frame.size.width * 0.5,
								   self.frame.size.height * 0.5);

	[self startRandomizedLogoGenerating];
}

- (void) startAnimation
{
    [super startAnimation];
}

- (void) stopAnimation
{
	for (LogoLayer *logo in logoArray) {
		[logo removeAllAnimations];
	}
    [super stopAnimation];
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

- (NSTimeInterval) randomTimeInterval
{
	// Return random time between 0.05s and 0.1s
	NSTimeInterval interval = (arc4random_uniform(50) + 50);
	return interval / 1000;
}

- (NSTimeInterval) randomFullLogoTimeInterval
{
	// Return random time etween 7.0s and 15.0s
	NSTimeInterval interval = (arc4random_uniform(8000) + 7000);
	return interval / 1000;
}

#pragma mark - Logo management

- (void) startRandomizedLogoGenerating
{
	[NSTimer scheduledTimerWithTimeInterval:[self randomTimeInterval]
									 target:self
								   selector:@selector(randomizeNewLogo)
								   userInfo:nil
									repeats:NO];
	[NSTimer scheduledTimerWithTimeInterval:[self randomFullLogoTimeInterval]
									 target:self
								   selector:@selector(generateFullLogo)
								   userInfo:nil
									repeats:NO];
}

- (void) randomizeNewLogo
{
	if (logoArray.count < maximumNumberOfLogos) {
		// Generate random position for logo
		CGFloat xPos = arc4random() % (UInt32)logoStartBigFrame.size.width;
		CGFloat yPos = arc4random() % (UInt32)logoStartBigFrame.size.height;

		// Create new logo
		LogoLayer *logo = [self generateNewLogoWithImage:logoImage
											  atPosition:CGPointMake(logoStartBigFrame.origin.x + xPos,
																	 logoStartBigFrame.origin.y + yPos)];
		if (!logo) {
			NSLog(@"ERROR: Couldn't generate flying logos");
			return;
		}

		[logoArray addObject:logo];
#if DEBUG
		NSLog(@"DEBUG: %lu logos", (unsigned long)logoArray.count);
#endif
	}
	// Tick timer
	[NSTimer scheduledTimerWithTimeInterval:[self randomTimeInterval]
									 target:self
								   selector:@selector(randomizeNewLogo)
								   userInfo:nil
									repeats:NO];
}

- (void) generateFullLogo
{
	// Generate random position for logo
	CGFloat xPos = arc4random() % (UInt32)logoStartSmallFrame.size.width;
	CGFloat yPos = arc4random() % (UInt32)logoStartSmallFrame.size.height;

	// Create new logo
	LogoLayer *logo = [self generateNewLogoWithImage:logoImageFull
										  atPosition:CGPointMake(logoStartSmallFrame.origin.x + xPos,
																 logoStartSmallFrame.origin.y + yPos)
											 scaleTo:1.5];
	if (!logo) {
		NSLog(@"ERROR: Couldn't generate full logo");
		return;
	}

	[logoArray addObject:logo];
#if DEBUG
	NSLog(@"DEBUG: %lu logos", (unsigned long)logoArray.count);
#endif

	// Tick timer
	[NSTimer scheduledTimerWithTimeInterval:[self randomFullLogoTimeInterval]
									 target:self
								   selector:@selector(generateFullLogo)
								   userInfo:nil
									repeats:NO];
}

- (LogoLayer*) generateNewLogoWithImage:(NSImage*)logoImage atPosition:(CGPoint)startPosition scaleTo:(CGFloat)scaleTo
{
	if (!logoImage) { return nil; }

	CGPoint endPosition = CGPointMake(screenCenterPosition.x + (startPosition.x - screenCenterPosition.x)/spreadFactor,
									  screenCenterPosition.y + (startPosition.y - screenCenterPosition.y)/spreadFactor);

	// Create new logo with this colour
	LogoLayer *newLogo = [[LogoLayer alloc] initWithImage:logoImage];
	newLogo.position = startPosition;

	[newLogo setScaleAnimationFromScale:logoStartingSizeMultiplier toScale:logoEndingSizeMultiplier * scaleTo];
	[newLogo setMovementAnimationFromPosition:startPosition toPosition:endPosition];

	// Add to layer and start animating
	[self.layer addSublayer:newLogo];

	newLogo.logoDelegate = self;
	[newLogo animate];

	return newLogo;
}

- (LogoLayer*) generateNewLogoWithImage:(NSImage*)logoImage atPosition:(CGPoint)startPosition
{
	return [self generateNewLogoWithImage:logoImage atPosition:startPosition scaleTo:1.0];
}

#pragma mark - LogoLayer delegate method

- (void) logoShouldBeRemoved:(LogoLayer *)logo
{
	[logoArray removeObject:logo];
	[logo removeFromSuperlayer];
}

@end
