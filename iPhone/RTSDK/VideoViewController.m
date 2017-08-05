//
//  VideoViewController.m
//  RTSDK
//
//  Created by 石冬冬 on 2017/7/19.
//  Copyright © 2017年 Derrick. All rights reserved.
//

#import "VideoViewController.h"
#import "AppDelegate.h"
#import "MLMSegmentPageView.h"
#import "Reachability.h"
#import "DSDragView.h"
#import "SCCheckInView.h"
#import "SCAudioWaveView.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface VideoViewController ()<GSBroadcastRoomDelegate,GSBroadcastVideoDelegate,GSBroadcastDesktopShareDelegate,GSBroadcastAudioDelegate> {
    
    BOOL _isNavHide; // 是否隐藏导航栏
    BOOL _isHandUp; // 是否举手
    
    Reachability* _reach;
    NetworkStatus _status;
    
    BOOL _isVideoFullScreen; // 是否全屏
    BOOL _isCameraOpen; // 是否打开摄像头
    
    NSString *_currentKey; // 当前在提问席的key
    
}
/// 直播管理类，管着所有的直播相关操作，包括加入直播，退出播，发送信息等
@property (nonatomic, strong) GSBroadcastManager *broadcastManager;
/// 直播视图
@property (nonatomic, strong) GSVideoView *videoView;
/// 预览视图
@property (nonatomic, strong) GSVideoView *qaVideoView;
/// 直播视图的尺寸
@property (assign, nonatomic)CGRect originalVideoFrame;

/// 当前用户的信息
@property (nonatomic, strong) GSUserInfo *userInfo;

/// 当前激活的视频id
@property (nonatomic, assign) long long  currentActiveUserID;

// 当前是哪种视频在播放
@property (assign, nonatomic)BOOL isCameraVideoDisplaying;
@property (assign, nonatomic)BOOL isLodVideoDisplaying;
@property (assign, nonatomic)BOOL isDesktopShareDisplaying;

// 自定义导航
@property (weak, nonatomic) IBOutlet UIView *customNavView;
@property (weak, nonatomic) IBOutlet UIImageView *noVideoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navTopCons;
@property (weak, nonatomic) IBOutlet UIImageView *navImgView;
@property (weak, nonatomic) IBOutlet UIView *tintBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *tintLable;

/// segment
@property (nonatomic, strong) MLMSegmentHead *seghead;
/// segScroll
@property (nonatomic, strong) MLMSegmentScroll *segScroll;
///
@property (nonatomic, strong) UIButton *handsUpBtn;
/// 视频全屏按钮
@property (nonatomic, strong) UIButton *videoFullScreenBtn;
/// 提问席视图
@property (nonatomic, strong) DSDragView *dragView;
/// 音量视图
@property (nonatomic, strong) SCAudioWaveView *audioWaveView;
// 定时器
@property (nonatomic, strong) dispatch_source_t timer;
/// 当前在提问席的userID
@property (nonatomic, strong) NSMutableSet *currentAskerID;
/// 当前在讲台的userID
@property (nonatomic, strong) NSMutableSet *currentRostrunID;
@end

@implementation VideoViewController
- (NSMutableSet *)currentAskerID {
    if (_currentAskerID == nil) {
        _currentAskerID = [NSMutableSet set];
    }
    return _currentAskerID;
}
- (NSMutableSet *)currentRostrunID {
    if (_currentRostrunID == nil) {
        _currentRostrunID = [NSMutableSet set];
    }
    return _currentRostrunID;
}
- (GSVideoView *)qaVideoView {
    if (_qaVideoView == nil) {
        _qaVideoView = [[GSVideoView alloc] init];
        _qaVideoView.videoViewContentMode = GSVideoViewContentModeRatioFill;
        
    }
    return _qaVideoView;
}

