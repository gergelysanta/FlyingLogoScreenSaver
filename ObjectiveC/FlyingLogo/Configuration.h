//
//  Configuration.h
//  FlyingLogo
//
//  Created by Gergely Sánta on 26/09/2019.
//  Copyright © 2019 TriKatz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSInteger {
	SceneTypeSpaceFly,
	SceneTypeHorizontalFlow
} SceneType;

@interface Configuration : NSObject

@property (readonly) NSArray *sceneNames;
@property (readonly) NSDictionary *scenes;
@property (readwrite) SceneType sceneType;

+ (instancetype) shared;

@end

NS_ASSUME_NONNULL_END
