// Gaussian filter
// Actual kernel width is (2*k + 1)
const int k = 2;
const float stddev = 1.;

const float expCoef = 0.15915494309189535;
vec4 guassianFilter(sampler2D channel, ivec2 coord) {

    //adjust position (unneccesary when using image)
    coord.x*=2;
    coord.x+=30;
    coord.y+=1035;
    
    int width = (2*k + 1);
    vec4 total = vec4(0.0);
    for (int i = 1; i <= width; i++) {
        for (int j = 1; j <= width; j++) {
            float mag = float((i-(k+1))*(i-(k+1)) + (j-(k+1))*(j-(k+1)));
            float coefficient = (expCoef/(stddev*stddev))*exp(-mag/(2.0*(stddev*stddev)));
            total += coefficient * texelFetch(channel, (coord + ivec2(i-(k+1),j-(k+1))) % textureSize(channel, 0), 0);
        }
    }
    return total;
}

#iChannel0 "file://../../../../assets/334.jpg"

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = guassianFilter(iChannel0, ivec2(fragCoord));
}