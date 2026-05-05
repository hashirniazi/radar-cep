# Advanced DSP Radar Processing Framework

**Author:** Hashir Niazi  
**Institution:** Ghulam Ishaq Khan Institute of Engineering Sciences and Technology (GIKI)  
**Course:** Digital Signal Processing (DSP) - Complex Engineering Problem (CEP)  
**Date:** May 2026  

---

## 📌 Project Overview
This repository contains a comprehensive, MATLAB-based Digital Signal Processing (DSP) framework for simulating and analyzing radar systems. It is designed as an interactive, menu-driven pipeline to demonstrate core radar concepts, including pulse compression, target detection under noise, clutter mitigation, and the specific trade-offs between different signal processing algorithms.

## ✨ Core Features & Scenarios

The framework is controlled via a master terminal menu (`test_pipeline.m`), offering four distinct simulation scenarios:

1. **Baseline LFM (Single Target + CA-CFAR)**
   * Simulates an LFM (Linear Frequency Modulated) chirp reflecting off a single moving target.
   * Demonstrates standard Matched Filtering (with Hamming Window) and Cell-Averaging CFAR detection.

2. **Target Masking Stress Test (Closely Spaced Targets)**
   * Simulates two targets spaced incredibly close together (e.g., 20 meters).
   * Demonstrates the catastrophic failure ("threshold tenting") of CA-CFAR and the mathematical resolution provided by **OS-CFAR (Order Statistic CFAR)** using 75th-percentile rank sorting.

3. **Clutter Mitigation (MTI Filtering)**
   * Introduces non-stationary ground clutter (e.g., a massive 1000-RCS mountain).
   * Implements a **2-Pulse Delay Line Canceller (MTI Filter)** to mathematically vaporize zero-Doppler clutter while allowing moving targets to punch through.
   * *Note: Built to specifically demonstrate the "Blind Speed" phenomenon if a target moves at exact wavelength multiples.*

4. **Waveform Comparison (LFM vs. Phase-Coded)**
   * Replaces the sweeping LFM chirp with a **13-Bit Barker Code** phase-modulated waveform.
   * Demonstrates perfect, flat sidelobe compression (-22.3 dB) without the need for a Hamming window.
   * Explores advanced edge-cases like Doppler intolerance and Extended Sidelobe Self-Masking.

## 🗂️ Project Structure

```text
dsp-cep/
│
├── test_pipeline.m                 # MASTER SCRIPT: Run this to launch the interactive menu
├── radar_config.m                  # Global system parameters (fs, fc, bandwidth, CFAR cells, etc.)
│
├── src/
│   ├── environment/
│   │   └── simulate_echo.m         # Multi-target, multi-pulse RCS and Doppler environment simulator
│   │
│   ├── processing/
│   │   ├── apply_matched_filter.m  # Pulse compression (handles adaptive Hamming windowing)
│   │   ├── apply_ca_cfar.m         # Cell-Averaging Constant False Alarm Rate detector
│   │   └── apply_os_cfar.m         # Order Statistic Constant False Alarm Rate detector
│   │
│   └── waveforms/
│       ├── generate_lfm_chirp.m    # Linear Frequency Modulated sweep generator
│       └── generate_barker_code.m  # 13-bit Phase-coded sequence generator
│
└── README.md