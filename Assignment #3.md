# Site

[GithubPages](https://inkremlin.github.io/4300-A3-Web-GPU/)

# Explanation

For this assignment, I played around with the noise a lot, not looking to do any style in particular. I first tried to create a flow-like pattern to mimic a lava lamp or ink blots, taking inspiration from one of the examples in The Book of Shaders, but without a smoothstep it looked a bit like TV static, which I thought was really fun. Just like the flow pattern, I used a 2D hash to get a messy grid, then sampled the hash at multiple scales and moved it around, using the moving slice of noise space to create cool streaks and patterns on the output.

The noise I ended up with was giving me a very MTV, grungy music video vibe, so I used gamma correction to increase the contrast and create a chiaroscuro kind of vibe that, to me, felt very reminiscent of this kind of underground aesthetic. The user has four modes of interaction with the visuals. First, the video with feedback. I find it pretty fun to move around quickly and see the way your body’s movement overlaps and trails. An interesting byproduct of the gamma correction and the feedback is that if you hold a bright surface still on the camera and move it away quickly, the outline of the surface will persist. The second and third modes of interaction are two sliders that multiply the red and green channels of the output, respectively. The fourth mode of interaction is clicking with the mouse, which inverts the blue channel.

# Code

[Project Folder](https://github.com/InKremlin/CS-4300/tree/main/Assignment-3-WebGPU)
