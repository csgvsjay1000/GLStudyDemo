//
//  KBOpenGLView8_0.h
//  GLStudyDemo
//
//  Created by David on 16/9/24.
//  Copyright © 2016年 Gan Tian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBOpenGLViewDelegate.h"
#import <CoreMotion/CoreMotion.h>

@interface KBOpenGLView8_0 : UIView<KBOpenGLViewDelegate>

@property (assign, nonatomic) CGFloat overture;
@property (assign, nonatomic) CGFloat degress;
@property (assign, nonatomic) CGFloat verticalDegress;

//陀螺仪
@property(nonatomic,strong) CMAttitude *referenceAttitude;
@property(nonatomic,strong) CMMotionManager *motionManager;

@end
