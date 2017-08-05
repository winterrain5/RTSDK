//
//  CAAnimationGroup+CompositeAnimation.m
//  Test___________________
//
//  Created by huangsongyao on 2017/7/10.
//  Copyright © 2017年 HSY.Animation.Demo. All rights reserved.
//

#import "CAAnimationGroup+CompositeAnimation.h"

@implementation CAAnimationGroup (CompositeAnimation)

+ (CAAnimationGroup *)groupAnimation:(NSArray <CAAnimation *>*)animations durationTimes:(CGFloat)times repeatCount:(CGFloat)count
{
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = animations;
    [animation setAnimationProperty:@{
                                      @(kCAAnimationPropertyTypeRemovedOnCompletion)    : @(NO),
                                      @(kCAAnimationPropertyTypeDuration)               : @(times),
                                      @(kCAAnimationPropertyTypeRepeatCount)            : @(count),
                                      @(kCAAnimationPropertyTypeFillMode)               : kCAFillModeForwards,
                                      }];
    return animation;
}

@end
