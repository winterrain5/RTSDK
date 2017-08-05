//
//  SCAudioWaveView.m
//  StudyChat
//
//  Created by 石冬冬 on 2017/7/27.
//  Copyright © 2017年 Lion_Lemon. All rights reserved.
//

#import "SCAudioWaveView.h"

@interface SCAudioWaveView()
///
@property (nonatomic, weak) UIImageView *imgView;
@end

@implementation SCAudioWaveView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.frame               = CGRectMake(0, kScreenHeight*0.35, 120, 40);
    self.centerX             = [UIApplication sharedApplication].keyWindow.centerX;
    self.layer.cornerRadius  = 20;
    self.layer.masksToBounds = YES;
    self.backgroundColor     = RGBA(18, 18, 18,0.8);
    
    UIImageView *imgView = [[UIImageView alloc] init];
    self.imgView         = imgView;
    imgView.image        = [UIImage imageNamed:@"volume2"];
    imgView.frame        = CGRectMake(10, 0, 50, 40);
    imgView.contentMode  = UIViewContentModeCenter;
    [self addSubview:imgView];
    
    UIButton *btn = [[UIButton alloc] init];
    btn.frame     = CGRectMake(CGRectGetMaxX(imgView.frame), 0, 50, 40);
    [btn setImage:[UIImage imageNamed:@"video_Hang"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
}

- (void)showAudioWaveView {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }];
}

- (void)removeAudioWaveView {
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.001;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)btnClick {
    if (self.AudioHangupBlock) {
        self.AudioHangupBlock();
    }
}

- (void)setAudioValue:(long long)audioValue {
    _audioValue = audioValue;
    NSString *imgName = [NSString stringWithFormat:@"volume%lld",audioValue/10];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imgView.image = [UIImage imageNamed:imgName];
    });
}

@end
