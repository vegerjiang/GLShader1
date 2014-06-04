precision mediump float;

uniform sampler2D u_background;
uniform sampler2D u_texture0;
uniform sampler2D u_texture1;

varying vec2 v_texCoord;
varying vec2 v_viewPort;
varying vec2 v_photoSize;

vec4 sepia(vec4 color, float amount) {
    float r = color.r;
    float g = color.g;
    float b = color.b;
    
    color.r = min(1.0, (r * (1.0 - (0.607 * amount))) + (g * (0.769 * amount)) + (b * (0.189 * amount)));
    color.g = min(1.0, (r * 0.349 * amount) + (g * (1.0 - (0.314 * amount))) + (b * 0.168 * amount));
    color.b = min(1.0, (r * 0.272 * amount) + (g * 0.534 * amount) + (b * (1.0 - (0.869 * amount))));
	return color;            
}


void main() {
	vec2 maskxy = vec2(1.063, 0.675);
	vec2 offset = maskxy + vec2(0.03, 0.08);
	float scale = 2.374;

    vec4 color = texture2D(u_texture0, v_texCoord * scale - offset);
	// color = sepia(color, 1.0);

    vec4 textureColor2 = texture2D(u_texture1, v_texCoord * scale - maskxy);

	vec2 area = offset / scale;

	vec4 back = texture2D(u_background, vec2(v_texCoord.x * 7.83/12.0 + 0.3, v_texCoord.y));
	if( v_texCoord.x < 0.45 || v_texCoord.x > 0.87 || v_texCoord.y < 0.29 || v_texCoord.y > 0.7 ) {
		gl_FragColor = back;
	} else {
	    gl_FragColor = mix(color, textureColor2, textureColor2.a); 

		// mix( vec4((color * .8 + textureColor2 * .5).rgb, textureColor2.a), textureColor2, textureColor2.a);
	}
	//*/

}