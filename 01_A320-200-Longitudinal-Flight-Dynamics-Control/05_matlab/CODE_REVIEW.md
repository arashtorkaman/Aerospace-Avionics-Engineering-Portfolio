# `05_matlab` — Two-Pass Code Review Record

This record documents the two requested review passes performed when the folder was created.

It is an implementation review record, not a substitute for the formal verification work that will belong in `07_verification`.

---

## Review Pass 1 — Mathematical and interface correctness

### State vector

Confirmed that the code consistently uses:

$$
x =
\begin{bmatrix}
u&w&q&\theta
\end{bmatrix}^{T}.
$$

### Linear state equation

Confirmed:

$$
\dot{x}=Ax+B\delta_e.
$$

### Dimensions

Confirmed:

```text
A    : 4 x 4
B    : 4 x m
Be   : 4 x 1
C    : 4 x 4
D    : 4 x 1
Cq   : 1 x 4
Kq   : scalar
Acl  : 4 x 4
```

For the pitch-rate damper:

```matlab
Acl = A - Be*Kq*Cq;
```

Dimension check:

```text
(4 x 1)(1 x 1)(1 x 4) = 4 x 4
```

therefore subtraction from `A` is dimensionally valid.

### Feedback sign

Starting with:

$$
\delta_e=\delta_{e,cmd}-K_q q
$$

and:

$$
q=C_qx,
$$

then:

$$
\dot{x}
=
Ax+B_e(\delta_{e,cmd}-K_qC_qx)
$$

which gives:

$$
\dot{x}
=
(A-B_eK_qC_q)x+B_e\delta_{e,cmd}.
$$

Therefore the implemented closed-loop matrix

```matlab
Acl = A - Be*Kq*Cq;
```

is algebraically correct for the stated control law.

### Pole calculations

Confirmed:

$$
\omega_n=|\lambda|
$$

and:

$$
\zeta=-\frac{\operatorname{Re}(\lambda)}{|\lambda|}.
$$

Confirmed that the code avoids division by zero for a zero pole.

### Damped frequency and period

Confirmed:

$$
\omega_d=|\operatorname{Im}(\lambda)|
$$

and for an oscillatory mode:

$$
T=\frac{2\pi}{\omega_d}.
$$

### Time constant

For a pole with nonzero real part, the code uses:

$$
\tau=-\frac{1}{\operatorname{Re}(\lambda)}.
$$

For stable poles with negative real part, this produces a positive decay time constant.

### Mode classification

The implementation classifies phugoid/short-period only when the four-state model contains exactly two positive-imaginary representatives of two complex-conjugate pairs.

The lower-natural-frequency pair is labeled phugoid and the higher-natural-frequency pair is labeled short-period.

The code does not force this classification for another pole structure.

### Elevator units

Confirmed that a degree command is converted to radians only when the data interface declares the elevator input in radians.

Unknown elevator units produce an error instead of an undocumented conversion.

### Data separation

Confirmed that no Phase 1 aircraft numerical matrix is hard-coded into the real analysis path.

The only embedded numerical model is in `self_test_05_matlab.m`, where it is repeatedly identified as synthetic software-test data.

---

## Review Pass 2 — MATLAB implementation and defensive checks

### Main-script flow

Reviewed the execution sequence:

```text
configuration
-> load
-> validate
-> build state-space
-> analyze
-> simulate
-> plot
-> save
-> optional feedback analysis
```

No controller analysis is run when `cfg.pitchRateGain` is empty.

### Input validation

Reviewed checks for:

- missing MAT-file,
- missing `A` or `B`,
- wrong matrix dimensions,
- NaN/Inf values,
- wrong state order,
- metadata length mismatch,
- unidentified elevator input,
- invalid pitch-rate gain,
- ambiguous elevator units,
- invalid simulation time/sample count.

### Matrix indexing

Confirmed that the elevator input is extracted as:

```matlab
Be = model.B(:, model.elevator_index);
```

This preserves a `4 x 1` column vector.

### State-space output dimensions

Confirmed:

```matlab
C = eye(4);
D = zeros(4,1);
```

so all four states are outputs and there is one selected elevator input.

### Response dimensions

`lsim` output is expected to be:

```text
N x 4
```

which is checked by the plotting function and by the self-test.

### File-output behavior

The output directory is created only when needed.

Tables and figures use distinct open-loop/closed-loop prefixes, reducing accidental overwriting.

### Native MATLAB runtime status

A native MATLAB executable was not available in the artifact-generation environment, so the code was not executed by MATLAB here.

To close that environment-specific gap, run:

```matlab
self_test_05_matlab
```

inside your installed MATLAB before committing the folder.

The supplied self-test verifies the interfaces, state-space construction, modal analysis, response shape, and the exact matrix equation used for pitch-rate feedback.

---

## Independent numerical cross-check

The synthetic self-test matrix was independently evaluated outside MATLAB. Its open-loop eigenvalues are:

```text
-0.02 + j0.20
-0.02 - j0.20
-1.00 + j2.00
-1.00 - j2.00
```

Therefore the lower-frequency pair is correctly selected as the phugoid test pair and the higher-frequency pair as the short-period test pair.

For the software-test gain `Kq = 1.0`, the high-frequency pair moves to approximately:

```text
-1.50 + j1.6583
-1.50 - j1.6583
```

while the low-frequency pair remains `-0.02 +/- j0.20` for this deliberately decoupled synthetic test system. This independently confirms the sign and matrix multiplication used by the feedback implementation.

This cross-check is intentionally separate from the real aircraft dataset.

---

## Status

Two review passes completed:

1. mathematical/interface review,
2. MATLAB/defensive-programming review.

Remaining project verification belongs in `07_verification` and must use the actual approved `02_data` values and the applicable Phase 1 requirements.


---

## Independent Python numerical execution

The synthetic MATLAB self-test mathematics were independently reimplemented using NumPy/SciPy and also compared against a direct continuous-time matrix-exponential solution.

Results:

- expected open-loop poles: PASS,
- phugoid/short-period frequency ordering: PASS,
- degree/radian conversion: PASS,
- open-loop state response: PASS,
- pitch-rate feedback matrix equation: PASS,
- expected closed-loop poles: PASS,
- closed-loop state response: PASS.

Maximum absolute discrepancy between the state-space simulation and the independent exact solution:

```text
Open loop : 2.984e-16
Closed loop: 9.021e-17
```

A MATLAB diagnostic-string robustness issue was also corrected during this pass. See `PYTHON_NUMERICAL_VERIFICATION.md`.
