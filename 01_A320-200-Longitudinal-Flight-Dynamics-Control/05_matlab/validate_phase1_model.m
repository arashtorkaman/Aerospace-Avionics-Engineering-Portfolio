function model = validate_phase1_model(model)
%VALIDATE_PHASE1_MODEL Validate the Phase 1 longitudinal data interface.
%
% INPUT/OUTPUT
%   model - model structure. Metadata defaults may be added.
%
% Checks:
%   * A is finite, real, numeric, and 4 x 4.
%   * B is finite, real, numeric, and has four rows.
%   * State order is [u, w, q, theta].
%   * State/input metadata lengths match matrix dimensions.
%   * Elevator input is identifiable.
%
% The function returns MODEL because it may add missing metadata defaults
% and the resolved field model.elevator_index.

    if ~isstruct(model)
        error("Phase1:ModelNotStruct", ...
            "The loaded Phase 1 model must be a structure.");
    end

    required = ["A","B"];
    for k = 1:numel(required)
        if ~isfield(model, required(k))
            error( ...
                "Phase1:MissingField", ...
                "Required model field '%s' is missing.", ...
                required(k));
        end
    end

    A = model.A;
    B = model.B;

    if ~isnumeric(A) || ~isreal(A) || ~isequal(size(A), [4 4])
        error( ...
            "Phase1:InvalidA", ...
            "model.A must be a real numeric 4 x 4 matrix.");
    end

    if ~all(isfinite(A), "all")
        error( ...
            "Phase1:NonFiniteA", ...
            "model.A contains NaN or Inf.");
    end

    if ~isnumeric(B) || ~isreal(B) || size(B,1) ~= 4 || size(B,2) < 1
        error( ...
            "Phase1:InvalidB", ...
            "model.B must be a real numeric 4 x m matrix with m >= 1.");
    end

    if ~all(isfinite(B), "all")
        error( ...
            "Phase1:NonFiniteB", ...
            "model.B contains NaN or Inf.");
    end

    numberOfInputs = size(B,2);

    % ---------------------------------------------------------------------
    % STATE NAMES
    % ---------------------------------------------------------------------
    requiredStateOrder = ["u","w","q","theta"];

    if ~isfield(model, "state_names") || isempty(model.state_names)
        % The Phase 1 design fixes the state order, so this is a valid
        % documented default when the MAT-file omitted only the labels.
        model.state_names = requiredStateOrder;
        warning( ...
            "Phase1:StateNamesDefaulted", ...
            "state_names missing; using Phase 1 order [u,w,q,theta].");
    else
        stateNames = string(model.state_names);
        stateNames = reshape(stateNames, 1, []);

        if numel(stateNames) ~= 4
             error( ...
               "Phase1:InvalidStateNames", ...
                "state_names must contain exactly four entries.");
        end

        normalized = lower(strtrim(stateNames));

        if ~isequal(normalized, requiredStateOrder)
            error( ...
                "Phase1:WrongStateOrder", ...
                "State order must be exactly [u,w,q,theta]. " + ...
                "Received [%s].", ...
                strjoin(stateNames, ","));
        end

        model.state_names = stateNames;
    end

    % ---------------------------------------------------------------------
    % STATE UNITS
    % ---------------------------------------------------------------------
    if ~isfield(model, "state_units") || isempty(model.state_units)
        model.state_units = repmat("unspecified", 1, 4);
        warning( ...
            "Phase1:StateUnitsMissing", ...
            "state_units missing; plot axes will show 'unspecified'.");
    else
        stateUnits = reshape(string(model.state_units), 1, []);
        if numel(stateUnits) ~= 4
            error( ...
                "Phase1:InvalidStateUnits", ...
                "state_units must contain exactly four entries.");
        end
        model.state_units = stateUnits;
    end

    % ---------------------------------------------------------------------
    % INPUT NAMES
    % ---------------------------------------------------------------------
    if ~isfield(model, "input_names") || isempty(model.input_names)
        if numberOfInputs == 1
            model.input_names = "elevator";
            warning( ...
                "Phase1:InputNameDefaulted", ...
                "Single input found; treating it as elevator.");
        else
            error( ...
                "Phase1:InputNamesRequired", ...
                "B has multiple columns. input_names is required so " + ...
                "the elevator column can be identified.");
        end
    else
        inputNames = reshape(string(model.input_names), 1, []);
        if numel(inputNames) ~= numberOfInputs
            error( ...
                "Phase1:InvalidInputNames", ...
                "input_names must contain one entry for each column " + ...
                "of B.");
        end
        model.input_names = inputNames;
    end

    normalizedInputs = lower(strtrim(string(model.input_names)));

    elevatorMask = ...
        contains(normalizedInputs, "elevator") | ...
        strcmp(normalizedInputs, "delta_e") | ...
        strcmp(normalizedInputs, "de");

    elevatorCandidates = find(elevatorMask);

    if isempty(elevatorCandidates)
        if numberOfInputs == 1
            elevatorCandidates = 1;
            warning( ...
                "Phase1:ElevatorNameNotExplicit", ...
                "Single input used as elevator although its name is '%s'.", ...
                model.input_names(1));
        else
            error( ...
                "Phase1:ElevatorNotFound", ...
                "Could not identify elevator input from input_names.");
        end
    end

    if numel(elevatorCandidates) > 1
        error( ...
            "Phase1:MultipleElevators", ...
            "More than one input is identified as elevator.");
    end

    model.elevator_index = elevatorCandidates(1);

    % ---------------------------------------------------------------------
    % INPUT UNITS
    % ---------------------------------------------------------------------
    if ~isfield(model, "input_units") || isempty(model.input_units)
        model.input_units = repmat("unspecified", 1, numberOfInputs);
        warning( ...
            "Phase1:InputUnitsMissing", ...
            "input_units missing. Elevator-step simulation will refuse " + ...
            "to guess degree/radian conversion.");
    else
        inputUnits = reshape(string(model.input_units), 1, []);
        if numel(inputUnits) ~= numberOfInputs
            error( ...
                "Phase1:InvalidInputUnits", ...
                "input_units must contain one entry for each column " + ...
                "of B.");
        end
        model.input_units = inputUnits;
    end
end
