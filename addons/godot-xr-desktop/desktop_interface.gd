class_name DesktopInterface
extends XRInterfaceExtension


func _trigger_haptic_pulse(
	action_name: String,
	_tracker_name: StringName,
	_frequency: float,
	_amplitude: float,
	_duration_sec: float,
	_delay_sec: float) -> void:
	print("Haptic: ", action_name)
