# 💡 Coherent Ising Machine Simulator (`CIMSimulator`)

*A Julia-based simulator to explore the dynamics and optimization capabilities of Coherent Ising Machines (CIMs) — analog systems inspired by optical computing architectures for solving combinatorial problems.*

---

## 📚 Overview

This repository contains a modular and extensible simulator for Coherent Ising Machines, implemented in Julia. Users can interactively explore:

- Various **Ising problem configurations**
- Multiple **simulation methods** (including chaotic modulation strategies)
- Dynamic **parameter tuning and modulation**
- Performance of different **control schemes** (e.g., CIM-CAC, CIM-CFC)

---

## 🗂️ Repository Structure

```plaintext
CIMSimulator/
├── src/
│   ├── CoherentIsingMachine.jl        # Core simulation engine
│   ├── IO.jl                          # Handles input/output and config parsing
│   └── Main.jl                        # CLI entry point
├── test/
│   └── test_CoherentIsingMachine.jl   # Unit tests
├── report/
│   ├── report.pdf                     # Full technical report
│   └── executive_summary.pdf          # High-level findings
├── Dockerfile                         # Docker config for environment setup
├── Manifest.toml                      # Julia package lock file
├── Project.toml                       # Project environment and dependencies
└── LICENSE                            # License information
```

---

## 🚀 Quick Start

### 📦 Run with Docker

Make sure [Docker](https://www.docker.com/) is installed.

```bash
# Step 1: Build the Docker image
docker build -t CIMSimulator .

# Step 2: Run the simulator interactively
docker run --rm -ti CIMSimulator
```
---

### 🧠 Example Workflow

1. **Launch the Simulator**  
    ```bash
    docker run --rm -ti CIMSimulator
    ```

2. **Follow On-screen Prompts**
    - 🔧 **Problem Definition:** Define your Ising Hamiltonian or select from predefined cases
    - 🧪 **Method Selection:** Choose a simulation type:
        - CIM 
        - CIM - NLF
        - CIM - CAC (Chaotic Amplitude Control)
        - CIM - CFC (Chaotic Feedback Control)
        - CIM - SFC (Separable Feedback Control)
    - 📈 **Modulation Strategy:** Specify how amplitudes or gain change over time
    - ⚙️ **Parameter Configuration:** Fine-tune your experiment parameters

3. **Run the Simulation**

--- 

## ✅ Testing
Unit tests are included to verify simulation integrity:
```bash
julia test/test_CoherentIsingMachine.jl
```
Ensure you have the required dependencies from `Project.toml`.

--- 

## 📄 Report

- 📘 [Full Report (PDF)](./report/report.pdf)  
  *"Chaotic Amplitude Control for the Ising Minimization using Optical Parametric Oscillator Systems"*

- 📑 [Executive Summary](./report/summary.pdf)  
  Key findings and methodology overview.

--- 

## 👥 Contributors
Julius H. Ramlau, James S. Cummins, and Natalia G. Berloff

--- 

## 📜 License
Distributed under the [MIT License](./LICENSE).

## 🌐 Related Topics
Coherent Ising Machines | Optical Computing | Nonlinear Dynamics | Combinatorial Optimisation | Analog Simulation | Julia for Physics
