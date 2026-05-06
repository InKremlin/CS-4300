struct VertexInput {
  @location(0) pos: vec2f,
  @builtin(instance_index) instance: u32,
};

struct VertexOutput {
  @builtin(position) pos: vec4f,
  @location(0) uv: vec2f,
  @location(1) seed: f32
};

struct Particle {
  pos: vec2f,
  vel: vec2f
};

@group(0) @binding(0) var<uniform> frame: f32;
@group(0) @binding(1) var<uniform> res:   vec2f;
@group(0) @binding(2) var<storage> state: array<Particle>;

@vertex 
fn vs(input: VertexInput) -> VertexOutput {
  let p = state[input.instance];

  let size = 0.015;
  let aspect = res.y / res.x;

  let local = input.pos;
  let offset = local * vec2f(size * aspect, size);
  let world = p.pos + offset;

  // per particle seed
  let seed = p.vel.x;

  return VertexOutput(
    vec4f(world, 0.0, 1.0),
    local,
    seed
  );
}

@fragment 
fn fs(vtx: VertexOutput) -> @location(0) vec4f {

  //rotation
  let angle = vtx.seed * 6.28318 + frame * 0.02;

  let s = sin(angle);
  let c = cos(angle);
  
  //shimmer
  let uv = vec2f(
    vtx.uv.x * c - vtx.uv.y * s,
    vtx.uv.x * s + vtx.uv.y * c
  );

  //shape
  let d = length(uv);
  let core = smoothstep(0.5, 0.0, d);

  let dx = abs(uv.x);
  let dy = abs(uv.y);

  var spikes = max(
    smoothstep(0.2, 0.0, dx),
    smoothstep(0.2, 0.0, dy)
  );

  let diag1 = smoothstep(0.2, 0.0, abs(uv.x + uv.y));
  let diag2 = smoothstep(0.2, 0.0, abs(uv.x - uv.y));

  spikes = max(spikes, max(diag1, diag2));

  //flicker
  let flicker = 0.5 + 0.5 * sin(frame * 0.1 + vtx.seed * 10.0);

  var alpha = (core + spikes) * flicker;
  alpha = pow(alpha, 2.2);

  let color = vec3f(1.0, 0.8, 0.0);

  return vec4f(color, alpha);
}