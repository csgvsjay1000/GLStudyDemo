//
//  KBOpenGLViewDelegate.h
//  GLStudyDemo
//
//  Created by chengshenggen on 8/23/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KBOpenGLViewDelegate <NSObject>

-(void)refreshFrame;

-(void)render;

-(void)upActions;
-(void)downActions;
-(void)leftActions;
-(void)rightActions;

@end
