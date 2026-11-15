extends Control

# Educational simulation values
# These are simplified gameplay units, not NASA measurements.

var oxygen: float = 80.0
var energy: float = 70.0
var radiation: float = 20.0
var research: float = 0.0
var hours: int = 0


# RESOURCE INDICATORS

@onready var oxygen_bar = $MarginContainer/VBoxContainer/Resources/OxygenPanel/OxygenBar
@onready var energy_bar = $MarginContainer/VBoxContainer/Resources/EnergyPanel/EnergyBar
@onready var radiation_bar = $MarginContainer/VBoxContainer/Resources/RadiationPanel/RadiationBar
@onready var research_bar = $MarginContainer/VBoxContainer/Resources/ResearchPanel/ResearchBar


# PLAYER CONTROLS

@onready var oxygen_slider = $MarginContainer/VBoxContainer/Controls/OxygenSlider
@onready var research_slider = $MarginContainer/VBoxContainer/Controls/ResearchSlider

@onready var simulate_button = $MarginContainer/VBoxContainer/Controls/SimulateButton
@onready var restart_button = $MarginContainer/VBoxContainer/Controls/RestartButton


# LABELS

@onready var oxygen_label = $MarginContainer/VBoxContainer/Controls/OxygenLabel
@onready var research_label = $MarginContainer/VBoxContainer/Controls/ResearchLabel

@onready var status_label = $MarginContainer/VBoxContainer/Results/StatusLabel
@onready var explanation_label = $MarginContainer/VBoxContainer/Results/ExplanationLabel


func _ready():

	simulate_button.pressed.connect(simulate_hour)
	restart_button.pressed.connect(restart_simulation)

	oxygen_slider.value_changed.connect(update_slider_labels)
	research_slider.value_changed.connect(update_slider_labels)

	update_slider_labels(0)
	update_display()


func update_slider_labels(_value):

	oxygen_label.text = "Oxygen Production: " + str(int(oxygen_slider.value)) + "%"
	research_label.text = "Research Power: " + str(int(research_slider.value)) + "%"


func simulate_hour():

	hours += 1

	var oxygen_setting: float = oxygen_slider.value / 100.0
	var research_setting: float = research_slider.value / 100.0

	# Simplified hourly resource requirements

	var life_support_cost: float = 2.0
	var oxygen_energy_cost: float = oxygen_setting * 5.0
	var research_energy_cost: float = research_setting * 4.0

	var available_energy: float = energy + 3.0

	var total_energy_required: float = (
		life_support_cost
		+ oxygen_energy_cost
		+ research_energy_cost
	)

	# If insufficient energy is available,
	# prioritize basic life support and oxygen production.

	var life_support_power: float = min(
		life_support_cost,
		available_energy
	)

	available_energy -= life_support_power

	var oxygen_power: float = min(
		oxygen_energy_cost,
		available_energy
	)

	available_energy -= oxygen_power

	var research_power: float = min(
		research_energy_cost,
		available_energy
	)

	available_energy -= research_power

	# Oxygen production depends on electricity supplied.

	var oxygen_produced: float = oxygen_power * 2.0

	var oxygen_consumed: float = 5.0

	oxygen += oxygen_produced - oxygen_consumed

	# Research only progresses when electricity is available.

	research += research_power * 2.0

	# Update remaining energy.

	energy = available_energy

	# Keep resource values within bounds.

	oxygen = clamp(oxygen, 0.0, 100.0)
	energy = clamp(energy, 0.0, 100.0)
	research = clamp(research, 0.0, 100.0)

	update_display()

	# Educational feedback

	if oxygen <= 0 or energy <= 0:

		status_label.text = "MISSION FAILURE"

		explanation_label.text = (
            "A critical resource has been depleted. "
			+ "Try a different balance of oxygen production "
			+ "and scientific research."
		)

		simulate_button.disabled = true

	elif oxygen <= 20:

		status_label.text = "WARNING: LOW OXYGEN!"

		explanation_label.text = (
            "Your astronauts are running low on oxygen. "
			+ "Oxygen production needs electricity, so "
			+ "consider reducing research power."
		)

	elif energy <= 20:

		status_label.text = "WARNING: LOW ENERGY!"

		explanation_label.text = (
            "Your base is running low on electricity. "
			+ "Increasing oxygen production and research "
			+ "uses more power."
		)

	else:

		status_label.text = "MISSION HOUR " + str(hours)

		explanation_label.text = (
			"Oxygen: " + str(int(oxygen)) + "% | "
			+ "Energy: " + str(int(energy)) + "% | "
			+ "Research: " + str(int(research)) + "%. "
			+ "Try changing the sliders to see how "
			+ "resource allocation affects your mission."
		)


func update_display():

	oxygen_bar.value = oxygen
	energy_bar.value = energy
	radiation_bar.value = radiation
	research_bar.value = research


func restart_simulation():

	oxygen = 80.0
	energy = 70.0
	radiation = 20.0
	research = 0.0
	hours = 0

	oxygen_slider.value = 50
	research_slider.value = 50

	simulate_button.disabled = false

	status_label.text = "SYSTEM STATUS: STABLE"

	explanation_label.text = (
        "Your mission has restarted. "
		+ "Adjust oxygen production and research power "
		+ "to discover how the systems interact."
	)

	update_display()
