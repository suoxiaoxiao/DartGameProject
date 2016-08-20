//
//  ViewController.m
//  DartGamePro
//
//  Created by 索晓晓 on 16/8/20.
//  Copyright © 2016年 SXiao.RR. All rights reserved.
//


#define  WIDTH [UIScreen mainScreen].bounds.size.width
#define  HEIGHT [UIScreen mainScreen].bounds.size.height
#define MOVEW (60)
#define MOVEH (60)

#import "ViewController.h"

@interface ViewController ()
{
    float _detumScale; //基准比例
    float _moveDuration; //松开手之后的速度
    NSTimeInterval _startTimer;
}
@property (strong, nonatomic)  UIView *move;

@property (nonatomic , assign)CGRect datumF; //基准点
@property (nonatomic , assign)CGPoint detumCen;//基准中心点
@property (nonatomic , assign)CGPoint detumPosition;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
//    self.view.backgroundColor = [UIColor clearColor];
    UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH/2, HEIGHT/2)];
    top.backgroundColor = [UIColor redColor];
    [self.view addSubview:top];
    [self.view sendSubviewToBack:top];
    
    UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(WIDTH/2, HEIGHT/2, WIDTH/2, HEIGHT/2)];
    bottom.backgroundColor = [UIColor redColor];
    [self.view addSubview:bottom];
    [self.view sendSubviewToBack:bottom];
    
    
    
    
    self.move = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MOVEW, MOVEH)];
    self.move.center = self.view.center;
    self.move.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.move];
    [self.move addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)]];
    
    self.datumF = self.move.frame;
    self.detumCen = self.move.center;
    self.detumPosition = self.move.layer.position;
    _detumScale = self.view.frame.size.width/self.view.frame.size.height;
    _moveDuration = 0;
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)handleSwipes:(UIPanGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self.move];
    
    self.move.layer.position = CGPointMake(location.y/self.move.frame.size.height,location.x/self.move.frame.size.width);
    CGPoint currentPoint = [sender locationInView:self.view];
    self.move.layer.position = currentPoint;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        //开始计时
        _startTimer = [NSDate date].timeIntervalSince1970;
        NSLog(@"开始计时%lf",[NSDate date].timeIntervalSince1970);
        
    }else if(sender.state == UIGestureRecognizerStateChanged){
        
    }else if (sender.state == UIGestureRecognizerStateEnded){
        
        //停止计时
        float timer = [NSDate date].timeIntervalSince1970 - _startTimer;
        
        //计算终点坐标
        CGPoint P = [self test];
        
        
        //计算时间  计算拖动路程
        float endPanDistance = sqrtf((powf(fabs(currentPoint.x - self.detumCen.x), 2)) + (powf(fabs(currentPoint.y - self.detumCen.y), 2)));
        
        float speed = endPanDistance/timer;
        
//        currentPoint  P
        float distance = sqrtf((powf(fabs(currentPoint.x - P.x), 2)) + (powf(fabs(currentPoint.y - P.y), 2)));
        
        _moveDuration = distance/speed > 2 ? 2 : distance/speed;
        
        [UIView animateWithDuration:_moveDuration animations:^{
            
            self.move.layer.position = P;
            
            NSLog(@"%@",NSStringFromCGPoint(P));
            
        } completion:^(BOOL finished) {
            
            self.move.layer.position = self.detumPosition;
            
        }];
        
        
        
    }
    
    
    
}

