#include "file://./sudokuCommon.glsl"
// generic workflow for values-in-grid  games ( sudoku, suguru/tectonic, crosswords, ... ) self: https://www.shadertoy.com/view/3t2XD3

void mainImage( out vec4 O, vec2 u ) // === manage display
{
    float s = cellsize;
    vec2 U = u - offset,
         C = mod(U,s), G = ceil(U /= s);    // G: cell ID   C: pixel in cell
    vec4 data = T(G);                       // .x: value  .y: type (block ID)
    
                                            // --- draw grid
    if (   C.x < border+thick && data.y != T(G-vec2(1,0)).y // thick borders at block transitions
        || C.y < border+thick && data.y != T(G-vec2(0,1)).y ) border+=thick, U+=thick/2./s; 
    O = vec4( min(C.x,C.y) > border && U.x > border/s && U.x < N+border/s );
  //O = vec4( smoothstep(-.5,.5,min(d - border, s*min (U.x,N+border/s-U.x))) ); // AA version
    
    if ( data.y >= 0.)                      // display cell type
        O *= mix(vec4(1),hue(data.y/10.),.1);   // option: id -> bg = hue
    else if (data.y == -2.) O -= O;         // black cell (e.g. crosswords)
        
    if ( T(0).zw==G && fract(3.*iTime)<.7 ) // --- flash current cell      
        O.gb *= .8;
                                            // --- display cell value
    float v = char( fract(U)-border/2./s, 
                    int( minKey+ (data.x<-1. ? -2.-data.x:data.x) ) ).x;
    if (data.x >= 0. )  if ( data.z > 0. ) O -= v; else O.rg -= v;
    if (data.x < -1. )  O.gb -= v;

    if (U.x>N) O += pInt(1.4*R.x/offset.x*(u-vec2(R.x-offset.x,0))/R.y, iTime).x; // --- timer

    O = clamp(O,0.,1.);    
    if (O==vec4(0)) O.g = Tb(u).x; else O.rb -= Tb(u).x;  // --- add draft layer  
}