function model = create_phase1_longitudinal_model()
%CREATE_PHASE1_LONGITUDINAL_MODEL Build 02_data/phase1_longitudinal_model.mat.
%
% DEVELOPMENT STATUS
% ------------------
% This generator uses the controlled aircraft/aerodynamic CSV data, but the
% CSV operating point is currently unresolved. To make the MATLAB analysis
% executable, this version uses an explicit DEVELOPMENT assumption:
%
%   ISA altitude = 10000 m
%   Mach         = 0.78
%   gamma        = 0 rad (straight-and-level trim)
%
% The resulting MAT-file is suitable for software integration and portfolio
% development, but it is NOT a baselined aircraft model until the operating
% point and elevator sign convention are formally reviewed.
%
% The aerodynamic CSV also marks CL_delta_e and Cm_delta_e as
% REQUIRED_BEFORE_USE for sign-convention review. This generator uses their
% stored signs exactly and records that unresolved status in the MAT-file.

    matlabFolder = fileparts(mfilename("fullpath"));
    projectRoot  = fileparts(matlabFolder);
    dataDir = fullfile(projectRoot, "03_data");

    aircraftFile = fullfile(dataDir, "aircraft_parameters.csv");
    aeroFile     = fullfile(dataDir, "aerodynamic_coefficients.csv");
    outputFile   = fullfile(dataDir, "phase1_longitudinal_model.mat");

    assert(isfile(aircraftFile), "Missing %s", aircraftFile);
    assert(isfile(aeroFile), "Missing %s", aeroFile);

    aircraft = readtable(aircraftFile, "TextType", "string");
    aero     = readtable(aeroFile, "TextType", "string");

    % Controlled values from CSV.
    m    = getAircraftValue(aircraft, "mass_kg");
    Iy   = getAircraftValue(aircraft, "Iyy_kgm2");
    S    = getAircraftValue(aircraft, "wing_area_m2");
    cbar = getAircraftValue(aircraft, "mean_aero_chord_m");

    C.CL0   = getAeroValue(aero, "CL0");
    C.CLa   = getAeroValue(aero, "CL_alpha");
    C.Cm0   = getAeroValue(aero, "Cm0");
    C.Cma   = getAeroValue(aero, "Cm_alpha");
    C.CLde  = getAeroValue(aero, "CL_delta_e");
    C.Cmde  = getAeroValue(aero, "Cm_delta_e");
    C.CD0   = getAeroValue(aero, "CD0");
    C.CLq   = getAeroValue(aero, "CL_q");
    C.Cmq   = getAeroValue(aero, "Cm_q");
    C.K     = getAeroValue(aero, "induced_drag_K");

    % ------------------------------------------------------------------
    % EXPLICIT DEVELOPMENT OPERATING POINT
    % ------------------------------------------------------------------
    h0 = 10000.0;  % m
    Mach0 = 0.78;

    % ISA troposphere.
    g = 9.80665;
    R = 287.05287;
    gammaAir = 1.4;
    Tsl = 288.15;
    psl = 101325.0;
    lapse = 0.0065;

    assert(h0 < 11000, ...
        "This simple ISA implementation is limited to h < 11 km.");

    Tatm = Tsl - lapse*h0;
    p = psl*(Tatm/Tsl)^(g/(R*lapse));
    rho = p/(R*Tatm);
    a = sqrt(gammaAir*R*Tatm);
    V0 = Mach0*a;

    % ------------------------------------------------------------------
    % STRAIGHT-AND-LEVEL TRIM
    % ------------------------------------------------------------------
    deltaEFromAlpha = @(alpha) -(C.Cm0 + C.Cma*alpha)/C.Cmde;

    residual = @(alpha) verticalTrimResidual( ...
        alpha, deltaEFromAlpha(alpha), V0, rho, ...
        m, S, cbar, g, C);

    alpha0 = fzero(residual, deg2rad([-5 15]));
    delta_e0 = deltaEFromAlpha(alpha0);
    theta0 = alpha0;

    [X0, Z0, M0aero, CLtrim, CDtrim, Cmtrim] = ...
        aeroForces(alpha0, 0, delta_e0, V0, rho, S, cbar, C);

    Ttrim = m*g*sin(theta0) - X0;

    u0 = V0*cos(alpha0);
    w0 = V0*sin(alpha0);
    x0 = [u0; w0; 0; theta0];

    rhs = @(x,de) longitudinalRHS( ...
        x, de, rho, m, Iy, S, cbar, g, Ttrim, C);

    trimResidual = rhs(x0, delta_e0);

    % ------------------------------------------------------------------
    % NUMERICAL LINEARIZATION
    % State perturbations are [u; w; q; theta].
    % ------------------------------------------------------------------
    A = zeros(4,4);
    for k = 1:4
        dx = 1e-6*max(1, abs(x0(k)));
        xp = x0;
        xm = x0;
        xp(k) = xp(k) + dx;
        xm(k) = xm(k) - dx;
        A(:,k) = (rhs(xp,delta_e0) - rhs(xm,delta_e0))/(2*dx);
    end

    dde = 1e-6;
    B = (rhs(x0,delta_e0+dde) - rhs(x0,delta_e0-dde))/(2*dde);

    % ------------------------------------------------------------------
    % PACKAGE THE EXACT INTERFACE REQUIRED BY 05_matlab
    % ------------------------------------------------------------------
    model = struct();

    model.A = A;
    model.B = B;

    model.state_names = ["u","w","q","theta"];
    model.state_units = ["m/s","m/s","rad/s","rad"];
    model.input_names = ["elevator"];
    model.input_units = ["rad"];

    model.description = ...
        "A320-200 Phase 1 linear longitudinal perturbation model; " + ...
        "PROVISIONAL DEVELOPMENT MODEL";

    model.source = ...
        "02_data/aircraft_parameters.csv and " + ...
        "02_data/aerodynamic_coefficients.csv; SRC-LIT-UPV-001";

    model.model_status = "PROVISIONAL_DEVELOPMENT_ONLY";

    model.operating_point_status = ...
        "ASSUMED: ISA altitude 10000 m, Mach 0.78; " + ...
        "not supplied by controlled CSV";

    model.elevator_sign_status = ...
        "UNRESOLVED_REVIEW_REQUIRED: CSV marks elevator derivatives " + ...
        "REQUIRED_BEFORE_USE";

    model.flight_condition = struct( ...
        "altitude_m", h0, ...
        "mach", Mach0, ...
        "true_airspeed_mps", V0, ...
        "density_kg_m3", rho, ...
        "temperature_K", Tatm, ...
        "pressure_Pa", p, ...
        "speed_of_sound_mps", a);

    model.trim = struct( ...
        "alpha_trim_rad", alpha0, ...
        "theta_trim_rad", theta0, ...
        "delta_e_trim_rad", delta_e0, ...
        "thrust_trim_N", Ttrim, ...
        "CL_trim", CLtrim, ...
        "CD_trim", CDtrim, ...
        "Cm_trim", Cmtrim, ...
        "u0_body_mps", u0, ...
        "w0_body_mps", w0, ...
        "rhs_residual", trimResidual);

    model.linearization_method = ...
        "Central finite-difference Jacobian about solved trim.";

    model.modeling_assumptions = [ ...
        "Standard body axes: x forward, z down"; ...
        "Straight-and-level trim, gamma = 0"; ...
        "ISA atmosphere at assumed operating point"; ...
        "Thrust held constant during perturbation linearization"; ...
        "CD = CD0 + K*CL^2"; ...
        "CL_alpha_dot and Cm_alpha_dot omitted pending review"; ...
        "Elevator derivative signs used exactly as stored in CSV"];

    save(outputFile, "model");

    fprintf("\nCreated:\n  %s\n\n", outputFile);
    fprintf("Status: %s\n", model.model_status);
    fprintf("A size: %d x %d\n", size(A,1), size(A,2));
    fprintf("B size: %d x %d\n", size(B,1), size(B,2));
    fprintf("Max trim residual: %.3e\n", max(abs(trimResidual)));
    fprintf("Open-loop poles:\n");
    disp(eig(A));
