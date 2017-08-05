//
//  AppDelegate.h
//  RTSDK
//
//  Created by 石冬冬 on 2017/7/19.
//  Copyright © 2017年 Derrick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RtSDK/RtSDK.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong)GSBroadcastManager *manager;

@end

