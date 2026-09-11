function closedLoop = apply_pitch_rate_damper(model, Kq)
%APPLY_PITCH_RATE_DAMPER Apply Phase 1 pitch-rate feedback.
%
% Control law:
%
%       delta_e = delta_e_cmd - Kq*q
%
% with:
%
%       q = Cq*x
%       Cq = [0 0 1 0]
%
% Therefore:
%
%       Acl = A - Be*Kq*Cq
%
% INPUTS
%   model - validated model structure
%   Kq    - scalar pitch-rate feedback gain
%
% OUTPUT
%   closedLoop - structure containing Acl, Cq, Kq, and state-space model
%
% No sign correction is hidden in this function. Kq must follow the
% sign convention established in the Phase 1 design and data.

    if ~isscalar(Kq) || ~isnumeric(Kq) || ~isreal(Kq) || ~isfinite(Kq)
        error("Phase1:InvalidKq", ...
            "Kq must be one finite real scalar.");
    end

    if exist("ss", "file") ~= 2
        error( ...
            "Phase1:ControlToolboxRequired", ...
            "Control System Toolbox is required.");
    end

    A  = model.A;
    Be = model.B(:, model.elevator_index);

    Cq = [0 0 1 0];

    Acl = A - Be * Kq * Cq;

    C = eye(4);
    D = zeros(4,1);

    sys = ss(Acl, Be, C, D);

    try
        sys.StateName  = cellstr(model.state_names);
        sys.OutputName = cellstr(model.state_names);
        sys.InputName  = {"elevator_command"};
    catch
    end

    closedLoop = struct();
    closedLoop.Kq = Kq;
    closedLoop.Cq = Cq;
    closedLoop.Acl = Acl;
    closedLoop.sys = sys;
end
