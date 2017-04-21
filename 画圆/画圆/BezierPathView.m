//
//  BezierPathView.m
//  画圆
//
//  Created by kkk on 17/4/20.
//  Copyright © 2017年 bianming. All rights reserved.
//

#import "BezierPathView.h"
//进度条的宽度
#define lineShowWidth 10
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

/***** 这个是计算十六进制颜色 *****/
@interface UIColor (myColor)
+ (UIColor *)colorWithHexString:(NSString *)color;

@end

@implementation UIColor (myColor)

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

//默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color
{
    return [self colorWithHexString:color alpha:1.0f];
}
@end


@interface BezierPathView()<CAAnimationDelegate> {
    NSTimer *_timer;
    CGFloat _i;
    UILabel *_label;
}

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation BezierPathView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)initBezierViewWithframe:(CGRect)frame {
    /****** 画圆 ******/
    //确定中心点
    float centerX = frame.size.width/2.0;
    
    float centerY = frame.size.height/2.0;

    //确定半径
    float radius = frame.size.width/2.0-lineShowWidth/2.0;
    //创建贝塞尔路径
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY) radius:radius startAngle:(-0.5*M_PI) endAngle:1.5*M_PI clockwise:YES];
    
    //根据贝塞尔路径添加 背景环
    CAShapeLayer *backLayer = [CAShapeLayer layer];
    backLayer.frame = self.bounds;
    backLayer.fillColor =  [[UIColor clearColor] CGColor];
    backLayer.strokeColor = [UIColor colorWithHexString:_backLayerColor].CGColor;
    backLayer.lineWidth = lineShowWidth;
    backLayer.path = [path CGPath];
    backLayer.strokeEnd = 1;
    [self.layer addSublayer:backLayer];
    
    //添加进度环
    self.progressLayer = [CAShapeLayer layer];
    self.progressLayer.frame = self.bounds;
    //底色为透明
    self.progressLayer.fillColor =  [[UIColor clearColor] CGColor];
    self.progressLayer.lineWidth = lineShowWidth;
    self.progressLayer.strokeColor  = [[UIColor blackColor] CGColor];
    self.progressLayer.path = [path CGPath];
    self.progressLayer.strokeEnd = _progress;
    [self.layer addSublayer:self.progressLayer];
    
    _label = [[UILabel alloc] init];
    _label.textColor = [UIColor colorWithHexString:@"#333333"];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = [NSString stringWithFormat:@"%0.f%%", _progress*100];
    _label.frame = CGRectMake(0, 0, frame.size.width, 30);
    _label.center = self.center;
    [self addSubview:_label];
    
    if (_isMoreColor) {
        //设置渐变色
        CAGradientLayer *moreColorLayer = [CAGradientLayer layer];
        moreColorLayer.frame = self.bounds;
        NSMutableArray *colors = [NSMutableArray arrayWithCapacity:0];
        for (NSString *colorStr in _colorArray) {
            [colors addObject:(id)[UIColor colorWithHexString:colorStr].CGColor];
        }
        [moreColorLayer setColors:colors];
        moreColorLayer.startPoint = CGPointMake(0, 0);
        moreColorLayer.endPoint = CGPointMake(0, 1);
        [moreColorLayer setMask:self.progressLayer];
        [self.layer addSublayer:moreColorLayer];
    }else {
        self.progressLayer.strokeColor = [UIColor colorWithHexString:_colorArray[0]].CGColor;

    }
    
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self progressAnimation:self.progressLayer];
    });
    
    if (self.progress > 0) {
        NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(newThread) object:nil];
        [thread start];
    }
}


-(void)newThread
 {
        @autoreleasepool {
                 _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timeLabel) userInfo:nil repeats:YES];
                 [[NSRunLoop currentRunLoop] run];
             }
}

-(void)timeLabel
{
    _i += self.progress/(_time/0.01);
    _label.text = [NSString stringWithFormat:@"%.0f%%",_i*100];
    if (_i >= self.progress) {
        _label.text = [NSString stringWithFormat:@"%.0f%%",_progress*100];
        [_timer invalidate];
        _timer = nil;
    }
}



//定义动画
- (void)progressAnimation:(CALayer *)layer {
    CABasicAnimation *bas = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.duration = _time;
    bas.delegate = self;
    bas.fromValue = [NSNumber numberWithFloat:_startProgress];
    bas.toValue = [NSNumber numberWithFloat:_progress];
    [layer addAnimation:bas forKey:@"key"];
}

- (void)layoutSubviews {
    [self initBezierViewWithframe:self.frame];
}
@end



