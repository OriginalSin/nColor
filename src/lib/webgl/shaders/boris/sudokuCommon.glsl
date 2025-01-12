#iChannel0 "file://./sudokuA.glsl"
#iChannel1 "file://./sudokuB.glsl"


#define N 10.           // grid = NxN
float border = 2.;      // line thickness in pixels
#define thick  2.       // extra thickness for block borders
#define minKey 48.      // digits: 48 -> 57  letters: 65 -> 90
#define maxKey 122.     //                                 +32 to allow lowcase

#define T(U)             texelFetch( iChannel0, ivec2(U), 0)
#define Tb(U)            texelFetch( iChannel1, ivec2(U), 0)
#define R               (iResolution.xy)
#define cellsize        ( (R.y-border) / N )
#define offset           vec2( (R.x-R.y)/2. , 0 )

// === utils

#define hash(p) fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453)

// --- fonts & keyboard from https://www.shadertoy.com/view/llySRh

#define keyToggle(ascii)  ( texelFetch(iKeyboard ,ivec2(ascii,2),0).x > 0.)
#define keyDown(ascii)    ( texelFetch(iKeyboard ,ivec2(ascii,1),0).x > 0.)
#define keyClick(ascii)   ( texelFetch(iKeyboard ,ivec2(ascii,0),0).x > 0.)

vec2 _p; int _c;  // draw character. NB: super-annoying iChan forbidden in Common -> macro compulsory
#define char(p,c) (  _p=p, _c=c,                                            \
    _p.x<.0|| _p.x>1. || _p.y<0.|| _p.y>1. ? vec4(0,0,0,1e5)                \
	: textureGrad( iKeyboard , (_p/=16.) + fract( vec2(_c, 15-_c/16) / 16. ),\
                        dFdx(_p), dFdy(_p) ) )
float _n; int _i; // draw numbers
#define digit(p)   char(p - .5*vec2(_i--,0), 48+ int(fract(_n/=9.999999)*10.) )
#define pInt(p,n) ( _n=n,_i=3, digit(p)+digit(p)+digit(p)+digit(p) )

// --- hue from https://www.shadertoy.com/view/ll2cDc
#define hue(v)  ( .6 + .6 * cos( 6.3*(v)  + vec4(0,23,21,0)  ) )