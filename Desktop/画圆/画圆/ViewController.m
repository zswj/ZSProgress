//
//  ViewController.m
//  画圆
//
//  Created by kkk on 17/4/20.
//  Copyright © 2017年 bianming. All rights reserved.
//

#import "ViewController.h"
#import "BezierPathView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    BezierPathView *bezierV = [[BezierPathView alloc] init];
    bezierV.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //设置环形比例
    bezierV.progress = 0.6;
    //设置动画时间
    bezierV.time = 2;
    //设置环形底层颜色
    bezierV.backLayerColor = @"#f5f5f5";
    //是否设置渐变色
    bezierV.isMoreColor = YES;
    //如果不设置渐变色 进度条颜色取第一个
    bezierV.colorArray = @[@"#C4FF2B",@"#FFE632",@"#FF6B44"];
    [self.view addSubview:bezierV];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
