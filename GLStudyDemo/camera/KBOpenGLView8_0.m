//
//  KBOpenGLView8_0.m
//  GLStudyDemo
//
//  Created by David on 16/9/24.
//  Copyright © 2016年 Gan Tian. All rights reserved.
//

#import "KBOpenGLView8_0.h"
#import <GLKit/GLKit.h>
#import "GLProgram.h"

#define ES_PI  (3.14159265f)
#define ROLL_CORRECTION ES_PI/2.0



@interface KBOpenGLView8_0 (){
    CGSize sizeInPixels;
    EAGLContext *context;
    GLuint displayRenderbuffer, displayFramebuffer;
    
    GLProgram *displayProgram;
    
    GLuint texture;
    
    GLuint VBO, VAO, EBO;
    
    int _numIndices;
    GLuint VBO_Texture;
    
    GLKVector3 cameraPos;
    GLKVector3 cameraFront;
    GLKVector3 cameraUp;
    
    GLfloat cameraSpeed;
    GLKMatrix4 model;

}


@end

@implementation KBOpenGLView8_0

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGL];
        self.overture = 85;
        model = GLKMatrix4Identity;
        cameraPos = GLKVector3Make(0, 0, 0);
        cameraFront = GLKVector3Make(0, 0, -1);
        cameraUp = GLKVector3Make(0.0f, 1.0f,  0.0f);
        
        cameraSpeed = 0.05f;
    }
    return self;
}

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
    
    [self loadVertexData];
    [self loadTexture];
    
}

-(void)layoutSubviews{
    
    if (self.bounds.size.width>0) {
        @synchronized (self) {
            [self destroyDisplayFramebuffer];
            [self createDisplayFramebuffer];
            glViewport(0, 0, sizeInPixels.width, sizeInPixels.height);
        }
    }
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
    
    glGenFramebuffers(1, &displayFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, displayRenderbuffer);
    
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
    
}

-(void)refreshFrame{
    
}

-(void)render{
    [EAGLContext setCurrentContext:context];
    glClearColor(0 , 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    [displayProgram use];
    model = GLKMatrix4Identity;
    
    CMDeviceMotion *deviceMotion = self.motionManager.deviceMotion;

    
    model = GLKMatrix4RotateX(model, GLKMathDegreesToRadians(self.verticalDegress));
    model = GLKMatrix4RotateY(model, GLKMathDegreesToRadians(self.degress));

    
    GLKMatrix4 viewM = GLKMatrix4Identity;
    
//    
    model = GLKMatrix4RotateX(model, ES_PI);


    
    GLKVector3 target = GLKVector3Add(cameraPos, cameraFront);
    
    viewM = GLKMatrix4MakeLookAt(cameraPos.x,cameraPos.y,cameraPos.z, target.x, target.y, target.z, cameraUp.x, cameraUp.y, cameraUp.z);
    
    GLKMatrix4 projection = GLKMatrix4Identity;
    projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(self.overture), sizeInPixels.width/sizeInPixels.height, 0.1, 100);
    
    
    
    glUniformMatrix4fv([displayProgram uniformIndex:@"model"], 1, GL_FALSE, model.m);
    glUniformMatrix4fv([displayProgram uniformIndex:@"view"], 1, GL_FALSE, viewM.m);
    glUniformMatrix4fv([displayProgram uniformIndex:@"projection"], 1, GL_FALSE, projection.m);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, texture);
    glUniform1i([displayProgram uniformIndex:@"inputImageTexture"], 3);
    
    glBindVertexArrayOES(VAO);
    glDrawElements ( GL_TRIANGLES, _numIndices,GL_UNSIGNED_SHORT, 0 );
    glBindVertexArrayOES(0);
    
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)upActions{
    _vertical = _vertical+0.1;
    cameraPos = GLKVector3Make(0, _vertical, 0);
}
-(void)downActions{
    _vertical = _vertical-0.1;
    cameraPos = GLKVector3Make(0, _vertical, 0);
}
-(void)leftActions{
    
}
-(void)rightActions{
    
}

