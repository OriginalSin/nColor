int      lod = 5;
float thresh = .4;
#iChannel0 "file://../cannyVideo/im.glsl"
// #iChannel0 "file://../../../../assets/334_256.jpg"
// #iChannel0 "file://../../../../assets/334.jpg"
//  #iChannel0 "file://../../../../assets/svetof.png"

#define s    textureSize(iChannel0, 0)
#define T(U) texelFetch(iChannel0, ivec2(U) %(s>>lod), lod).r // texture access
#define S(v) smoothstep( -.8,.8,(v)/fwidth(v) )      // antialiasing draw

void mainImage( out vec4 O, vec2 u )
{   //u*=2.;
    float Z = exp2(float(lod)),                      // scaling
          t = floor(30.*iTime);                      // animation
//    u += t;
    vec2  R = iResolution.xy, v,
          U = u/Z,
          V = mod(u-.5,Z);
    if (V.x*V.y==0.) { O = vec4(.5); return; }       // grid

    if ( iMouse.x > u.x-t ) {                        // mouse.x show ref
        O = vec4( texelFetch(iChannel0,ivec2(u+Z/2.) %s,0).r > thresh ,
                  T(U+.5) > thresh , 0,1);
        return;
    }
    O-=O;                                            // --- marching cube -------
    vec4 c = vec4( T(U)          , T(U+vec2(1,0)),   // value at corners
                   T(U+vec2(0,1)), T(U+vec2(1,1)) ), 
         b = step(thresh,c);                         // is > threshold ?
    int  n = int(b.x+b.y+b.z+b.w);                   // number of yes
    U = fract(U);                                    // tile local coordinates
    if      (n==0) O += .3;                          // empty ( for test )
    else if (n==4) O += 1.;                          // full
    else if (n==1 || n==3 || n==2 && b.x==b.w ) {    // corner + checker case 
        if (n==3) b = 1.-b;  
        if(b.x>0.) O += S( (1.-U.x-U.y)*c.x +   U.x   *c.y +   U.y   *c.z - thresh );
        if(b.y>0.) O += S( (  U.x -U.y)*c.y + (1.-U.x)*c.x +   U.y   *c.w - thresh );
        if(b.z>0.) O += S( (-U.x+ U.y )*c.z +   U.x   *c.w + (1.-U.y)*c.x - thresh );
        if(b.w>0.) O += S( (U.x+U.y-1.)*c.w + (1.-U.x)*c.z + (1.-U.y)*c.y - thresh );
    } else { // n==2                                      // (checker treated above)
        if      (b.x==b.y) v = (thresh-c.xy)/(c.zw-c.xy), // horizontal
                           O += S( U.y - mix(v.x,v.y,U.x) );
        else if (b.x==b.z) v = (thresh-c.xz)/(c.yw-c.xz), // vertical
                           O += S( U.x - mix(v.x,v.y,U.y) );
        if (b.x>0.) O = 1.-O;
    }
}