- (UIButton *)videoFullScreenBtn {
    if (_videoFullScreenBtn == nil) {
        CGRect rect = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT*0.26, 40, 40);
        _videoFullScreenBtn = [[UIButton alloc] initWithFrame:rect];
        [_videoFullScreenBtn setImage:[UIImage imageNamed:@"video_full"] forState:UIControlStateNormal];
        _videoFullScreenBtn.backgroundColor = RGB(18, 18, 18);
        _videoFullScreenBtn.layer.cornerRadius = 20;
        _videoFullScreenBtn.layer.masksToBounds = YES;
        [_videoFullScreenBtn addTarget:self action:@selector(videoFullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoFullScreenBtn;
}
- (SCAudioWaveView *)audioWaveView {
    if (_audioWaveView == nil) {
        _audioWaveView = [[SCAudioWaveView alloc] init];
        __weak __typeof(self)weakSelf = self;
        _audioWaveView.AudioHangupBlock = ^{
            if ([weakSelf.broadcastManager inactivateMicrophone]) {
//                [BaseMethod showError:@"麦克风已关闭"];
            }
        };
    }
    return _audioWaveView;
}
#pragma mark - init
- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加播放视图
    [self initVieoView];
    // 初始化分类导航视图
    [self initSegmentView];
    // 初始化顶部导航视图
    [self initCustomNavView];
    
    [self initNavTitle];
    
    [SVProgressHUD showWithStatus:@"直播连接中"];
    // 初始化管理类
    [self initBroadCastManager];
    
    [self setupNotifications];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [_dragView removeFromSuperview];
}

/// 添加预览视图
- (void)addPreviewVideoViewWithFrame:(CGRect)frame videoViewFrame:(CGRect)videoFrame buttonHidden:(BOOL)hidden{
    
    _dragView                 = [[DSDragView alloc] init];
    _dragView.frame           = frame;
    [_dragView addSubview:self.qaVideoView];
    _dragView.backgroundColor = self.view.backgroundColor;
    _dragView.dragEnable      = !hidden;
    
    self.qaVideoView.frame = videoFrame;
    
    _dragView.button.frame  = CGRectMake(0, CGRectGetMaxY(self.qaVideoView.frame), _dragView.width, 30);
    _dragView.button.hidden = hidden;
    [_dragView.button addTarget:self action:@selector(endQuestionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_dragView.button setImage:[UIImage imageNamed:@"video_Hang"] forState:UIControlStateNormal];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:_dragView];
}

- (void)initVieoView {
    CGSize viewSize     = self.view.frame.size;
    _originalVideoFrame = CGRectMake(0, 0, viewSize.width, viewSize.height*0.42);
    self.videoView      = [[GSVideoView alloc] initWithFrame:_originalVideoFrame];
    UITapGestureRecognizer *tapGes      = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleVideoViewTap:)];
    tapGes.numberOfTapsRequired = 1;
    self.videoView.videoViewContentMode = GSVideoViewContentModeRatioFill;
    
    
    self.noVideoView.userInteractionEnabled = YES;
    [self.noVideoView addGestureRecognizer:tapGes];
    [self.videoView addGestureRecognizer:tapGes];
    [self.view addSubview:self.videoView];
    [self.view addSubview:self.videoFullScreenBtn];
    [self.view bringSubviewToFront:self.videoFullScreenBtn];
    
    self.tintBackgroundView.backgroundColor = RGBA(18, 18, 18, 0.4);
    self.tintLable.text = @"直播正在开启...";

}