-(void)loadVertexData{
    GLfloat *vVertices = NULL;
    GLfloat *vTextCoord = NULL;
    GLushort *indices = NULL;
    int numVertices = 0;
    _numIndices =  esGenSphere_3(200, 1.0f, &vVertices,  NULL,&vTextCoord, &indices, &numVertices,0);
    glGenVertexArraysOES (1, &VAO);
    glBindVertexArrayOES(VAO);
    
    // Vertex
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER,
                 numVertices*3*sizeof(GLfloat),
                 vVertices,
                 GL_STATIC_DRAW);
    glEnableVertexAttribArray([displayProgram attributeIndex:@"position"]);
    glVertexAttribPointer([displayProgram attributeIndex:@"position"],
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(GLfloat) * 3,
                          NULL);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // Texture Coordinates
    glGenBuffers(1, &VBO_Texture);
    glBindBuffer(GL_ARRAY_BUFFER, VBO_Texture);
    glBufferData(GL_ARRAY_BUFFER,
                 numVertices*2*sizeof(GLfloat),
                 vTextCoord,
                 GL_STATIC_DRAW);
    glEnableVertexAttribArray([displayProgram attributeIndex:@"inputTextureCoordinate"]);
    glVertexAttribPointer([displayProgram attributeIndex:@"inputTextureCoordinate"],
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(GLfloat) * 2,
                          NULL);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    //Indices
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                 sizeof(GLushort) * _numIndices,
                 indices, GL_STATIC_DRAW);
    //    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
    
    
    free(vVertices);
    free(vTextCoord);
    free(indices);
    
}



int esGenSphere_3 ( int numSlices, float radius, float **vertices, float **normals,
                   float **texCoords, uint16_t **indices, int *numVertices_out,int videoType) {
    int i;
    int j;
    int numParallels = numSlices / 2;
    int numVertices = ( numParallels + 1 ) * ( numSlices + 1 );
    int numIndices = numParallels * numSlices * 6;
    
    float angleStep = (2.0f * 3.14159265f) / ((float) numSlices);
    
    if ( vertices != NULL )
        *vertices = malloc ( sizeof(float) * 3 * numVertices );
    
    // Pas besoin des normals pour l'instant
    //    if ( normals != NULL )
    //        *normals = malloc ( sizeof(float) * 3 * numVertices );
    
    if ( texCoords != NULL )
        *texCoords = malloc ( sizeof(float) * 2 * numVertices );
    
    if ( indices != NULL )
        *indices = malloc ( sizeof(uint16_t) * numIndices );
    
    for ( i = 0; i < numParallels + 1; i++ ) {
        for ( j = 0; j < numSlices + 1; j++ ) {
            int vertex = ( i * (numSlices + 1) + j ) * 3;
            
            if ( vertices ) {
                (*vertices)[vertex + 0] = radius * sinf ( angleStep * (float)i ) *
                sinf ( angleStep * (float)j );
                (*vertices)[vertex + 1] = radius * cosf ( angleStep * (float)i );
                (*vertices)[vertex + 2] = radius * sinf ( angleStep * (float)i ) *
                cosf ( angleStep * (float)j );
            }
            
            if (texCoords) {
                int texIndex = ( i * (numSlices + 1) + j ) * 2;
                (*texCoords)[texIndex + 0] = (float) j / (float) numSlices;
                (*texCoords)[texIndex + 1] = 1.0f - ((float) i / (float) (numParallels));
                
            }
        }
    }
    
    // Generate the indices
    if ( indices != NULL ) {
        uint16_t *indexBuf = (*indices);
        for ( i = 0; i < numParallels ; i++ ) {
            for ( j = 0; j < numSlices; j++ ) {
                *indexBuf++  = i * ( numSlices + 1 ) + j;
                *indexBuf++ = ( i + 1 ) * ( numSlices + 1 ) + j;
                *indexBuf++ = ( i + 1 ) * ( numSlices + 1 ) + ( j + 1 );
                
                *indexBuf++ = i * ( numSlices + 1 ) + j;
                *indexBuf++ = ( i + 1 ) * ( numSlices + 1 ) + ( j + 1 );
                *indexBuf++ = i * ( numSlices + 1 ) + ( j + 1 );
            }
        }
    }
    
    if (numVertices_out) {
        *numVertices_out = numVertices;
    }
    
    return numIndices;
}


-(void)loadTexture{
    texture = [GLProgram rendImage:[UIImage imageNamed:@"sztest.png"]];
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
