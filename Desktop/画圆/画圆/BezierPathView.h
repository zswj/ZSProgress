//
//  BezierPathView.h
//  画圆
//
//  Created by kkk on 17/4/20.
//  Copyright © 2017年 bianming. All rights reserved.
//

#import <UIKit/UIKit.h>

/*** 环形进度条的宽度 在.m中宏定义 只要改动即可 ***/

@interface BezierPathView : UIView
///进度时间
@property (nonatomic, assign) CGFloat time;
///进度 0~1
@property (nonatomic, assign) CGFloat progress;
///开始进度 默认是0
@property (nonatomic, assign) CGFloat startProgress;
///原型的底层颜色(十六进制)
@property (nonatomic, copy) NSString *backLayerColor;

///是否设置渐变色
@property (nonatomic, assign) BOOL isMoreColor;
///存储颜色数组 - 如果没有设置渐变色 只加入一个颜色即可
@property (nonatomic, strong) NSArray *colorArray;


@end
