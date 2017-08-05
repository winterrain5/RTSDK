//
//  SCCheckInView.m
//  StudyChat
//
//  Created by 石冬冬 on 2017/7/22.
//  Copyright © 2017年 Lion_Lemon. All rights reserved.
//

#import "SCCheckInView.h"
#import "CABasicAnimation+Basis.h"
@interface SCCheckInView ()<CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tintLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkinBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *enCountLabel;

@end

@implementation SCCheckInView

- (void)awakeFromNib {
    [super awakeFromNib];
    
   
    self.frame = CGRectMake(SCREENWIDTH*0.1, SCREENHEIGHT*0.29, SCREENWIDTH*0.8, SCREENHEIGHT*0.42);
    

}


- (void)showInViewWithCountDownNumber:(NSInteger)numner vc:(UIViewController *)vc {
    _countDownNumber = numner;
    
    self.bgImgView.hidden = NO;
    self.checkinBtn.hidden = NO;
    self.enCountLabel.hidden= YES;
    self.countDownLabel.hidden = NO;
    
    self.countDownLabel.text = [NSString stringWithFormat:@"%ld",numner];
    self.countDownLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0f, 0.0f);
    
    
    TYAlertController *controller = [TYAlertController alertControllerWithAlertView:self preferredStyle:TYAlertControllerStyleAlert transitionAnimation:TYAlertTransitionAnimationDropDown];
    
    [vc presentViewController:controller animated:YES completion:nil];
    
    __weak __typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.countDownLabel.layer addAnimation:[CABasicAnimation diffusionByDelegate:self] forKey:self.countDownLabel.text];
    });
    
}

- (IBAction)closebtnClick:(id)sender {
    
    [self hideView];
    
}
- (IBAction)checkinBtnClick:(id)sender {
    if (self.checkinBlock) {
        self.checkinBlock();
    }
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        self.countDownNumber --;
        self.countDownLabel.text = [NSString stringWithFormat:@"%ld", self.countDownNumber];
        if (self.countDownNumber == 0) {
            self.enCountLabel.hidden= NO;
            self.countDownLabel.hidden = YES;
            self.bgImgView.hidden = YES;
            self.checkinBtn.hidden = YES;
        }
        if (self.countDownNumber < 0) {
            return;
        }
        [self.countDownLabel.layer addAnimation:[CABasicAnimation diffusionByDelegate:self] forKey:self.countDownLabel.text];
    }
}
@end
