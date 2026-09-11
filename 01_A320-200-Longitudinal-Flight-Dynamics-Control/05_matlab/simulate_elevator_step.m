function response = simulate_elevator_step( ...
    sys, model, stepDeg, simulationTimeSec, numberOfSamples)
%SIMULATE_ELEVATOR_STEP Simulate response to an elevator step command.
%
% INPUTS
%   sys               - state-space system from elevator to all states
%   model             - validated model structure
%   stepDeg           - requested elevator step, expressed in degrees
%   simulationTimeSec - final simulation time [s]
%   numberOfSamples   - number of time samples
%
% OUTPUT
%   response - structure containing time, command, states, and units
%
% IMPORTANT:
% The function converts the human-readable degree command into the
% elevator units declared by model.input_units. It does not guess units.

    if exist("lsim", "file") ~= 2
        error( ...
            "Phase1:ControlToolboxRequired", ...
            "MATLAB function 'lsim' was not found. " + ...
            "Control System Toolbox is required.");
    end

    if ~isscalar(stepDeg) || ~isfinite(stepDeg)
        error("Phase1:InvalidStep", ...
            "stepDeg must be one finite scalar.");
    end

    if ~isscalar(simulationTimeSec) || ...
            ~isfinite(simulationTimeSec) || simulationTimeSec <= 0
        error("Phase1:InvalidSimulationTime", ...
            "simulationTimeSec must be a positive finite scalar.");
    end

    if ~isscalar(numberOfSamples) || ...
            numberOfSamples < 2 || ...
            numberOfSamples ~= floor(numberOfSamples)
        error("Phase1:InvalidSampleCount", ...
            "numberOfSamples must be an integer >= 2.");
    end

    elevatorUnit = lower(strtrim( ...
        string(model.input_units(model.elevator_index))));

    switch elevatorUnit
        case {"rad","radian","radians"}
            stepModelUnits = deg2rad(stepDeg);

        case {"deg","degree","degrees"}
            stepModelUnits = stepDeg;

        otherwise
            error( ...
                "Phase1:UnknownElevatorUnit", ...
                "Elevator unit is '%s'. Declare it as degrees or " + ...
                "radians in 02_data before step simulation.", ...
                elevatorUnit);
    end

    t = linspace(0, simulationTimeSec, numberOfSamples).';
    command = stepModelUnits * ones(size(t));

    [y, tOut, x] = lsim(sys, command, t);

    response = struct();
    response.time_s = tOut;
    response.command_model_units = command;
    response.command_deg = stepDeg;
    response.states = y;
    response.internal_states = x;
    response.state_names = model.state_names;
    response.state_units = model.state_units;
    response.elevator_unit = model.input_units(model.elevator_index);
end
