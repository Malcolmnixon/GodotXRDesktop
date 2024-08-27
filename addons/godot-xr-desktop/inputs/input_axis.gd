class_name GodotXRDesktopInputAxis
extends GodotXRDesktopInput


## Godot Input Action positive
@export var input_positive : StringName

## Godot Input Action negative
@export var input_negative : StringName


## Handle boolean input for controller
func process(tracker : XRControllerTracker) -> void:
	# Read the input axis (float)
	var value := Input.get_axis(input_negative, input_positive)

	# Set the tracker input
	tracker.set_input(xr_action, value)
