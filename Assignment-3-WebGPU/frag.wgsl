fn hash2d(p: vec2f) -> f32 {
  let p2 = floor(p * vec2f(234.34, 435.345));
  let p3 = fract(vec2f(dot(p2, vec2f(127.1, 311.7)), dot(p2, vec2f(269.5, 183.3))));
  return fract(sin(dot(p3, vec2f(26.9e4, 27e4))) * 1e4);
}

@group(0) @binding(0) var<uniform> params: vec4f; // resolution.xy, time.z, hueOffset.w
@group(0) @binding(1) var videoSampler: sampler;
@group(0) @binding(2) var backBuffer: texture_2d<f32>;
@group(0) @binding(3) var<uniform> sliderRed: vec4f;
@group(0) @binding(4) var<uniform> mouse: vec4f;
@group(1) @binding(0) var videoBuffer: texture_external;

@fragment 
fn fs(@builtin(position) pos: vec4f) -> @location(0) vec4f {
  let p = pos.xy / params.xy;

  let video = textureSampleBaseClampToEdge(videoBuffer, videoSampler, p);

  let fb = textureSample(backBuffer, videoSampler, p);

  var out = video * 0.05 + fb * 0.975;
  
  //sliders
  out.r *= mix(0.5, 2.0, sliderRed.r);

  out.b *= mix(0.5, 2.0, sliderRed.g);

  // Mouse press invert
  if (mouse[2] == 1.0) {
    out.g = 1.0 - out.g;
  }

  var final_out = pow(out.rgb, vec3f(1.1));
  final_out = clamp(final_out, vec3f(0.), vec3f(1.));

  // noise overlay
  let t = params.z;
  let flow_p = p + vec2f(t * 0.01, sin(t * 0.3) * 0.3);
  var n = hash2d(flow_p) * 2.0 - 1.0;
  n += hash2d(flow_p * 2.0 + 3.14) * 0.5;
  n += hash2d(flow_p * 4.0 + 7.0) * 0.25;
  let noise = n * 0.02;
  final_out += vec3f(noise);

  return vec4f(final_out, 1.0);
}
