//
//  ViewController.m
//  GLStudyDemo
//
//  Created by chengshenggen on 8/18/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "ViewController.h"
//#import "KBOpenglView.h"
#import "KBOpenGLView6_0.h"
//#import "KBOpenGLView4_0.h"

@interface ViewController (){
//    KBOpenglView *glView;
    UIView<KBOpenGLViewDelegate> *glView;

    CADisplayLink *displayLink;

}
@property (weak, nonatomic) IBOutlet UIView *leftView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkPresent)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    displayLink.paused = YES;
    displayLink.frameInterval = 2;
    glView = [[KBOpenGLView6_0 alloc] initWithFrame:CGRectZero];
    [self.view addSubview:glView];
    
    [self.view bringSubviewToFront:self.leftView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
//    glView.frame = CGRectMake(0, 0, 400, 300);

    glView.frame = CGRectMake(0, 0, width, height);

    [glView refreshFrame];
    
    displayLink.paused = NO;
    
    
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


@end