- (void)initSegmentView {
    NSArray *list = @[@"文档",@"聊天",@"小黑板"];
    CGRect rect = CGRectMake(12, CGRectGetMaxY(_videoView.frame), SCREEN_WIDTH, 40);
    MLMSegmentHead *seghead= [[MLMSegmentHead alloc] initWithFrame:rect titles:list headStyle:SegmentHeadStyleLine layoutStyle:MLMSegmentLayoutLeft];
    self.seghead       = seghead;
    seghead.fontScale  = 1.15;
    seghead.lineScale  = 0.8;
    seghead.fontSize   = 15;
    seghead.lineHeight = 1.5;
    
    seghead.lineColor         = [UIColor whiteColor];
    seghead.selectColor       = [UIColor whiteColor];
    seghead.deSelectColor     = RGB(99, 99, 99);
    self.view.backgroundColor = seghead.headColor = RGB(36, 36, 36);
    
    MLMSegmentScroll *segScroll = [[MLMSegmentScroll alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(seghead.frame), SCREEN_WIDTH, SCREEN_HEIGHT-CGRectGetMaxY(seghead.frame)) vcOrViews:[self vcArr]];
    self.segScroll              = segScroll;
    segScroll.loadAll           = NO;
    
    __weak __typeof(self)weakSelf = self;
    [MLMSegmentManager associateHead:seghead withScroll:segScroll completion:^{
        [weakSelf.view addSubview:seghead];
        [weakSelf.view addSubview:segScroll];
    }];
    
    self.handsUpBtn                          = [UIButton buttonWithType:UIButtonTypeCustom];
    self.handsUpBtn.frame                    = CGRectMake(SCREEN_WIDTH - 70, 7, 50, 26);
    self.handsUpBtn.layer.cornerRadius       = 13;
    self.handsUpBtn.layer.masksToBounds      = YES;
    self.handsUpBtn.layer.borderColor        = [UIColor whiteColor].CGColor;
    self.handsUpBtn.layer.borderWidth        = 1;
    self.handsUpBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.handsUpBtn.titleLabel.font          = [UIFont systemFontOfSize:13];
    [self.handsUpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [seghead addSubview:self.handsUpBtn];
    [self.handsUpBtn setTitle:@"举手" forState:UIControlStateNormal];

    [self.handsUpBtn addTarget:self action:@selector(handsUpBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

// 初始化导航视图
- (void)initCustomNavView {
    [self.view bringSubviewToFront:self.customNavView];
    
    self.customNavView.alpha = 0.6;
    self.navTopCons.constant = -64;
    [self.view layoutIfNeeded];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (NSArray *) vcArr {
    NSArray *vcName = @[@"DocumentViewController",@"ChatViewController",@"LittleBlackBoardViewController"];
    NSMutableArray *vc = @[].mutableCopy;
    for (int i = 0; i < vcName.count; i ++ ) {
        UIViewController *controller = [[NSClassFromString(vcName[i]) alloc] init];
        [vc addObject:controller];
    }
    return vc.copy;
}

- (void)initBroadCastManager {
    _broadcastManager = [GSBroadcastManager sharedBroadcastManager];
    // 直播代理，回调直播信息数据
    _broadcastManager.broadcastRoomDelegate = self;
    // 直播视频代理
    _broadcastManager.videoDelegate = self;
    // 共享桌面代理
    _broadcastManager.desktopShareDelegate = self;
    // 音频代理
    _broadcastManager.audioDelegate = self;
    // 设置摄像头预览视图
    _broadcastManager.videoView = self.qaVideoView;
    
    [_broadcastManager setLogLevel:GSLogLevelError];
    
    // 连接直播间
    if ([_broadcastManager connectBroadcastWithConnectInfo:self.connectInfo]) {
        
    }
    
    // 获取访问指定站点的Reachability对象
    _reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    
    // 让Reachability对象开启被监听
    [_reach startNotifier];
}

- (void)initNavTitle {
    [_broadcastManager fetchLoginInfomationWithDomain:self.connectInfo.domain serviceType:GSBroadcastServiceTypeTraining roomNuber:self.connectInfo.roomNumber Synchronous:YES completion:^(NSDictionary * _Nullable loginInfo, GSFetchLoginInformationResult result) {
        NSLog(@"loginInfo == %@",loginInfo);
    }];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(onBackground:)
     
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(onForeground:)
     
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(reachabilityChanged:)
     
                                                 name:kReachabilityChangedNotification object:nil];

}


#pragma mark - GSBroadcastRoomDelegate 直播代理，回调直播信息数据

// 直播初始化代理
- (void)broadcastManager:(GSBroadcastManager*)manager didReceiveBroadcastConnectResult:(GSBroadcastConnectResult)result
{
    NSString *errorMsg = nil;
    
    self.tintLable.text = @"初始化直播参数...";
    switch (result) {
        case GSBroadcastConnectResultSuccess:
            
            // 直播初始化成功，加入直播
            if (![_broadcastManager join]) {
                errorMsg = @"加入失败";
            }
            break;
        case GSBroadcastConnectResultInitFailed:
            errorMsg = @"初始化出错";
            break;
        case GSBroadcastConnectResultJoinCastPasswordError:
            errorMsg = @"口令错误";
            break;
        case GSBroadcastConnectResultWebcastIDInvalid:
            errorMsg = @"webcastID错误";
            break;
        case GSBroadcastConnectResultRoleOrDomainError:
            errorMsg = @"口令错误";
            break;
        case GSBroadcastConnectResultLoginFailed:
            errorMsg = @"登录信息错误";
            break;
        case GSBroadcastConnectResultNetworkError:
            errorMsg = @"网络错误";
            break;
        case GSBroadcastConnectResultWebcastIDNotFound:
            errorMsg = @"找不到对应的webcastID，roomNumber, domain填写有误";
            break;
        case  GSBroadcastConnectResultThirdTokenError:
            errorMsg = @"第三方验证错误";
            break;
        default:
            errorMsg = @"未知错误";
            break;
            
    }
    if (errorMsg) {
       self.tintLable.text = errorMsg;
    }
    
}

/*
 直播连接代理
 rebooted为YES，表示这次连接行为的产生是由于根服务器重启而导致的重连
 */
- (void)broadcastManager:(GSBroadcastManager*)manager didReceiveBroadcastJoinResult:(GSBroadcastJoinResult)joinResult selfUserID:(long long)userID rootSeverRebooted:(BOOL)rebooted;
{
    
    
    NSString * errorMsg = nil;
    
    switch (joinResult) {
            
            /**
             *  直播加入成功
             */
            
        case GSBroadcastJoinResultSuccess:
        {
            // 服务器重启导致重连的相应处理
            // 服务器重启的重连，直播中的各种状态将不再保留，如果想要实现重连后恢复之前的状态需要在本地记住，然后再重连成功后主动恢复。
            if (rebooted) {
                
                
            }
            self.userInfo = [_broadcastManager queryMyUserInfo];
            self.tintLable.text = @"成功加入直播...";
            [UIView animateWithDuration:1.5 animations:^{
                self.tintBackgroundView.alpha = 0.001;
            } completion:^(BOOL finished) {
                self.tintBackgroundView.hidden = YES;
            }];
            break;
        }
        case GSBroadcastJoinResultUnknownError:
            errorMsg = @"未知错误";
            break;
        case GSBroadcastJoinResultLocked:
            errorMsg = @"直播已上锁";
            break;
        case GSBroadcastJoinResultHostExist:
            errorMsg = @"直播组织者已经存在";
            break;
        case GSBroadcastJoinResultMembersFull:
            errorMsg = @"直播成员人数已满";
            break;        case GSBroadcastJoinResultAudioCodecUnmatch:
            errorMsg = @"音频编码不匹配";
            break;
        case GSBroadcastJoinResultTimeout:
            errorMsg = @"加入直播超时";
            break;
        case GSBroadcastJoinResultIPBanned:
            errorMsg = @"ip地址被ban";
            break;
        case GSBroadcastJoinResultTooEarly:
            errorMsg = @"直播尚未开始";
            break;
            
        default:
            errorMsg = @"未知错误";
            break;
    }
    
    if (errorMsg) {
        self.tintLable.text = errorMsg;
    }
    

    
}
// 断线重连
- (void)broadcastManagerWillStartRoomReconnect:(GSBroadcastManager*)manager
{
    self.tintLable.text = @"正在重连...";
}


// 直播状态改变代理
- (void)broadcastManager:(GSBroadcastManager *)manager didSetStatus:(GSBroadcastStatus)status
{
    NSString *errorMsg = @"";
    switch (status) {
            case GSBroadcastStatusRunning: // 正在直播
            self.navImgView.image = [UIImage imageNamed:@"live_status_living"];
            break;
            
            case GSBroadcastStatusStop: // 停止直播
            errorMsg = @"直播已停止";
            self.navImgView.image = [UIImage imageNamed:@"live_status_end"];
            [SVProgressHUD showInfoWithStatus:errorMsg];
            break;
            
            case GSBroadcastStatusPause: // 暂停直播
            errorMsg = @"直播已暂停";
            self.navImgView.image = [UIImage imageNamed:@"live_status_pause"];
            [SVProgressHUD showInfoWithStatus:errorMsg];
            break;
            
        default:
            break;
    }
}

// 自己离开直播代理
- (void)broadcastManager:(GSBroadcastManager*)manager didSelfLeaveBroadcastFor:(GSBroadcastLeaveReason)leaveReason
{
    NSLog(@"***--- leave1...");
    [_broadcastManager invalidate];
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/// 举手代理
- (void)broadcastManager:(GSBroadcastManager*)manager handUpUser:(long long)userID extraData:(NSString*)data {
    
}
/**
 *  手放下代理（对应于举手）
 */
- (void)broadcastManager:(GSBroadcastManager*)manager handDownUser:(long long)userID{
    if (userID == [_broadcastManager queryMyUserInfo].userID) {
        [_broadcastManager handDown];
        dispatch_source_cancel(self.timer);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.handsUpBtn.enabled = YES;
            self.handsUpBtn.width = 50;
            self.handsUpBtn.x = SCREEN_WIDTH - 70;
            [self.handsUpBtn setTitle:@"举手" forState:UIControlStateNormal];
        });
    }
}

/**
 *  点名倒计时代理
 */
- (void)broadcastManager:(GSBroadcastManager*)manager checkinRequestCountingDownFrom:(NSInteger)number {
    SCCheckInView *view = [SCCheckInView createViewFromNib];
    [view showInViewWithCountDownNumber:number vc:self];
    __weak __typeof(view)weakView = view;
    view.checkinBlock = ^{
        if ([manager checkin]) {
            [weakView hideView];
        } else {
            [SVProgressHUD showErrorWithStatus:@"签到失败"];
        }
    };
}

// 接收到广播消息 自己发自己也会收到
- (void)broadcastManager:(GSBroadcastManager *)manager broadcastMessage:(NSString *)message {
    NSString *myUserID = [NSString stringWithFormat:@"%lld",self.userInfo.userID];
    
    NSArray *strArray = [message componentsSeparatedByString:@","];
    NSString *command = strArray[0];
    NSString *userID = strArray[1];
    
    // 如果是邀请别人进入小黑板 自己需要禁用麦克风 关闭喇叭 暂停显示视频
    if ([command isEqualToString:@"01"] && ![userID isEqualToString:myUserID]) {
        
        [manager inactivateSpeaker]; // 关喇叭
        [manager inactivateMicrophone]; // 关麦克风
        self.videoView.hidden = YES; // 隐藏图像
        [UIView animateWithDuration:0.2 animations:^{
            self.noVideoView.alpha       = 1;
            self.noVideoView.contentMode = UIViewContentModeCenter;
            self.noVideoView.image       = [UIImage imageNamed:@"vod_audio_playing"];
        }];
    }
    if ([command isEqualToString:@"06"] && ![userID isEqualToString:myUserID]) {
        
        [manager activateSpeaker]; // 开喇叭
        [manager activateMicrophone]; // 开麦克风
        self.videoView.hidden = NO; // 显示图像
        [UIView animateWithDuration:0.2 animations:^{
            self.noVideoView.alpha       = 0;
        }];
    }

    
    
    if ([userID isEqualToString:myUserID]) { // 是发给自己的指令
        if ([command isEqualToString:@"01"]) { // 开启小黑板
            
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.seghead setSelectIndex:2];
                NSString *recievdata = strArray[2];
                // 发送反馈给老师端确认进入黑板 发送的data 是该学生的userID 接收的data是老师的userid
                [_broadcastManager publishRoomNotifyBroadcastMsg:[NSString stringWithFormat:@"%@,%@,%@",@"05",recievdata,myUserID]];
            }];
            
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"老师邀请你进入小黑板" preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:action1];
            [self presentViewController:controller animated:YES completion:nil];
            
        }
        if ([command isEqualToString:@"02"]) { // 加载文档图片
            NSString *data = strArray[2];
            NSLog(@"data == %@",data);
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoadDocumentNotification object:nil userInfo:@{@"data":data}];
        }
        
        if ([command isEqualToString:@"03"]) { // 画线
            
            NSMutableDictionary *dict = @{}.mutableCopy;
            dict[@"fx"] = strArray[2];
            dict[@"fy"] = strArray[3];
            dict[@"tx"] = strArray[4];
            dict[@"ty"] = strArray[5];

            [[NSNotificationCenter defaultCenter] postNotificationName:kDrawLineNotification object:nil userInfo:@{@"data":dict}];
        }
        if ([command isEqualToString:@"04"]) { // 擦除线
            [[NSNotificationCenter defaultCenter] postNotificationName:kUndoNotification object:nil];
        }
        
        if ([command isEqualToString:@"06"]) { // 全部进入大黑板
            
            
        }
        
        if ([command isEqualToString:@"07"]) { // 清屏
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kClearScreenNotification object:nil];
        }
        
        if ([command isEqualToString:@"08"]) { // 清除背景图片
        
            [[NSNotificationCenter defaultCenter] postNotificationName:kClearBackImageNotification object:nil];
        }
        if ([command isEqualToString:@"09"]) { // 切换背景图片
            NSString *data = strArray[2];

            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeDocNotification object:nil userInfo:@{@"data":data}];
        }
        
        

    }
    
}


