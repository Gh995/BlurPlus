#version 120

varying vec2 texcoord;
varying float v_swing;   // smoothed swing proxy
varying float v_time;    // frame time

uniform float frameTimeCounter;

void main() {
    gl_Position = ftransform();
    texcoord = gl_MultiTexCoord0.st;

    // simple time value for fsh smoothing
    v_time = frameTimeCounter;
    // v_swing will be controlled/approximated in fsh (keeps vsh cheap)
    v_swing = 0.0;
}
