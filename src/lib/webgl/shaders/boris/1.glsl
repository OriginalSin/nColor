#define SCALE 1.0

// Generates a chessboard pattern.
//
// It is made of vertical stripes that are shifted by oscillating xOffset along with vertical axis.
// Stripes and oscillation are made by a square wave.
// float chessboard1(vec2 uv) {
//     float xOffset = step(fract(uv.y), 0.5) * 0.5;
//     return step(fract(uv.x + xOffset), 0.5);
// }
// vec2 data1[2] = vec2[2] (
//     vec2(1.), vec2(2.)
// );

int data[24] = int[24] (
    0,  0,  0,  1,  0,  1,
    1,  1,  0,  1,  1,  1,
    0,  0,  1,  0,  1,  0,
    1,  0,  1,  1,  1,  1
);
float dx = 6.;
float dy = 4.;
//  0 0 0 1 0 1
//  1 1 0 1 1 1
//  0 0 1 0 1 0
//  1 0 1 1 1 1
// float p1 = 0.5;
float p1 = 0.25;
// float p1 = 1. / 6.;
float chessboard(vec2 uv) {
    float xOffset = step(fract(uv.y), p1) * 0.25;
    return step(fract(uv.x + xOffset), 0.5);
}
float chess1(vec2 uv, float mn, float mx) {
    // float xOffset = step(fract(uv.y), p1) * 0.25;
    return clamp(uv.x , mn, mx);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy * SCALE;
	// vec2 uv = fragCoord.xy;
    // vec3 color = vec3(chess1(uv, 0., 1. / 6.));
    vec3 color = vec3(1., 0., 0.);
    float x = floor(uv.x * dx*3.);
    float y = floor(uv.y * dy*3.);
    // fragColor = vec4(vec3(data[int(x*dy + y)]) , 1.0);
    if (mod(x, 3.) == 1. && mod(y, 3.) == 1.){
        float x1 = floor((x - 1.) /3.);
        float y1 = floor(dy - 1. - (y - 1.) /3.);
        int ind = int(y1*dx  + x1 - 1.);
        // 1 4 7 10
        // 3 2 1 0
        color = vec3(data[ind]);

        // fragColor = vec4(v3 , 1.0);


    }
    fragColor = vec4(color , 1.0);

    // fragColor = vec4(vec3(data[int(floor(y*dx + x))]) , 1.0);

    // for(int x = 0; x < dx; x++) {
    //     if (
    //         uv.x > float(x/dx)
    //        ) continue;
    //     for(int y = 0; y < dy; y++) {
    //        if (
    //         uv.y < float( y / dy)
    //         // (step(uv.x, float(x / dx)) +
    //         // step(uv.y, float( y / dy))) > 1.9
    //        ) {
    //         fragColor = vec4(vec3(data[y*dx+x]) , 1.0);
    //         // fragColor = vec4(vec3(data[3]) , 1.0);
    //         return;
    //     }
    //     }
    // }
    // if (uv.x < 1. / 6. &&  uv.y > 3. / 4.) color = vec3(0.); 
}

