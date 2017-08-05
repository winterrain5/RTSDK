//
//  ScanViewController.m
//  RTSDK
//
//  Created by Derrick on 2017/7/31.
//  Copyright © 2017年 Derrick. All rights reserved.
//

#import "ScanViewController.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
@interface ScanViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_imageView yy_setImageWithURL:[NSURL URLWithString:@"http://image.tianjimedia.com/uploadImages/2015/159/22/OX6JH9918VX5.jpg"] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
