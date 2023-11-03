# BreakoutShot
 This small pool billiards game is a first project for me to learn a bit about game development and get into the Godot Engine.

![Table](/screenshots/1_table.png "Table")

The billiards rules are simplified because there is no multiplayer functionality implemented. This game is primarily designed for testing the engine rather than providing an enjoyable gameplay experience.

## How to Play

Download zip-File from release page or play in browser on [itch.io](https://derdan-iel.itch.io/breakoutshot).

## Technical Features
Here are some features that I implemented on my own because I did not find much about how it could be done based on my research. Maybe it can be useful for someone.

**Dotted Aim Line**

It is not completely perfect and there might be more lightweight solutions for this. The way it works is by using a chain of nodes representing the white dots, that are connected using a Path2D between the cue ball and the target, which progress at a given speed at each frame.

![Break](/screenshots/2_break.gif "Break")

**Resizable Window Functionality**

The idea here was to make the game adapt dynamically to any screen orientation and window size. The stretch mode is disabled to preserve the size of the GUI elements, and the stretch aspect is set to expand. Everytime the window size changes, the game performs calculations to always keep the table field centered and properly scaled to fit the screen. Portrait and landscape mode change automatically dependent on the aspect ratio.

![Resize](/screenshots/3_resize.gif "Resize")

## Contact

[Mastodon](https://mastodon.social/@Daniero)

## Resources
- [Another pool billiards game made with Godot (GitHub)](https://github.com/fswienty/godot-multiplayer-billiards)
- [German tutorial for programming a billiards game written in JavaScript (YouTube)](https://www.youtube.com/watch?v=pJ0SW4ayXzU&list=PL1LHMFscti8vGfIvK5-9P5RAavTxzoQWP)