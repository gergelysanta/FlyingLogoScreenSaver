//
//  LogoLayer.m
//  FlyingLogo
//
//  Created by Gergely Sánta on 22/04/2018.
//  Copyright © 2018 TriKatz. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "LogoLayer.h"

@implementation LogoLayer

- (instancetype) init
{
	if (self = [super init]) {
		_animationDuration = 5.0;
		_fadeDuration = 1.0;
	}
	return self;
}

- (instancetype) initWithImage:(NSImage*)image
{
	if (self = [self init]) {
		[self initializeWithImage:image];
	}
	return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	return self;
}

- (void) initializeWithImage:(NSImage*)image
{
	self.contents = image;

	CGRect frame = self.frame;
	frame.size = image.size;
	self.frame = frame;
}

- (void) setScaleAnimationFromScale:(CGFloat)fromScale toScale:(CGFloat)toScale
{
	_scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];

	// We just created the animation, it exists for sure
	// so we can forcewrap the optional in this method
	self.scaleAnimation.fromValue = [NSNumber numberWithDouble:fromScale];
	self.scaleAnimation.toValue = [NSNumber numberWithDouble:toScale];
	self.scaleAnimation.duration = self.animationDuration;

	// Set timing to animate slower at the beginning and faster at the end
	self.scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

	// Don't do reverse animation
	self.scaleAnimation.autoreverses = NO;

	// The default behavior of how animations look (their fill mode) is kCAFillModeRemoved
	// which means that just after the duration of the animation the layer will look as if the animation never happened.
	// By changing to kCAFillModeForwards we make the layer look as if it remained in the end state of the animation.
	self.scaleAnimation.fillMode = kCAFillModeForwards;
	self.scaleAnimation.removedOnCompletion = NO;

	// Bigger logos are visually closer to camera so we need to animate also the z position
	_zposAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];

	// We just created the animation, it exists for sure
	// so we can forcewrap the optional in this method
	self.zposAnimation.fromValue = [NSNumber numberWithDouble:fromScale];
	self.zposAnimation.toValue = [NSNumber numberWithDouble:toScale];
	self.zposAnimation.duration = self.animationDuration;

	// Set timing to animate slower at the beginning and faster at the end
	self.zposAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];

	// Don't do reverse animation
	self.zposAnimation.autoreverses = NO;

	// The default behavior of how animations look (their fill mode) is kCAFillModeRemoved
	// which means that just after the duration of the animation the layer will look as if the animation never happened.
	// By changing to kCAFillModeForwards we make the layer look as if it remained in the end state of the animation.
	self.zposAnimation.fillMode = kCAFillModeForwards;
	self.zposAnimation.removedOnCompletion = NO;
}

- (void) setMovementAnimationFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition
{
	return [self setMovementAnimationFromPosition:fromPosition toPosition:toPosition timing:kCAMediaTimingFunctionEaseIn];
}

- (void) setMovementAnimationFromPosition:(CGPoint)fromPosition toPosition:(CGPoint)toPosition timing:(CAMediaTimingFunctionName)timingFunctionName
{
	_moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];

	// We just created the animation, it exists for sure
	// so we can forcewrap the optional in this method
	self.moveAnimation.fromValue = [NSValue valueWithPoint:fromPosition];
	self.moveAnimation.toValue = [NSValue valueWithPoint:toPosition];
	self.moveAnimation.duration = self.animationDuration;

	// Set timing to animate slower at the beginning and faster at the end
	self.moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunctionName];

	// Don't do reverse animation
	self.moveAnimation.autoreverses = NO;

	// The default behavior of how animations look (their fill mode) is kCAFillModeRemoved
	// which means that just after the duration of the animation the layer will look as if the animation never happened.
	// By changing to kCAFillModeForwards we make the layer look as if it remained in the end state of the animation.
	self.moveAnimation.fillMode = kCAFillModeForwards;
	self.moveAnimation.removedOnCompletion = NO;

	// Set delegate to self, so 'animationDidStop' of this object will be called when movement ended
	self.moveAnimation.delegate = self;
}

- (void) animate
{
	// Run animations
	if (self.moveAnimation) {
		[self addAnimation:self.moveAnimation forKey:@"MoveAnimation"];
	}
	if (self.zposAnimation) {
		[self addAnimation:self.zposAnimation forKey:@"ZPosAnimation"];
	}
	if (self.scaleAnimation) {
		[self addAnimation:self.scaleAnimation forKey:@"ScaleAnimation"];
		
		// Start to fade out before animation ends
		[NSTimer scheduledTimerWithTimeInterval:self.animationDuration - self.fadeDuration
										 target:self
									   selector:@selector(fadeOut)
									   userInfo:nil
										repeats:NO];
	}
}

- (void) fadeOut
{
	CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];

	fadeAnimation.toValue = [NSNumber numberWithDouble:0.0];
	fadeAnimation.duration = self.fadeDuration;

	// Don't do reverse animation
	fadeAnimation.autoreverses = NO;

	// The default behavior of how animations look (their fill mode) is kCAFillModeRemoved
	// which means that just after the duration of the animation the layer will look as if the animation never happened.
	// By changing to kCAFillModeForwards we make the layer look as if it remained in the end state of the animation.
	fadeAnimation.fillMode = kCAFillModeForwards;
	fadeAnimation.removedOnCompletion = NO;

	[self addAnimation:fadeAnimation forKey:@"FadeOutAnimation"];
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	[self.logoDelegate logoShouldBeRemoved:self];
}

@end
