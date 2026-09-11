function analysis = analyze_longitudinal_modes(A)
%ANALYZE_LONGITUDINAL_MODES Compute poles and classify oscillatory modes.
%
% INPUT
%   A - 4 x 4 longitudinal state matrix
%
% OUTPUT
%   analysis - structure containing pole and mode tables
%
% For each pole lambda:
%   natural frequency  wn   = abs(lambda)
%   damping ratio      zeta = -real(lambda)/abs(lambda)
%   damped frequency   wd   = abs(imag(lambda))
%
% For a conventional 4-state model with exactly two complex-conjugate
% pairs:
%   lower wn  -> phugoid
%   higher wn -> short-period
%
% If this pole pattern does not exist, no forced classification is made.

    if ~isnumeric(A) || ~isequal(size(A), [4 4])
        error("Phase1:ModeAnalysisInvalidA", ...
            "A must be a numeric 4 x 4 matrix.");
    end

    lambda = eig(A);

    wn = abs(lambda);
    zeta = nan(size(lambda));
    nonzero = wn > eps;
    zeta(nonzero) = -real(lambda(nonzero)) ./ wn(nonzero);

    wd = abs(imag(lambda));

    periodSec = nan(size(lambda));
    oscillatory = wd > 1e-10;
    periodSec(oscillatory) = 2*pi ./ wd(oscillatory);

    timeConstantSec = inf(size(lambda));
    nonzeroReal = abs(real(lambda)) > 1e-12;
    timeConstantSec(nonzeroReal) = -1 ./ real(lambda(nonzeroReal));

    stablePole = real(lambda) < 0;

    poleNumber = (1:numel(lambda)).';

    analysis.PoleTable = table( ...
        poleNumber, ...
        real(lambda), ...
        imag(lambda), ...
        wn, ...
        zeta, ...
        wd, ...
        periodSec, ...
        timeConstantSec, ...
        stablePole, ...
        'VariableNames', { ...
            'PoleNumber', ...
            'RealPart', ...
            'ImagPart', ...
            'NaturalFrequency_rad_s', ...
            'DampingRatio', ...
            'DampedFrequency_rad_s', ...
            'OscillationPeriod_s', ...
            'TimeConstant_s', ...
            'StablePole'});

    analysis.Poles = lambda;
    analysis.IsAsymptoticallyStable = all(real(lambda) < 0);

    % ---------------------------------------------------------------------
    % MODE CLASSIFICATION
    % ---------------------------------------------------------------------
    % Keep only one pole from each complex conjugate pair: imag(lambda)>0.
    positiveImagIndex = find(imag(lambda) > 1e-10);

    modeNames = strings(0,1);
    modePoles = complex(zeros(0,1));
    modeWn = zeros(0,1);
    modeZeta = zeros(0,1);
    modeWd = zeros(0,1);
    modePeriod = zeros(0,1);

    if numel(positiveImagIndex) == 2
        pairWn = wn(positiveImagIndex);
        [~, order] = sort(pairWn, "ascend");
        orderedIndex = positiveImagIndex(order);

        labels = ["Phugoid"; "Short-period"];

        for k = 1:2
            idx = orderedIndex(k);
            modeNames(end+1,1) = labels(k); %#ok<AGROW>
            modePoles(end+1,1) = lambda(idx); %#ok<AGROW>
            modeWn(end+1,1) = wn(idx); %#ok<AGROW>
            modeZeta(end+1,1) = zeta(idx); %#ok<AGROW>
            modeWd(end+1,1) = wd(idx); %#ok<AGROW>
            modePeriod(end+1,1) = periodSec(idx); %#ok<AGROW>
        end
    else
        % Report oscillatory modes without claiming phugoid/short-period.
        for k = 1:numel(positiveImagIndex)
            idx = positiveImagIndex(k);
            modeNames(end+1,1) = "Unclassified oscillatory mode"; %#ok<AGROW>
            modePoles(end+1,1) = lambda(idx); %#ok<AGROW>
            modeWn(end+1,1) = wn(idx); %#ok<AGROW>
            modeZeta(end+1,1) = zeta(idx); %#ok<AGROW>
            modeWd(end+1,1) = wd(idx); %#ok<AGROW>
            modePeriod(end+1,1) = periodSec(idx); %#ok<AGROW>
        end
    end

    if isempty(modeNames)
        analysis.ModeTable = table();
    else
        analysis.ModeTable = table( ...
            modeNames, ...
            real(modePoles), ...
            imag(modePoles), ...
            modeWn, ...
            modeZeta, ...
            modeWd, ...
            modePeriod, ...
            'VariableNames', { ...
                'Mode', ...
                'PoleRealPart', ...
                'PoleImagPart', ...
                'NaturalFrequency_rad_s', ...
                'DampingRatio', ...
                'DampedFrequency_rad_s', ...
                'OscillationPeriod_s'});
    end
end
