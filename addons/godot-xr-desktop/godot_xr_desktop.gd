extends Node


## This script supports basic XR desktop input by synthesizing XRTracker
## data from standard input events.


# Table of left-hand pose transforms by PoseType
const _POSE_TRANSFORMS_LEFT : Array[Transform3D] = [
	# Skeleton-pose (identity)
	Transform3D(
		Basis.IDENTITY,
		Vector3.ZERO),

	# Aim pose - see OpenXR specification
	Transform3D(
		Basis(Quaternion(0.5, -0.5, 0.5, 0.5)),
		Vector3(-0.05, 0.11, 0.035)),

	# Grip pose - see OpenXR specification
	Transform3D(
		Basis(Quaternion(0.6408564, -0.2988362, 0.6408564, 0.2988362)),
		Vector3(0.0, 0.0, 0.025))
]

# Table of right-hand pose transforms by PoseType
const _POSE_TRANSFORMS_RIGHT : Array[Transform3D] = [
	# Skeleton-pose (identity)
	Transform3D(
		Basis.IDENTITY,
		Vector3.ZERO),

	# Aim pose - see OpenXR specification
	Transform3D(
		Basis(Quaternion(0.5, 0.5, -0.5, 0.5)),
		Vector3(0.05, 0.11, 0.035)),

	# Grip pose - see OpenXR specification
	Transform3D(
		Basis(Quaternion(-0.6408564, -0.2988362, 0.6408564, -0.2988362)),
		Vector3(0.0, 0.0, 0.025))
]


## Body settings
@export var body_settings : GodotXRDesktopBodySettings

## Input settings
@export var input_settings : GodotXRDesktopInputSettings

## Auto-start option
@export var auto_start : bool = false


# XR Desktop Active flag
var _active : bool = false

# Head tracker
var _head_tracker : XRPositionalTracker

# Left controller tracker
var _left_controller_tracker : XRControllerTracker

# Right controller tracker
var _right_controller_tracker : XRControllerTracker

# Head position
var _head_position : Transform3D = Transform3D.IDENTITY

# Head pitch angle (radians)
var _pitch : float = 0.0

# Head yaw angle (radians)
var _yaw : float = 0.0


# This method tries to auto-start the XR Desktop experience if enabled. Note
# that this approach is a fall-back and the preferred approach is for the
# application to call the start_desktop() method if a real XR interface
# cannot be found
func _ready() -> void:
	# If auto-start then schedule XR check
	if auto_start:
		await get_tree().create_timer(0.2).timeout
		start_desktop()


# This method generates simulated XR input when the XR Desktop experience is
# active.
func _physics_process(delta: float) -> void:
	# Skip if not active
	if not _active:
		set_physics_process(false)
		return

	# Process the inputs
	input_settings.process(_left_controller_tracker, _right_controller_tracker)

	# Handle physical crouching
	if Input.is_action_pressed("physical_crouch"):
		_head_position.origin.y = body_settings.height_crouching
	else:
		_head_position.origin.y = body_settings.height_standing

	# Handle physical movement
	var forward := _get_forward() * body_settings.physical_move_speed * delta
	var left := forward.rotated(Vector3.UP, PI/2)
	_head_position.origin += forward * Input.get_axis(
		"physical_move_backwards",
		"physical_move_forwards")
	_head_position.origin += left * Input.get_axis(
		"physical_move_right",
		"physical_move_left")

	# Handle looking around
	var look_scale := body_settings.look_speed * delta
	_pitch += Input.get_axis("head_down", "head_up") * look_scale
	_yaw += Input.get_axis("head_right", "head_left") * look_scale
	_pitch = clampf(_pitch, -PI/2, PI/2)
	_yaw = fmod(_yaw, 2 * PI)

	# Set the look
	_head_position.basis = Basis.IDENTITY \
		.rotated(Vector3.LEFT, _pitch) \
		.rotated(Vector3.UP, _yaw)

	# Update the poses
	_update_poses()


# This method generates simulated XR input when the XR Desktop experience is
# active.
func _input(event: InputEvent) -> void:
	# Skip if not active
	if not _active:
		return

	# Handle rotation by right-mouse-drag
	var motion := event as InputEventMouseMotion
	if motion and motion.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		_pitch += motion.relative.y * 0.001
		_yaw -= motion.relative.x * 0.001

	# Handle mouse capture and mouse-wheel movement in/out
	var button := event as InputEventMouseButton
	if button and button.pressed and button.button_index == MOUSE_BUTTON_RIGHT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if button and not button.pressed and button.button_index == MOUSE_BUTTON_RIGHT:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


