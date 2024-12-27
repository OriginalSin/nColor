// Sobel operator
float toGray(vec4 color) {
    return 0.2126*color.x + 0.7152*color.y + 0.0722*color.z;
}

const mat3 sobelMatrixX = mat3(
   1.0, 2.0, 1.0,
   0.0, 0.0, 0.0,
   -1.0, -2.0, -1.0
);
const mat3 sobelMatrixY = mat3(
   1.0, 0.0, -1.0,
   2.0, 0.0, -2.0,
   1.0, 0.0, -1.0
);
vec2 sobel(sampler2D channel, ivec2 coord) {
    vec2 g = vec2(0.0);
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            vec2 coef = vec2(sobelMatrixX[i][j],sobelMatrixY[i][j]);
            g += coef*toGray(texelFetch(channel, coord+ivec2(i-1,j-1), 0));
        }
    }
    return g;
}
#iChannel1 "file://./a.glsl"

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 Color = vec4(sobel(iChannel1, ivec2(fragCoord)).x,sobel(iChannel1, ivec2(fragCoord)).y,0.,0.);
    if(iMouse.z>0.){
    Color.x*=iMouse.x/iResolution.x;
    Color.y*=iMouse.y/iResolution.y;
    }else{
    Color.x*=cos(iTime)*1.2;
    Color.y*=sin(iTime)*1.2;
    }
    fragColor=Color;
}