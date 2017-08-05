//
//  ViewController.m
//  RTSDK
//
//  Created by 石冬冬 on 2017/7/19.
//  Copyright © 2017年 Derrick. All rights reserved.
//

#import "ViewController.h"
#import "VideoViewController.h"
@interface ViewController ()
// 域名
@property (weak, nonatomic) IBOutlet UITextField *domainTf;
// 房间号
@property (weak, nonatomic) IBOutlet UITextField *roomNumTf;
// 昵称
@property (weak, nonatomic) IBOutlet UITextField *nickNameTf;
// 观看密码
@property (weak, nonatomic) IBOutlet UITextField *watchPwdTf;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[VideoViewController class]]) {
        VideoViewController *controller = segue.destinationViewController;
        GSConnectInfo *connectInfo = [GSConnectInfo new];
        connectInfo.domain = self.domainTf.text;
        connectInfo.serviceType = GSBroadcastServiceTypeTraining;
        connectInfo.roomNumber = self.roomNumTf.text;
        connectInfo.nickName = self.nickNameTf.text;
        connectInfo.watchPassword = self.watchPwdTf.text;
        controller.connectInfo = connectInfo;
        NSLog(@"connectInfo == %@",self.domainTf.text);
    }
}

@end
