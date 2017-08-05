//
//  CABasicAnimation+Basis.h
//  Test___________________
//
//  Created by huangsongyao on 2017/7/10.
//  Copyright © 2017年 HSY.Animation.Demo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CABasicAnimation+KeyPath.h"
#import "CAAnimation+Property.h"

@interface CABasicAnimation (Basis)

/**
 组合动画，组合放缩和淡入淡出两个动画

 @param delegate 动画的委托
 @return CAAnimationGroup
 */
+ (CAAnimationGroup *)diffusionByDelegate:(id<CAAnimationDelegate>)delegate;

@end
