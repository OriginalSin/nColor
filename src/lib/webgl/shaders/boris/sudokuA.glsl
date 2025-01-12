// === manage grid and interactions
#include "file://./sudokuCommon.glsl"
// #iChannel0 "file://./sudokuA.glsl"
// #iChannel1 "file://./sudokuB.glsl"

void mainImage( out vec4 O, vec2 U )
{
    U -= .5;
    
    if (iFrame==0) {                 // --- init grid and controls
        O = vec4(-1);                // O.x = value  O.y = cell type
        // init values: for demo, random
#define set(X,Y,v) if (U==vec2(X,Y)) O.x = v, O.z = 1. // O.z > 0 : not erasable
        if (hash(U+.5)<.1) O.x = floor(mix(0.,10.,hash(U))), O.z = 1.;
        // draw your blocks id here:
        if ( abs( length(U-.5-N/2.)-N/4. ) < .5 ) O.y=1.; // mark a circle
        if ( abs( length(U-.5-N/4.)-N/7. ) < .5 ) O.y=3.; // mark a small circle
        if ( max(abs(U.x-2.),abs(U.y-9.))<1.5 )   O.y=5.; // mark a box
        if ( ceil(U) == vec2(9,9) )               O.y=7.; // mark a cell
        if ( ceil(U) == vec2(9,2) )               O.y=-2.;// black cell
        // for demo, init cur cell:
        if (U==vec2(0)) O.zw = vec2(6,5);
        return;
    }
    
    O = T(U);                        // recover prev state -----------------
    
    if (U==vec2(0)) {                // --- control active cell
        if keyDown(37) if (--O.z < 1.) O.z += N;        //  with arrow keys
        if keyDown(39) if (++O.z > N ) O.z -= N;
        if keyDown(38) if (++O.w > N ) O.w -= N;
        if keyDown(40) if (--O.w < 1.) O.w += N;
        if ( iMouse.z>0. ) O.zw = ceil((iMouse.xy-offset)/cellsize); // or mouse
    }
        
    if ( U == T(0).zw ) {            // --- write keyboard value in cell
        if ( O.z > 0. ) return;      // can't edit initial values 
        for( float i = minKey; i <= maxKey; i++)
            if keyDown(i) {
                i = i-minKey +(maxKey>96. && i>64. && keyClick(16)?32.:0.); 
                // optional: entry validation.       \ special case for shift (16) on letters :
                O.x = i;
                return; 
            }
        if (keyDown(32) || keyDown(8) || keyDown(46)) O.x = -1.;  // erase cell
    }        
}