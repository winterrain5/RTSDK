//
//  CABasicAnimation+KeyPath.h
//  Test___________________
//
//  Created by huangsongyao on 2017/7/7.
//  Copyright © 2017年 HSY.Animation.Demo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSUInteger, kBasicAnimationKeyPathType) {
    
    kBasicAnimationKeyPathTypeTransform,
    kBasicAnimationKeyPathTypeTransformScale,                       //视图的宽度和高度比例转换
    kBasicAnimationKeyPathTypeTransformScaleX,                      //视图的宽度比例转换
    kBasicAnimationKeyPathTypeTransformScaleY,                      //视图的高度比例转换
    kBasicAnimationKeyPathTypeTransformTranslation,                 //视图的x和y坐标
    kBasicAnimationKeyPathTypeTransformTranslationX,                //视图x坐标点
    kBasicAnimationKeyPathTypeTransformTranslationY,                //视图y坐标点
    kBasicAnimationKeyPathTypeTransformRotationZ,                   //视图的平面旋轉
    kBasicAnimationKeyPathTypeOpacity,                              //透明度
    kBasicAnimationKeyPathTypeMargin,
    kBasicAnimationKeyPathTypeZPosition,
    kBasicAnimationKeyPathTypeBackgroundColor,
    kBasicAnimationKeyPathTypeCornerRadius,
    kBasicAnimationKeyPathTypeBorderWidth,
    kBasicAnimationKeyPathTypeBounds,
    kBasicAnimationKeyPathTypeContents,
    kBasicAnimationKeyPathTypeContentsRect,
    kBasicAnimationKeyPathTypeFrame,
    kBasicAnimationKeyPathTypeHidden,
    kBasicAnimationKeyPathTypeMask,
    kBasicAnimationKeyPathTypeMasksToBounds,
    kBasicAnimationKeyPathTypePosition,
    kBasicAnimationKeyPathTypeShadowColor,
    kBasicAnimationKeyPathTypeShadowOffset,
    kBasicAnimationKeyPathTypeShadowRadius,
};

@interface CABasicAnimation (KeyPath)

/**
 keyPath动画由协定的枚举，转换为相应的字符串（PS：CABasicAnimation所使用的父类中的keyPath方法，传入的keyPath必须是CALayer的属性成员的属性名称）

 @param type 枚举类型
 @return 枚举对应的属性类型字符串
 */
+ (NSString *)enumToKeyPathByBasicAnimationType:(kBasicAnimationKeyPathType)type;

@end
