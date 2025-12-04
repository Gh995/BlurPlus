#version 120

uniform sampler2D texture;
uniform vec2 mouseDelta;
uniform float attackStrength;
uniform float frameTimeCounter;

varying vec2 texcoord;

// LOW-END SETTINGS
const float BASE_BLUR = 0.015;
const float MAX_BLUR = 0.08;
const float TRAIL_FADE = 0.82;
const float POTION_SAFE_FADE = 0.92;

float trail = 0.0;

void main() {

    // read texture
    vec4 base = texture2D(texture, texcoord);


    // ============================================================
    //  FULLBRIGHT COMPATIBILITY
    // ============================================================

    float lum = (base.r + base.g + base.b) / 3.0;

    float fb = smoothstep(0.55, 1.35, lum);

    vec3 normalized = mix(base.rgb, base.rgb * 0.55, fb);
    vec4 calc = vec4(normalized, base.a);


    // -----------------------------------
    // POTION-SAFE COLOR CHECK
    // -----------------------------------
    float sat = max(max(calc.r, calc.g), calc.b)
              - min(min(calc.r, calc.g), calc.b);

    float potionFade = 1.0 - smoothstep(0.25, 0.45, sat);
    potionFade = mix(1.0, POTION_SAFE_FADE, potionFade);


    // -----------------------------------
    // VELOCITY CURVE
    // -----------------------------------
    float speed = length(mouseDelta);
    float velCurve = smoothstep(0.0, 0.45, speed);


    // -----------------------------------
    // BLUR ONLY DURING ATTACK
    // -----------------------------------
    float attack = 1.0 - attackStrength;
    attack = smoothstep(0.0, 0.7, attack);

    float blur = BASE_BLUR + velCurve * MAX_BLUR * attack;

    blur *= potionFade;
    blur = clamp(blur, 0.0, MAX_BLUR);


    // -----------------------------------
    // ITEM TRAIL
    // -----------------------------------
    trail = mix(velCurve, trail, pow(TRAIL_FADE, frameTimeCounter * 60.0));
    float trailBlur = blur * trail;


    // -----------------------------------
    // DIRECTIONAL BLUR
    // -----------------------------------
    vec2 dir = normalize(mouseDelta + 0.0001);

    vec4 c = vec4(0.0);
    c += texture2D(texture, texcoord - dir * trailBlur * 1.0) * 0.16;
    c += texture2D(texture, texcoord - dir * trailBlur * 0.6) * 0.16;
    c += texture2D(texture, texcoord - dir * trailBlur * 0.3) * 0.16;
    c += base                                            * 0.16;
    c += texture2D(texture, texcoord + dir * trailBlur * 0.3) * 0.16;
    c += texture2D(texture, texcoord + dir * trailBlur * 0.6) * 0.16;

    gl_FragColor = c;
}
