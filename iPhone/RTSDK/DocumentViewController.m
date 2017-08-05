//
//  DocumentViewController.m
//  RTSDK
//
//  Created by 石冬冬 on 2017/7/19.
//  Copyright © 2017年 Derrick. All rights reserved.
//

#import "DocumentViewController.h"
#import <RtSDK/RtSDK.h>
#import <Masonry.h>
#import "DocumentDetailController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface DocumentViewController ()<GSDocViewDelegate,GSBroadcastDocumentDelegate> {
    BOOL _isBtnHide;
}
@property (strong, nonatomic)GSBroadcastManager *broadcastManager;
@property (strong, nonatomic)GSDocView *docView;
///
@property (nonatomic, strong) UIImageView *noDocView;
///
@property (nonatomic, strong) UIButton *docFullScreenBtn;

@end
static BOOL kdocViewNeedHide = YES;
@implementation DocumentViewController
- (UIImageView *)noDocView {
    if (_noDocView == nil) {
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*0.58 - 40);
        _noDocView = [[UIImageView alloc] initWithFrame:rect];
        _noDocView.image = [UIImage imageNamed:@"vod_no_doc"];
        _noDocView.contentMode = UIViewContentModeCenter;
    }
    return _noDocView;
}
- (UIButton *)docFullScreenBtn {
    if (_docFullScreenBtn == nil) {
        CGRect rect = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT*0.26, 40, 40);
        _docFullScreenBtn = [[UIButton alloc] initWithFrame:rect];
        [_docFullScreenBtn setImage:[UIImage imageNamed:@"doc_sidebar_fullscreen"] forState:UIControlStateNormal];
        _docFullScreenBtn.backgroundColor = RGB(166, 166, 166);
        _docFullScreenBtn.layer.cornerRadius = 20;
        _docFullScreenBtn.layer.masksToBounds = YES;
        [_docFullScreenBtn addTarget:self action:@selector(docFullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _docFullScreenBtn;
}
- (GSDocView *)docView {
    if (_docView == nil) {
        
        _docView = [[GSDocView alloc] init];
        _docView.gSDocShowType = GSDocEqualWidthType;
        _docView.zoomEnabled = YES;
        _docView.fullMode = YES;
        _docView.isVectorScale = YES;
        _docView.docDelegate = self;
    }
    return _docView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(53, 53, 53);
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 初始化docView
    [self initDocView];
    [self initBroadcastManager];
}


- (void)initDocView {
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.docView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*0.58 - 40);
    [self.view addSubview:self.docView];
    [self.view addSubview:self.noDocView];
    self.docFullScreenBtn.hidden = YES;
    [self.view addSubview:self.docFullScreenBtn];
    [self.view bringSubviewToFront:self.docFullScreenBtn];

    if (kdocViewNeedHide) {
        self.docView.hidden = YES;
        self.noDocView.hidden = NO;
        kdocViewNeedHide = NO;
    } else {
        self.docView.hidden = NO;
        self.noDocView.hidden = YES;
        kdocViewNeedHide = YES;
    }
    
    UITapGestureRecognizer *singleTapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDocViewSingleTap:)];
    singleTapGes.numberOfTapsRequired = 1;
    [self.docView addGestureRecognizer:singleTapGes];

    
}

- (void)initBroadcastManager {
    _broadcastManager = [GSBroadcastManager sharedBroadcastManager];
    _broadcastManager.documentView = self.docView;
    _broadcastManager.documentDelegate = self;
}

#pragma mark - docViewDelegate

- (void)docViewOpenFinishSuccess:(GSDocPage*)page   docID:(unsigned)docID
{
    if (self.docView.hidden) {
        self.noDocView.hidden = YES;
        self.docView.hidden=NO;
    }
}

- (void)broadcastManager:(GSBroadcastManager *)manager didReceiveDocModuleInitResult:(BOOL)result {
    
}

/**
 *  文档关闭代理
 */
- (void)broadcastManager:(GSBroadcastManager *)manager didCloseDocument:(unsigned)docID{
    self.docView.hidden = YES;
    self.noDocView.hidden = NO;
    kdocViewNeedHide = YES;
}

#pragma mark - 手势
// 单击手势
- (void)handleDocViewSingleTap:(UIGestureRecognizer *)rec {
    
    self.docFullScreenBtn.hidden = NO;
    _isBtnHide = !_isBtnHide;
    
    __block CGRect originFrame = self.docFullScreenBtn.frame;
    
    if (CGRectGetMinX(self.docFullScreenBtn.frame) == SCREEN_WIDTH - 50) {
        return;
    }
    
    if (!_isBtnHide) {
        
        [UIView animateWithDuration:0.25 animations:^{
            originFrame = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT*0.26, 40, 40);
            self.docFullScreenBtn.frame = originFrame;
        }];
        
    } else {
        
       [UIView animateWithDuration:0.25 animations:^{
           originFrame = CGRectMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT*0.26, 40, 40);
           self.docFullScreenBtn.frame = originFrame;
       } completion:^(BOOL finished) {
           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               _isBtnHide = !_isBtnHide;
               [UIView animateWithDuration:0.25 animations:^{
                   originFrame = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT*0.26, 40, 40);
                   self.docFullScreenBtn.frame = originFrame;
               }];
           });
       }];
    }
    
}

#pragma mark - action

// 全屏文档
- (void)docFullScreenBtnClick:(UIButton *)sender {

    DocumentDetailController *vc = [[DocumentDetailController alloc] init];
    vc.detailDocView = self.docView;
    [self presentViewController:vc animated:YES completion:nil];
   
}

@end