end


function value = getAircraftValue(T, name)
    idx = string(T.matlab_name) == name;
    assert(nnz(idx) == 1, ...
        "Expected exactly one aircraft parameter named '%s'.", name);

    value = T.value_numeric(idx);
    assert(isfinite(value), ...
        "Aircraft parameter '%s' is unresolved in the CSV.", name);
end


function value = getAeroValue(T, name)
    idx = string(T.matlab_name) == name;
    assert(nnz(idx) == 1, ...
        "Expected exactly one aerodynamic coefficient named '%s'.", name);

    value = T.value(idx);
    assert(isfinite(value), ...
        "Aerodynamic coefficient '%s' is unresolved in the CSV.", name);
end


function r = verticalTrimResidual( ...
    alpha, de, V, rho, m, S, cbar, g, C)

    [~, Z] = aeroForces(alpha, 0, de, V, rho, S, cbar, C);
    r = Z/m + g*cos(alpha);
end


function [X,Z,M,CL,CD,Cm] = aeroForces( ...
    alpha, q, de, V, rho, S, cbar, C)

    qbar = 0.5*rho*V^2;
    qhat = q*cbar/(2*V);

    CL = C.CL0 + C.CLa*alpha + C.CLq*qhat + C.CLde*de;
    CD = C.CD0 + C.K*CL^2;
    Cm = C.Cm0 + C.Cma*alpha + C.Cmq*qhat + C.Cmde*de;

    L = qbar*S*CL;
    D = qbar*S*CD;
    M = qbar*S*cbar*Cm;

    % Standard body axes: x forward, z down.
    X = -D*cos(alpha) + L*sin(alpha);
    Z = -D*sin(alpha) - L*cos(alpha);
end


function xdot = longitudinalRHS( ...
    x, de, rho, m, Iy, S, cbar, g, Ttrim, C)

    U = x(1);
    W = x(2);
    q = x(3);
    theta = x(4);

    V = hypot(U,W);
    alpha = atan2(W,U);

    [Xaero, Zaero, M] = ...
        aeroForces(alpha, q, de, V, rho, S, cbar, C);

    Xtotal = Xaero + Ttrim;

    xdot = zeros(4,1);
    xdot(1) = -q*W + Xtotal/m - g*sin(theta);
    xdot(2) =  q*U + Zaero/m + g*cos(theta);
    xdot(3) = M/Iy;
    xdot(4) = q;
end
