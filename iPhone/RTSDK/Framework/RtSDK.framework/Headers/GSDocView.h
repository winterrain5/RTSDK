//
//  GSDocView.h
//  RtSDK
//
//  Created by Gaojin Hsu on 3/23/15.
//  Copyright (c) 2015 Geensee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSDocPage.h"









@protocol GSDocViewDelegate <NSObject>

@optional

- (void)docViewOpenFinishSuccess:(GSDocPage*)page   docID:(unsigned)docID;

@end




/**
 *  用于显示文档的View
 */
@interface GSDocView : UIScrollView

/**
 *  设置zoomEnabled值，打开和关闭缩放功能，设置为YES表示可以缩放
 */
@property (assign, nonatomic)BOOL zoomEnabled;


/**
 *  设置isVectorScale值，在打开缩放功能的情况下，使用这个这个变量进行缩放方式的选择，yes表示是矢量放大，no表示是一般放大，默认是yes矢量放大
 */
@property (assign, nonatomic)BOOL isVectorScale;




/**
 *  设置文档显示模式，YES为平铺模式，No为正常比例缩放模式
 */
@property (assign, nonatomic)BOOL fullMode;


/**
 *  设置文档文档的显示类型
 */
@property(assign,nonatomic)GSDocShowType  gSDocShowType; //文档的显示类型



/**
 *  TextureCount 如果超过的话，OpenFile返回false, TextureCount =0，不限制
 */
@property (assign, nonatomic)NSUInteger limitTextureCount;

/**
 *  初始化GSDocView对象
 *
 *  @param frame GSDocView对象的矩形区域
 *
 *  @return GSDocView对象
 */
- (id)initWithFrame:(CGRect)frame;


//- (void)drawPage:(GSDocPage*)page  step:(int)step;

- (void)drawPage:(GSDocPage*)page  step:(int)step docID:(unsigned)docID;









//文档代理
@property (nonatomic, weak)id<GSDocViewDelegate> docDelegate;



@property(nonatomic,strong)GSDocPage* currentPage ;




/**
 *  绘制文档页
 *
 *  @param page 文档页对象
 *  @see GSDocPage
 */
- (void)drawPage:(GSDocPage*)page docID:(unsigned)docID;


/**
 *  在文档上绘制标注
 *
 *  @param anno 标注对象
 *  @param page 文档页对象
 *  @see GSAnnoBase
 *  @see GSDocPage
 */
- (void)drawAnno:(GSAnnoBase*)anno onPage:(GSDocPage*)page;


-(void)goToAnimationStep:(int)step;


-(void)clearPageAndAnno;


-(void)setGlkBackgroundColor:(int)red green:(int)green blue:(int)blue;


/**
 *  重新打开文档，视频进行了全屏的切换
 */


- (void)docViewReOpenFile;




- (void)docViewInitRender;


- (void)docViewFreeRender;




- (int)docViewGetCurrentDocAnnoStepCount;



-(void)reSetDocView;




//add  anno
//设置线的颜色
-(void)setupDocAnnoColor:(UIColor*)annoColor;

//设置线框
-(void)setupDocAnnoLineSize:(Byte)LineSize;

//发布端开启标注模式 YES,发布端可以标注，否则不能标注
@property (assign, nonatomic)BOOL isAnnomationModeOpen;

//设置需要绘制那种标注线型
-(void)setupDocAnnoType:(GSDocumentAnnoType)annoType;

//设置线的类型
-(void)setupLineExAnnoType:(LineExAnnoType)lineType;

//设置清除标注的类型
-(void)setupClearAnnoType:(GSDocumentClearAnnoType)clearType;

//设置PointEx的显示类型
-(void)setupPointExType:(GSDocumentPointExAnnoType)pointExType;

@end
