//
//  DocumentDetailController.m
//  RTSDK
//
//  Created by 石冬冬 on 2017/7/21.
//  Copyright © 2017年 Derrick. All rights reserved.
//

#import "DocumentDetailController.h"
#import <RtSDK/RtSDK.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface DocumentDetailController () <GSBroadcastDocumentDelegate,GSDocViewDelegate,UIScrollViewDelegate> {
    BOOL _isBtnHide;
}
@property (strong, nonatomic)GSBroadcastManager *broadcastManager;
@property (nonatomic, strong) UIButton *docFullScreenBtn;
@end

@implementation DocumentDetailController

- (UIButton *)docFullScreenBtn {
    if (_docFullScreenBtn == nil) {
        CGRect rect = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT*0.5, 40, 40);
        _docFullScreenBtn = [[UIButton alloc] initWithFrame:rect];
        [_docFullScreenBtn setImage:[UIImage imageNamed:@"doc_noFullScree"] forState:UIControlStateNormal];
        _docFullScreenBtn.backgroundColor = [UIColor colorWithRed:166/255.0 green:166/255.0 blue:166/255.0 alpha:1];
        _docFullScreenBtn.layer.cornerRadius = 20;
        _docFullScreenBtn.layer.masksToBounds = YES;
        [_docFullScreenBtn addTarget:self action:@selector(docFullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _docFullScreenBtn;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    [self initBroadcastManager];
    [self initDocView];
    
    [self.view addSubview:self.docFullScreenBtn];
    [self.view bringSubviewToFront:self.docFullScreenBtn];
    
}

- (void)initDocView {
    self.view.backgroundColor =  [UIColor colorWithRed:53/255.0 green:53/255.0 blue:53/255.0 alpha:1];
    
    self.detailDocView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.detailDocView.gSDocShowType = GSDocEqualWidthType;
    [self.view addSubview:self.detailDocView];
    
    UITapGestureRecognizer *singleTapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDocViewSingleTap:)];
    singleTapGes.numberOfTapsRequired = 1;
    [self.detailDocView addGestureRecognizer:singleTapGes];
}

- (void)initBroadcastManager {
    
    _broadcastManager = [GSBroadcastManager sharedBroadcastManager];
    _broadcastManager.documentView = self.detailDocView;
    _broadcastManager.documentDelegate = self;

}
#pragma mark - documentDelegate
- (void)broadcastManager:(GSBroadcastManager *)manager didReceiveDocModuleInitResult:(BOOL)result {
    
}
#pragma mark - action

- (void)docFullScreenBtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 手势

- (void)handleDocViewSingleTap:(UIGestureRecognizer *)rec {
    _isBtnHide = !_isBtnHide;
    
    __block CGRect originFrame = self.docFullScreenBtn.frame;
    
    if (CGRectGetMinX(self.docFullScreenBtn.frame) == SCREEN_WIDTH - 50) {
        return;
    }
    
    if (!_isBtnHide) {
        
        [UIView animateWithDuration:0.25 animations:^{
            originFrame = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT*0.5, 40, 40);
            self.docFullScreenBtn.frame = originFrame;
        }];
        
    } else {
        
        [UIView animateWithDuration:0.25 animations:^{
            originFrame = CGRectMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT*0.5, 40, 40);
            self.docFullScreenBtn.frame = originFrame;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _isBtnHide = !_isBtnHide;
                [UIView animateWithDuration:0.25 animations:^{
                    originFrame = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT*0.5, 40, 40);
                    self.docFullScreenBtn.frame = originFrame;
                }];
            });
        }];
    }
    
}
@end
