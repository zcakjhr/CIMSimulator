# Coherent Ising Machine Simulator (CIMSimulator)

## Overview 
This repository contains a Julia implementation of a simulator for the Coherent Ising Machine (CIM). The CIMSimulator allows users to interactively explore different problem settings, methods, modulation strategies, and parameters related to the Coherent Ising Machine. 

## Contents
- `src/`
    - `CoherentIsingMachine.jl`: Main module for the CIM implementation.
    - `IO.jl`: Module for handling input and output functionalities.
    - `Main.jl`: Entry point script for launching the simulator.
- `test/`
    - `test_CoherentIsingMachine.jl`: Unit tests for the CIM implementation.
- `Dockerfile`: Docker configuration file for building the simulator environment.
- `report/`
    - `report.pdf`: Detailed report on Chaotic Amplitude Control in Coherent Ising Machines and its application.
    - `executive_summary.pdf`: Summary of key findings and conclusions from the report.
- `LICENSE`
- `Manifest.toml`, `Project.toml`: Julia project files specifying dependencies and environment configurations.

## Usage 
### Docker Installation
To run the CIMSimulator, Docker is used for easy setup and deployment:
1. Build the docker image:
    ```
    docker build -t CIMSimulator .
    ```
2. Run the docker container:
    ```
    docker run --rm -ti CIMSimulator
    ```
### Example Workflow
1. Launch the Simulator:
    ```
    docker run --rm -ti CIMSimulator
    ```
2. Follow On-screen Prompts:
    Upon launching the simulator, users will be prompted to input various parameters and settings:
    - Problem Definition: Specify the Ising problem to be solved or simulated.
    - Method Selection: Choose from available methods (CIM, CIM-NLF, CIM-CAC, CIM-CFC, CIM-SFC) for simulating the CIM.
    - Modulation Strategy: Define how parameters should be modulated over iterations.
    - Parameter Configuration: State the parameter combination you wish to try out. 

3. Run Simulation:
    - Execute the simulation based on the provided inputs.

### Testing
Unit tests are provided in `test/test_CoherentIsingMachine.jl` to ensure the correctness of the CIM implementation. To run tests, execute:
```
julia test/test_CoherentIsingMachine.jl
```

# Contributors
Julius H. Ramlau, James S. Cummins, and Natalia G. Berloff
