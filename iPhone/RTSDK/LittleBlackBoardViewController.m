//
//  LittleBlackBoardViewController.m
//  RTSDK
//
//  Created by Derrick on 2017/7/28.
//  Copyright © 2017年 Derrick. All rights reserved.
//

#import "LittleBlackBoardViewController.h"
#import "DrawView.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYWebImage/UIImage+YYWebImage.h>
@interface LittleBlackBoardViewController ()
///
@property (nonatomic, strong)  DrawView *drawView;
///
@property (nonatomic, strong) UIScrollView *scrollView;
///
@property (nonatomic, strong) NSMutableArray *urlArray;
@end

@implementation LittleBlackBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _urlArray = @[].mutableCopy;
    
    [self initDrawView];
    [self setupNotification];
    
}

- (void)initDrawView {
    
    CGRect rect = CGRectMake(0, 0, kScreenWidth, kScreenHeight*0.58 - 40);
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    [self.view addSubview:_scrollView];
    
    _drawView = [[DrawView alloc] initDrawViewWithType:DrawViewTypeReadOnly];
    _drawView.backgroundColor = [UIColor whiteColor];
    _drawView.frame = rect;
    [_scrollView addSubview:_drawView];

}

- (void)setupNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDocumentNotification:) name:kLoadDocumentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawLineNotification:) name:kDrawLineNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearScreenNotificatio:) name:kClearScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearBackImageNotification:) name:kClearBackImageNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undoNotification:) name:kUndoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDocNotification:) name:kChangeDocNotification object:nil];
    
}

#pragma mark - notification

// 加载图片
- (void)loadDocumentNotification:(NSNotification *)noti {
    NSURL *url = [NSURL URLWithString:noti.userInfo[@"data"]];
    [_urlArray addObject:url];
    
    [self downImageWithUrl:_urlArray[0]];
}


// 画线
- (void)drawLineNotification:(NSNotification *)noti {
    NSDictionary *dict  = noti.userInfo[@"data"];
    CGFloat superWidth  = self.view.width;
    CGFloat superHeight = _drawView.height;
    CGFloat fromPX      = [dict[@"fx"] floatValue] * superWidth;
    CGFloat fromPY      = [dict[@"fy"] floatValue] * superHeight;
    CGFloat toPX        = [dict[@"tx"] floatValue] * superWidth;
    CGFloat toPY        = [dict[@"ty"] floatValue] * superHeight;
    CGPoint fromP       = CGPointMake(fromPX, fromPY);
    CGPoint toP         = CGPointMake(toPX, toPY);
    [_drawView drawFromPoint:fromP toPoint:toP];
}

// 清屏
- (void)clearScreenNotificatio:(NSNotification *)noti {
    [_drawView clearScreen];
}

// 清除背景图片
- (void)clearBackImageNotification:(NSNotification *)noti {
    _drawView.image = nil;
}

- (void)undoNotification:(NSNotification *)noti {
     [_drawView undo];
}

// 更改文档图片
- (void)changeDocNotification:(NSNotification *)noti {
    NSInteger index = [noti.userInfo[@"data"] integerValue];
    NSURL *url = _urlArray[index];
    [self downImageWithUrl:url];
}

- (void)downImageWithUrl:(NSURL *)url {
    __block CGFloat progress = 0.f;
    [SVProgressHUD show];
    [_drawView yy_setImageWithURL:url
                      placeholder:nil
                          options:YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionProgressive
                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             progress = (float)receivedSize / expectedSize;
                             
                         }
                        transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                            return [self imageCompressForWidth:image targetWidth:kScreenWidth];
                        }
                       completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                           [SVProgressHUD dismiss];
                           if (!error) {
                               CGFloat height = MAX(kScreenHeight*0.58 - 40, image.size.height);
                               _drawView.height = height;
                               _scrollView.contentSize = CGSizeMake(0, height);
                               [self.view layoutIfNeeded];
                           }
                           if (from == YYWebImageFromDiskCache) {
                               NSLog(@"load from disk cache");
                           }
                       }];
}

-(UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
