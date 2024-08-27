class_name GodotXRDesktopInputPressed
extends GodotXRDesktopInput


## Godot XR Desktop Input for Pressed (bool)


## Godot Input Action name
@export var input_action : StringName


## Handle boolean input for controller
func process(tracker : XRControllerTracker) -> void:
	# Read the input action (bool)
	var value := Input.is_action_pressed(input_action)

	# Set the tracker input
	tracker.set_input(xr_action, value)
