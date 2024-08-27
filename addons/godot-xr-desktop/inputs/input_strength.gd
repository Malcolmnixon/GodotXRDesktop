class_name GodotXRDesktopInputStrength
extends GodotXRDesktopInput


## Godot XR Desktop Input for Strength (float)


## Godot Input Action name
@export var input_action : StringName


## Handle boolean input for controller
func process(tracker : XRControllerTracker) -> void:
	# Read the input action (float)
	var value := Input.get_action_strength(input_action)

	# Set the tracker input
	tracker.set_input(xr_action, value)
