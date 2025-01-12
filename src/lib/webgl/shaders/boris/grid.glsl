//parent=https://www.shadertoy.com/view/Mt2GDV
//just slightly crunched with minot optimizations

#define pi 3.14159265359
//#define E  2.71828182845 //exists as y=exp(1.);
#define dd(a) dot(a,a)
//complex number space transforms.
vec2 sinz(vec2 c){vec2 d=vec2(exp(c.y),exp(-c.y));
 return vec2(sin(c.x)*(d.x+d.y)*.5,cos(c.x)*(d.x-d.y)*.5);}
vec2 cosz(vec2 c){vec2 d=vec2(exp(c.y),exp(-c.y));
 return vec2(cos(c.x)*(d.x+d.y)*.5,-sin(c.x)*(d.x-d.y)*.5);}
vec2 tanz(vec2 c){vec2 d=vec2(exp(c.y),exp(-c.y));
 float e=cos(c.x),s=(d.x-d.y)*.5;
 return vec2(sin(c.x)*e, s*(d.x+d.y)*.5)/(e*e+s*s);}
vec2 logz(vec2 c){return vec2(log(length(c)),atan(c.y, c.x));}
vec2 sqrtz(vec2 c){float n=c.x+length(c);
 return vec2(n,c.y)/sqrt(2.*n);}
vec2 exp2z(vec2 c){vec2 d=c*c;return vec2(d.x-d.y,2.*c.x*c.y);}
vec2 epowz(vec2 c){return vec2(cos(c.y),sin(c.y))*exp(c.x);}
vec2 mulz(vec2 a,vec2 b){return a*mat2(b.x,-b.y,b.yx);}
vec2 divz(vec2 n,vec2 d){return n*mat2(d,-d.y,d.x)/dd(d);}
vec2 invz(vec2 c){return vec2(c.x,-c.y)/dd(c);}
//by David Bargo-davidbargo/2015
//License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec2 func(float i,vec2 c){vec2 r;
      if(i==1.)r=sinz(c);
 else if(i==2.)r=sqrtz(divz(logz(vec2(-c.y-6.,c.x)),logz(vec2(-c.y+2.,c.x))));
 else if(i==3.)r=epowz(c);
 else if(i==4.)r=tanz(tanz(c));
 else if(i==5.)r=tanz(sinz(c));
 else if(i==6.)r=sqrtz(vec2(1.+c.x,c.y))+sqrtz(vec2(1.- c.x,-c.y));
 else if(i==7.)r=divz(tanz(exp2z(c)),c);
 else if(i==8.)r=sinz(cosz(sinz(c)));
 else if(i==9.)r=invz(vec2(1,0)+epowz(vec2(c.y, c.x)));
 else if(i==10.)r=epowz(invz(sqrtz(-c)));
 else if(i==11.)r=exp2z(invz(c));
 else if(i==12.)r=epowz(sinz(epowz(cosz(c))));   	
 else if(i==13.)r=divz(sinz(c),c);
 else if(i==14.)r=exp2z(c);
 else if(i==15.)r=divz(sinz(c),cosz(exp2z(c)));
 else if(i==16.)r=invz(c+vec2(1,0))+invz(c-vec2(1,0));
 else if(i==17.)r=logz(c-invz(c));
 else if(i==18.)r=divz(sqrtz(vec2(c.x+1., c.y)), sqrtz(vec2(c.x-1.,c.y)));
 else if(i==19.)r=invz(vec2(1,0)+mulz(c,exp2z(exp2z(c))));
 else return c;return r;}

//2d rotation by iTime
vec2 animate(vec2 v){
 float s=sin(iTime),c=cos(iTime);return v*mat2(c,-s,s,c);}

//color space
vec3 hsv2rgb(in vec3 c){//iq's smooth hsv to rgb
 vec3 rgb=clamp( abs(mod(c.x*6.+vec3(0,4,2),6.)-3.)-1.,0.,1.);
 rgb=rgb*rgb*(3.0-2.0*rgb);return c.z*mix(vec3(1),rgb,c.y);}

//for tiling grid, by aiekick https://www.shadertoy.com/view/4lj3Ww
vec2 gridSize=vec2(5,4);
vec3 getCell(vec2 s,vec2 h){
    vec2 c = floor(h * gridSize / s);
    return vec3(c.x, c.y, (gridSize.y - 1. - c.y) * gridSize.x + c.x);
}

vec3 getSmallCells(vec2 s,vec2 h) {
 vec3 c=getCell(s,h);
 vec2 g=s/gridSize;
 float r=g.x/g.y;
 vec2 u = pi*((2.*h-g)/g.y - 2.*vec2(c.x*r,c.y));
 return vec3(c.z,u);
 }

void mainImage( out vec4 Out,in vec2 In){vec2 e=iResolution.xy;    
 vec3 c=iMouse.z>0.? 
  vec3(getCell(e, iMouse.xy).z,pi*(2.*In-e)/(e.y))://fullscreen cell 
  getSmallCells(e,In);//tiled cells
 vec2 z=animate(func(c.x,c.yz))*2.;
 float h=atan(z.y,z.x)/(2.*pi),l=length(z),
 s=abs(fract(l)-.5)-.25;s=step(0.,s)*s*4.;s=1.-s*s;
 vec2  r=abs(fract(z)-.5)-.25;r=step(0.,r)*r*4.;r=1.-r*r*r*r;
 float v=mix(1.,r.x*r.y,s*.5);
 Out=vec4(hsv2rgb(vec3(h,s,v)),1.);}
