%% 05_MATLAB SOFTWARE SELF-TEST
%
% PURPOSE
% This test checks the MATLAB implementation with a synthetic stable
% four-state system.
%
% IMPORTANT
% The numerical values below are NOT aircraft data.
% They exist only to exercise the software functions.
%
% A successful self-test does not verify the Phase 1 aircraft model.
% Aircraft verification belongs in 07_verification.


clear;
clc;
close all;

fprintf("============================================================\n");
fprintf(" 05_matlab SOFTWARE SELF-TEST\n");
fprintf("============================================================\n\n");

%% 1. Synthetic two-mode mathematical model
%
% State labels use the Phase 1 interface [u,w,q,theta], but the numbers
% are deliberately synthetic.
%
% This A matrix contains:
%   low-frequency pair  approximately -0.02 +/- j0.20
%   high-frequency pair approximately -1.00 +/- j2.00

model = struct();

model.A = [ ...
     0.0000,  0.0000,  0.0000,  1.0000; ...
     0.0000,  0.0000,  1.0000,  0.0000; ...
     0.0000, -5.0000, -2.0000,  0.0000; ...
    -0.0404,  0.0000,  0.0000, -0.0400];

model.B = [ ...
    0.0; ...
    0.0; ...
    1.0; ...
    0.1];

model.state_names = ["u","w","q","theta"];
model.state_units = ["test","test","test","test"];
model.input_names = ["elevator"];
model.input_units = ["rad"];

%% 2. Interface validation

model = validate_phase1_model(model);

assert(isequal(size(model.A), [4 4]));
assert(isequal(size(model.B), [4 1]));
assert(model.elevator_index == 1);

fprintf("Interface validation: PASS\n");

%% 3. Open-loop state-space construction

sysOpen = build_longitudinal_ss(model);

assert(size(sysOpen.A,1) == 4);
assert(size(sysOpen.B,2) == 1);

fprintf("State-space construction: PASS\n");

%% 4. Modal calculation

analysisOpen = analyze_longitudinal_modes(model.A);

assert(numel(analysisOpen.Poles) == 4);
assert(height(analysisOpen.ModeTable) == 2);
assert(analysisOpen.IsAsymptoticallyStable);

modeNames = string(analysisOpen.ModeTable.Mode);
assert(any(modeNames == "Phugoid"));
assert(any(modeNames == "Short-period"));

fprintf("Modal analysis: PASS\n");

% Independent expected eigenvalues for the synthetic A matrix.
% Eigenvalue ordering is not assumed.
expectedOpenPoles = [ ...
    -0.02 + 0.20i; ...
    -0.02 - 0.20i; ...
    -1.00 + 2.00i; ...
    -1.00 - 2.00i];

for k = 1:numel(expectedOpenPoles)
    assert(any(abs(analysisOpen.Poles - expectedOpenPoles(k)) < 1e-10));
end

fprintf("Independent open-loop pole check: PASS\n");


%% 5. Elevator-step simulation

responseOpen = simulate_elevator_step( ...
    sysOpen, ...
    model, ...
    1.0, ...
    10.0, ...
    201);

assert(numel(responseOpen.time_s) == 201);
assert(isequal(size(responseOpen.states), [201 4]));
assert(all(isfinite(responseOpen.states), "all"));

fprintf("Elevator-step simulation: PASS\n");

% Verify the 1-degree command was converted to radians.
expectedCommandRad = pi / 180;
assert(max(abs(responseOpen.command_model_units - expectedCommandRad)) < 1e-12);

% Independent reference value generated from the exact continuous-time
% matrix-exponential solution for this synthetic system at t = 10 s.
expectedFinalState = [ ...
    5.470420191775400e-02, ...
    3.490521493121863e-03, ...
    3.616989821342634e-07, ...
    6.496724308174199e-03];

assert(max(abs(responseOpen.states(end,:) - expectedFinalState)) < 1e-10);

fprintf("Independent step-response check: PASS\n");


%% 6. Pitch-rate feedback equation

Kq = 1.0;
closedLoop = apply_pitch_rate_damper(model, Kq);

CqExpected = [0 0 1 0];
AclExpected = model.A - model.B * Kq * CqExpected;

difference = closedLoop.Acl - AclExpected;

assert(max(abs(difference), [], "all") < 1e-12);

fprintf("Pitch-rate feedback equation: PASS\n");

%% 7. Closed-loop modal calculation

analysisClosed = analyze_longitudinal_modes(closedLoop.Acl);

assert(numel(analysisClosed.Poles) == 4);
assert(all(isfinite(real(analysisClosed.Poles))));
assert(all(isfinite(imag(analysisClosed.Poles))));

fprintf("Closed-loop calculation: PASS\n");

expectedClosedPoles = [ ...
    -0.02 + 0.20i; ...
    -0.02 - 0.20i; ...
    -1.50 + 1.658312395177700i; ...
    -1.50 - 1.658312395177700i];

for k = 1:numel(expectedClosedPoles)
    assert(any(abs(analysisClosed.Poles - expectedClosedPoles(k)) < 1e-10));
end

fprintf("Independent closed-loop pole check: PASS\n\n");


fprintf("05_matlab SELF-TEST: PASS\n");
fprintf("Reminder: this verifies software plumbing only. ");
fprintf("It does not verify aircraft data or requirements.\n");
