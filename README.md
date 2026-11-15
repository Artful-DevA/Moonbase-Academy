# Moonbase Academy

**Moonbase Academy** is a small, interactive lunar-base resource-management simulator for students aged 7–12, created for the **2026 NASA Space Apps Challenge**, challenge **Build a Junior Astronaut Mission Trainer**.

**Team:** Artful Astronauts

## What it does

Players manage a simplified Moon outpost by adjusting oxygen production and power allocated to research, then advancing the simulation one hour at a time. The dashboard displays:

- **Oxygen reserves:** Life-support oxygen availability.
- **Energy reserves:** Available electricity for essential systems and research.
- **Scientific progress:** Advances only when research receives electricity.
- **Radiation exposure risk:** An illustrative risk indicator that changes when the player chooses how to respond to a space-weather event.

The simulation prioritizes essential life-support electricity before oxygen production and research. Players experience the trade-off between scientific progress and keeping the outpost supplied. After two simulated hours, a solar-activity scenario presents a choice between sheltering the crew and continuing research. A restart button allows experimenting with different strategies.

## Run locally

1. Install **Godot 4** (this project was set up with Godot 4.7).
2. Clone or download this repository.
3. Open **project.godot** in the Godot Project Manager.
4. Press **F6** with `main.tscn` open, or **F5** to run the project.
5. Change the sliders, press **Simulate Next Hour**, make the solar-event decision, and use **Restart Simulation** to try again.

## Implementation

- **Engine:** Godot 4, GDScript.
- **Interface:** A single 2D scene containing resource bars, controls, simulation feedback, and a space-weather decision.
- **Data:** `data/solar_event.json` contains a curated historical NASA DONKI solar energetic particle event, rather than making a live API request.
- **Backend:** None.

For a browser export, use Godot's Web export preset and ensure `*.json` is included in the exported non-resource files, then upload the web build to a host such as itch.io. Test the export before sharing it.

## Science and educational limitations

The event in `data/solar_event.json` is a **real spacecraft-observed solar energetic particle event** recorded by NASA DONKI on May 11, 2024. It is **not** a measurement of radiation dose inside a Moon base. The simulator's resource percentages, hourly consumption rates, protective actions, and risk adjustments are **simplified illustrative gameplay values**, not engineering design specifications or medically meaningful radiation doses. The scenario is scripted, not live space-weather monitoring or machine learning.

NASA source: [DONKI solar energetic particle event, May 11, 2024](https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/30717/1).

Engineering reference: [NASA Environmental Control and Life Support System (ECLSS)](https://www.nasa.gov/reference/environmental-control-and-life-support-systems-eclss/).

## Learning goals

The simulation introduces limited-resource allocation, trade-offs between life support and science, and the importance of safety decisions under space-weather hazards. It is an educational prototype, not a validated engineering simulator.

Claude and ChatGPT were used for coding.
