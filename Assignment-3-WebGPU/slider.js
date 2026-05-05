const Slider = {
  value: [0.5, 0, 0, 0],
  init() {
    // Red slider
    const sliderRed = document.getElementById('myRangeRed')
    if (sliderRed) {
      Slider.value[0] = parseFloat(sliderRed.value) / 100.0
      sliderRed.addEventListener('input', event => {
        Slider.value[0] = parseFloat(event.target.value) / 100
      })
    }

    // Blue slider
    const sliderBlue = document.getElementById('myRangeBlue')
    if (sliderBlue) {
      Slider.value[1] = parseFloat(sliderBlue.value) / 100
      sliderBlue.addEventListener('input', event => {
        Slider.value[1] = parseFloat(event.target.value) / 100.0
      })
    }
  }
}

export default Slider