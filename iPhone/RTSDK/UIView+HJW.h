//
//  UIView+HJW.h
//  zhuoyan
//
//  Created by Lion_Lemon on 16/9/7.
//  Copyright © 2016年 Lion_Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>

CGPoint CGRectGetCenter(CGRect rect);
CGRect CGRectMoveToCenter(CGRect rect, CGPoint center);

/**
 *  边框类型设置 可多选
 */
typedef NS_OPTIONS(NSUInteger, HJWBorder) {
    HJWBorderLeft   = 1 << 0,
    HJWBorderRight  = 1 << 1,
    HJWBorderTop    = 1 << 2,
    HJWBorderBottom = 1 << 3,
    HJWBorderAll    = ~0UL
};

/**
 *  圆角类型设置
 */
typedef NS_OPTIONS(NSUInteger, HJWCorner) {
    HJWCornerLeft,
    HJWCornerRight,
    HJWCornerTop,
    HJWCornerBottom,
    HJWCornerAll,
};

@interface UIView (HJW)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;

@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, readonly) CGPoint bottomLeft;
@property (nonatomic, readonly) CGPoint bottomRight;
@property (nonatomic, readonly) CGPoint topRight;

- (void)moveBy:(CGPoint)delta;
- (void)scaleBy:(CGFloat)scaleFactor;
- (void)fitInSize:(CGSize)aSize;
/** 获取View所在的控制器 */
- (UIViewController *)viewController;

#pragma mark - 其它的效果😎
/** 变圆 */
- (UIView *)roundV;
/**  加阴影 self.layer.shadowOffset = CGSizeMake(0, 2)self.layer.shadowOpacity = 0.2; */
- (void)addShadow;

typedef void (^GestureActionBlock)(UIGestureRecognizer *ges);
/** 单点击手势 */
- (void)tapGesture:(GestureActionBlock)block;
/** 长按手势 */
- (void)longPressGestrue:(GestureActionBlock)block;

/** 添加边框:四边 */
- (void)border:(UIColor *)color width:(CGFloat)width CornerRadius:(CGFloat)radius;
/** 添加边框:四边 默认4*/
- (void)border:(UIColor *)color width:(CGFloat)width;
/** 四边变圆 */
- (void)borderRoundCornerRadius:(CGFloat)radius;
/** 四边变圆 默认4*/
- (void)borderRound;

- (void)debug:(UIColor *)color width:(CGFloat)width;
/** 移除对应的view */
- (void)removeClassView:(Class)classV;

/** 画线 */
+ (CAShapeLayer *)drawLine:(CGPoint)points to:(CGPoint)pointe color:(UIColor *)color;

/** 画框框线 */
+ (CAShapeLayer *)drawRect:(CGRect)rect radius:(CGFloat)redius color:(UIColor *)color;

/** 画圆 */
+ (CAShapeLayer *)drawArc:(CGPoint)points radius:(CGFloat)radius startD:(CGFloat)startd endD:(CGFloat)endD color:(UIColor *)color;

/** 利用mask设置圆角 */
- (void)hjw_setCornerWithType:(HJWCorner)cornerType cornerRadius:(CGFloat)radius;
/** 边框 设置好frame再设置边框 */
- (void)hjw_setBorders:(HJWBorder)Borders color:(UIColor*) color width:(CGFloat) width;
@end