- (CGPoint )test
{
    //最新的
    CGPoint newCen = self.move.center;
    CGPoint endCen = CGPointZero;
    
    // 特殊情况
    if (newCen.x == self.detumCen.x) { //在Y轴上运动
        
        if (newCen.y > self.detumCen.y) {//往下走
            
            endCen = CGPointMake(self.detumCen.x, HEIGHT);
            
        }else if (newCen.y < self.detumCen.y) { //往上走
            
            endCen = CGPointMake(self.detumCen.x, 0);
            
        }else{
            
            endCen = self.detumCen;
        }
        
        
        return endCen;
    }
    // 特殊情况
    if (newCen.y == self.detumCen.y) { //在X轴上运动
        
        if (newCen.x > self.detumCen.x) {//往右走
            
            endCen = CGPointMake(WIDTH, self.detumCen.y);
            
        }else if (newCen.x < self.detumCen.x) { //往左走
            
            endCen = CGPointMake(0, self.detumCen.y);
            
        }else{
            
            endCen = self.detumCen;
        }
        
        return endCen;
    }
    
    
    if (newCen.y > self.detumCen.y) { //整体往下走
        
        
        //判断 X轴差/Y轴差 比
        
        float newAngle = [self getXscaleYAngle];
        
        if (newAngle > _detumScale) { //不是左边就是右边
            
            if (newCen.x > self.detumCen.x) { //右边
                
                float angle = [self getYscaleXAngle];
                
                endCen = CGPointMake(self.view.frame.size.width + MOVEW/2, angle * (self.view.frame.size.width - _detumCen.x) + self.view.frame.size.height/2 + MOVEH/2);
                
            }else if (newCen.x < self.detumCen.x){ //左边
                
                float angle = [self getYscaleXAngle];
                
                endCen = CGPointMake(0 - MOVEW/2, angle * (self.view.frame.size.width - _detumCen.x) + self.view.frame.size.height/2 + MOVEH/2);
                
            }
            
        }else{ //就是下边
            
            if (newCen.x > self.detumCen.x) { //下边右边
                
                float angle = [self getXscaleYAngle];
                
                endCen = CGPointMake(angle * (self.view.frame.size.height - _detumCen.y) + self.view.frame.size.width/2,self.view.frame.size.height + MOVEH/2);
                
            }else if (newCen.x < self.detumCen.x){ //下边左边
                
                float angle = [self getXscaleYAngle];
                endCen = CGPointMake(WIDTH/2 - angle * (self.view.frame.size.height - _detumCen.y),self.view.frame.size.height + MOVEH/2);
                
            }
            
        }
        
    }else if (newCen.y < self.detumCen.y) { //整体往上走
        
        //判断 X轴差/Y轴差 比
        float newAngle = [self getXscaleYAngle];
        
        if (newAngle > _detumScale) { //不是左边就是右边
            
            if (newCen.x > self.detumCen.x) { //右边
                
                float angle = [self getYscaleXAngle];
                
                endCen = CGPointMake(WIDTH + MOVEW/2, HEIGHT/2 - angle * (self.view.frame.size.width - _detumCen.x));
                
                
            }else if (newCen.x < self.detumCen.x){ //左边
                
                float angle = [self getYscaleXAngle];
                
                endCen = CGPointMake(0 - MOVEW/2, HEIGHT/2 - angle * (self.view.frame.size.width - _detumCen.x));
                
            }
            
        }else{ //就是上边
            
            if (newCen.x > self.detumCen.x) { //上边右边
                
                float angle = [self getXscaleYAngle];
                
                endCen = CGPointMake(WIDTH/2 + angle * (self.view.frame.size.height - _detumCen.y),0 - MOVEH/2);
                
            }else if (newCen.x < self.detumCen.x){ //上边左边
                
                float angle = [self getXscaleYAngle];
                
                endCen = CGPointMake(WIDTH/2 - angle * (self.view.frame.size.height - _detumCen.y),0 - MOVEH/2);
            }
            
        }
        
        
    }
    
    return endCen;
}

- (float)getXscaleYAngle
{
    //基准Frame
//    self.datumF;
    //最新的
    CGPoint newCen = self.move.center;
    //X轴差/Y轴差
    float angleX = fabs(self.detumCen.x - newCen.x);
    float angleY = fabs(self.detumCen.y - newCen.y);
    
    return angleX/angleY;
}


- (float)getYscaleXAngle
{
    //基准Frame
    //    self.datumF;
    //最新的
    CGPoint newCen = self.move.center;
    //X轴差/Y轴差
    float angleX = fabs(self.detumCen.x - newCen.x);
    float angleY = fabs(self.detumCen.y - newCen.y);
    
    return angleY/angleX;
}

- (float)getSpeed
{
    return 0.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
