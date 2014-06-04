precision mediump float;

uniform sampler2D u_background;
uniform sampler2D u_texture0;
uniform sampler2D u_texture1;


varying vec2 v_texCoord;

float rand(vec2 co) {
	return fract(sin(dot(co.xy ,vec2(12.9898,45.233))) * 43758.5453);
}

vec4 noise(vec2 coord, vec4 color, float amount) {
    float diff = (rand(coord) - 0.5) * amount;
	diff *= diff;
    color.r += diff;
    color.g += diff;
    color.b += diff;
	return color;
}

vec4 denoise(sampler2D texture, vec2 coord, vec4 color, float weight, float exponent) {
    vec2 texSize = vec2(320.0, 320.0);
    vec4 color2 = vec4(0.0);
    float total = 0.0;
    for (float x = 0.0-4.0; x <= 4.0; x += 1.0) {
        for (float y = 0.0-4.0; y <= 4.0; y += 1.0) {
            vec4 sample = texture2D(texture, coord + vec2(x, y) / texSize);
            float weight = 1.0 - abs(dot(sample.rgb - color.rgb, vec3(0.25)));
            weight = pow(weight, exponent);
            color2 += sample * weight;
            total += weight;
        }
    }
	return color2;
}

vec4 sepia(vec4 color, float amount) {
    float r = color.r;
    float g = color.g;
    float b = color.b;
    
    color.r = min(1.0, (r * (1.0 - (0.607 * amount))) + (g * (0.769 * amount)) + (b * (0.189 * amount)));
    color.g = min(1.0, (r * 0.349 * amount) + (g * (1.0 - (0.314 * amount))) + (b * 0.168 * amount));
    color.b = min(1.0, (r * 0.272 * amount) + (g * 0.534 * amount) + (b * (1.0 - (0.869 * amount))));
	return color;            
}

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
    return vec4( vec3(0.43, 0.35, 0.23) + 1.0 - mix(irgb, target, intensity), 1.);
}

mat2 rotate(float rotation) {  
    float c = cos(rotation);  
    float s = sin(rotation);  
 
    return mat2(c, -s, s ,c);  
} 

void main() {
	vec2 maskxy = vec2(0.166, 0.0);
	vec2 offset = maskxy + vec2(0.0, 0.8);
	float scale = 1.71;

    vec4 color = texture2D(u_texture0, (v_texCoord * scale - offset)  * rotate(1.2));// edge(u_texture0, v_texCoord, 0.5);

	color = sepia(color, 1.0);

	vec4 bt = vec4(0.6, 0.45, 0.15, 0.2);
	color += bt;

    vec4 textureColor2 = texture2D(u_texture1, v_texCoord * scale - maskxy);

	vec2 area = offset / scale;

	vec4 back = texture2D(u_background, vec2(v_texCoord.x * 5.47/8.0 + 0.2, v_texCoord.y));
	if( v_texCoord.x < area.x || v_texCoord.x > 0.66 || v_texCoord.y > 0.55 ) {
		gl_FragColor = back;
	} else {
	    gl_FragColor = mix(color, textureColor2, textureColor2.a);
	}
}