## Start the XR Desktop simulated input
func start_desktop() -> void:
	# Skip if already active, or XR is active
	if _active or get_viewport().use_xr:
		return

	# Report starting
	print("XR Desktop - Starting")

	# Sanity check the settings
	if not body_settings or not input_settings:
		push_error("XR Desktop - Missing Settings")
		return

	# Construct the head tracker
	_head_tracker = XRPositionalTracker.new()
	_head_tracker.name = "head"
	XRServer.add_tracker(_head_tracker)

	# Construct the left controller tracker
	_left_controller_tracker = XRControllerTracker.new()
	_left_controller_tracker.name = "left_hand"
	XRServer.add_tracker(_left_controller_tracker)

	# Construct the right controller tracker
	_right_controller_tracker = XRControllerTracker.new()
	_right_controller_tracker.name = "right_hand"
	XRServer.add_tracker(_right_controller_tracker)

	# Update the poses
	_head_position = Transform3D(
		Basis.IDENTITY,
		Vector3(0, body_settings.height_standing, 0))
	_update_poses()

	# Create dummy interface
	XRServer.primary_interface = DesktopInterface.new()

	# Enable
	_active = true
	set_physics_process(true)


## End the XR Desktop simulated inout
func end_desktop() -> void:
	# Skip if not active
	if not _active:
		return

	# Report ending
	print("XR Desktop - Ending")

	# Remove the head tracker
	XRServer.remove_tracker(_head_tracker)
	_head_tracker = null

	# Remove the left controller tracker
	XRServer.remove_tracker(_left_controller_tracker)
	_left_controller_tracker = null

	# Remove the right controller tracker
	XRServer.remove_tracker(_right_controller_tracker)
	_right_controller_tracker = null

	# Disable
	_active = false


func _update_poses() -> void:
	# Set the head default pose
	_head_tracker.set_pose(
		"default",
		_head_position,
		Vector3.ZERO,
		Vector3.ZERO,
		XRPose.XR_TRACKING_CONFIDENCE_HIGH)

	# Set the left controller pose
	var left_hand := _head_position
	left_hand.origin += left_hand.basis * body_settings.left_controller_offset
	left_hand.basis = left_hand.basis.rotated(left_hand.basis.x, -PI/2)
	left_hand.basis = left_hand.basis.rotated(left_hand.basis.y, PI/2)
	_left_controller_tracker.set_pose(
		"skeleton",
		left_hand * _POSE_TRANSFORMS_LEFT[0],
		Vector3.ZERO,
		Vector3.ZERO,
		XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_left_controller_tracker.set_pose(
		"aim",
		left_hand * _POSE_TRANSFORMS_LEFT[1],
		Vector3.ZERO,
		Vector3.ZERO,
		XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_left_controller_tracker.set_pose(
		"grip",
		left_hand * _POSE_TRANSFORMS_LEFT[2],
		Vector3.ZERO,
		Vector3.ZERO,
		XRPose.XR_TRACKING_CONFIDENCE_HIGH)

	# Set the right controller pose
	var right_hand := _head_position
	right_hand.origin += right_hand.basis * body_settings.right_controller_offset
	right_hand.basis = right_hand.basis.rotated(right_hand.basis.x, -PI/2)
	right_hand.basis = right_hand.basis.rotated(right_hand.basis.y, -PI/2)
	_right_controller_tracker.set_pose(
		"skeleton",
		right_hand * _POSE_TRANSFORMS_RIGHT[0],
		Vector3.ZERO,
		Vector3.ZERO,
		XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_right_controller_tracker.set_pose(
		"aim",
		right_hand * _POSE_TRANSFORMS_RIGHT[1],
		Vector3.ZERO,
		Vector3.ZERO,
		XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_right_controller_tracker.set_pose(
		"grip",
		right_hand * _POSE_TRANSFORMS_RIGHT[2],
		Vector3.ZERO,
		Vector3.ZERO,
		XRPose.XR_TRACKING_CONFIDENCE_HIGH)


# Get the player forward direction
func _get_forward() -> Vector3:
	# Start by assuming forwards is best defined by head-forwards
	var forward := -_head_position.basis.z

	# Refine if looking too far up or down
	var elevation := forward.dot(Vector3.UP)
	if elevation > 0.75:
		forward = -_head_position.basis.y
	elif elevation < -0.75:
		forward = _head_position.basis.y

	# Set horizontal and normalzie
	return forward.slide(Vector3.UP).normalized()
