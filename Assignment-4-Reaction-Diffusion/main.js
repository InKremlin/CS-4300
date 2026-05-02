import { default as seagulls } from '../../gulls.js'

const sg      = await seagulls.init()
const frag    = await seagulls.import( './frag.wgsl' )
const compute = await seagulls.import( './compute.wgsl' )
const render  = seagulls.constants.vertex + frag
const size    = (window.innerWidth * window.innerHeight)
const centerX = Math.floor(window.innerWidth / 2)
const centerY = Math.floor(window.innerHeight / 2)
const seedSize  = 10

// Initialize data arrays
const a = new Float32Array( size )
const b = new Float32Array( size )
const allA = new Float32Array( size )
const allB = new Float32Array( size )

function fillInitialState() {
  // Reset arrays
  for( let i = 0; i < size; i++ ) {
    a[ i ] = 1.0
    b[ i ] = 0.0
    allA[ i ] = 1.0
    allB[ i ] = 0.0
  }

  // Initialize state arrays
  for( let y = centerY - seedSize; y < centerY + seedSize; y++ ) {
    for( let x = centerX - seedSize; x < centerX + seedSize; x++ ) {
      if( (x - centerX)**2 + (y - centerY)**2 < seedSize**2 ) {
        b[ y * window.innerWidth + x ] = 1.0
        allB[ y * window.innerWidth + x ] = 1.0
      }
    }
  }
}

fillInitialState()

// Create buffers once and reuse them
const a1 = sg.buffer( a )
const a2 = sg.buffer( a )
const b1 = sg.buffer( b )
const b2 = sg.buffer( b )

const res = sg.uniform([ window.innerWidth, window.innerHeight ])
const dt = sg.uniform(1.0)
const DA = sg.uniform(1.0)
const DB = sg.uniform(0.5)
const feed = sg.uniform(0.0545)
const kill = sg.uniform(0.0620)

// Slider controls
document.getElementById('feedSlider').addEventListener('input', (e) => {
  const value = parseFloat(e.target.value)
  feed.value = value
  document.getElementById('feedValue').textContent = value.toFixed(3)
})

document.getElementById('killSlider').addEventListener('input', (e) => {
  const value = parseFloat(e.target.value)
  kill.value = value
  document.getElementById('killValue').textContent = value.toFixed(3)
})

document.getElementById('daSlider').addEventListener('input', (e) => {
  const value = parseFloat(e.target.value)
  DA.value = value
  document.getElementById('daValue').textContent = value.toFixed(2)
})

document.getElementById('dbSlider').addEventListener('input', (e) => {
  const value = parseFloat(e.target.value)
  DB.value = value
  document.getElementById('dbValue').textContent = value.toFixed(2)
})

// Reset button
document.getElementById('resetButton').addEventListener('click', () => {
  fillInitialState()
  sg.device.queue.writeBuffer(a1.buffer, 0, allA)
  sg.device.queue.writeBuffer(a2.buffer, 0, allA)
  sg.device.queue.writeBuffer(b1.buffer, 0, allB)
  sg.device.queue.writeBuffer(b2.buffer, 0, allB)
})

const renderPass = await sg.render({
  shader: render,
  data: [
    res,
    sg.pingpong( a1, a2 ),
    sg.pingpong( b1, b2 )
  ]
})

const computePass = sg.compute({
  shader: compute,
  data: [ res, dt, DA, DB, feed, kill, sg.pingpong( a1, a2 ), sg.pingpong( b1, b2 ) ],
  dispatchCount:  [Math.round(seagulls.width / 8), Math.round(seagulls.height/8), 1],
  times: 20
})

sg.run( computePass, renderPass )
