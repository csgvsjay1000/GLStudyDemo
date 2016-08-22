//
//  KBOpenGLView4_0.m
//  GLStudyDemo
//
//  Created by chengshenggen on 8/22/16.
//  Copyright © 2016 Gan Tian. All rights reserved.
//

#import "KBOpenGLView4_0.h"
#import <GLKit/GLKit.h>
#import "GLProgram.h"

@interface KBOpenGLView4_0 (){
    CGSize sizeInPixels;
    EAGLContext *context;
    GLuint displayRenderbuffer, displayFramebuffer,_depthRenderBuffer;
    
    GLProgram *displayProgram;
    
    GLuint VBO, VAO, EBO;
    GLuint texture;
    
    GLKVector3 cameraPos;
    GLKVector3 cameraFront;
    GLKVector3 cameraUp;
    
    GLfloat cameraSpeed;
}

@end

@implementation KBOpenGLView4_0

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGL];
        cameraPos = GLKVector3Make(0, 0, 3);
        cameraFront = GLKVector3Make(0, 0, -1);
        cameraUp = GLKVector3Make(0.0f, 1.0f,  0.0f);
        
        cameraSpeed = 0.05f;
        
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
    glEnable(GL_DEPTH_TEST);
    
    glClearColor(0 , 0.1, 0.1, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self drawObjects];
    
    [self presentFramebuffer];
}

-(void)upActions{
    cameraPos = GLKVector3Add(cameraPos, GLKVector3MultiplyScalar(cameraFront, cameraSpeed));
}
-(void)downActions{
    cameraPos = GLKVector3Subtract(cameraPos, GLKVector3MultiplyScalar(cameraFront, cameraSpeed));

}
-(void)leftActions{
    cameraPos = GLKVector3Subtract(cameraPos, GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3CrossProduct(cameraFront, cameraUp)),cameraSpeed));
}
-(void)rightActions{
    cameraPos = GLKVector3Add(cameraPos, GLKVector3MultiplyScalar(GLKVector3Normalize(GLKVector3CrossProduct(cameraFront, cameraUp)),cameraSpeed));
}

#pragma mark - drawObjects
-(void)drawObjects{
    
    [displayProgram use];

    GLKMatrix4 model = GLKMatrix4Identity;
    
//    model = GLKMatrix4Rotate(model, GLKMathDegreesToRadians(-55), 1, 0, 0);
    
    GLKMatrix4 viewM = GLKMatrix4Identity;
    
//    GLfloat radius = 5.0f;
//    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
//    GLfloat camX = sin(time) * radius;
//    GLfloat camZ = cos(time) * radius;
//    viewM = GLKMatrix4Translate(viewM, 0.3, 0, -4);
    
    GLKVector3 target = GLKVector3Add(cameraPos, cameraFront);

    viewM = GLKMatrix4MakeLookAt(cameraPos.x,cameraPos.y,cameraPos.z, target.x, target.y, target.z, cameraUp.x, cameraUp.y, cameraUp.z);
    
    GLKMatrix4 projection = GLKMatrix4Identity;
    projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(15), sizeInPixels.width/sizeInPixels.height, 0.1, 100);
    

    glUniformMatrix4fv([displayProgram uniformIndex:@"model"], 1, GL_FALSE, model.m);
    glUniformMatrix4fv([displayProgram uniformIndex:@"view"], 1, GL_FALSE, viewM.m);
    glUniformMatrix4fv([displayProgram uniformIndex:@"projection"], 1, GL_FALSE, projection.m);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i([displayProgram uniformIndex:@"inputImageTexture"], 0);
    
    glBindVertexArrayOES(VAO);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
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
    
    glGenRenderbuffers(1, &displayRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
    
    GLint backingWidth, backingHeight;
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    sizeInPixels.width = (CGFloat)backingWidth;
    sizeInPixels.height = (CGFloat)backingHeight;
    
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, sizeInPixels.width, sizeInPixels.height);
    
    glGenFramebuffers(1, &displayFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
    
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
    
    [self loadCube];
    [self loadTexture];

}

-(void)loadCube{
    // Set up vertex data (and buffer(s)) and attribute pointers
    // Set up vertex data (and buffer(s)) and attribute pointers
    GLfloat vertices[] = {
        // Positions          // Colors           // Texture Coords
        0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f, // Top Right
        0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f, // Bottom Right
        -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f, // Bottom Left
        -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f  // Top Left
    };

    glGenVertexArraysOES (1, &VAO);
    glGenBuffers(1, &VBO);
    
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindVertexArrayOES(VAO);
    glVertexAttribPointer([displayProgram attributeIndex:@"position"], 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)0);
    glEnableVertexAttribArray([displayProgram attributeIndex:@"position"]);
    
    glVertexAttribPointer([displayProgram attributeIndex:@"inputTextureCoordinate"], 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat), (GLvoid*)(6 * sizeof(GLfloat)));
    glEnableVertexAttribArray([displayProgram attributeIndex:@"inputTextureCoordinate"]);
    
    glBindVertexArrayOES(0);
    
}

-(void)loadTexture{
    texture = [GLProgram rendImage:[UIImage imageNamed:@"1234.jpg"]];
}


-(void)loadLightingShader{
    displayProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"lighting4_0" fragmentShaderFilename:@"lighting4_0"];
    
    if (!displayProgram.initialized)
    {
        [displayProgram addAttribute:@"position"];
        [displayProgram addAttribute:@"inputTextureCoordinate"];
        
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


@end
