%% PHASE 1 — LONGITUDINAL MATLAB ANALYSIS
%
% Main entry point for the 05_matlab folder.
%
% Phase 1 state order:
%       x = [u; w; q; theta]
%
% Linear perturbation model:
%       x_dot = A*x + B*delta_e
%
% This script:
%   1. Loads the approved Phase 1 model from 02_data.
%   2. Validates dimensions, state order, inputs, and units.
%   3. Builds the elevator-to-state state-space system.
%   4. Computes poles and modal properties.
%   5. Simulates an elevator step.
%   6. Saves plots/tables.
%   7. Optionally evaluates the Phase 1 pitch-rate damper.
%
% Before calling the controller portion, place the Kq value approved by
% 04_design into phase1_config.m.

clear;
clc;
close all;

fprintf("============================================================\n");
fprintf(" PHASE 1 — LONGITUDINAL MATLAB ANALYSIS\n");
fprintf("============================================================\n\n");

%% 1. Load analysis configuration

cfg = phase1_config();

fprintf("Data file:\n  %s\n\n", cfg.dataFile);

%% 2. Load and validate the Phase 1 model

model = load_phase1_model(cfg.dataFile);
model = validate_phase1_model(model);

fprintf("Model interface validation: PASS\n");
fprintf("State order: %s\n", strjoin(model.state_names, ", "));
fprintf("Elevator input column: %d\n\n", model.elevator_index);

%% 3. Build open-loop state-space model

sysOpen = build_longitudinal_ss(model);

fprintf("Open-loop state-space model created.\n\n");

%% 4. Open-loop pole and mode analysis

openAnalysis = analyze_longitudinal_modes(model.A);

fprintf("OPEN-LOOP POLES\n");
disp(openAnalysis.PoleTable);

if ~isempty(openAnalysis.ModeTable)
    fprintf("OPEN-LOOP OSCILLATORY MODES\n");
    disp(openAnalysis.ModeTable);
else
    fprintf("No complex oscillatory mode pair was identified.\n\n");
end

if openAnalysis.IsAsymptoticallyStable
    fprintf("Open-loop linear model: ASYMPTOTICALLY STABLE\n\n");
else
    fprintf("Open-loop linear model: NOT ASYMPTOTICALLY STABLE\n\n");
end

%% 5. Open-loop elevator-step simulation

openResponse = simulate_elevator_step( ...
    sysOpen, ...
    model, ...
    cfg.elevatorStepDeg, ...
    cfg.simulationTimeSec, ...
    cfg.numberOfSamples);

fprintf( ...
    "Simulated %+g degree elevator command for %.1f s.\n\n", ...
    cfg.elevatorStepDeg, ...
    cfg.simulationTimeSec);

%% 6. Plot open-loop results

figOpenPoles = plot_poles( ...
    openAnalysis, ...
    "Phase 1 — Open-Loop Longitudinal Poles");

figOpenStates = plot_state_response( ...
    openResponse, ...
    "Phase 1 — Open-Loop Elevator-Step Response");

%% 7. Save open-loop outputs

saveOptions = struct( ...
    "saveFigures", cfg.saveFigures, ...
    "saveTables", cfg.saveTables, ...
    "saveMatFile", cfg.saveMatFile);

save_analysis_outputs( ...
    cfg.outputDir, ...
    "open_loop", ...
    openAnalysis, ...
    openResponse, ...
    figOpenPoles, ...
    figOpenStates, ...
    saveOptions);

%% 8. Optional pitch-rate damper

if isempty(cfg.pitchRateGain)
    fprintf("Pitch-rate damper analysis: SKIPPED\n");
    fprintf("Reason: cfg.pitchRateGain is empty.\n");
    fprintf("Enter the Kq value approved by 04_design before treating ");
    fprintf("closed-loop results as project evidence.\n\n");
else
    fprintf("Applying pitch-rate damper with Kq = %.8g\n\n", ...
        cfg.pitchRateGain);

    closedLoop = apply_pitch_rate_damper( ...
        model, ...
        cfg.pitchRateGain);

    closedAnalysis = analyze_longitudinal_modes(closedLoop.Acl);

    fprintf("CLOSED-LOOP POLES\n");
    disp(closedAnalysis.PoleTable);

    if ~isempty(closedAnalysis.ModeTable)
        fprintf("CLOSED-LOOP OSCILLATORY MODES\n");
        disp(closedAnalysis.ModeTable);
    end

    if closedAnalysis.IsAsymptoticallyStable
        fprintf("Closed-loop linear model: ASYMPTOTICALLY STABLE\n\n");
    else
        fprintf("Closed-loop linear model: NOT ASYMPTOTICALLY STABLE\n\n");
    end

    closedResponse = simulate_elevator_step( ...
        closedLoop.sys, ...
        model, ...
        cfg.elevatorStepDeg, ...
        cfg.simulationTimeSec, ...
        cfg.numberOfSamples);

    figClosedPoles = plot_poles( ...
        closedAnalysis, ...
        "Phase 1 — Closed-Loop Longitudinal Poles");

    figClosedStates = plot_state_response( ...
        closedResponse, ...
        "Phase 1 — Pitch-Rate-Damper Response");

    save_analysis_outputs( ...
        cfg.outputDir, ...
        "closed_loop", ...
        closedAnalysis, ...
        closedResponse, ...
        figClosedPoles, ...
        figClosedStates, ...
        saveOptions);

    % Save the actual closed-loop matrix so later verification can compare
    % implementation results against an independent calculation.
    if cfg.saveMatFile
        Acl = closedLoop.Acl; %#ok<NASGU>
        Kq = closedLoop.Kq; %#ok<NASGU>
        save( ...
            fullfile(cfg.outputDir, "pitch_rate_damper_design.mat"), ...
            "Acl", ...
            "Kq");
    end
end

fprintf("Analysis complete.\n");
fprintf("Outputs:\n  %s\n", cfg.outputDir);
