# Independent Numerical Verification — Phase 1 `05_matlab`

## Scope

This check independently reproduces the numerical calculations used by the MATLAB self-test with Python/NumPy/SciPy. It is intentionally separate from the MATLAB implementation.

It verifies the software mathematics and data flow, not the real Phase 1 aircraft data. The real aircraft verification must use the approved `02_data` model.

## Result

**Overall numerical result: PASS**

### Checks

- PASS — A dimension 4x4
- PASS — B dimension 4x1
- PASS — open poles expected
- PASS — open system stable
- PASS — 1 deg -> rad conversion
- PASS — open response shape 201x4
- PASS — open response finite
- PASS — open lsim vs exact solution
- PASS — Acl dimension 4x4
- PASS — closed poles expected
- PASS — closed system stable
- PASS — closed response finite
- PASS — closed lsim vs exact solution

## Open-loop reference results

Synthetic test poles:

- `-0.02 ± j0.20`
- `-1.00 ± j2.00`

Modal quantities:

- Slow pair natural frequency: `0.200997512422 rad/s`
- Slow pair damping ratio: `0.099503719021`
- Slow pair period: `31.415926535898 s`
- Fast pair natural frequency: `2.236067977500 rad/s`
- Fast pair damping ratio: `0.447213595500`
- Fast pair period: `3.141592653590 s`

The software classification therefore correctly assigns:

- lower-frequency pair -> `Phugoid`
- higher-frequency pair -> `Short-period`

For the 1-degree elevator step, the independent exact continuous-time matrix-exponential solution agrees with the SciPy state-space simulation with maximum absolute error:

`2.984e-16`

Final state at `t = 10 s`:

```text
u     = 5.470420191775400e-02
w     = 3.490521493121863e-03
q     = 3.616989821342634e-07
theta = 6.496724308174199e-03
```

## Pitch-rate feedback check

Control law:

`delta_e = delta_e_cmd - Kq*q`

with:

`Cq = [0 0 1 0]`

therefore:

`Acl = A - B*Kq*Cq`

For the synthetic test value `Kq = 1`, the independently calculated closed-loop poles are:

- `-0.02 ± j0.20`
- `-1.50 ± j1.658312395177700`

The independent closed-loop state-space simulation agrees with the exact matrix-exponential solution with maximum absolute error:

`9.021e-17`

## MATLAB robustness correction made during this review

Several diagnostic messages originally used MATLAB string-array construction across multiple lines, for example:

```matlab
["first text" ...
 "second text"]
```

For diagnostic functions such as `error` and `fprintf`, a scalar format/message string is safer. These were changed to scalar concatenation or separate `fprintf` calls.

This does **not** alter the flight-dynamics mathematics. It prevents an error-reporting path from potentially failing because the message itself is a nonscalar string array.

## Strengthened MATLAB self-test

`self_test_05_matlab.m` now also checks:

1. the four independently expected open-loop eigenvalues,
2. the 1-degree-to-radian conversion,
3. an independently generated exact final state at `t = 10 s`,
4. the four independently expected closed-loop eigenvalues.

## Remaining limitation

MATLAB itself is not installed in this execution environment. Therefore this independent test verifies numerical correctness and the implementation equations, but it cannot prove MATLAB parser/runtime compatibility for your particular MATLAB release.

Run the updated MATLAB self-test locally:

```matlab
cd 05_matlab
self_test_05_matlab
```

The expected final status is:

```text
05_matlab SELF-TEST: PASS
```

After that, connect the approved `02_data/phase1_longitudinal_model.mat` and run:

```matlab
run_phase1_analysis
```
