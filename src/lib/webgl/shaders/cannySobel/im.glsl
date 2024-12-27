// Convert the input color to grayscale using the luminosity method
vec3 toGrayscale(vec3 color) {
    float gray = dot(color, vec3(0.299, 0.587, 0.114)); // Luminosity weights
    return vec3(gray); // Return as a grayscale color (vec3)
}

// Gaussian blur (simplified with a 3x3 kernel for demonstration)
vec3 gaussianBlur(vec2 uv, vec2 texel) {
    vec3 result = vec3(0.0);
    float weight[3] = float[](0.25, 0.5, 0.25); // Simplified 1D kernel

    // Apply horizontal blur (3x3)
    for (int i = -1; i <= 1; i++) {
        result += texture(iChannel0, uv + texel * float(i)).rgb * weight[i + 1];
    }

    return result;
}

// Sobel operator to detect gradients in the image (horizontal and vertical)
vec2 sobelGradient(vec2 uv, vec2 texel) {
    float Gx = 0.0;
    float Gy = 0.0;

    // Sobel kernels for X and Y directions (written out instead of using arrays of arrays)
    Gx += texture(iChannel0, uv + texel * vec2(-1.0, -1.0)).r * -1.0;
    Gx += texture(iChannel0, uv + texel * vec2(0.0, -1.0)).r * 0.0;
    Gx += texture(iChannel0, uv + texel * vec2(1.0, -1.0)).r * 1.0;
    Gx += texture(iChannel0, uv + texel * vec2(-1.0, 0.0)).r * -2.0;
    Gx += texture(iChannel0, uv + texel * vec2(0.0, 0.0)).r * 0.0;
    Gx += texture(iChannel0, uv + texel * vec2(1.0, 0.0)).r * 2.0;
    Gx += texture(iChannel0, uv + texel * vec2(-1.0, 1.0)).r * -1.0;
    Gx += texture(iChannel0, uv + texel * vec2(0.0, 1.0)).r * 0.0;
    Gx += texture(iChannel0, uv + texel * vec2(1.0, 1.0)).r * 1.0;

    Gy += texture(iChannel0, uv + texel * vec2(-1.0, -1.0)).r * -1.0;
    Gy += texture(iChannel0, uv + texel * vec2(-1.0, 0.0)).r * -2.0;
    Gy += texture(iChannel0, uv + texel * vec2(-1.0, 1.0)).r * -1.0;
    Gy += texture(iChannel0, uv + texel * vec2(0.0, -1.0)).r * 0.0;
    Gy += texture(iChannel0, uv + texel * vec2(0.0, 0.0)).r * 0.0;
    Gy += texture(iChannel0, uv + texel * vec2(0.0, 1.0)).r * 0.0;
    Gy += texture(iChannel0, uv + texel * vec2(1.0, -1.0)).r * 1.0;
    Gy += texture(iChannel0, uv + texel * vec2(1.0, 0.0)).r * 2.0;
    Gy += texture(iChannel0, uv + texel * vec2(1.0, 1.0)).r * 1.0;

    return vec2(Gx, Gy); // Return the gradient vector (Gx, Gy)
}

// Calculate the magnitude and direction of the gradient
vec2 calculateMagnitudeDirection(vec2 grad) {
    float magnitude = length(grad); // Compute the magnitude (gradient strength)
    float direction = atan(grad.y, grad.x); // Calculate the direction (angle) in radians
    return vec2(magnitude, direction); // Return both magnitude and direction
}

// Apply edge thresholds to classify pixels as strong or weak edges
vec3 applyThreshold(float magnitude, float lowThreshold, float highThreshold) {
    if (magnitude > highThreshold) {
        return vec3(1.0); // Strong edge (white)
    } else if (magnitude > lowThreshold) {
        return vec3(0.5); // Weak edge (gray)
    } else {
        return vec3(0.0); // No edge (black)
    }
}

#iChannel0 "file://../../../../assets/334.jpg"

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Normalize pixel coordinates (0.0 to 1.0)
    vec2 uv = fragCoord / iResolution.xy;
    vec2 texel = 1.0 / iResolution.xy; // Size of one texel in UV space

    // Convert the image to grayscale (to simplify processing)
    vec3 gray = toGrayscale(texture(iChannel0, uv).rgb);

    // Apply Gaussian Blur (for simplicity, we use a basic 3x3 filter here)
    vec3 blurred = gaussianBlur(uv, texel);

    // Compute the gradient using Sobel operator
    vec2 grad = sobelGradient(uv, texel);
    vec2 mag_dir = calculateMagnitudeDirection(grad);

    // Apply edge thresholding
    float lowThreshold = 0.1;
    float highThreshold = 0.3;
    fragColor = vec4(applyThreshold(mag_dir.x, lowThreshold, highThreshold), 1.0);
}
