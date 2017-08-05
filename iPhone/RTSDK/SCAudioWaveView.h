//
//  SCAudioWaveView.h
//  StudyChat
//
//  Created by 石冬冬 on 2017/7/27.
//  Copyright © 2017年 Lion_Lemon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCAudioWaveView : UIView
///
@property (nonatomic, copy) void (^AudioHangupBlock)();

///
@property (nonatomic, assign) long long audioValue;

- (void)showAudioWaveView;
- (void)removeAudioWaveView;
@end
