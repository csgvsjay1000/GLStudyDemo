//
//  ViewController.m
//  GLStudyDemo
//
//  Created by chengshenggen on 8/18/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "ViewController.h"
//#import "KBOpenglView.h"
//#import "KBOpenGLView6_0.h"
//#import "KBOpenGLView7_0.h"
#import "KBOpenGLView8_0.h"
#import <GLKit/GLKit.h>

// 枚举值，包含水平移动方向和垂直移动方向
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};

#define MAX_OVERTURE 95.0
#define MIN_OVERTURE 25.0

@interface ViewController (){
//    KBOpenGLView4_0 *glView;
    KBOpenGLView8_0 *glView;

    CADisplayLink *displayLink;
    
    NSInteger degress;
    NSInteger verticalDegress;


}
@property (weak, nonatomic) IBOutlet UIView *leftView;

@property (nonatomic, assign) PanDirection panDirection;

//陀螺仪
@property(nonatomic,strong) CMAttitude *referenceAttitude;
@property(nonatomic,strong) CMMotionManager *motionManager;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkPresent)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    displayLink.paused = YES;
    displayLink.frameInterval = 2;
    glView = [[KBOpenGLView8_0 alloc] initWithFrame:CGRectZero];
    [self.view addSubview:glView];
    
    [self.view bringSubviewToFront:self.leftView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
    [self.view addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    [self startDeviceMotion];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    

    glView.frame = CGRectMake(0, 0, width, height);

    
    displayLink.paused = NO;
    
    
}

-(BOOL)shouldAutorotate{
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    
    glView.frame = CGRectMake(0, 0, width, height);
    
    return YES;
}

-(void)displayLinkPresent{
    [glView render];
    
}
- (IBAction)upActions:(id)sender {
    [glView upActions];
}
- (IBAction)downActions:(id)sender {
    [glView downActions];

}
- (IBAction)leftActions:(id)sender {
    [glView leftActions];

}
- (IBAction)rightActions:(id)sender {
    [glView rightActions];

}

#pragma mark - 手势滑动 pan
- (void)panDirection:(UIPanGestureRecognizer *)pan
{
    UIView *tempView = pan.view;
    
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:tempView];
    //获取移动了多少像素
    CGPoint movePoint = [pan translationInView:tempView];
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:tempView];
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            degress = glView.degress + degress;
            verticalDegress = glView.verticalDegress + verticalDegress;

            NSLog(@" locationPoint %@",NSStringFromCGPoint(locationPoint));
            NSLog(@" movePoint %@",NSStringFromCGPoint(movePoint));
            NSLog(@" veloctyPoint %@",NSStringFromCGPoint(veloctyPoint));
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) {
                // 水平移动,调节快进后台
                self.panDirection = PanDirectionHorizontalMoved;
            }
            else if (x < y){
                // 垂直移动调节音量和亮度
                self.panDirection = PanDirectionVerticalMoved;
            }
            break;
        }case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    NSInteger value = movePoint.x / 3;
                    glView.degress = value+degress;
                    NSLog(@"value = %lf",glView.degress);

                    break;
                }case PanDirectionVerticalMoved:{
                    NSInteger value = movePoint.y;
                    glView.verticalDegress = value+verticalDegress;
                    NSLog(@"value = %lf",glView.verticalDegress);
                }
                default:
                    break;
            }
            break;
        }case UIGestureRecognizerStateEnded:{ // 移动停止
            degress = 0;
            verticalDegress = 0;
//            degress = glView.degress + degress;
//            if (degress >= 360) {
//                degress = 0;
//            }
        }
        default:
            break;
    }
    
    
    
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    glView.overture /= recognizer.scale;
    
    if (glView.overture > MAX_OVERTURE) {
        glView.overture = MAX_OVERTURE;
    }
    
    if (glView.overture < MIN_OVERTURE) {
        glView.overture = MIN_OVERTURE;
    }
}

- (void)startDeviceMotion
{
    if (_motionManager) {
        return;
    }
    _motionManager = [[CMMotionManager alloc] init];
    _referenceAttitude = nil;
    _motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    _motionManager.gyroUpdateInterval = 1.0f / 60;
    _motionManager.showsDeviceMovementDisplay = YES;
    
    [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXMagneticNorthZVertical];
    
    _referenceAttitude = _motionManager.deviceMotion.attitude; // Maybe nil actually. reset it
    glView.motionManager = _motionManager;
    glView.referenceAttitude = _referenceAttitude;
    displayLink.paused = NO;
    
}

-(void)stopDeviceMotion{
    [_motionManager stopDeviceMotionUpdates];
    _referenceAttitude = nil;
    displayLink.paused = YES;
    _motionManager = nil;
    
}


@end
