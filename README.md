# Artifact for TAPDance - NDSS '24

This repository contains the code to reproduce the experiments for the paper: `Architecting Trigger-Action Platforms for Security, Performance and Functionality`. For conducting the experiments, 3 networked machines running Ubuntu 18.04 LTS is required. The paper's results were obtained by running on a [StarFive VisonFive SBC](https://doc-en.rvspace.org/Doc_Center/visionfive.html) and this repository provides an emulation of the same using Qemu.


## Contents
1. [Pre-Build](#pre-build)
2. [Building](#build)
3. [Setting up Trigger Shim](#trigger-shim)
4. [Setting up Action Shim](#action-shim)
5. [Running Baseline Benchmarks](#baseline)
6. [Running Spigot Benchmarks](#spigot)
7. [Running Spigot without Enclaves](#noenclave)

## Pre Build
