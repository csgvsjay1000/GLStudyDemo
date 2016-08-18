//
//  KBOpenGLView2_0.m
//  GLStudyDemo
//
//  Created by chengshenggen on 8/18/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBOpenGLView2_0.h"
#import <GLKit/GLKit.h>
#import "GLProgram.h"

@interface KBOpenGLView2_0 (){
    CGSize sizeInPixels;
    EAGLContext *context;
    GLuint displayRenderbuffer, displayFramebuffer,_depthRenderBuffer;
    
    GLProgram *displayProgram;
    GLProgram *lampShader;
    
    GLuint VBO, VAO, EBO;
    GLuint VBO_1, VAO_1, EBO_1;
}

@end

@implementation KBOpenGLView2_0

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGL];
    }
    return self;
}

#pragma mark - public method
-(void)refreshFrame{
    // The frame buffer needs to be trashed and re-created when the view size changes.
    if (!CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        [self destroyDisplayFramebuffer];
        [self createDisplayFramebuffer];
        glViewport(0, 0, sizeInPixels.width, sizeInPixels.height);
        
    }
}

-(void)render{
    glClearColor(0 , 0.1, 0.1, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self drawObjects];
    
    [self drawLights];
    
    [self presentFramebuffer];
}

#pragma mark - drawObjects
-(void)drawObjects{
    
    [displayProgram use];
    
    glUniform3f([displayProgram uniformIndex:@"objectColor"], 1.0, 0.5, 0.31);  //珊瑚红
    glUniform3f([displayProgram uniformIndex:@"lightColor"], 1.0, 1.0, 1.0);  //白色
    glUniform3f([displayProgram uniformIndex:@"lightPos"], -1, -1, 1);  // 光源位置

    GLKMatrix4 model = GLKMatrix4Identity;
    GLKMatrix4 viewM = GLKMatrix4Identity;
    
    GLKMatrix4 projection = GLKMatrix4Identity;
    projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45), sizeInPixels.width/sizeInPixels.height, 0.1, 100);
    
    GLKVector3 cameraPos = GLKVector3Make(1, 1, -3);
    GLKVector3 cameraFront = GLKVector3Make(-1, -1, 3);
    
    GLKVector3 temp = GLKVector3Make(0, 3, 1);
    
    GLKVector3 cameraUp = GLKVector3CrossProduct(temp, cameraFront);
    
    GLKVector3 cameraTarget = GLKVector3Add(cameraPos, cameraFront);
    
    
    viewM = GLKMatrix4MakeLookAt(cameraPos.x, cameraPos.y, cameraPos.z, cameraTarget.x, cameraTarget.y, cameraTarget.z, cameraUp.x, cameraUp.y, cameraUp.z);
    
    
    glUniformMatrix4fv([displayProgram uniformIndex:@"model"], 1, GL_FALSE, model.m);
    glUniformMatrix4fv([displayProgram uniformIndex:@"view"], 1, GL_FALSE, viewM.m);
    glUniformMatrix4fv([displayProgram uniformIndex:@"projection"], 1, GL_FALSE, projection.m);
    
    glBindVertexArrayOES(VAO);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArrayOES(0);
}

-(void)drawLights{
    
    glBindVertexArrayOES(VAO_1);
    
    GLKMatrix4 model = GLKMatrix4Identity;
    
    model = GLKMatrix4TranslateWithVector3(model, GLKVector3Make(-0.5, 0.0, 10.0));
    //    model = GLKMatrix4ScaleWithVector3(model, GLKVector3Make(0.5, 0.5, 0.5));
    GLKMatrix4 viewM = GLKMatrix4Identity;
    
    GLKMatrix4 projection = GLKMatrix4Identity;
    projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45), sizeInPixels.width/sizeInPixels.height, 0.1, 100);
    
    GLKVector3 cameraPos = GLKVector3Make(1, 1, -3);
    GLKVector3 cameraFront = GLKVector3Make(-1, -1, 3);   // Z 轴
    
    GLKVector3 temp = GLKVector3Make(0, 3, 1);  // X 轴
    
    //    float a = 1,b = 1,c;
    
    GLKVector3 cameraUp = GLKVector3CrossProduct(temp, cameraFront);  // Y 轴
    
    GLKVector3 cameraTarget = GLKVector3Add(cameraPos, cameraFront);
    
    
    viewM = GLKMatrix4MakeLookAt(cameraPos.x, cameraPos.y, cameraPos.z, cameraTarget.x, cameraTarget.y, cameraTarget.z, cameraUp.x, cameraUp.y, cameraUp.z);
    
    [lampShader use];
    
    glUniformMatrix4fv([lampShader uniformIndex:@"model"], 1, GL_FALSE, model.m);
    glUniformMatrix4fv([lampShader uniformIndex:@"view"], 1, GL_FALSE, viewM.m);
    glUniformMatrix4fv([lampShader uniformIndex:@"projection"], 1, GL_FALSE, projection.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArrayOES(0);
}


