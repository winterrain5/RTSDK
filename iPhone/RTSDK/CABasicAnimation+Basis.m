//
//  CABasicAnimation+Basis.m
//  Test___________________
//
//  Created by huangsongyao on 2017/7/10.
//  Copyright © 2017年 HSY.Animation.Demo. All rights reserved.
//

#import "CABasicAnimation+Basis.h"
#import "CAAnimationGroup+CompositeAnimation.h"

@implementation CABasicAnimation (Basis)

+ (CABasicAnimation *)faceOut:(CFTimeInterval)times
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:[CABasicAnimation enumToKeyPathByBasicAnimationType:kBasicAnimationKeyPathTypeOpacity]];
    [animation setAnimationProperty:@{
                                      @(kCAAnimationPropertyTypeDuration)               : @(times),
                                      @(kCAAnimationPropertyTypeAutoreverses)           : @(YES),
                                      }];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];
    
    return animation;
}

+ (CABasicAnimation *)transformScale:(CFTimeInterval)times fromValue:(NSNumber *)fromValue toValue:(NSNumber *)toValue
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:[CABasicAnimation enumToKeyPathByBasicAnimationType:kBasicAnimationKeyPathTypeTransformScale]];
    
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    [animation setAnimationProperty:@{
                                      @(kCAAnimationPropertyTypeDuration)               : @(times),
                                      @(kCAAnimationPropertyTypeAutoreverses)           : @(YES),
                                      }];
    return animation;
}

+ (CAAnimationGroup *)diffusionByDelegate:(id<CAAnimationDelegate>)delegate
{
    CFTimeInterval time = 1.0f;
    CABasicAnimation *faceOut = [self.class faceOut:time];
    CABasicAnimation *scale = [self.class transformScale:time fromValue:@(0.0f) toValue:@(1.2f)];
    CAAnimationGroup *group = [CAAnimationGroup groupAnimation:@[faceOut, scale]
                                                 durationTimes:time
                                                   repeatCount:1];
    group.delegate = delegate;
    return group;
}

@end
