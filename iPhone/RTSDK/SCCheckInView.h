//
//  SCCheckInView.h
//  StudyChat
//
//  Created by 石冬冬 on 2017/7/22.
//  Copyright © 2017年 Lion_Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^CheckInBlock)();
@interface SCCheckInView : UIView
///
@property (nonatomic, assign) NSInteger countDownNumber;
///
@property (nonatomic, copy) CheckInBlock checkinBlock;

- (void)showInViewWithCountDownNumber:(NSInteger)numner vc:(UIViewController *)vc;
@end
