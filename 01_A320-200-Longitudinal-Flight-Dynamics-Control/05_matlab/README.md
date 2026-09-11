# Phase 1 — `05_matlab`

## Longitudinal Aircraft Model Implementation

This folder is the MATLAB implementation layer for Phase 1 of the aerospace engineering portfolio.

It implements the Phase 1 longitudinal state-space model that was defined earlier in the project. The required state order is

```math
x =
\begin{bmatrix}
u & w & q & \theta
\end{bmatrix}^{T}
```

with the linear model

```math
\dot{x} = Ax + B\delta_e
```

where:

- `u` = perturbation in longitudinal/forward velocity,
- `w` = perturbation in vertical body-axis velocity,
- `q` = pitch rate,
- `theta` = pitch attitude,
- `delta_e` = elevator input.

The MATLAB layer does **not** redefine the aircraft. Its job is to load the model created in `03_data`, check it, analyze it, simulate it, and produce repeatable engineering results.

---

## 1. Why the MATLAB folder is separate from `03_data`

A clean engineering project should separate:

1. **Data** — numerical aircraft/model values.
2. **Requirements** — what the model and software must do.
3. **Design** — how the implementation is structured.
4. **Implementation** — executable MATLAB code.
5. **Verification** — evidence that the implementation satisfies the requirements.

This is why the numerical matrices should remain in `03_data` and the analysis algorithms belong in `05_matlab`.

If an aircraft coefficient changes later, you should normally update the data source, not rewrite the analysis algorithms.

---

## 2. Folder contents

```text
05_matlab/
├── README.md
├── DATA_INTERFACE.md
├── CODE_REVIEW.md
├── phase1_config.m
├── run_phase1_analysis.m
├── load_phase1_model.m
├── validate_phase1_model.m
├── build_longitudinal_ss.m
├── analyze_longitudinal_modes.m
├── simulate_elevator_step.m
├── apply_pitch_rate_damper.m
├── plot_poles.m
├── plot_state_response.m
├── save_analysis_outputs.m
└── self_test_05_matlab.m
```

Generated figures and tables are written to:

```text
05_matlab/output/
```

unless `10_results` already exists, in which case the configuration can be changed later to export selected final evidence there.

---

## 3. Required `03_data` file

The main script expects:

```text
03_data/phase1_longitudinal_model.mat
```

The preferred contents are a MATLAB structure named `model`:

```matlab
model.A = ...;              % 4 x 4 state matrix
model.B = ...;              % 4 x m input matrix
model.state_names = ["u","w","q","theta"];
model.state_units = ["m/s","m/s","rad/s","rad"];
model.input_names = ["elevator"];
model.input_units = ["rad"];

save("phase1_longitudinal_model.mat","model");
```

The code also accepts raw variables `A`, `B`, `state_names`,
`state_units`, `input_names`, and `input_units` in the MAT-file.

Do not copy arbitrary example aircraft matrices into the portfolio merely to make the script run. Use the approved Phase 1 values from `03_data`.

---

## 4. First-time execution

### Step 1 — Open MATLAB

Open the project root in MATLAB.

### Step 2 — Confirm the data file exists

Confirm that this file exists:

```text
03_data/phase1_longitudinal_model.mat
```

### Step 3 — Run the software-only self-test

In the MATLAB command window:

```matlab
cd 05_matlab
self_test_05_matlab
```

The self-test uses a synthetic mathematical model only to check the software plumbing. It is **not** aircraft data and must not be presented as the Phase 1 aircraft model.

Expected final line:

```text
05_matlab SELF-TEST: PASS
```

### Step 4 — Run the real Phase 1 analysis

```matlab
run_phase1_analysis
```

---

## 5. What `run_phase1_analysis.m` does

The script performs the following sequence.

### A. Loads configuration

`phase1_config.m` defines:

- the location of the Phase 1 data file,
- simulation duration,
- elevator step magnitude,
- whether figures are saved,
- the optional pitch-rate feedback gain.

### B. Loads the aircraft model

`load_phase1_model.m` reads the MAT-file.

### C. Verifies the model interface

`validate_phase1_model.m` checks:

- `A` is `4 x 4`,
- `B` has four rows,
- all numerical values are finite,
- the state order is exactly `u, w, q, theta`,
- an elevator input can be identified,
- metadata dimensions match matrix dimensions.

These checks are important because a mathematically valid matrix with the wrong state ordering can produce plausible-looking but incorrect results.

### D. Builds the MATLAB state-space object

`build_longitudinal_ss.m` creates:

```matlab
sys = ss(A, Be, C, D);
```

where:

```matlab
C = eye(4);
D = zeros(4,1);
```

This means all four state perturbations are available as outputs.

### E. Computes the poles

The system poles are the eigenvalues of `A`:

```math
\det(\lambda I-A)=0
```

The code computes:

```matlab
lambda = eig(A);
```

For each pole,

```math
\omega_n = |\lambda|
```

and, when $\omega_n \neq 0$,

```math
\zeta = -\frac{\mathrm{Re}(\lambda)}{|\lambda|}
```

For a complex pole,

```math
\lambda = \sigma \pm j\omega_d
```

the damped frequency is

```math
\omega_d = |\mathrm{Im}(\lambda)|
```

and the oscillation period is

```math
T = \frac{2\pi}{\omega_d}.
```

### F. Identifies the longitudinal modes

