class_name GodotXRDesktopInputVector
extends GodotXRDesktopInput


## Godot XR Desktop Input for Vector (Vector2)


## Godot Input Action positive x
@export var input_positive_x : StringName

## Godot Input Action negative x
@export var input_negative_x : StringName

## Godot Input Action positive y
@export var input_positive_y : StringName

## Godot Input Action positive y
@export var input_negative_y : StringName

## Godot Input Dead Zone
@export var input_deadzone : float = -1.0


## Handle boolean input for controller
func process(tracker : XRControllerTracker) -> void:
	# Read the input action (Vector2)
	var value := Input.get_vector(
		input_negative_x,
		input_positive_x,
		input_negative_y,
		input_positive_y,
		input_deadzone)

	# Set the tracker input
	tracker.set_input(xr_action, value)
