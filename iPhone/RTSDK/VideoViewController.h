//
//  VideoViewController.h
//  RTSDK
//
//  Created by 石冬冬 on 2017/7/19.
//  Copyright © 2017年 Derrick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RtSDK/RtSDK.h>
@interface VideoViewController : UIViewController
/// 直播的连接参数信息
@property (nonatomic, strong) GSConnectInfo *connectInfo;
@end
