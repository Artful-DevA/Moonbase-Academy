extends Control

# Educational simulation units, not calibrated NASA engineering measurements.
var oxygen: float = 80.0
var energy: float = 70.0
var radiation: float = 20.0
var research: float = 0.0
var hours: int = 0
var event_pending: bool = false
var event_completed: bool = false
var solar_event: Dictionary = {}

@onready var oxygen_bar = $MarginContainer/VBoxContainer/Resources/OxygenPanel/OxygenBar
@onready var energy_bar = $MarginContainer/VBoxContainer/Resources/EnergyPanel/EnergyBar
@onready var radiation_bar = $MarginContainer/VBoxContainer/Resources/RadiationPanel/RadiationBar
@onready var research_bar = $MarginContainer/VBoxContainer/Resources/ResearchPanel/ResearchBar

@onready var oxygen_slider = $MarginContainer/VBoxContainer/Controls/OxygenSlider
@onready var research_slider = $MarginContainer/VBoxContainer/Controls/ResearchSlider
@onready var simulate_button = $MarginContainer/VBoxContainer/Controls/SimulateButton
@onready var restart_button = $MarginContainer/VBoxContainer/Controls/RestartButton

@onready var oxygen_label = $MarginContainer/VBoxContainer/Controls/OxygenLabel
@onready var research_label = $MarginContainer/VBoxContainer/Controls/ResearchLabel
@onready var status_label = $MarginContainer/VBoxContainer/Results/StatusLabel
@onready var explanation_label = $MarginContainer/VBoxContainer/Results/ExplanationLabel

@onready var solar_event_panel = $MarginContainer/VBoxContainer/SolarEvent
@onready var solar_event_label = $MarginContainer/VBoxContainer/SolarEvent/SolarEventLabel
@onready var shelter_button = $MarginContainer/VBoxContainer/SolarEvent/SolarChoices/ShelterButton
@onready var continue_research_button = $MarginContainer/VBoxContainer/SolarEvent/SolarChoices/ContinueResearchButton


func _ready() -> void:
	simulate_button.pressed.connect(simulate_hour)
	restart_button.pressed.connect(restart_simulation)
	shelter_button.pressed.connect(_choose_shelter)
	continue_research_button.pressed.connect(_choose_research)
	oxygen_slider.value_changed.connect(update_slider_labels)
	research_slider.value_changed.connect(update_slider_labels)
	_load_solar_event()
	restart_simulation()


func _load_solar_event() -> void:
	var file := FileAccess.open("res://data/solar_event.json", FileAccess.READ)
	if file == null:
		push_warning("Solar-event JSON is unavailable. Using a clearly labeled illustrative fallback.")
		solar_event = {"date": "historical", "instrument": "spacecraft", "source_url": ""}
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		solar_event = parsed
	else:
		push_warning("Invalid solar-event JSON; using illustrative fallback.")
		solar_event = {"date": "historical", "instrument": "spacecraft", "source_url": ""}


func update_slider_labels(_value: float) -> void:
	oxygen_label.text = "Oxygen Production: %d%%" % int(oxygen_slider.value)
	research_label.text = "Research Power: %d%%" % int(research_slider.value)


func simulate_hour() -> void:
	if event_pending or simulate_button.disabled:
		return

	hours += 1
	var oxygen_setting: float = oxygen_slider.value / 100.0
	var research_setting: float = research_slider.value / 100.0

	# The model gives essential life support first claim on the available power.
	# All rates below are illustrative gameplay values.
	var available_energy: float = min(100.0, energy + 3.0)
	var life_support_power: float = min(2.0, available_energy)
	available_energy -= life_support_power

	var requested_oxygen_power: float = oxygen_setting * 5.0
	var oxygen_power: float = min(requested_oxygen_power, available_energy)
	available_energy -= oxygen_power

	var requested_research_power: float = research_setting * 4.0
	var research_power: float = min(requested_research_power, available_energy)
	available_energy -= research_power

	oxygen = clamp(oxygen + oxygen_power * 2.0 - 5.0, 0.0, 100.0)
	research = clamp(research + research_power * 2.0, 0.0, 100.0)
	energy = clamp(available_energy, 0.0, 100.0)
	update_display()

	if oxygen <= 0.0 or energy <= 0.0:
		_end_simulation("A critical resource ran out. Try reducing research power or changing oxygen production.")
		return

	# A single educational space-weather decision occurs after two hours.
	if hours == 2 and not event_completed:
		_show_solar_event()
		return

	if oxygen <= 20.0:
		status_label.text = "WARNING: LOW OXYGEN"
		explanation_label.text = "Oxygen production requires energy. Consider prioritizing life support."
	elif energy <= 20.0:
		status_label.text = "WARNING: LOW ENERGY"
		explanation_label.text = "Oxygen production and research share a limited supply of electricity."
	else:
		status_label.text = "MISSION HOUR %d" % hours
		explanation_label.text = "Oxygen %d%% | Energy %d%% | Research %d%%. Try different allocations and compare the results." % [int(oxygen), int(energy), int(research)]


func _show_solar_event() -> void:
	event_pending = true
	simulate_button.disabled = true
	solar_event_panel.visible = true
	solar_event_label.text = "SPACE WEATHER ALERT | NASA DONKI, %s: a solar particle event was recorded by %s. This is NOT a measured lunar dose. Choose how your hypothetical crew responds." % [str(solar_event.get("date", "2024-05-11")), str(solar_event.get("instrument", "STEREO A"))]
	status_label.text = "SOLAR ACTIVITY: MAKE A DECISION"
	explanation_label.text = "Sheltering protects the crew but costs energy and delays research. Continuing research saves that time but increases simulated exposure risk."


func _choose_shelter() -> void:
	if not event_pending:
		return
	energy = max(0.0, energy - 7.0)
	_finish_solar_event("The crew sheltered. You spent 7 simulated energy units and postponed science, reducing exposure risk.")


func _choose_research() -> void:
	if not event_pending:
		return
	radiation = min(100.0, radiation + 30.0)
	research = min(100.0, research + 8.0)
	_finish_solar_event("Research continued (+8 progress), but simulated exposure risk increased (+30). Real doses require location and shielding models.")


func _finish_solar_event(message: String) -> void:
	event_pending = false
	event_completed = true
	solar_event_panel.visible = false
	update_display()
	if energy <= 0.0:
		_end_simulation(message + " Energy reserves were depleted.")
		return
	status_label.text = "SPACE WEATHER DECISION COMPLETE"
	explanation_label.text = message
	simulate_button.disabled = false


func _end_simulation(message: String) -> void:
	status_label.text = "SIMULATION ENDED"
	explanation_label.text = message
	simulate_button.disabled = true
	solar_event_panel.visible = false
	event_pending = false


func update_display() -> void:
	oxygen_bar.value = oxygen
	energy_bar.value = energy
	radiation_bar.value = radiation
	research_bar.value = research


func restart_simulation() -> void:
	oxygen = 80.0
	energy = 70.0
	radiation = 20.0
	research = 0.0
	hours = 0
	event_pending = false
	event_completed = false
	oxygen_slider.value = 50.0
	research_slider.value = 50.0
	simulate_button.disabled = false
	solar_event_panel.visible = false
	status_label.text = "SYSTEM STATUS: STABLE"
	explanation_label.text = "Adjust oxygen production and research power. Simulate each hour to see how limited energy affects the lunar base. All resource percentages are educational gameplay values."
	update_slider_labels(0.0)
	update_display()
