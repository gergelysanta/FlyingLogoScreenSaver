//
//  SceenSaverScene.h
//  FlyingLogo
//
//  Created by Gergely Sánta on 14/08/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScreenSaverScene: CALayer

@property (readonly) NSTimeInterval animationTimeInterval;

- (instancetype) initWithAnimationTimeInterval:(NSTimeInterval)timeInterval;

- (void) start;
- (void) stop;

@end

NS_ASSUME_NONNULL_END