- (void)presentFramebuffer{
    [EAGLContext setCurrentContext:context];
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - Framebuffer
- (void)createDisplayFramebuffer{
    [EAGLContext setCurrentContext:context];
    
    glGenFramebuffers(1, &displayFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
    
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    
    glGenRenderbuffers(1, &displayRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    
    

    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    GLint backingWidth, backingHeight;
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    sizeInPixels.width = (CGFloat)backingWidth;
    sizeInPixels.height = (CGFloat)backingHeight;
    if ( (backingWidth == 0) || (backingHeight == 0) )
    {
        [self destroyDisplayFramebuffer];
        return;
    }
    
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, sizeInPixels.width, sizeInPixels.height);
    
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, displayRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);

    

    
    __unused GLuint framebufferCreationStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(framebufferCreationStatus == GL_FRAMEBUFFER_COMPLETE, @"Failure with display framebuffer generation for display of size: %f, %f", self.bounds.size.width, self.bounds.size.height);
    
    
    

    
}

- (void)destroyDisplayFramebuffer;
{
    [EAGLContext setCurrentContext:context];
    
    if (displayFramebuffer)
    {
        glDeleteFramebuffers(1, &displayFramebuffer);
        displayFramebuffer = 0;
    }
    
    if (displayRenderbuffer)
    {
        glDeleteRenderbuffers(1, &displayRenderbuffer);
        displayRenderbuffer = 0;
    }
    
    if (_depthRenderBuffer)
    {
        glDeleteRenderbuffers(1, &_depthRenderBuffer);
        _depthRenderBuffer = 0;
    }
}


#pragma mark - private method
-(void)setupGL{
    // Set scaling to account for Retina display
    if ([self respondsToSelector:@selector(setContentScaleFactor:)])
    {
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
    }
    
    self.opaque = YES;
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:context];
    
    [self loadLightingShader];
    [self loadLampShader];
    
    [self loadCube];
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
}

-(void)loadCube{
    GLfloat vertices[] = {
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        
        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f
    };
    
    glGenVertexArraysOES (1, &VAO);
    glGenBuffers(1, &VBO);
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindVertexArrayOES(VAO);
    glVertexAttribPointer([displayProgram attributeIndex:@"position"], 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray([displayProgram attributeIndex:@"position"]);
    
    glVertexAttribPointer([displayProgram attributeIndex:@"normalLocal"], 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (GLvoid*)(3*sizeof(GLfloat)));
    glEnableVertexAttribArray([displayProgram attributeIndex:@"normalLocal"]);
    glBindVertexArrayOES(0);
    
    
    
    glGenVertexArraysOES (1, &VAO_1);
    glGenBuffers(1, &VBO_1);
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO_1);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindVertexArrayOES(VAO_1);
    glVertexAttribPointer([lampShader attributeIndex:@"position"], 3, GL_FLOAT, GL_FALSE, 6 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray([lampShader attributeIndex:@"position"]);
    glBindVertexArrayOES(0);
    
    
}

-(void)loadLightingShader{
    displayProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"lighting2_0" fragmentShaderFilename:@"lighting2_0"];
    
    if (!displayProgram.initialized)
    {
        [displayProgram addAttribute:@"position"];
        [displayProgram addAttribute:@"normalLocal"];

        if (![displayProgram link])
        {
            NSString *progLog = [displayProgram programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [displayProgram fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [displayProgram vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            displayProgram = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
}

-(void)loadLampShader{
    lampShader = [[GLProgram alloc] initWithVertexShaderFilename:@"lamp" fragmentShaderFilename:@"lamp"];
    
    if (!lampShader.initialized)
    {
        [lampShader addAttribute:@"position"];
        
        if (![lampShader link])
        {
            NSString *progLog = [lampShader programLog];
            NSLog(@"Program link log: %@", progLog);
            NSString *fragLog = [lampShader fragmentShaderLog];
            NSLog(@"Fragment shader compile log: %@", fragLog);
            NSString *vertLog = [lampShader vertexShaderLog];
            NSLog(@"Vertex shader compile log: %@", vertLog);
            lampShader = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
    }
}


@end
