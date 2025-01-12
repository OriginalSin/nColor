// === free draw notepad superimposed to grid ( user draft notes )
#include "file://./sudokuCommon.glsl"

float line(vec2 p, vec2 a,vec2 b) { // draw line segment. From  https://www.shadertoy.com/view/4dcfW8
    float h = dot(p-=a, b-=a) / dot(b, b);                  // proj coord on line
    return h==clamp(h, 0., 1.) ? max(0., 1.-length(p - b * h)) : 0.; // length = dist to line
}

void mainImage( out vec4 O, vec2 U )
{
    O = T(U);
    if (iFrame==0) { O = vec4(0); if (U==vec2(.5)) O.zw = vec2(-1); }
    
    if (U==vec2(.5)) O.zw = iMouse.z>0. ? iMouse.xy : vec2(-1);    // last curve pos or -1
    if (iMouse.z>0. && T(0).z>0. ) O += line(U,T(0).zw,iMouse.xy); // draw from prev mouse pos

    vec2 G = ceil( (U-offset)/cellsize ), C = Tb(0).zw;            // erase cell or margin
    if (   ( G == C || (G.x<1. && C.x<1.)  || ( G.x>N && C.x>N ) )
        && ( keyDown(32) || keyDown(8) || keyDown(46)) ) O -= O; 
}