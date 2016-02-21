//
//  ViewController..m
//  SolarSystem
//
//  Created by michael on 2/19/16.
//  Copyright © 2016 michaelfx. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLSolarSystemController.h"
#import "OpenGLSolarSystem.h"

@interface ViewController ()
@property(strong, nonatomic) EAGLContext *context;
@end

@implementation ViewController {
    OpenGLSolarSystemController *m_SolarSystem;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }

    GLKView *view = (GLKView *) self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;

    m_SolarSystem = [[OpenGLSolarSystemController alloc] init];
    [EAGLContext setCurrentContext:self.context];

    [self setClipping];
    [self initLighting];
}

- (void)setClipping {
    float aspectRatio;
    const float zNear = .1;                                                         //1
    const float zFar = 1000;                                                        //2
    const float fieldOfView = 60.0;                                                 //3
    GLfloat size;
    CGRect frame = [[UIScreen mainScreen] bounds];                                  //4
    //Height and width values clamp the fov to the height; flipping it would make it relative to the width.
    //So if we want the field-of-view to be 60 degrees, similar to that of a wide angle lens, it will be
    //based on the height of our window and not the width.  This is important to know when rendering
    // to a non-square screen.
    aspectRatio = (float) frame.size.width / (float) frame.size.height;             //5
    //Set the OpenGL projection matrix.
    glMatrixMode(GL_PROJECTION);                                                    //6
    glLoadIdentity();
    size = zNear * tanf(GLKMathDegreesToRadians(fieldOfView) / 2.0);                //7
    glFrustumf(-size, size, -size / aspectRatio, size / aspectRatio, zNear, zFar);  //8
    glViewport(0, 0, frame.size.width * 2.0, frame.size.height * 2.0);              //9
    //Make the OpenGL ModelView matrix the default.
    glMatrixMode(GL_MODELVIEW);                                                     //10
}

- (void)initLighting {
    GLfloat pos[] = {10.0, 3.0, 0.0, 1.0};

    GLfloat white[] = {1.0, 1.0, 1.0, 1.0};
    GLfloat red[] = {1.0, 0.0, 0.0, 1.0};
    GLfloat green[] = {0.0, 1.0, 0.0, 1.0};
    GLfloat blue[] = {0.0, 0.0, 1.0, 1.0};

    GLfloat cyan[] = {0.0, 1.0, 1.0, 1.0};
    GLfloat yellow[] = {1.0, 1.0, 0.0, 1.0};
    GLfloat magenta[] = {1.0, 0.0, 1.0, 1.0};
    GLfloat halfcyan[] = {0.0, .5, .5, 1.0};

    glLightfv(SS_SUNLIGHT, GL_POSITION, pos);          //3
    glLightfv(SS_SUNLIGHT, GL_DIFFUSE, white);       //4
    glLightfv(SS_SUNLIGHT, GL_SPECULAR, red);
    glLightfv(SS_SUNLIGHT, GL_AMBIENT, blue);

    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, green);
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, red);
    glMaterialf(GL_FRONT_AND_BACK, GL_SHININESS, 25);
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, blue);

    GLfloat colorVector[4] = {0.7, 0.7, 0.7, 1.0};
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, colorVector);
    glLightModelf(GL_LIGHT_MODEL_TWO_SIDE, 1.0);
    glFrontFace(GL_CCW);

    glShadeModel(GL_SMOOTH);                           //5
    glEnable(GL_LIGHTING);                           //6
    glEnable(SS_SUNLIGHT);                           //7

    glLoadIdentity();
}

- (void)dealloc {
    [self tearDownGL];

    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;

        [self tearDownGL];

        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [m_SolarSystem execute];
}

@end