#pragma mark GSBroadcastDesktopShareDelegate 共享桌面代理

// 桌面共享视频连接代理
- (void)broadcastManager:(GSBroadcastManager*)manager didReceiveDesktopShareModuleInitResult:(BOOL)result;
{
}

// 开启桌面共享代理
- (void)broadcastManager:(GSBroadcastManager*)manager didActivateDesktopShare:(long long)userID
{
    _isDesktopShareDisplaying = YES;
    
    _videoView.videoLayer.hidden = YES;
    _videoView.movieASImageView.hidden = NO;
    
    // 桌面共享时，需要主动取消订阅当前直播的摄像头视频
    if (_currentActiveUserID != 0) {
        [_broadcastManager undisplayVideo:_currentActiveUserID];
    }
}


// 桌面共享视频每一帧的数据代理, 软解数据
- (void)broadcastManager:(GSBroadcastManager*)manager renderDesktopShareFrame:(UIImage*)videoFrame
{
    // 指定Videoview渲染每一帧数据
    if (_isDesktopShareDisplaying) {
        [_videoView renderAsVideoByImage:videoFrame];
    }
    
}

/**
 *  桌面共享每一帧的数据, 硬解； 暂不支持
 *
 */
- (void)OnAsData:(unsigned char*)data dataLen: (unsigned int)dataLen width:(unsigned int)width height:(unsigned int)height
{
    
}

