# Site

[GithubPages]()

# Explanation

For the vants mini assignment, I gave my vants sensors so pheremones nearby can effect their steering behavior. Each vant looks ahead, left, and right to detect nearby pheromone intensity, then turns based on its behavior type. Vants with flag 0 are attracted to pheromones and tend to follow trails, while flag 1 causes avoidance behavior, making them move away from dense areas. As they travel, they either place or erase pheromones, constantly reshaping the environment. A small wobble is added to movement to the paths to try and make them less predictable. For some reason these rules tend to make a colony that expands pretty far, they don't tend to jumble too close to eachother like the original rules, instead many of the vants immediately long straight line and bridges. Many vants create these diagnonal shapes across the screen. These set of rules ends up spreading a lot of pheremone across the screen.

# Code

[Project Folder]()
