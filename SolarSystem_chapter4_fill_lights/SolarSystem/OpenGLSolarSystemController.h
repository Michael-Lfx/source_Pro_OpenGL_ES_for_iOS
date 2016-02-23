//
// Created by michael on 2/19/16.
// Copyright (c) 2016 michaelfx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Planet.h"

@interface OpenGLSolarSystemController : NSObject {
    Planet *m_Earth;
}
- (void)execute;

- (id)init;

- (void)initGeometry;
@end