// 桌面共享关闭代理
- (void)broadcastManagerDidInactivateDesktopShare:(GSBroadcastManager*)manager
{
    _videoView.videoLayer.hidden = YES;
    _videoView.movieASImageView.hidden = YES;
    
    // 如果桌面共享前，有摄像头视频在直播，需要在结束桌面共享后恢复
    if (_currentActiveUserID != 0)
    {
        _videoView.videoLayer.hidden = NO;
        [_broadcastManager displayVideo:_currentActiveUserID];
    }
    _isDesktopShareDisplaying = NO;
}


#pragma mark - GSBroadcastVideoDelegate 直播视频代理

// 视频模块连接代理
- (void)broadcastManager:(GSBroadcastManager*)manager didReceiveVideoModuleInitResult:(BOOL)result
{
    
}

// 摄像头是否可用代理
- (void)broadcastManager:(GSBroadcastManager*)manager isCameraAvailable:(BOOL)isAvailable
{
    
}

// 摄像头打开 成功
- (void)broadcastManagerDidActivateCamera:(GSBroadcastManager*)manager
{
    _isCameraOpen = YES;
}

// 摄像头关闭代理
- (void)broadcastManagerDidInactivateCamera:(GSBroadcastManager*)manager
{
    _isCameraOpen = NO;
}

// 某个用户加入视频 上提问席、上讲台、摄像头打开成功、进入直播 会进入这里
- (void)broadcastManager:(GSBroadcastManager*)manager didUserJoinVideo:(GSUserInfo *)userInfo
{
    [SVProgressHUD dismiss];

    [UIView animateWithDuration:0.2 animations:^{
        self.noVideoView.alpha = 0.001;
        self.customNavView.hidden = NO;
    }];
    
    // 判断是否是插播，插播优先级比摄像头视频大
    if (userInfo.userID == LOD_USER_ID)
    {
        //为了删掉最后一帧的问题， 收到新数据的时候GSVideoView的videoLayer自动创建
        [_videoView.videoLayer removeFromSuperlayer];
        _videoView.videoLayer = nil;
        
        // 如果之前有摄像头视频作为直播视频，先要取消订阅摄像头视频
        if (_isCameraVideoDisplaying) {
            [_broadcastManager undisplayVideo:_currentActiveUserID];
        }
        
        [_broadcastManager displayVideo:LOD_USER_ID];
        _isLodVideoDisplaying = YES;
        
    } else {
            [_broadcastManager displayVideo:userInfo.userID];
            _isLodVideoDisplaying    = NO;
            _isCameraVideoDisplaying = NO;
    }
}

