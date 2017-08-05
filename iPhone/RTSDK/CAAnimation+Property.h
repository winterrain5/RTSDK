//
//  CAAnimation+Property.h
//  Test___________________
//
//  Created by huangsongyao on 2017/7/10.
//  Copyright © 2017年 HSY.Animation.Demo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

//kCAFillModeForwards(设置为该值，动画即使之后layer的状态将保持在动画的最后一帧，而removedOnCompletion的默认属性值是 YES，所以为了使动画结束之后layer保持结束状态，应将removedOnCompletion设置为NO。)
//kCAFillModeBackwards(设置为该值，将会立即执行动画的第一帧，不论是否设置了 beginTime属性。)
//kCAFillModeBoth(该值是 kCAFillModeForwards 和 kCAFillModeBackwards的组合状态)
//kCAFillModeRemoved(设置为该值，动画将在设置的 beginTime 开始执行（如没有设置beginTime属性，则动画立即执行），动画执行完成后将会layer的改变恢复原状。)
typedef NS_ENUM(NSUInteger, kCAAnimationPropertyType) {
    
    kCAAnimationPropertyTypeMediaTimingFunction,                //设定动画的速度变化
    kCAAnimationPropertyTypeRemovedOnCompletion,                //动画结束后是否移除动画
    kCAAnimationPropertyTypeDuration,                           //动画时长，默认为0
    kCAAnimationPropertyTypeBeginTime,                          //指定动画开始时间。从开始指定延迟几秒执行的话，请设置为 CACurrentMediaTime() + 秒数」的形式。默认为0
    kCAAnimationPropertyTypeSpeed,                              //动画速度，默认为1，表示单倍速度
    kCAAnimationPropertyTypeAutoreverses,                       //动画结束后，是否执行逆向动画，默认是NO
    kCAAnimationPropertyTypeRepeatCount,                        //动画重复执行次数，不能和repeatDuration一起使用
    kCAAnimationPropertyTypeRepeatDuration,                     //动画重复执行的时间，不能和repeatCount一起使用
    kCAAnimationPropertyTypeFillMode,                           //类型包括：kCAFillModeForwards，kCAFillModeBackwards，kCAFillModeBoth，kCAFillModeRemoved

};

@interface CAAnimation (Property)

/**
 设置基础值，格式为@{@(枚举类型) : id}

 @param property 基础值
 */
- (void)setAnimationProperty:(NSDictionary <NSNumber *, id>*)property;

@end
