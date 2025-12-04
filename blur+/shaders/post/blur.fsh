#version 120

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform float frameTimeCounter;
varying vec2 texcoord;

const float FADE_SPEED = 6.0;
const float BASE_BLUR = 1.0 / 300.0;
const float SMOOTHING = 0.80; // temporal blend (previous frame)
float fadeVal = 0.0;

// cheap brightness-based GUI detection (works for menus/inventory)
bool detectGUI(vec4 c) {
    float v = (c.r + c.g + c.b) / 3.0;
    return v > 0.88;
}

void main() {
    vec4 cur = texture2D(colortex0, texcoord);

    // update fade (simple local "memory" using frameTimeCounter)
    bool gui = detectGUI(cur);
    if (gui) { fadeVal += FADE_SPEED * frameTimeCounter; if (fadeVal > 1.0) fadeVal = 1.0; }
    else     { fadeVal -= FADE_SPEED * frameTimeCounter; if (fadeVal < 0.0) fadeVal = 0.0; }

    if (fadeVal <= 0.001) {
        gl_FragColor = cur;
        return;
    }

    float b = BASE_BLUR * fadeVal;

    // 4-tap cheap gaussian
    vec4 sum = vec4(0.0);
    sum += texture2D(colortex0, texcoord + vec2(-b, -b)) * 0.25;
    sum += texture2D(colortex0, texcoord + vec2( b, -b)) * 0.25;
    sum += texture2D(colortex0, texcoord + vec2(-b,  b)) * 0.25;
    sum += texture2D(colortex0, texcoord + vec2( b,  b)) * 0.25;

    // temporal smoothing to stabilize across frames
    vec4 last = texture2D(colortex1, texcoord);
    vec4 blurred = mix(sum, last, SMOOTHING);

    // cheap corner smoothing (soften at corners -> Badlion feel)
    vec2 d = abs(texcoord - 0.5) * 2.0;
    float cornerMask = 1.0 - smoothstep(0.86, 1.0, length(d));

    gl_FragColor = mix(cur, blurred, cornerMask * fadeVal);
}
