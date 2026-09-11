function sys = build_longitudinal_ss(model)
%BUILD_LONGITUDINAL_SS Create state-space model from validated Phase 1 data.
%
% INPUT
%   model - validated model structure
%
% OUTPUT
%   sys   - MATLAB state-space object from elevator to all four states
%
% The input is the elevator column of B.
% Outputs are [u, w, q, theta].

    if exist("ss", "file") ~= 2
        error( ...
            "Phase1:ControlToolboxRequired", ...
            "MATLAB function 'ss' was not found. " + ...
            "Control System Toolbox is required for this analysis.");
    end

    A  = model.A;
    Be = model.B(:, model.elevator_index);

    C = eye(4);
    D = zeros(4,1);

    sys = ss(A, Be, C, D);

    % Add labels when the MATLAB release supports these properties.
    try
        sys.StateName  = cellstr(model.state_names);
        sys.OutputName = cellstr(model.state_names);
        sys.InputName  = cellstr(model.input_names(model.elevator_index));
    catch
        % Labels are helpful metadata but are not required for the
        % mathematical calculation.
    end
end
