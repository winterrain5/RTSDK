//
//  CAAnimationGroup+CompositeAnimation.h
//  Test___________________
//
//  Created by huangsongyao on 2017/7/10.
//  Copyright © 2017年 HSY.Animation.Demo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CAAnimation+Property.h"

@interface CAAnimationGroup (CompositeAnimation)

/**
 组合动画

 @param animations 需要合并的动画
 @param times 动画时间
 @param count 动画次数
 @return CAAnimationGroup
 */
+ (CAAnimationGroup *)groupAnimation:(NSArray <CAAnimation *>*)animations durationTimes:(CGFloat)times repeatCount:(CGFloat)count;

@end