// 某个用户退出视频
- (void)broadcastManager:(GSBroadcastManager*)manager didUserQuitVideo:(long long)userID
{
    // 判断是否是插播
    if (userID == LOD_USER_ID)
    {
        //为了删掉最后一帧的问题， 收到新数据的时候GSVideoView的videoLayer自动创建
        [_videoView.videoLayer removeFromSuperlayer];
        _videoView.videoLayer = nil;
        
        _isLodVideoDisplaying = NO;
        
        // 如果之前有摄像头视频在直播，需要恢复之前的直播视频
        if (_currentActiveUserID != 0) {
            [_broadcastManager displayVideo:_currentActiveUserID];
        }
    }
    
    else {
        
        if ([self.currentRostrunID containsObject:@(userID)]) {
            [self.currentRostrunID removeObject:@(userID)];
            [_videoView.videoLayer removeFromSuperlayer];
            _videoView.videoLayer = nil;
            [UIView animateWithDuration:0.2 animations:^{
                self.noVideoView.alpha       = 1;
                self.noVideoView.contentMode = UIViewContentModeCenter;
                self.noVideoView.image       = [UIImage imageNamed:@"vod_audio_playing"];
            }];

        }
    }
    
}


// 设置某一路摄像头或插播视频的激活状态代理 下讲台、 上讲台这里会被激活 桌面共享激活
/*
 *  @param userInfo 激活视频所属用户的用户信息
 *  @param active   布尔值表示是否激活，YES表示激活
 */
- (void)broadcastManager:(GSBroadcastManager*)manager didSetVideo:(GSUserInfo*)userInfo active:(BOOL)active
{
    
    if (active)
    {
        // 桌面共享和插播的优先级比摄像头视频大
        if (!_isDesktopShareDisplaying && !_isLodVideoDisplaying) {
            
            // 订阅当前激活的视频
            [_broadcastManager displayVideo:userInfo.userID];
            _currentActiveUserID         = userInfo.userID;
            _isCameraVideoDisplaying     = YES;
            _videoView.videoLayer.hidden = NO;
            
        }
    }

}

// 某一路视频被订阅代理
- (void)broadcastManager:(GSBroadcastManager*)manager didDisplayVideo:(GSUserInfo*)userInfo
{
    
}
// 某一路视频取消订阅代理
- (void)broadcastManager:(GSBroadcastManager*)manager didUndisplayVideo:(long long)userID
{
    
}


// 摄像头或插播视频每一帧的数据代理，软解
- (void)broadcastManager:(GSBroadcastManager*)manager userID:(long long)userID renderVideoFrame:(GSVideoFrame*)videoFrame
{
    // 指定Videoview渲染每一帧数据
    if (![self.currentAskerID containsObject:@(userID)]) {
        [_videoView renderVideoFrame:videoFrame];
    }
    
}


// 硬解数据从这个代理返回 摄像头采集的数据也会从这里返回
- (void)OnVideoData4Render:(long long)userId width:(int)nWidth nHeight:(int)nHeight frameFormat:(unsigned int)dwFrameFormat displayRatio:(float)fDisplayRatio data:(void *)pData len:(int)iLen
{
    // 指定Videoview渲染每一帧数据
    if (![self.currentAskerID containsObject:@(userId)]) {
        [_videoView hardwareAccelerateRender:pData size:iLen dwFrameFormat:dwFrameFormat];
    }
 
}

/**
 *  手机摄像头开始采集数据
 *
 *  @param manager 触发此代理的GSBroadcastManager对象
 */
- (BOOL)broadcastManagerDidStartCaptureVideo:(GSBroadcastManager*)manager
{
    NSLog(@"摄像头开始采集数据");
    return YES;
}

/**
 手机摄像头停止采集数据
 */
- (void)broadcastManagerDidStopCaptureVideo:(GSBroadcastManager*)manager
{
    
}

