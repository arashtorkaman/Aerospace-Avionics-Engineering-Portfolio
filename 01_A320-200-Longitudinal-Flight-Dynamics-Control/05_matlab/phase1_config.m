function cfg = phase1_config()
%PHASE1_CONFIG Configuration for Phase 1 longitudinal MATLAB analysis.
%
% This function contains analysis settings, not aircraft aerodynamic data.
% Aircraft/model data belong in ../02_data/phase1_longitudinal_model.mat.
%
% OUTPUT
%   cfg - structure containing file locations and analysis settings.

    matlabFolder = fileparts(mfilename("fullpath"));
    projectRoot  = fileparts(matlabFolder);

    cfg = struct();

    % ---------------------------------------------------------------------
    % DATA SOURCE
    % ---------------------------------------------------------------------
   cfg.dataFile = fullfile( ...
    projectRoot, ...
    "03_data", ...
    "phase1_longitudinal_model.mat");

    % ---------------------------------------------------------------------
    % OUTPUT LOCATION
    % ---------------------------------------------------------------------
    % Keep development outputs in 05_matlab/output for now.
    % Selected final evidence can later be copied/exported to 10_results.
    cfg.outputDir = fullfile(matlabFolder, "output");

    % ---------------------------------------------------------------------
    % OPEN-LOOP ELEVATOR STEP
    % ---------------------------------------------------------------------
    % The numerical command is entered in degrees for human readability.
    % simulate_elevator_step.m converts the command to the units declared
    % by the 02_data model.
    cfg.elevatorStepDeg = 1.0;

    % Simulation duration in seconds. Change this if the Phase 1 phugoid
    % requires a longer time window for meaningful interpretation.
    cfg.simulationTimeSec = 2000;

    % Number of simulation samples.
    cfg.numberOfSamples = 10000;

    % ---------------------------------------------------------------------
    % PITCH-RATE DAMPER
    % ---------------------------------------------------------------------
    % Enter the Kq value approved by the Phase 1 design artifact.
    %
    % Control law:
    %       delta_e = delta_e_cmd - Kq*q
    %
    % Leave empty until the design value is available.
    cfg.pitchRateGain = -1.80;
    % ---------------------------------------------------------------------
    % OUTPUT OPTIONS
    % ---------------------------------------------------------------------
    cfg.saveFigures = true;
    cfg.saveTables  = true;
    cfg.saveMatFile = true;
end
