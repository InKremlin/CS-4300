# Site

[GithubPages](https://inkremlin.github.io/4300-Final-AudioSmoothLife/)

# Explanation

For the final project I decided to go with explorations of options 1 and 3, so I created a morphogenetic simulation with a unique mode of interaction. I started with the Game of Life demo and transformed it into a SmoothLife simulation that focused on continuous motion and organic growth instead of binary cells. My goal was to create something that felt alive and reactive, similar to the reaction diffusion project like a digital organism.

The process involved rewriting much of the original logic in WGSL compute shaders. Instead of using traditional alive-or-dead cellular automata rules, I implemented smooth transition functions using sigmoid curves, which allowed the simulation to gradually blend between states. I also separated the neighborhood sampling into inner and outer regions, helping create the soft blob-like growth patterns associated with SmoothLife. Much of the development process involved experimenting with parameter values such as growth thresholds and neighborhood radii, since even small adjustments could drastically change the system’s behavior. At first I included sliders that allowed the user to play with these parameters, but I decided they were too volatile and were better left in a specific range. 

My main technical goal was to make the simulation reactive to audio input. While originally I wanted to use the phones touch screen and gyro controls, I had trouble testing and decided to implement audio interaction. The mouse allows users to paint energy directly into the simulation. You can also paint with audio input, but audio is mainly used to boost the simulation's birth parameters, making cells grow. Microphone inputs spawning behavior changes based on low, mid, and high frequency audio levels. Integrating audio into the system was a challenge because I had to normalize the sound data to keep the simulation stable and not overwhelm it.
Another challenge involved optimization and performance. Since every pixel samples neighboring cells, the compute shader becomes expensive at larger radii. I had to clamp values and optimize loops to maintain smooth frame rates.
I wanted the simulation to feel fluid rather than mechanical. I designed the fragment shader with smooth color gradients that shift from dark blues to bright cyan, yellow, and white depending on the simulation state.


# Code

[Project Folder](https://github.com/InKremlin/CS-4300/tree/main/4300Final)
