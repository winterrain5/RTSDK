//
//  DrawView.h
//  whiteBoard
//
//  Created by 石冬冬 on 2017/6/27.
//  Copyright © 2017年 Derrick. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DrawView;

typedef NS_ENUM(NSUInteger,DrawViewType) {
    DrawViewTypeReadOnly = 0, // 只读模式
    DrawViewTypeOperable, // 可操作的
};

@protocol DrawViewDelegate <NSObject>

- (void)drawView:(DrawView *)drawView fromPoint:(CGPoint)fromP toPoint:(CGPoint)toP;

@end
@interface DrawView : UIImageView
/**线宽*/
@property (nonatomic, assign) CGFloat linewidth;
/**线条颜色*/
@property (nonatomic, strong) UIColor *lineColor;
/// 代理
@property (nonatomic, weak) id<DrawViewDelegate> delegate;
/// 是否为橡皮擦
@property (nonatomic, assign) BOOL isEarse;

- (instancetype)initDrawViewWithType:(DrawViewType)type;

/**清屏*/
- (void)clearScreen;
/**撤销*/
- (void)undo;
/**恢复*/
- (void)redo;
/**
 给定起始坐标和终点坐标画线
 @param fromP 起始坐标
 @param toP 终点坐标
 */
- (void)drawFromPoint:(CGPoint)fromP toPoint:(CGPoint)toP;



@end
