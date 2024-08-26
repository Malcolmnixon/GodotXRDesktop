class_name DesktopInterface
extends XRInterfaceExtension


func _trigger_haptic_pulse(
	action_name: String,
	tracker_name: StringName,
	frequency: float,
	amplitude: float,
	duration_sec: float,
	delay_sec: float) -> void:
	print("Haptic: ", action_name)
