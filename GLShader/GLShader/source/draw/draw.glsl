precision mediump float;

uniform sampler2D u_background;
uniform sampler2D u_texture0;
uniform sampler2D u_texture1;


varying vec2 v_texCoord;

vec4 edge(sampler2D texture, vec2 coord, float intensity) {
    vec3 irgb = texture2D(texture, coord).rgb;
    float ResS = 720.;
    float ResT = 720.;

    vec2 stp0 = vec2(1./ResS, 0.);
    vec2 st0p = vec2(0., 1./ResT);
    vec2 stpp = vec2(1./ResS, 1./ResT);
    vec2 stpm = vec2(1./ResS, -1./ResT);

    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    float i00 = dot(texture2D(texture, coord).rgb, W);
    float im1m1 = dot(texture2D(texture, coord-stpp).rgb, W);
    float ip1p1 = dot(texture2D(texture, coord+stpp).rgb, W);
    float im1p1 = dot(texture2D(texture, coord-stpm).rgb, W);
    float ip1m1 = dot(texture2D(texture, coord+stpm).rgb, W);
    float im10 = dot(texture2D(texture, coord-stp0).rgb, W);
    float ip10 = dot(texture2D(texture, coord+stp0).rgb, W);
    float i0m1 = dot(texture2D(texture, coord-st0p).rgb, W);
    float i0p1 = dot(texture2D(texture, coord+st0p).rgb, W);
    float h = -1.*im1p1 - 2.*i0p1 - 1.*ip1p1 + 1.*im1m1 + 2.*i0m1 + 1.*ip1m1;
    float v = -1.*im1m1 - 2.*im10 - 1.*im1p1 + 1.*ip1m1 + 2.*ip10 + 1.*ip1p1;

    float mag = length(vec2(h, v));
    vec3 target = vec3(mag, mag, mag);
    return vec4(vec3(1.1) - mix(irgb, target, intensity), 1.);
}

mat2 rotate(float rotation) {  
    float c = cos(rotation);  
    float s = sin(rotation);  
 
    return mat2(c, -s, s ,c);  
} 

void main() {
	vec2 maskxy = vec2(0.208, 0.134);
	vec2 offset = maskxy + vec2(0.1, 0.2);
	float scale = 1.3944;

	vec2 coord = ((v_texCoord - 0.5) * rotate(-0.6) + 0.5)  * scale - offset;
    vec4 color = edge(u_texture0, coord, 1.0);

    vec4 textureColor2 = texture2D(u_texture1, v_texCoord * scale - maskxy);

	vec2 area = offset / scale;

	vec4 back = texture2D(u_background, vec2(v_texCoord.x * 7.07/10.63 + 0.2, v_texCoord.y));
	if( v_texCoord.x < 0.152 || v_texCoord.x > 0.86 || v_texCoord.y < 0.1 || v_texCoord.y > 0.8 ) {
		gl_FragColor = back;
	} else {
	    gl_FragColor = mix(color, textureColor2, textureColor2.a);
	}

}