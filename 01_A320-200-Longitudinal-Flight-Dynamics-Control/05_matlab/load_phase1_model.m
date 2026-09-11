function model = load_phase1_model(dataFile)
%LOAD_PHASE1_MODEL Load the Phase 1 longitudinal model from 02_data.
%
% INPUT
%   dataFile - full path to phase1_longitudinal_model.mat
%
% OUTPUT
%   model - structure containing at least A and B
%
% The MAT-file may contain:
%   (1) one structure named "model", or
%   (2) raw variables A, B, and optional metadata.
%
% This function deliberately does not create fallback aircraft numbers.
% Missing project data should be corrected in 02_data.

    arguments
        dataFile (1,1) string
    end

    if ~isfile(dataFile)
        error( ...
            "Phase1:DataFileMissing", ...
            "Phase 1 data file not found:\n  %s\n\n" + ...
            "Expected file:\n" + ...
            "  02_data/phase1_longitudinal_model.mat\n\n" + ...
            "Create/export this MAT-file from the approved 02_data " + ...
            "artifact before running the real Phase 1 analysis.", ...
            dataFile);
    end

    raw = load(dataFile);

    if isfield(raw, "model")
        if ~isstruct(raw.model)
            error( ...
                "Phase1:InvalidModelVariable", ...
                'Variable "model" exists but is not a structure.');
        end
        model = raw.model;
    else
        model = struct();

        if isfield(raw, "A")
            model.A = raw.A;
        end

        if isfield(raw, "B")
            model.B = raw.B;
        end

        optionalFields = [ ...
            "state_names", ...
            "state_units", ...
            "input_names", ...
            "input_units", ...
            "description", ...
            "source"];

        for k = 1:numel(optionalFields)
            name = optionalFields(k);
            if isfield(raw, name)
                model.(name) = raw.(name);
            end
        end
    end

    model.data_file = dataFile;
end
