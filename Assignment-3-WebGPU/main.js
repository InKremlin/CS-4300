import { default as gulls } from './gulls.js'
import { default as Video } from './video.js'
import { default as Slider } from './slider.js'
import { default as Mouse } from './mouse.js'

const sg = await gulls.init(),
      frag = await gulls.import('./frag.wgsl'),
      shader = gulls.constants.vertex + frag

await Video.init()
await Slider.init()
Mouse.init()

const back = new Float32Array(gulls.width * gulls.height * 4)
const feedback_t = sg.texture(back)

let time = 0.0
const uniformData = sg.uniform([sg.width, sg.height, 0.0, 0.0])
const sliderData = sg.uniform(Slider.value)
const mouseData = sg.uniform([0,0,0,0])
const render = await sg.render({
  shader,
  data: [
    uniformData,
    sg.sampler(),
    feedback_t,
    sg.video(Video.element),
    sliderData,
    mouseData
  ],
  copy: feedback_t,
  onframe: () => {
    time = performance.now() / 1000.0
    uniformData.value[2] = time
    sliderData.value = Slider.value
    mouseData.value = Mouse.values
    uniformData.value = uniformData.value
  }
})

sg.run(render)

const container = document.getElementById('tweakpane-container')
const pane = new Tweakpane.Pane({ container })
const hueFolder = pane.addFolder({title: 'Hue Shift'})
const hueParams = {hue: 0.0}
hueFolder.addInput(hueParams, 'hue', {min: -1, max: 1, step: 0.01})
hueFolder.on('change', () => {
  uniformData.value[3] = hueParams.hue
})
