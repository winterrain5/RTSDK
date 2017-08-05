//
//  CAAnimation+Property.m
//  Test___________________
//
//  Created by huangsongyao on 2017/7/10.
//  Copyright © 2017年 HSY.Animation.Demo. All rights reserved.
//

#import "CAAnimation+Property.h"

@implementation CAAnimation (Property)

- (void)setAnimationProperty:(NSDictionary<NSNumber *,id> *)property
{
    if (property[@(kCAAnimationPropertyTypeMediaTimingFunction)]) {
        self.timingFunction = property[@(kCAAnimationPropertyTypeMediaTimingFunction)];
    }
    if (property[@(kCAAnimationPropertyTypeRemovedOnCompletion)]) {
        self.removedOnCompletion = [property[@(kCAAnimationPropertyTypeRemovedOnCompletion)] boolValue];
    }
    if (property[@(kCAAnimationPropertyTypeDuration)]) {
        self.duration = [property[@(kCAAnimationPropertyTypeDuration)] floatValue];
    }
    if (property[@(kCAAnimationPropertyTypeBeginTime)]) {
        self.beginTime = [property[@(kCAAnimationPropertyTypeBeginTime)] floatValue];
    }
    if (property[@(kCAAnimationPropertyTypeSpeed)]) {
        self.speed = [property[@(kCAAnimationPropertyTypeSpeed)] floatValue];
    }
    if (property[@(kCAAnimationPropertyTypeAutoreverses)]) {
        self.autoreverses = [property[@(kCAAnimationPropertyTypeAutoreverses)] boolValue];
    }
    if (property[@(kCAAnimationPropertyTypeRepeatCount)]) {
        self.repeatCount = [property[@(kCAAnimationPropertyTypeRepeatCount)] floatValue];
    }
    if (property[@(kCAAnimationPropertyTypeRepeatDuration)]) {
        self.repeatDuration = [property[@(kCAAnimationPropertyTypeRepeatDuration)] floatValue];
    }
    if (property[@(kCAAnimationPropertyTypeFillMode)]) {
        self.fillMode = property[@(kCAAnimationPropertyTypeFillMode)];
    }
}

@end
