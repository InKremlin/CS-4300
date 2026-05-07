import { default as seagulls } from './gulls.js'
import { default as Mouse } from './mouse.js'
import { default as audio } from './audio.js'

Mouse.init()
audio.start()

const sg = await seagulls.init()
const frag = await seagulls.import('./frag.wgsl')
const compute = await seagulls.import('./compute.wgsl')

const render = seagulls.constants.vertex + frag
const size = window.innerWidth * window.innerHeight
const state = new Float32Array(size)

const numBlobs = 20
const blobs = []

// Create random blob centers
for(let i = 0; i < numBlobs; i++) {
  blobs.push({
    x: Math.random() * window.innerWidth,
    y: Math.random() * window.innerHeight,
    radius: 30 + Math.random() * 80,
    strength: 0.6 + Math.random() * 0.4
  })
}

// Initialize state
for(let i = 0; i < size; i++) {
  const x = i % window.innerWidth
  const y = Math.floor(i / window.innerWidth)
  let value = 0
  
  // Check distance to each blob
  for(const blob of blobs) {
    const dx = x - blob.x
    const dy = y - blob.y
    const dist = Math.sqrt(dx*dx + dy*dy)
    
    if(dist < blob.radius) {
      // Smooth falloff from center
      const factor = 1 - (dist / blob.radius)
      value = Math.max(value, factor * blob.strength)
    }
  }
  
  state[i] = value
}

const statebuffer1 = sg.buffer(state)
const statebuffer2 = sg.buffer(state)
const res = sg.uniform([window.innerWidth, window.innerHeight])
const mouse = sg.uniform([0,0,0])
const audioUniform = sg.uniform([0.0, 0.0, 0.0, 0.0])


// SmoothLife parameters
// params: [ra, ri, b1, b2]
const simParams = sg.uniform([10.0, 8.7, 0.087, 0.260])
const simParams2 = sg.uniform([0.304, 0.757])


const renderPass = await sg.render({
  shader: render,
  data: [
    res,
    sg.pingpong(statebuffer1, statebuffer2)
  ]
})

const computePass = sg.compute({
  shader: compute,
  data: [
    res,
    mouse,
    simParams,
    simParams2,
    audioUniform,
    sg.pingpong(statebuffer1, statebuffer2)
  ],

  dispatchCount: [Math.round(seagulls.width / 8), Math.round(seagulls.height / 8), 1],
  onframe: () => {
    mouse.value = Mouse.values

    // Drive blobs from mic energy
    const low = window.Audio?.low ?? 0
    const mid = window.Audio?.mid ?? 0
    const high = window.Audio?.high ?? 0

    const energy = Math.max(low * 0.6 + mid * 0.8 + high * 1.0, 0)
    const strength = Math.min(1.0, Math.pow(energy, 1.2) * 1.4)

    audioUniform.value = [strength, low, mid, high]
  }

})

sg.run(computePass, renderPass)

const ui = window.__simUI
if (ui) {
  const syncFromUI = () => {

    const ra = ui.ra.value
    const ri = ui.ri.value
    const b1 = ui.b1.value
    const b2 = ui.b2.value
    const d1 = ui.d1.value
    const d2 = ui.d2.value

    simParams.value = [ra, ri, Math.min(b1, b2), Math.max(b1, b2)]
    simParams2.value = [Math.min(d1, d2), Math.max(d1, d2)]

  }
  syncFromUI()
  ui.el.addEventListener('input', syncFromUI)
}