// 上提问席和讲台
- (void)broadcastManager:(GSBroadcastManager *)manager didReceiveBroadcastInfoKey:(NSString *)key value:(long long)value {
    // 四个提问席
    if ([key isEqualToString:@"user.asker"] ||
        [key isEqualToString:@"user.asker.1"] ||
        [key isEqualToString:@"user.asker.2"] ||
        [key isEqualToString:@"user.asker.3"]) {
        GSUserInfo *info = [_broadcastManager queryMyUserInfo];
        if ([_currentKey isEqualToString:@""] || hjw_StrIsEmpty(_currentKey)) { // 当前自己不在提问席上
            if (value == info.userID) { // 让自己上提问席
                _currentKey = key;
                // 打开摄像头
                if ([_broadcastManager activateCamera:NO landscape:NO] &&  [_broadcastManager activateMicrophone]) {
                    // 显示预览摄像视图
                    [self addPreviewVideoViewWithFrame:CGRectMake(0,SCREENHEIGHT * 0.5, 120, 150) videoViewFrame:CGRectMake(0, 0, 120, 120) buttonHidden:NO];
                  
                } else {
//                    [BaseMethod showError:@"摄像头或麦克风打开失败"];
                }
            }
        }
        if (value == 0 && [_currentKey isEqualToString:key]) { // 自己被下提问席
           
            [self removePreviewVideoView];
           
        }
        if (value != self.userInfo.userID && value != 0) { // 别人上提问席
            [self.currentAskerID addObject:@(value)];
        }
    }
    if ([key isEqualToString:@"user.rostrum"]) { // 上讲台
        //
        if ([_currentKey isEqualToString:@""] || hjw_StrIsEmpty(_currentKey)) { // 当前自己不在讲台
            if (value == self.userInfo.userID) { // 让自己上讲台
                _currentKey = key;
                // 打开摄像头和麦克风
                if ([_broadcastManager activateCamera:NO landscape:NO] && [_broadcastManager activateMicrophone]) {
                    [self addPreviewVideoViewWithFrame:CGRectMake(0,0, SCREENWIDTH, SCREENHEIGHT*0.42) videoViewFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT*0.42) buttonHidden:YES];
                }else {
//                    [BaseMethod showError:@"摄像头或麦克风打开失败"];
                }
            }
        }
        if (value == 0 && [_currentKey isEqualToString:key]) { // 自己被下讲台
            [self removePreviewVideoView];
        }
        if (value != self.userInfo.userID && value != 0) { // 别人上讲台 非主讲人
            [self.currentAskerID removeObject:@(value)];
            [self.currentRostrunID addObject:@(value)];
        }
    }
}
#pragma mark - GSBroadcastAudioDelegate 直播音频代理
-(void)broadcastManager:(GSBroadcastManager *)manager didReceiveAudioModuleInitResult:(BOOL)result {
    
}
/**
 *  麦克风打开代理
 */
- (void)broadcastManagerDidActivateMicrophone:(GSBroadcastManager*)manager{
    // 打开自己的麦克风
    if ([manager activateMicrophone]) {
        
        [self.audioWaveView showAudioWaveView];
//        [BaseMethod showError:@"麦克风已打开"];
    }
}


/**
 *  麦克风关闭代理
 */
- (void)broadcastManagerDidInactivateMicrophone:(GSBroadcastManager*)manager{
    // 关闭自己的麦克风
    if ([manager inactivateMicrophone]) {
        
        [self.audioWaveView removeAudioWaveView];
//        [BaseMethod showError:@"麦克风已关闭"];
    }
}

/**
 *  麦克风音量波值代理（在音量固定的情况下，声音的强弱是不固定的）
 */
- (void)broadcastManager:(GSBroadcastManager*)manager microphoneAudioWaveValue:(long long)value{
    self.audioWaveView.audioValue = value;
}





#pragma mark - aciton

/// 结束提问席
- (void)endQuestionBtnClick:(UIButton *)sender {
    
    // 自己主动下提问席或讲台
    if ([_broadcastManager setBroadcastInfo:_currentKey value:0]) {
        // 关闭摄像头
        [_broadcastManager inactivateCamera];
        [_broadcastManager inactivateMicrophone];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.dragView.alpha = 0.001;
    } completion:^(BOOL finished) {
        [self.dragView removeFromSuperview];
    }];
}

/// 举手
- (void)handsUpBtnClick:(UIButton *)sender {
    
    sender.titleLabel.font = [UIFont systemFontOfSize:13];
    
    _isHandUp = !_isHandUp;
    __block NSInteger remainTime  = 59;
    dispatch_queue_t queue        = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    __weak __typeof(self)weakSelf = self;
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    if (_isHandUp) {
        // 举手
        [_broadcastManager handUp:[NSString stringWithFormat:@"%lld",self.userInfo.userID]];
        // 开启定时器
        dispatch_source_set_event_handler(weakSelf.timer, ^{
            if (remainTime <= 0) {
                // 手放下
                [_broadcastManager handDown];
                dispatch_source_cancel(weakSelf.timer);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    sender.width = 50;
                    sender.x     = SCREEN_WIDTH - 70;
                    [sender setTitle:@"举手" forState:UIControlStateNormal];
                });
            } else {
                NSString *timeStr = [NSString stringWithFormat:@"%ld", remainTime];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [sender setTitle:[NSString stringWithFormat:@"手放下%@",timeStr] forState:UIControlStateNormal];
                    sender.width = 80;
                    sender.x     = SCREEN_WIDTH - 100;
                });
                remainTime--;
            }
        });
       dispatch_resume(self.timer);
    } else {
        
        // 手放下
        remainTime = 0;
        [_broadcastManager handDown];
        dispatch_source_cancel(self.timer);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            sender.width   = 50;
            sender.x       = SCREEN_WIDTH - 70;
            [sender setTitle:@"举手" forState:UIControlStateNormal];
        });
        
    }
}

