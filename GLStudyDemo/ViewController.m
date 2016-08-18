//
//  ViewController.m
//  GLStudyDemo
//
//  Created by chengshenggen on 8/18/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "ViewController.h"
//#import "KBOpenglView.h"
//#import "KBOpenGLView1_0.h"
#import "KBOpenGLView2_0.h"

@interface ViewController (){
//    KBOpenglView *glView;
    KBOpenGLView2_0 *glView;

    CADisplayLink *displayLink;

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkPresent)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    displayLink.paused = YES;
    displayLink.frameInterval = 2;
    glView = [[KBOpenGLView2_0 alloc] initWithFrame:CGRectZero];
    [self.view addSubview:glView];
    
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
    
    [glView refreshFrame];
    
    displayLink.paused = NO;
    
    
}

-(void)displayLinkPresent{
    [glView render];
    
}


@end
