# `03_data` -> `05_matlab` Interface Contract

This file defines exactly what the MATLAB implementation expects from the Phase 1 data layer.

## Required file

```text
03_data/phase1_longitudinal_model.mat
```

## Preferred variable

The MAT-file should contain one structure called `model`.

Required fields:

```matlab
model.A
model.B
```

Recommended metadata:

```matlab
model.state_names
model.state_units
model.input_names
model.input_units
model.description
model.source
```

## Required state order

The Phase 1 state order is fixed as:

```matlab
["u","w","q","theta"]
```

or equivalently:

```math
x =
\begin{bmatrix}
u&w&q&\theta
\end{bmatrix}^{T}.
```

The software rejects a different named order instead of silently reordering the matrix.

## Matrix dimensions

For four states:

```text
A : 4 x 4
B : 4 x m
```

where `m >= 1`.

If there is only one input, it is treated as elevator.

If there is more than one input, one `input_names` entry must clearly identify the elevator using a name such as:

```text
elevator
delta_e
de
```

## Units

Units should be declared explicitly.

Typical metadata could be:

```matlab
model.state_units = ["m/s","m/s","rad/s","rad"];
model.input_units = ["rad"];
```

These are examples only. Use the units defined by the actual Phase 1 data.

The elevator step simulator currently accepts models whose elevator unit is explicitly declared as either degrees or radians.

## Example file-creation pattern

Replace the placeholders below with the already-approved Phase 1 values from `03_data`.

```matlab
model = struct();

model.A = [ ...
    % Phase 1 values here
];

model.B = [ ...
    % Phase 1 values here
];

model.state_names = ["u","w","q","theta"];
model.state_units = ["YOUR_UNIT","YOUR_UNIT","YOUR_UNIT","YOUR_UNIT"];

model.input_names = ["elevator"];
model.input_units = ["rad"];  % or "deg", according to the actual model

model.description = "Phase 1 linear longitudinal perturbation model";
model.source = "See 03_data documentation";

save("phase1_longitudinal_model.mat","model");
```

Do not use numerical values from the software self-test as aircraft data.
