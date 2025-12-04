#version 120

uniform sampler2D colortex0; // scene
uniform sampler2D colortex1; // previous
uniform float frameTimeCounter;
varying vec2 texcoord;

void main() {
    vec4 scene = texture2D(colortex0, texcoord);

    // --- crosshair bloom heuristic:
    // approximate "swing" by comparing center brightness to previous frame center.
    vec2 center = vec2(0.5, 0.5);
    vec4 curCenter = texture2D(colortex0, center);
    vec4 prevCenter = texture2D(colortex1, center);
    float delta = max(0.0, (curCenter.r + curCenter.g + curCenter.b) / 3.0 - (prevCenter.r + prevCenter.g + prevCenter.b) / 3.0);

    // bloom strength mapped from delta (attack like)
    float bloom = smoothstep(0.01, 0.06, delta);

    // cheap 4-tap blur around center for bloom
    vec4 b = vec4(0.0);
    float bsize = 0.008 * (1.0 + bloom * 2.0);
    b += texture2D(colortex0, center + vec2(-bsize, -bsize)) * 0.25;
    b += texture2D(colortex0, center + vec2( bsize, -bsize)) * 0.25;
    b += texture2D(colortex0, center + vec2(-bsize,  bsize)) * 0.25;
    b += texture2D(colortex0, center + vec2( bsize,  bsize)) * 0.25;

    // combine: add a subtle bloom to crosshair area (only near center)
    float dist = length(texcoord - center);
    float mask = 1.0 - smoothstep(0.0, 0.25, dist); // localized to center
    scene.rgb += b.rgb * bloom * mask * 0.6;

    // small global crit saturation when bloom high
    float critSat = bloom * 0.18;
    scene.rgb = mix(scene.rgb, scene.rgb * 1.2, critSat);

    gl_FragColor = scene;
}
