#define SCALE 1.0

// Generates a chessboard pattern.
//
// It is made of vertical stripes that are shifted by oscillating xOffset along with vertical axis.
// Stripes and oscillation are made by a square wave.
// float chessboard1(vec2 uv) {
//     float xOffset = step(fract(uv.y), 0.5) * 0.5;
//     return step(fract(uv.x + xOffset), 0.5);
// }
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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy * SCALE;
    // vec3 color = vec3(chess1(uv, 0., 1. / 6.));
    vec3 color = vec3(1.);
    if (uv.x < 1. / 6. &&  uv.y > 3. / 4.) color = vec3(0.); 
	fragColor = vec4(color , 1.0);
}