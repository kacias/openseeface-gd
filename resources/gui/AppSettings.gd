extends Control

# Console

const MAX_LOGS: int = 26

var console: VBoxContainer

func setup_console(element: Control) -> void:
	if console:
		return
	
	console = VBoxContainer.new()
	element.vbox.add_child(console)

	AppManager.logger.connect("on_log", self, "_on_log")

func _on_log(message: String) -> void:
	var label := Label.new()
	label.autowrap = true
	label.text = message

	console.add_child(label)

	console.move_child(label, 0)

	if console.get_child_count() > MAX_LOGS:
		console.get_child(MAX_LOGS).free()

# Fxaa

var has_shown_fxaa_popup: bool = false

func fxaa(element: Control) -> void:
	if not element.toggle.is_connected("toggled", self, "_on_fxaa_toggled"):
		element.toggle.connect("toggled", self, "_on_fxaa_toggled")

func _on_fxaa_toggled(button_state: bool) -> void:
	if (not has_shown_fxaa_popup and button_state == true):
		AppManager.logger.notify("Enabling FXAA will cause transparent backgrounds to malfunction, if you have transparent backgrounds enabled.")
		has_shown_fxaa_popup = true
