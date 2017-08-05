//
//  DrawView.m
//  whiteBoard
//
//  Created by 石冬冬 on 2017/6/27.
//  Copyright © 2017年 Derrick. All rights reserved.
//

#import "DrawView.h"

@interface PaintPath : UIBezierPath
+ (instancetype) paintPathWithLineWidth:(CGFloat) width
                             startPoint:(CGPoint) startPoint;
@end

@implementation PaintPath

+ (instancetype) paintPathWithLineWidth:(CGFloat) width
                             startPoint:(CGPoint) startPoint{
    
    PaintPath *path = [[self alloc] init];
    path.lineWidth = width;
    
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    [path moveToPoint:startPoint];
    return path;
}

@end


@interface DrawView ()
@property (nonatomic, strong) PaintPath *path;
@property (nonatomic, strong) CAShapeLayer *slayer;
/**撤销的线条数组*/
@property (nonatomic, strong) NSMutableArray *canceledLines;
/**线条数组*/
@property (nonatomic, strong) NSMutableArray *lines;
/// 前一个坐标点
@property (nonatomic, assign) CGPoint fromPoint;
@end

@implementation DrawView
- (NSMutableArray *)lines {
    if (!_lines) {
        _lines = [NSMutableArray array];
    }
    return _lines;
}

- (NSMutableArray *)canceledLines {
    if (!_canceledLines) {
        _canceledLines = [NSMutableArray array];
    }
    return _canceledLines;
}

- (instancetype)initDrawViewWithType:(DrawViewType)type {
    if (self = [super init]) {
        self.lineColor = [UIColor redColor];
        self.linewidth = 3;
        self.userInteractionEnabled =  type;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // 默认线条颜色红色
    self.lineColor = [UIColor redColor];
    self.linewidth = 3;
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 默认线条颜色红色
        self.lineColor = [UIColor redColor];
        self.linewidth = 3;
        
    }
    return  self;
}


#pragma mark ----- private methoh

/**
 获取触摸点坐标  并计算相对坐标
 
 @param touches 触摸点
 @return 坐标
 */
- (CGPoint) pointWithTouches:(NSSet *) touches {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat superWidth = self.superview.width;
    CGFloat superHeight = self.superview.height;
    CGFloat rx = (point.x / superWidth);
    CGFloat ry = (point.y / superHeight);
    CGPoint rPoint = CGPointMake(rx, ry);
    return  rPoint;
}

// 开始触摸屏幕
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 线条起点
    self.fromPoint = [self pointWithTouches:touches];
    
    CGPoint startP = [[touches anyObject] locationInView:self];
    
    
    if ([event allTouches].count == 1) { // 触摸点只有一个 绘制起点
        PaintPath *path = [PaintPath paintPathWithLineWidth:self.linewidth startPoint:startP];
        _path = path;
        CGBlendMode mode = self.isEarse ? kCGBlendModeClear : kCGBlendModeNormal;
        CGFloat alpha = self.isEarse ? 0 : 1;
        [_path fillWithBlendMode:mode alpha:alpha];
        // 通过CAShapeLayer画线
        CAShapeLayer *slayer = [CAShapeLayer layer];
        slayer.path = path.CGPath;
        slayer.backgroundColor = [UIColor clearColor].CGColor;
        slayer.fillColor = [UIColor clearColor].CGColor;
        slayer.lineCap = kCALineCapRound;
        slayer.lineJoin = kCALineJoinRound;
        slayer.strokeColor = self.isEarse ? self.backgroundColor.CGColor : self.lineColor.CGColor;
        slayer.lineWidth = self.isEarse ? 8.f : path.lineWidth;
        [self.layer addSublayer:slayer];
        _slayer = slayer;
        
        [[self mutableArrayValueForKey:@"canceledLines"] removeAllObjects];
        [[self mutableArrayValueForKey:@"lines"] addObject:_slayer];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 获取移动点
    CGPoint moveP = [self pointWithTouches:touches];
    [self respondDelegateWithPoint:moveP];
    
    // 获取移动中的上一个坐标点
    UITouch *touch = [touches anyObject];
    CGPoint fromPoint = [touch previousLocationInView:self];
    CGFloat superWidth = self.superview.width;
    CGFloat superHeight = self.superview.height;
    CGFloat rx = (fromPoint.x / superWidth) ;
    CGFloat ry = (fromPoint.y / superHeight);
    CGPoint rPoint = CGPointMake(rx, ry);
    self.fromPoint = rPoint;
    
    // 获取当前需要画线的点
    CGPoint point = [[touches anyObject] locationInView:self];
    
    if ([event allTouches].count > 1) { // 触摸点大于一个 父容器处理该事件
        [self.superview touchesMoved:touches withEvent:event];
    } else if ([event allTouches].count == 1) { // 绘制线条到移动点
        [_path addLineToPoint:point];
        _slayer.path = _path.CGPath;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 获取结束点
    CGPoint endP = [self pointWithTouches:touches];
    [self respondDelegateWithPoint:endP];
    
    if ([event allTouches].count > 1) { // 触摸点大于一个 父容器处理该事件
        [self.superview touchesEnded:touches withEvent:event];
    }
}

/**
 画线
 */
- (void)drawLine {
    [self.layer addSublayer:self.lines.lastObject];
}


#pragma mark ----- public method

- (void) respondDelegateWithPoint:(CGPoint)toP {
    if ([self.delegate respondsToSelector:@selector(drawView:fromPoint:toPoint:)]) {
        [self.delegate drawView:self fromPoint:self.fromPoint toPoint:toP];
    }
}

// 绘图
/////////////////////////////////////////////////////////
/**
 清屏
 */
- (void) clearScreen {
    if (!self.lines.count) return ;
    [self.lines makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [[self mutableArrayValueForKey:@"lines"] removeAllObjects];
    [[self mutableArrayValueForKey:@"canceledLines"] removeAllObjects];
    
}

/**
 撤销
 */
- (void) undo {
    //当前屏幕已经清空，就不能撤销了
    if (!self.lines.count) return;
    [[self mutableArrayValueForKey:@"canceledLines"] addObject:self.lines.lastObject];
    [self.lines.lastObject removeFromSuperlayer];
    [[self mutableArrayValueForKey:@"lines"] removeLastObject];
}

/**
 恢复
 */
- (void) redo {
    //当没有做过撤销操作，就不能恢复了
    if (!self.canceledLines.count) return;
    [[self mutableArrayValueForKey:@"lines"] addObject:self.canceledLines.lastObject];
    [[self mutableArrayValueForKey:@"canceledLines"] removeLastObject];
    [self drawLine];
}

/**
 给定起始坐标和终点坐标画线
 
 @param fromP 起始坐标
 @param toP 终点坐标
 */
- (void)drawFromPoint:(CGPoint)fromP toPoint:(CGPoint)toP{
    NSLog(@"%s,%@",__func__,[NSThread currentThread]);
    // 线的路径
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    // 起点
    [linePath moveToPoint:fromP];
    // 其他点
    [linePath addLineToPoint:toP];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    
    lineLayer.lineWidth = 2;
    lineLayer.strokeColor = [UIColor redColor].CGColor;
    lineLayer.path = linePath.CGPath;
    lineLayer.lineCap = kCALineCapRound;
    lineLayer.lineJoin = kCALineJoinRound;
    lineLayer.fillColor = nil; // 默认为blackColor
    
    [self.layer addSublayer:lineLayer];
    
    [[self mutableArrayValueForKey:@"canceledLines"] removeAllObjects];
    [[self mutableArrayValueForKey:@"lines"] addObject:lineLayer];
}

@end
