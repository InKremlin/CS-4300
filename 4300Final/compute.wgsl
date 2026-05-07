@group(0) @binding(0) var<uniform> res: vec2f;
@group(0) @binding(1) var<uniform> mouse: vec3f;
@group(0) @binding(2) var<uniform> params: vec4f;
@group(0) @binding(3) var<uniform> params2: vec2f;
@group(0) @binding(4) var<uniform> audio: vec4f;
@group(0) @binding(5) var<storage> statein: array<f32>;
@group(0) @binding(6) var<storage, read_write> stateout: array<f32>;


fn index( x:u32, y:u32 ) -> u32 {
  let _res = vec2u(res);
  return (y % _res.y) * _res.x + (x % _res.x);
}

// Smooth transition function (sigmoid)
fn sigma(x: f32, a: f32, alpha: f32) -> f32 {
  return 1.0 / (1.0 + exp(-(x - a) * 4.0 / alpha));
}

// Smooth interval function
fn sigma_n(x: f32, a: f32, b: f32) -> f32 {
  return sigma(x, a, 0.5) * (1.0 - sigma(x, b, 0.5));
}

// Linear mix between two values
fn sigma_m(x: f32, y: f32, m: f32) -> f32 {
  return x * (1.0 - sigma(m, 0.5, 0.15)) + y * sigma(m, 0.5, 0.15);
}

@compute
@workgroup_size(8,8)
fn cs( @builtin(global_invocation_id) cell:vec3u ) {
  let i = index(cell.x, cell.y);
  
  // Convert cell position to normalized coordinates
  let cellX = f32(cell.x) / res.x;
  let cellY = f32(cell.y) / res.y;
  
  // Audio spawning
  // audio: vec4f(strength, low, mid, high)
  let audioStrength = clamp(audio.x, 0.0, 1.0);

  // Map audio into a spawn position
  let spawnX = clamp(0.5 + (audio.y - 0.5) * 0.25, 0.0, 1.0);
  let spawnY = clamp(0.5 + (audio.z - 0.5) * 0.25, 0.0, 1.0);

  var spawnValue = 0.0;

  // Audio-driven spawn
  if(audioStrength > 0.08) {
    let dx = cellX - spawnX;
    let dy = cellY - spawnY;
    let dist = sqrt(dx*dx + dy*dy);

    // Radius and strength scale with audio
    let spawnRadius = 0.02 + audioStrength * 0.08;
    if(dist < spawnRadius) {
      let factor = 1.0 - (dist / spawnRadius);
      spawnValue = factor * factor * (0.35 + audioStrength * 0.9);
    }
  }

  let mouseDown = clamp(mouse[2], 0.0, 1.0);
  if(mouse[2] == 1.0) {
    let mdx = cellX - mouse.x;
    let mdy = cellY - mouse.y;
    let mdist = sqrt(mdx*mdx + mdy*mdy);

    //mouse draw stronger/brighter while held
    let mouseRadius = 0.02 + 0.07 * mouseDown;
    if(mdist < mouseRadius) {
      let factor = 1.0 - (mdist / mouseRadius);
      let mouseValue = factor * factor * (0.55 + 0.35 * mouseDown);
      spawnValue = max(spawnValue, mouseValue);
    }
  }


  
  // Params
  let ra = max(params.x, 1.0);
  let ri = max(params.y, 0.0);
  let b1 = min(params.z, params.w);
  let b2 = max(params.z, params.w);
  let d1 = min(params2.x, params2.y);
  let d2 = max(params2.x, params2.y);
  var m = 0.0;  // inner disk average
  var n = 0.0;  // outer annulus average
  var inner_count = 0.0;
  var outer_count = 0.0;
  
  // Sample the neighborhood
  let raClamped = clamp(ra, 1.0, 22.0);
  let riClamped = clamp(ri, 0.0, raClamped);
  let rad = i32(raClamped);

  for (var dy = -rad; dy <= rad; dy++) {
    for (var dx = -rad; dx <= rad; dx++) {
      let dist = sqrt(f32(dx * dx + dy * dy));
      
      if (dist < raClamped) {

        let nx = u32(i32(cell.x) + dx);
        let ny = u32(i32(cell.y) + dy);
        let val = statein[index(nx, ny)];
        
        if (dist <= riClamped) {

          m += val;
          inner_count += 1.0;
        } else {
          n += val;
          outer_count += 1.0;
        }
      }
    }
  }
  
  // Normalize
  m = m / max(inner_count, 1.0);
  n = n / max(outer_count, 1.0);

  // Boost Blob Growth
  let b2Boost = audio.x; // 0..1
  let b2Adj = clamp(b2 + 0.150 * b2Boost, 0.0, 0.4);


  let s_val = sigma_n(n, b1, b2Adj);
  let alive = sigma_n(n, d1, d2);


  
  // Smooth transition
  let new_state = sigma_m(s_val, alive, m);
  
  let dt = 0.1;
  var result = mix(statein[i], new_state, dt);

  result = max(result, spawnValue);
  
  stateout[i] = result;
}
