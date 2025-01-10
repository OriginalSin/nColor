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
    float x = floor(uv.x * dx*3.); // меняется от 0 до 3*dx-1=17
    float y = floor(uv.y * dy*3.); // меняется от 9 до 3*dy-1=11
    // левый нижний угол x=0, y=0
    // правый верхний угол x=17, y=11
    // 24 пиксела матрицы должны иметь следующие координаты (x,y) в текстуре (18,12)
    //  (1,10) (4,10) (7,10) (10,10) (13,10) (16,10)
    //  (1,7) (4,7) (7,7) (10,7) (13,7) (16,7)
    //  (1,4) (4,4) (7,4) (10,4) (13,4) (16,4)
    //  (1,1) (4,1) (7,1) (10,1) (13,1) (16,1)
    // индексы этих пикселов в текстуре data
    //  18 19 20 21 22 23
    //  12 13 14 15 16 17
    //   6  7  8  9 10 11
    //   0  1  2  3  4  5
    // fragColor = vec4(vec3(data[int(x*dy + y)]) , 1.0);
    if (mod(x, 3.) == 1. && mod(y, 3.) == 1.){
        // (x,y)
        //  (1,10) (4,10) (7,10) (10,10) (13,10) (16,10)
        //   (1,7)  (4,7)  (7,7)  (10,7)  (13,7)  (16,7)
        //   (1,4)  (4,4)  (7,4)  (10,4)  (13,4)  (16,4)
        //   (1,1)  (4,1)  (7,1)  (10,1)  (13,1)  (16,1)
        float x1 = floor((x - 1.) /3.);
        float y1 = floor(dy - 1. - (y - 1.) /3.);
        // (x1,y1)
        //  (0,3) (1,3) (2,3) (3,3) (4,3) (5,3)
        //  (0,2) (1,2) (2,2) (3,2) (4,2) (5,2)
        //  (0,1) (1,1) (2,1) (3,1) (4,1) (5,1)
        //  (0,0) (1,0) (2,0) (3,0) (4,0) (5,0)
        int ind = int(y1*dx  + x1);
        // ind
        //  18 19 20 21 22 23
        //  12 13 14 15 16 17
        //   6  7  8  9 10 11
        //   0  1  2  3  4  5
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

