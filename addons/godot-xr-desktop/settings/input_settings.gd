class_name GodotXRDesktopInputSettings
extends Resource


## Godot XR Desktop Inputs


## Array of left controller inputs
@export var left_inputs : Array[GodotXRDesktopInput] = []

## Array of right controller inputs
@export var right_inputs : Array[GodotXRDesktopInput] = []


## Process the inputs
func process(
	left_tracker : XRControllerTracker,
	right_tracker : XRControllerTracker) -> void:

	# Process the left inputs
	for i in left_inputs:
		i.process(left_tracker)

	# Process the right inputs
	for i in right_inputs:
		i.process(right_tracker)
