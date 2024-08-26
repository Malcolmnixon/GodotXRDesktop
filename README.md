# Godot XR Desktop

![GitHub forks](https://img.shields.io/github/forks/Malcolmnixon/GodotXRDesktop?style=plastic)
![GitHub Repo stars](https://img.shields.io/github/stars/Malcolmnixon/GodotXRDesktop?style=plastic)
![GitHub contributors](https://img.shields.io/github/contributors/Malcolmnixon/GodotXRDesktop?style=plastic)
![GitHub](https://img.shields.io/github/license/Malcolmnixon/GodotXRDesktop?style=plastic)

Godot XR addon to allow XR games to be driven as a standard 3D experience.


# Inputs

At this time the following inputs (defined by the Godot Input Map) are supported:

| Input | Action |
| :--- | :----- |
| physical_move_forwards | Causes the virtual XR player to walk forwards (in the tracking space) |
| physical_move_backwards | Causes the virtual XR player to walk backwards (in the tracking space) |
| physical_move_left | Causes the virtual XR player to walk to their left (in the tracking space) |
| physical_move_right | Causes the virtual XR player to walk to their right (in the tracking space) |
| physical_crouch | Causes the virtual XR player to crouch |
| right-mouse-drag | Causes the virtual XR player to look up/down and rotate left/right |


# TODO

At this time the GodotXRDesktopInputSettings resource does not contain any means of
specifying which Godot Input Map entries drive which OpenXR Action Map events.

Button, 1D, and 2D inputs need to be mapped appropriately.
