//
//  Planet.m
//  SolarSystem
//
//  Created by michael on 2/19/16.
//  Copyright © 2016 michaelfx. All rights reserved.
//

#import "Planet.h"

@implementation Planet

- (id)init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius squash:(GLfloat)squash {
    unsigned int colorIncrment = 0; // 1
    unsigned int blue = 0;
    unsigned int red = 255;
    int numVertices = 0;

    m_Scale = radius;
    m_Squash = squash;

    colorIncrment = 255 / stacks; // 2

    if (self = [super init]) {
        m_Stacks = stacks;
        m_Slices = slices;
        m_VertexData = nil;

        /**
         * The basic algorithm divides the sphere into stacks and slices.
         * Stacks are the lateral pieces while slices are vertical.
         * The boundaries of the stacks are generated two at a time as partners.
         * These form the boundaries of the triangle strip.
         * So, stack A and B are calculated and subdivided into triangles
         * based on the number of slices around the circle.
         * The next time through, take stacks B and C and rinse and repeat.
         * Two boundary conditions apply:
         *      1. The first and last stacks contain the two poles,
         *      in which case they are more of a triangle fan,
         *      as opposed to a strip, but we treat them as strips to simplify the code.
         *      2. Make sure that the end of each strip
         *      connects with the beginning to form a contiguous set of triangles.
         *
         */

        // vertices
        GLfloat *vPtr = m_VertexData = (GLfloat *) malloc(sizeof(GLfloat) * 3 * ((m_Slices * 2 + 2) * m_Stacks)); // 3

        // color data
        GLubyte *cPtr = m_ColorData = (GLubyte *) malloc((sizeof(GLubyte) * 4 * (m_Slices * 2 + 2) * m_Stacks)); // 4

        // Normal pointers for lighting.
        GLfloat *nPtr = m_NormalData = (GLfloat *) malloc(sizeof(GLfloat) * 3 * ((m_Slices * 2 + 2) * (m_Stacks)));

        unsigned int phiIdx, thetaIdx;

        // latitude
        for (phiIdx = 0; phiIdx < m_Stacks; ++phiIdx) { // 5
            // Starts at -1.57 goes up to +1.57 radians

            // the first circle.
            float phi0 = M_PI * ((float) (phiIdx + 0) * (1.0 / (float) (m_Stacks)) - 0.5); // 6

            // the next, or second one

            float phi1 = M_PI * ((float) (phiIdx + 1) * (1.0 / (float) (m_Stacks)) - 0.5); // 7
            float cosPhi0 = cos(phi0);  // 8 precalculated to minimize the CPU load.
            float sinPhi0 = sin(phi0);
            float cosPhi1 = cos(phi1);
            float sinPhi1 = sin(phi1);

            float cosTheta, sinTheta;
            // longtitude
            /**
             * going from 0 to 360 degrees, and defines the slices.
             * The math is similar, so no need to go into extreme detail,
             * except that we are calculating the points on a circle, via line 10.
             * Both m_Scale and m_Squash come into play here.
             * But for now, just assume that they are both 1.0, so the sphere is normalized.
             */
            for (int thetaIdx = 0; thetaIdx < m_Slices; ++thetaIdx) { //9
                // increment along the longitude circle each "slice"
                float theta = 2.0 * M_PI * ((float) thetaIdx) * (1.0 / (float) (m_Slices - 1));

                cosTheta = cos(theta);
                sinTheta = sin(theta);

                //We're generating a vertical pair of points, such
                //as the first point of stack 0 and the first point of stack 1
                //above it. This is how TRIANGLE_STRIPS work,
                //taking a set of 4 vertices and essentially drawing two triangles
                //at a time. The first is v0-v1-v2 and the next is v2-v1-v3, and so on.
                //Get x-y-z for the first vertex of stack.

                vPtr[0] = m_Scale * cosPhi0 * cosTheta;                              //10
                vPtr[1] = m_Scale * sinPhi0 * m_Squash;
                vPtr[2] = m_Scale * cosPhi0 * sinTheta;

                //The same but for the vertex immediately above the previous one.
                vPtr[3] = m_Scale * cosPhi1 * cosTheta;
                vPtr[4] = m_Scale * sinPhi1 * m_Squash;
                vPtr[5] = m_Scale * cosPhi1 * sinTheta;

                // Normal pointers for lighting.
                nPtr[0] = cosPhi0 * cosTheta;                                       //2
                nPtr[1] = sinPhi0;
                nPtr[2] = cosPhi0 * sinTheta;
                nPtr[3] = cosPhi1 * cosTheta;                                       //3
                nPtr[4] = sinPhi1;
                nPtr[5] = cosPhi1 * sinTheta;

                cPtr[0] = red;                                                     //11
                cPtr[1] = 0;
                cPtr[2] = blue;
                cPtr[4] = red;
                cPtr[5] = 0;
                cPtr[6] = blue;
                cPtr[3] = cPtr[7] = 255;
                cPtr += 2 * 4;                                                        //12
                vPtr += 2 * 3;
            }
            blue += colorIncrment;                                                    //13
            red -= colorIncrment;
        }
        numVertices = (vPtr - m_VertexData) / 6;
    }
    return self;
}

- (bool)execute {
    glMatrixMode(GL_MODELVIEW);                                                     //1
    glEnable(GL_CULL_FACE);                                                         //2
    glCullFace(GL_BACK);                                                            //3

    glEnableClientState(GL_NORMAL_ARRAY);                                           //1
    glEnableClientState(GL_VERTEX_ARRAY);                                           //4
    glEnableClientState(GL_COLOR_ARRAY);                                            //5

    glNormalPointer(GL_FLOAT, 0, m_NormalData);                                     //2
    glVertexPointer(3, GL_FLOAT, 0, m_VertexData);                                  //6
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_ColorData);                            //7
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (m_Slices + 1) * 2 * (m_Stacks - 1) + 2);    //8
    return true;
}

@end
