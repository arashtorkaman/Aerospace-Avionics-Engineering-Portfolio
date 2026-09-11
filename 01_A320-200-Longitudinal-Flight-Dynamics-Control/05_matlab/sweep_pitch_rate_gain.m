%% PITCH-RATE DAMPER Kq GAIN SWEEP
%
% Sweeps Kq and evaluates:
%   1. closed-loop pole locations,
%   2. maximum real pole,
%   3. approximate short-period damping ratio,
%   4. closed-loop stability.
%
% Control law:
%
%   delta_e = delta_e_cmd - Kq*q
%
% Closed-loop matrix:
%
%   Acl = A - Be*Kq*Cq

clear;
clc;
close all;

fprintf("============================================================\n");
fprintf(" PITCH-RATE DAMPER Kq GAIN SWEEP\n");
fprintf("============================================================\n\n");


%% 1. Load the Phase 1 model

cfg = phase1_config();

model = load_phase1_model(cfg.dataFile);
model = validate_phase1_model(model);

A = model.A;
Be = model.B(:, model.elevator_index);

% q is state number 3:
%
% x = [u; w; q; theta]

Cq = [0 0 1 0];


%% 2. Define Kq sweep

% Start with a moderate design range.
KqValues = linspace(-1.0, 0.15, 300);

numberOfGains = numel(KqValues);


%% 3. Allocate storage

poleReal = zeros(4, numberOfGains);
poleImag = zeros(4, numberOfGains);

maxRealPole = zeros(numberOfGains,1);

shortPeriodZeta = nan(numberOfGains,1);
shortPeriodWn   = nan(numberOfGains,1);

stable = false(numberOfGains,1);


%% 4. Sweep Kq

for k = 1:numberOfGains

    Kq = KqValues(k);

    % Closed-loop matrix
    Acl = A - Be*Kq*Cq;

    % Closed-loop eigenvalues
    lambda = eig(Acl);

    poleReal(:,k) = real(lambda);
    poleImag(:,k) = imag(lambda);

    % Largest real part determines stability margin.
    maxRealPole(k) = max(real(lambda));

    stable(k) = all(real(lambda) < 0);


    % -------------------------------------------------------------
    % Approximate short-period identification
    %
    % Keep only positive-imaginary representatives of complex pairs.
    % If two complex pairs exist, the higher-natural-frequency pair
    % is treated as the short-period mode.
    % -------------------------------------------------------------

    complexIndex = find(imag(lambda) > 1e-8);

    if numel(complexIndex) == 2

        wnCandidates = abs(lambda(complexIndex));

        [~, idxMax] = max(wnCandidates);

        idxSP = complexIndex(idxMax);

        shortPeriodWn(k) = abs(lambda(idxSP));

        shortPeriodZeta(k) = ...
            -real(lambda(idxSP)) / abs(lambda(idxSP));

    end

end


%% 5. Determine stable gain range

stableKq = KqValues(stable);

if isempty(stableKq)

    fprintf("No stable Kq values found in sweep.\n");

else

    fprintf("Stable Kq range in this sweep:\n");
    fprintf("  %.6f <= Kq <= %.6f\n\n", ...
        min(stableKq), ...
        max(stableKq));

end


%% 6. Plot pole migration

figure("Name","Kq Pole Migration");

hold on;
grid on;

for poleNumber = 1:4

    plot( ...
        poleReal(poleNumber,:), ...
        poleImag(poleNumber,:), ...
        ".", ...
        "MarkerSize",8);

end

xline(0,"--");

xlabel("Real(\lambda) [1/s]");
ylabel("Imag(\lambda) [rad/s]");

title("Closed-Loop Pole Migration with Kq");

hold off;


%% 7. Plot maximum real pole versus Kq

figure("Name","Kq Stability Sweep");

plot( ...
    KqValues, ...
    maxRealPole, ...
    "LineWidth",1.5);

grid on;
hold on;

yline(0,"--");

xlabel("K_q");
ylabel("Maximum Real Pole [1/s]");

title("Closed-Loop Stability versus Pitch-Rate Gain");

hold off;


%% 8. Plot short-period damping ratio versus Kq

figure("Name","Kq Damping Sweep");

plot( ...
    KqValues, ...
    shortPeriodZeta, ...
    "LineWidth",1.5);

grid on;

xlabel("K_q");
ylabel("Short-Period Damping Ratio \zeta");

title("Short-Period Damping versus Pitch-Rate Gain");


%% 9. Plot short-period natural frequency

figure("Name","Kq Natural Frequency Sweep");

plot( ...
    KqValues, ...
    shortPeriodWn, ...
    "LineWidth",1.5);

grid on;

xlabel("K_q");
ylabel("\omega_n [rad/s]");

title("Short-Period Natural Frequency versus Pitch-Rate Gain");


%% 10. Create results table

results = table( ...
    KqValues(:), ...
    maxRealPole, ...
    shortPeriodZeta, ...
    shortPeriodWn, ...
    stable, ...
    'VariableNames', { ...
        'Kq', ...
        'MaximumRealPole', ...
        'ShortPeriodDampingRatio', ...
        'ShortPeriodNaturalFrequency_rad_s', ...
        'Stable'});

fprintf("First rows of gain-sweep results:\n\n");

disp(results(1:min(10,height(results)),:));


%% 11. Save results

if ~isfolder(cfg.outputDir)
    mkdir(cfg.outputDir);
end

writetable( ...
    results, ...
    fullfile(cfg.outputDir, ...
    "pitch_rate_gain_sweep.csv"));

fprintf("\nGain sweep complete.\n");
fprintf("Results saved to:\n");
fprintf("  %s\n", cfg.outputDir);