For a conventional four-state longitudinal model with two oscillatory
complex-conjugate pairs, the code uses natural frequency to distinguish:

- lower-frequency pair → **phugoid**,
- higher-frequency pair → **short-period**.

The program does not force this classification if the pole structure does not support it. In that case it reports the mode as unclassified and leaves the engineering interpretation to the analyst.

This is safer than blindly assigning labels.

### G. Simulates an elevator step

A commanded elevator step is simulated using `lsim`.

The configured command is entered in degrees for readability. The code converts it to the model's declared elevator units.

For example, if `03_data` declares:

```matlab
model.input_units = ["rad"];
```

then:

```math
\delta_{e,\mathrm{rad}}
=
\delta_{e,\mathrm{deg}}\frac{\pi}{180}.
```

The sign convention still comes from the aircraft model. A positive numerical step does not automatically mean aircraft nose-up or nose-down.

### H. Optionally applies pitch-rate feedback

The Phase 1 pitch-rate damper is

```math
\delta_e = \delta_{e,cmd} - K_q q.
```

Because

```math
q = C_qx,
\qquad
C_q =
\begin{bmatrix}
0&0&1&0
\end{bmatrix},
```

the closed-loop state matrix is

```math
A_{cl}=A-B_eK_qC_q.
```

The MATLAB implementation uses this exact equation.

The gain is intentionally left empty by default:

```matlab
cfg.pitchRateGain = [];
```

Enter the gain approved in `04_design` before treating a closed-loop result as a portfolio result.

---

## 6. Why the gain is not guessed automatically

A pitch-rate feedback gain has units and sign conventions that depend on the model.

For example, if:

- elevator is measured in radians,
- pitch rate is measured in rad/s,

then $K_q$ has units of seconds.

If the elevator sign convention changes, the sign of a stabilizing gain may also change.

Therefore this implementation does not silently invent a gain.

That decision is part of engineering traceability: controller values should come from the design process, not from an undocumented number inside an implementation file.

---

## 7. Files you should expect after a successful run

The output folder will contain items such as:

```text
pole_map_open_loop.png
states_open_loop.png
pole_table_open_loop.csv
mode_table_open_loop.csv
phase1_analysis_results.mat
```

If a pitch-rate gain is configured:

```text
states_open_vs_closed_loop.png
pole_table_closed_loop.csv
mode_table_closed_loop.csv
```

These are implementation outputs. Later, `07_verification` should decide whether each result passes a requirement, and `10_results` should contain only selected final presentation-quality evidence.

---

## 8. Beginner interpretation guide

### What does a pole tell you?

A pole describes one natural behavior of the linearized system.

If:

```math
\mathrm{Re}(\lambda)<0,
```

that mode decays with time.

If:

```math
\mathrm{Re}(\lambda)>0,
```

that mode grows with time and is unstable.

If a pole has an imaginary part, the associated motion oscillates.

### What is damping ratio?

The damping ratio tells you how strongly an oscillation decays.

For a stable complex pair:

- small positive `zeta` → lightly damped,
- larger positive `zeta` → faster decay,
- negative `zeta` → unstable growth.

Do not use a single universal damping threshold as a certification claim. Acceptable damping is a requirement/design question and belongs in the applicable requirements and verification artifacts.

### What is the short-period mode?

The short-period mode is normally the higher-frequency longitudinal oscillation. It is strongly associated with angle-of-attack/pitch-rate dynamics and usually occurs on a shorter time scale.

### What is the phugoid mode?

The phugoid is normally the lower-frequency longitudinal oscillation. It involves a slower exchange between kinetic and potential energy and often has lighter damping.

---

## 9. Engineering rules for this folder

1. Do not hard-code aircraft matrices inside plotting functions.
2. Do not change the state order without updating requirements, design, code, and verification.
3. Do not hide unit conversions.
4. Do not label a mode merely because two poles exist; inspect the pole structure.
5. Do not call a controller "verified" because a plot looks good.
6. Keep generated outputs reproducible.
7. Record MATLAB/toolbox versions later in `09_configuration`.
8. Treat this as portfolio/engineering development code, not qualified airborne software.

---

## 10. Recommended MATLAB products

The model analysis uses MATLAB and the Control System Toolbox because the implementation calls `ss` and `lsim`.

You can check your installation with:

```matlab
ver
license("test","Control_Toolbox")
```

---

## 11. Connection to later folders

### `06_simulink`

The same `A`, `B`, state order, units, and elevator convention should be reused in Simulink. Do not create a separate undocumented Simulink aircraft model.

### `07_verification`

Verification should test statements such as:

- data dimensions are correct,
- state order is correct,
- computed poles match an independent calculation,
- step-response execution is repeatable,
- the pitch-rate feedback equation uses the approved gain and sign,
- closed-loop stability or damping requirements are met, if such requirements exist.

### `08_traceability`

Each requirement should eventually map to:

```text
Requirement -> Design -> MATLAB implementation -> Verification test -> Result
```

### `09_configuration`

Record:

- MATLAB release,
- Control System Toolbox release,
- operating system,
- Git commit,
- data-file version/checksum,
- configuration baseline.

### `10_results`

Store only final approved plots/tables that communicate the completed Phase 1 analysis.

---

## 12. Recommended Git commit

After the real Phase 1 data are connected and the self-test passes:

```text
Implement Phase 1 longitudinal MATLAB analysis framework
```

A later commit can record controller results separately:

```text
Add Phase 1 pitch-rate damper analysis
```
