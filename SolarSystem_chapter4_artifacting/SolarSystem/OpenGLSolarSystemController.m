//
// Created by michael on 2/19/16.
// Copyright (c) 2016 michaelfx. All rights reserved.
//

#import "OpenGLSolarSystemController.h"

@implementation OpenGLSolarSystemController

- (id)init {
    [self initGeometry];
    return self;
}

- (void)initGeometry {
    m_Earth = [[Planet alloc] init:5 slices:5 radius:1.0 squash:1.0];
}

- (void)execute {
    static GLfloat angle = 0;
    glLoadIdentity();
    glTranslatef(0.0, -0.0, -3.0);
    glRotatef(angle, 0.0, 1.0, 0.0);
    [m_Earth execute];
    angle += .5;
}

@end