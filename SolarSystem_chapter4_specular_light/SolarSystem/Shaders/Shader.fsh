//
//  Shader.fsh
//  SolarSystem
//
//  Created by michael on 2/19/16.
//  Copyright © 2016 michaelfx. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