// 退出直播
- (IBAction)broadcastBackBtnClick:(id)sender {
    
    
//    SCLAlertView *alert = [[SCLAlertView alloc] init];
//    [alert setHorizontalButtons:YES];
//    
//    __weak __typeof(self)weakSelf = self;
//    [alert addButton:@"确定" actionBlock:^{
//        weakSelf.customNavView.hidden = YES;
//        [SVProgressHUD show];
//        [weakSelf.broadcastManager leaveAndShouldTerminateBroadcast:NO];
//    }];
//    
//    [alert showInfo:self title:@"温馨提示" subTitle:@"确定离开直播间吗？" closeButtonTitle:@"取消" duration:0];
    
}

// 全屏操作
- (void)videoFullScreenBtnClick:(UIButton *)sender {
    _isVideoFullScreen = !_isVideoFullScreen;
    
    // 全屏时先隐藏按钮
    [UIView animateWithDuration:0.25 animations:^{
        self.videoFullScreenBtn.alpha = 0.001;
    } completion:^(BOOL finished) {
        self.videoFullScreenBtn.hidden = YES;
    }];
    
    if (_isVideoFullScreen) {

        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];

            self.videoView.frame  = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
            self.segScroll.hidden = YES;
            self.seghead.hidden   = YES;
            int val = UIInterfaceOrientationLandscapeRight;//这里可以改变旋转的方向
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
        
        
    }else {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            
            self.videoView.frame  = _originalVideoFrame;
            self.segScroll.hidden = NO;
            self.seghead.hidden   = NO;
            int val = UIInterfaceOrientationPortrait;//这里可以改变旋转的方向
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
    }
}


#pragma mark - 手势
- (void)handleVideoViewTap:(UITapGestureRecognizer *)rec {
   
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    self.videoFullScreenBtn.alpha = 1;
    self.videoFullScreenBtn.hidden = NO;
    
    // 正在显示 不操作
    if (self.navTopCons.constant == 0) {
        return;
    }
    _isNavHide = !_isNavHide;
    __block CGRect originFrame = self.videoFullScreenBtn.frame;
    if (!_isNavHide) {
        
        self.navTopCons.constant = -64;
        [UIView animateWithDuration:0.25 animations:^{
            [self.view layoutIfNeeded];
        }];
        [UIView animateWithDuration:0.25 animations:^{
            originFrame = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT*0.26, 40, 40);
            self.videoFullScreenBtn.frame = originFrame;
        }];
        
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.navTopCons.constant = 0;
            [self.view layoutIfNeeded];
            
            originFrame = CGRectMake(SCREEN_WIDTH - 50, SCREEN_HEIGHT*0.26, 40, 40);
            self.videoFullScreenBtn.frame = originFrame;
        } completion:^(BOOL finished) {
            _isNavHide = !_isNavHide;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.navTopCons.constant = -64;
                [UIView animateWithDuration:0.25 animations:^{
                    [self.view layoutIfNeeded];
                }];
                [UIView animateWithDuration:0.25 animations:^{
                    originFrame = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT*0.26, 40, 40);
                    self.videoFullScreenBtn.frame = originFrame;
                }];
            });
        }];
    }

}

#pragma mark - notification

// 进入后台关闭视频
- (void)onBackground:(NSNotification *)noti {
    [_broadcastManager undisplayVideo:_currentActiveUserID];
}
// 重新进入前台开启视频
- (void)onForeground:(NSNotification *)noti {
    [_broadcastManager displayVideo:_currentActiveUserID];

}

- (void)reachabilityChanged:(NSNotification *)noti {
    Reachability *curentReach = [noti object];
    _status = [curentReach currentReachabilityStatus];
    
    if (_status == NotReachable) { // 网络无连接
        
    }else if (_status == ReachableViaWiFi) { // WiFi
        
        // 强制重连
        [[GSBroadcastManager sharedBroadcastManager]setCurrentIDC:@""];
        
    }else if (_status == ReachableViaWWAN) { // 4G
        
        // 提醒用户正在使用4G 是否需要重连
//        [self.alertView showWarning:self title:@"温馨提示" subTitle:@"您当前网络为4G，继续观看会消耗您的流量，建议切换到WiFi" closeButtonTitle:@"我知道了" duration:0.0f];
       
        

    }
}


#pragma mark - other private method

// 移除预览视图
- (void)removePreviewVideoView {
    _currentKey = @"";
    [_broadcastManager inactivateCamera]; // 关闭摄像头
    [_broadcastManager inactivateMicrophone];
    [UIView animateWithDuration:0.25 animations:^{
        self.dragView.alpha = 0.001;
    } completion:^(BOOL finished) {
        [self.dragView removeFromSuperview];
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
