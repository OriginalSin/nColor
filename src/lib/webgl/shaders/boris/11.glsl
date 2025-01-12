#define pi 3.14159265359
float sx = 6.;
float sy = 6.;
vec2 gridSize=vec2(5,4);
vec3 getCell(vec2 s,vec2 h){
    vec2 c = floor(h * gridSize / s);
    return vec3(c.x, c.y, (gridSize.y - 1. - c.y) * gridSize.x + c.x);
}

vec3 getSmallCells(vec2 s,vec2 h) {
    vec3 c = getCell(s,h);
    vec2 g = s / gridSize;
    float r = g.x / g.y;
    vec2 u = pi * ((2. * h - g) / g.y - 2.*vec2(c.x * r, c.y));
    return vec3(c.z,u);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
    // vec3 cell = getSmallCells(iResolution.xy, fragCoord); //tiled cells
    // fragColor = vec4(cell, 1.0);

    // vec2 tiledUV = fract(vec2(uv.x * sx, uv.y * sy));
    vec2 tiledUV = fract(uv * gridSize);
    vec2 square = abs(tiledUV * 2. -1.);
    vec2 sharpSquare = step(0.5,square);
    float result = sharpSquare.x + sharpSquare.y;

    fragColor = vec4(1.0)*result;
}