uniform float uSize;
uniform vec2 uResolution;
uniform float uProgress;

attribute float aSize;
attribute float aTimeMultiplier;

#include '../utils/remap.glsl'

void main() { 
    float progress = uProgress * aTimeMultiplier;
    vec3 newPosition = position;

    // Exploding
    float explodingProgress = remap(progress, 0.0, 0.1, 0.0, 1.0);
    explodingProgress = clamp(explodingProgress, 0.0, 1.0);
    explodingProgress = 1.0 - pow(1.0 - explodingProgress, 3.0);
    newPosition *= explodingProgress;

    // Falling
    float fallingProgress = remap(progress, 0.1, 1.0, 0.0, 1.0);
    explodingProgress = clamp(fallingProgress, 0.0, 1.0);
    explodingProgress = 1.0 - pow(1.0 - fallingProgress, 3.0);
    newPosition.y -= fallingProgress * 0.2;

    // Scaling
    float sizeOpeningProgress = remap(progress, 0.0, 0.125, 0.0, 1.0);
    float sizeClosingProgress = remap(progress, 0.125, 1.0, 1.0, 0.0);
    float sizeProgress = min(sizeOpeningProgress, sizeClosingProgress);
    sizeProgress = clamp(sizeProgress, 0.0, 1.0);

    // Twinkling
    float twinkleProgress = remap(progress, 0.2, 0.8, 0.0, 1.0);
    twinkleProgress = clamp(twinkleProgress, 0.0, 1.0);
    float sizeTwinkle = sin(progress * 30.0) * 0.5 + 0.5;
    sizeTwinkle = 1.0 - sizeTwinkle * twinkleProgress;

    // Final Position
    vec4 modelPosition = modelMatrix * vec4(newPosition, 1.0);
    vec4 viewPosition = viewMatrix * modelPosition;
    gl_Position = projectionMatrix * viewPosition; 

    // Final Size
    gl_PointSize = uSize * uResolution.y * aSize * sizeProgress * sizeTwinkle;
    gl_PointSize *= 1.0 / -viewPosition.z;

    if (gl_PointSize < 1.0)
        gl_Position = vec4(9999.9);
}