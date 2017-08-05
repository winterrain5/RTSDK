//
//  CABasicAnimation+KeyPath.m
//  Test___________________
//
//  Created by huangsongyao on 2017/7/7.
//  Copyright © 2017年 HSY.Animation.Demo. All rights reserved.
//

#import "CABasicAnimation+KeyPath.h"

static NSString *const kCABasicAnimationKeyPathByTransform                      = @"transform";
static NSString *const kCABasicAnimationKeyPathByTransformScale                 = @"transform.scale";
static NSString *const kCABasicAnimationKeyPathByTransformScaleX                = @"transform.scale.x";
static NSString *const kCABasicAnimationKeyPathByTransformScaleY                = @"transform.scale.y";
static NSString *const kCABasicAnimationKeyPathByTransformTranslation           = @"transform.translation";
static NSString *const kCABasicAnimationKeyPathByTransformTranslationX          = @"transform.translation.x";
static NSString *const kCABasicAnimationKeyPathByTransformTranslationY          = @"transform.translation.y";
static NSString *const kCABasicAnimationKeyPathByTransformRotationZ             = @"transform.rotation.z";
static NSString *const kCABasicAnimationKeyPathByOpacity                        = @"opacity";
static NSString *const kCABasicAnimationKeyPathByMargin                         = @"margin";
static NSString *const kCABasicAnimationKeyPathByZPosition                      = @"zPosition";
static NSString *const kCABasicAnimationKeyPathByBackgroundColor                = @"backgroundColor";
static NSString *const kCABasicAnimationKeyPathByCornerRadius                   = @"cornerRadius";
static NSString *const kCABasicAnimationKeyPathByBorderWidth                    = @"borderWidth";
static NSString *const kCABasicAnimationKeyPathByBounds                         = @"bounds";
static NSString *const kCABasicAnimationKeyPathByContents                       = @"contents";
static NSString *const kCABasicAnimationKeyPathByContentsRect                   = @"contentsRect";
static NSString *const kCABasicAnimationKeyPathByFrame                          = @"frame";
static NSString *const kCABasicAnimationKeyPathByHidden                         = @"hidden";
static NSString *const kCABasicAnimationKeyPathByMask                           = @"mask";
static NSString *const kCABasicAnimationKeyPathByMasksToBounds                  = @"masksToBounds";
static NSString *const kCABasicAnimationKeyPathByPosition                       = @"position";
static NSString *const kCABasicAnimationKeyPathByShadowColor                    = @"shadowColor";
static NSString *const kCABasicAnimationKeyPathByShadowOffset                   = @"shadowOffset";
static NSString *const kCABasicAnimationKeyPathByShadowOpacity                  = @"shadowOpacity";
static NSString *const kCABasicAnimationKeyPathByShadowRadius                   = @"shadowRadius";

@implementation CABasicAnimation (KeyPath)

+ (NSString *)enumToKeyPathByBasicAnimationType:(kBasicAnimationKeyPathType)type
{
    NSString *keyPath = nil;
    switch (type) {
        case kBasicAnimationKeyPathTypeTransform: {
            keyPath = kCABasicAnimationKeyPathByTransform;
        }
            break;
        case kBasicAnimationKeyPathTypeTransformScale: {
            keyPath = kCABasicAnimationKeyPathByTransformScale;
        }
            break;
        case kBasicAnimationKeyPathTypeTransformScaleX: {
            keyPath = kCABasicAnimationKeyPathByTransformScaleX;
        }
            break;
        case kBasicAnimationKeyPathTypeTransformScaleY: {
            keyPath = kCABasicAnimationKeyPathByTransformScaleY;
        }
            break;
        case kBasicAnimationKeyPathTypeTransformTranslation: {
            keyPath = kCABasicAnimationKeyPathByTransformTranslation;
        }
            break;
        case kBasicAnimationKeyPathTypeTransformTranslationX: {
            keyPath = kCABasicAnimationKeyPathByTransformTranslationX;
        }
            break;
        case kBasicAnimationKeyPathTypeTransformTranslationY: {
            keyPath = kCABasicAnimationKeyPathByTransformTranslationY;
        }
            break;
        case kBasicAnimationKeyPathTypeTransformRotationZ: {
            keyPath = kCABasicAnimationKeyPathByTransformRotationZ;
        }
            break;
        case kBasicAnimationKeyPathTypeOpacity: {
            keyPath = kCABasicAnimationKeyPathByOpacity;
        }
            break;
        case kBasicAnimationKeyPathTypeMargin: {
            keyPath = kCABasicAnimationKeyPathByMargin;
        }
            break;
        case kBasicAnimationKeyPathTypeZPosition: {
            keyPath = kCABasicAnimationKeyPathByZPosition;
        }
            break;
        case kBasicAnimationKeyPathTypeBackgroundColor: {
            keyPath = kCABasicAnimationKeyPathByBackgroundColor;
        }
            break;
        case kBasicAnimationKeyPathTypeCornerRadius: {
            keyPath = kCABasicAnimationKeyPathByCornerRadius;
        }
            break;
        case kBasicAnimationKeyPathTypeBorderWidth: {
            keyPath = kCABasicAnimationKeyPathByBorderWidth;
        }
            break;
        case kBasicAnimationKeyPathTypeBounds: {
            keyPath = kCABasicAnimationKeyPathByBounds;
        }
            break;
        case kBasicAnimationKeyPathTypeContents: {
            keyPath = kCABasicAnimationKeyPathByContents;
        }
            break;
        case kBasicAnimationKeyPathTypeContentsRect: {
            keyPath = kCABasicAnimationKeyPathByContentsRect;
        }
            break;
        case kBasicAnimationKeyPathTypeFrame: {
            keyPath = kCABasicAnimationKeyPathByFrame;
        }
            break;
        case kBasicAnimationKeyPathTypeHidden: {
            keyPath = kCABasicAnimationKeyPathByHidden;
        }
            break;
        case kBasicAnimationKeyPathTypeMask: {
            keyPath = kCABasicAnimationKeyPathByMask;
        }
            break;
        case kBasicAnimationKeyPathTypeMasksToBounds: {
            keyPath = kCABasicAnimationKeyPathByMasksToBounds;
        }
            break;
        case kBasicAnimationKeyPathTypePosition: {
            keyPath = kCABasicAnimationKeyPathByPosition;
        }
            break;
        case kBasicAnimationKeyPathTypeShadowColor: {
            keyPath = kCABasicAnimationKeyPathByShadowColor;
        }
            break;
        case kBasicAnimationKeyPathTypeShadowOffset: {
            keyPath = kCABasicAnimationKeyPathByShadowOffset;
        }
            break;
        case kBasicAnimationKeyPathTypeShadowRadius: {
            keyPath = kCABasicAnimationKeyPathByShadowRadius;
        }
            break;
        default:
            break;
    }
    return keyPath;
}

@end
