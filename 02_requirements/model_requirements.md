# Model Requirements

**Project:** A320-200 Longitudinal Flight Dynamics and Control  
**Document ID:** REQ-MDL-001  
**Revision:** 0.1  
**Status:** Draft for engineering review  
**Date:** 2026-09-10  

## 1. Purpose

This document defines the requirements for the mathematical and computational longitudinal flight-dynamics model used by the A320-200 Research Model.

These requirements translate the system-level objectives into explicit model behavior, interfaces, equations, numerical conventions, and analysis outputs.

## 2. Requirement Identification

Model requirements use the identifier:

```text
MDL-xxx
```

The model shall conform to:

- `system_requirements.md`;
- `../01_docs/aircraft_definition.md`;
- `../01_docs/coordinate_systems.md`;
- `../01_docs/modeling_assumptions.md`;
- `../01_docs/data_provenance.md`;
- `../01_docs/model_limitations.md`.

## 3. Model Boundary

The initial mathematical scope is a four-state longitudinal small-disturbance model about one nominal trim point.

The state vector shall be

$$
x_L
=
\begin{bmatrix}
\Delta u \\
\Delta w \\
\Delta q \\
\Delta\theta
\end{bmatrix}.
$$

The primary input shall be

$$
u_L=\Delta\delta_e.
$$

## 4. State and Interface Requirements

### MDL-001 — State Ordering

The model shall use the state ordering:

$$
x_L(1)=\Delta u,
$$

$$
x_L(2)=\Delta w,
$$

$$
x_L(3)=\Delta q,
$$

$$
x_L(4)=\Delta\theta.
$$

**Verification:** Interface inspection and automated state-index test.

### MDL-002 — State Units

The model shall use:

- $\Delta u$ in m/s;
- $\Delta w$ in m/s;
- $\Delta q$ in rad/s;
- $\Delta\theta$ in rad.

**Verification:** Unit review.

### MDL-003 — Input Definition

The longitudinal control input shall be elevator perturbation:

$$
\Delta\delta_e
=
\delta_e-\delta_{e0}
$$

in radians.

**Verification:** Interface inspection.

### MDL-004 — Elevator Sign Convention

The model shall use the elevator sign convention defined in `../01_docs/coordinate_systems.md`.

If imported source data uses a different convention, the source value shall be transformed before use.

**Verification:** Provenance and sign-conversion review.

## 5. Parameter Requirements

### MDL-010 — Controlled Parameter Input

The mathematical model shall load numerical aircraft parameters from a controlled parameter dataset rather than redefining aircraft constants independently in multiple analysis scripts.

**Verification:** Code/configuration inspection.

### MDL-011 — Parameter Provenance

Every aircraft-specific numerical parameter used by the model shall trace to a registered source or derivation.

**Verification:** Source-register audit.

### MDL-012 — Parameter Units

Every parameter imported into the computational model shall have defined SI units or shall be explicitly nondimensional.

**Verification:** Parameter-schema inspection.

### MDL-013 — Parameter Applicability

The selected aerodynamic derivative set shall identify, where available:

- aircraft variant;
- flight condition;
- configuration;
- coefficient normalization;
- sign convention.

**Verification:** Source review.

### MDL-014 — Inertia Identification

The pitch moment of inertia $I_y$ used by the model shall be identified as `OEM-PUBLIC`, `LITERATURE`, `DERIVED`, or `ASSUMED`.

**Verification:** Source-register inspection.

## 6. Atmosphere Requirements

### MDL-020 — Atmospheric State

The model shall calculate or import an atmospheric state consistent with the nominal operating altitude.

The atmospheric state shall include, as required:

$$
\rho,\quad
T,\quad
p,\quad
a.
$$

**Verification:** Comparison with an ISA reference calculation.

### MDL-021 — Dynamic Pressure

The model shall calculate dynamic pressure as

$$
\bar{q}
=
\frac{1}{2}\rho V^2.
$$

**Verification:** Independent numerical calculation.

### MDL-022 — Atmosphere Consistency

The same nominal atmospheric state shall be used for trim, aerodynamic force calculation, and dimensional-derivative conversion unless a documented reason requires otherwise.

**Verification:** Parameter/configuration inspection.

## 7. Aerodynamic Model Requirements

### MDL-030 — Aerodynamic Coefficient Representation

The longitudinal aerodynamic model shall represent sufficient aerodynamic coefficient dependence to support trim and small-disturbance linearization.

A candidate lift representation is

$$
C_L
=
C_{L_0}
+
C_{L_\alpha}\alpha
+
C_{L_q}\frac{q\bar{c}}{2V}
+
C_{L_{\delta_e}}\delta_e
$$

with additional terms included only when supported by the selected model source.

**Verification:** Equation/design inspection.

### MDL-031 — Pitching-Moment Representation

The model shall represent pitching-moment coefficient dependence sufficient to support static and dynamic longitudinal stability analysis.

A candidate representation is

$$
C_m
=
C_{m_0}
+
C_{m_\alpha}\alpha
+
C_{m_q}\frac{q\bar{c}}{2V}
+
C_{m_{\delta_e}}\delta_e.
$$

**Verification:** Equation/design inspection.

### MDL-032 — Optional Rate-Derivative Terms

Terms involving $\dot{\alpha}$, including

$$
C_{L_{\dot{\alpha}}}
\qquad\text{or}\qquad
C_{m_{\dot{\alpha}}},
$$

shall be included only if their source definition and implementation convention are understood and documented.

**Verification:** Design review.

### MDL-033 — Aerodynamic Force Calculation

Where coefficient-based forces are used, lift shall be calculated using

$$
L=\bar{q}SC_L.
$$

**Verification:** Independent calculation.

### MDL-034 — Aerodynamic Pitching Moment

Where coefficient-based moments are used, pitching moment shall be calculated using

$$
M=\bar{q}S\bar{c}C_m.
$$

**Verification:** Independent calculation.

### MDL-035 — Wind-to-Body Force Transformation

If lift and drag are calculated in wind axes, the transformation to body-axis force components shall be documented and implemented using the project angle/sign conventions.

**Verification:** Analytical sign and limiting-case tests.

## 8. Trim Model Requirements

### MDL-040 — Equilibrium Condition

The trim model shall solve or verify an equilibrium condition consistent with the chosen nominal flight case.

For steady longitudinal flight, the required equilibrium shall include:

$$
\dot{u}_0 \approx 0,
\qquad
\dot{w}_0 \approx 0,
\qquad
\dot{q}_0 \approx 0.
$$

**Verification:** Trim residual test.

### MDL-041 — Trim Variables

The trim solution shall report, as applicable:

$$
\alpha_0,\quad
\theta_0,\quad
\delta_{e0},\quad
T_0.
$$

**Verification:** Output inspection.

### MDL-042 — Trim Residual Vector

The model shall calculate an explicit trim residual vector:

$$
r_{\mathrm{trim}}
=
f(x_0,u_0).
$$

**Verification:** Automated calculation.

### MDL-043 — Trim Residual Norm

The model shall calculate a documented norm or component-wise acceptance test for $r_{\mathrm{trim}}$.

The acceptance tolerance is defined at system level as `TRIM_RESIDUAL_TOLERANCE`.

**Verification:** Automated threshold test.

### MDL-044 — Trim Failure Handling

If the trim solution does not satisfy the baselined residual criterion, the model shall not classify the operating point as a valid trim point for final linearization results.

**Verification:** Negative test.

## 9. Linearization Requirements

### MDL-050 — Nonlinear Model Form

Where numerical linearization is used, the nonlinear model shall be expressible as

$$
\dot{x}=f(x,u).
$$

**Verification:** Design inspection.

### MDL-051 — Perturbation Definition

Linearization shall be performed about

$$
x=x_0+\Delta x,
\qquad
u=u_0+\Delta u.
$$

**Verification:** Analysis inspection.

### MDL-052 — State Jacobian

The longitudinal state matrix shall correspond to

$$
A_L
=
\left.
\frac{\partial f_L}{\partial x_L}
\right|_{x_0,u_0}
$$

or to an analytically equivalent derivation from dimensional stability derivatives.

**Verification:** Analytical or finite-difference comparison.

### MDL-053 — Input Jacobian

The longitudinal input matrix shall correspond to

$$
B_L
=
\left.
\frac{\partial f_L}{\partial \delta_e}
\right|_{x_0,u_0}
$$

or to an analytically equivalent derivation from control derivatives.

**Verification:** Analytical or finite-difference comparison.

### MDL-054 — Matrix Shape

The baseline model shall produce

$$
A_L\in\mathbb{R}^{4\times4}
$$

and

$$
B_L\in\mathbb{R}^{4\times1}.
$$

**Verification:** Automated dimension test.

### MDL-055 — Kinematic Relationship

For the small-disturbance longitudinal model, the pitch-attitude row shall implement the selected linearized kinematic relationship consistent with

$$
\Delta\dot{\theta}\approx\Delta q
$$

for the baseline approximation.

**Verification:** Matrix inspection and unit test.

### MDL-056 — Gravity Terms

Gravity-coupling terms in the longitudinal matrix shall be derived using the project coordinate and perturbation conventions rather than copied without sign verification.

**Verification:** Analytical review.

### MDL-057 — Dimensional Consistency

Every element of $A_L$ and $B_L$ shall be dimensionally consistent with its corresponding state derivative.

**Verification:** Dimensional-consistency worksheet/test.

## 10. Linearization Validation Requirements

### MDL-060 — Perturbation Comparison

The linearized model shall be compared against its nonlinear or source-reference model for at least one sufficiently small longitudinal perturbation.

**Verification:** Simulation comparison.

### MDL-061 — Linearization Error

For a selected comparison trajectory, model error shall be calculated as

$$
e_x(t)
=
x_{\mathrm{reference}}(t)
-
x_{\mathrm{linear}}(t).
$$

**Verification:** Automated comparison.

### MDL-062 — Validity Range

The project shall document the perturbation magnitude used to demonstrate acceptable linear-model behavior.

**Verification:** Report inspection.

### MDL-063 — Linearization Tolerance

A numerical acceptance criterion for the linear-versus-reference comparison shall be baselined before final validation.

```text
LINEARIZATION_COMPARISON_TOLERANCE = TBD
```

**Verification:** Threshold test.

## 11. Stability Analysis Requirements

### MDL-070 — Eigenvalues

The model shall calculate all eigenvalues of $A_L$:

$$
\lambda_i=\operatorname{eig}(A_L).
$$

**Verification:** Independent solver comparison.

### MDL-071 — Eigenvectors

The model shall calculate eigenvectors or equivalent state-participation information used in mode identification.

**Verification:** Analysis review.

### MDL-072 — Natural Frequency

For each complex mode

$$
\lambda=\sigma\pm j\omega_d,
$$

the model shall calculate

$$
\omega_n
=
\sqrt{\sigma^2+\omega_d^2}.
$$

**Verification:** Independent calculation.

### MDL-073 — Damping Ratio

For each complex mode, the model shall calculate

$$
\zeta
=
-\frac{\sigma}{\omega_n}.
$$

**Verification:** Independent calculation.

### MDL-074 — Damped Frequency

The model shall report

$$
\omega_d=|\operatorname{Im}(\lambda)|.
$$

**Verification:** Independent calculation.

### MDL-075 — Oscillation Period

When $\omega_d>0$, the model shall calculate

$$
T=\frac{2\pi}{\omega_d}.
$$

**Verification:** Independent calculation.

### MDL-076 — Stability Classification

The model shall classify each continuous-time mode as:

- stable when $\operatorname{Re}(\lambda)<0$;
- neutrally stable when $\operatorname{Re}(\lambda)=0$ within numerical tolerance;
- unstable when $\operatorname{Re}(\lambda)>0$.

**Verification:** Automated classification test.

### MDL-077 — Mode Identification Evidence

Short-period and phugoid labels shall not be assigned solely from plotting appearance.

The classification shall use modal frequency, damping, and state participation or equivalent physical evidence.

**Verification:** Engineering review.

## 12. Time-Domain Simulation Requirements

### MDL-080 — Initial Condition Input

The model shall permit defined initial perturbations in each longitudinal state.

**Verification:** Input-interface test.

### MDL-081 — Elevator Input

The model shall permit a defined elevator perturbation profile as an external input.

**Verification:** Input-interface test.

### MDL-082 — State Output

The simulation shall provide time histories for all four longitudinal states.

**Verification:** Output inspection.

### MDL-083 — Simulation Time Vector

Each simulation result shall include a monotonically increasing time vector in seconds.

**Verification:** Automated data-integrity test.

### MDL-084 — Initial-State Reproduction

At simulation time $t=0$, the recorded state shall agree with the defined initial state within numerical tolerance.

**Verification:** Automated test.

## 13. Numerical Implementation Requirements

### MDL-090 — Finite Values

For valid nominal inputs, the model shall not produce `NaN` or infinite state values.

**Verification:** Automated runtime test.

### MDL-091 — Solver Configuration

The solver type, step-size behavior, tolerances, and simulation duration used for baselined results shall be recorded.

**Verification:** Configuration inspection.

### MDL-092 — Deterministic Nominal Results

For identical baselined inputs and deterministic solver settings, repeated executions shall produce numerically consistent nominal results.

**Verification:** Regression test.

### MDL-093 — Parameter Validation

The model shall detect or reject missing required parameters before beginning a baselined analysis.

**Verification:** Negative test.

### MDL-094 — Unit Conversion Location

Source-unit conversions shall occur in a controlled data-ingestion or parameter-loading step rather than being scattered throughout flight-dynamics equations.

**Verification:** Code review.

## 14. MATLAB and Simulink Requirements

### MDL-100 — MATLAB Model

The MATLAB implementation shall provide a reproducible analysis path from parameter loading through state-space generation and stability analysis.

**Verification:** Clean execution test.

### MDL-101 — Simulink Plant

The Simulink model shall implement the same baseline longitudinal state definition and parameter dataset as MATLAB.

**Verification:** Model inspection.

### MDL-102 — Cross-Implementation Test

For equivalent linear plant inputs and initial conditions, MATLAB and Simulink state histories shall be compared using

$$
e_i(t)
=
x_{i,\mathrm{MATLAB}}(t)
-
x_{i,\mathrm{Simulink}}(t).
$$

**Verification:** Automated comparison.

### MDL-103 — Maximum Comparison Error

The comparison shall report

$$
e_{i,\max}
=
\max_t |e_i(t)|
$$

for each modeled state.

**Verification:** Automated calculation.

## 15. Output and Evidence Requirements

### MDL-110 — State-Space Report

The model shall export or document the final baselined $A_L$ and $B_L$ matrices with sufficient numerical precision for independent reproduction.

**Verification:** Output inspection.

### MDL-111 — Modal Analysis Table

The model shall generate a result table containing, as applicable:

- eigenvalue;
- mode classification;
- $\omega_n$;
- $\zeta$;
- $\omega_d$;
- $T$.

**Verification:** Output inspection.

### MDL-112 — Parameter Revision

The model output shall identify the aircraft-parameter baseline or revision used.

**Verification:** Results audit.

## 16. Model TBD Register

| TBD | Description | Closure point |
|---|---|---|
| Nominal operating point | $h_0$, $V_0/M_0$, $m_0$, $x_{CG,0}$ | Before trim-model baseline |
| $I_y$ | Pitch inertia | Before dimensional dynamics baseline |
| Aerodynamic derivative set | Longitudinal coefficient/derivative dataset | Before state-space derivation |
| `TRIM_RESIDUAL_TOLERANCE` | Trim acceptance criterion | Before trim verification |
| `LINEARIZATION_COMPARISON_TOLERANCE` | Linear/reference model agreement criterion | Before linearization validation |
| `MODEL_COMPARISON_TOLERANCE` | MATLAB/Simulink agreement criterion | Before cross-implementation verification |

## 17. Model Verification Summary

The model is not accepted merely because a simulation executes.

Acceptance requires evidence for:

$$
\text{Data}
\rightarrow
\text{Equations}
\rightarrow
\text{Trim}
\rightarrow
A_L,B_L
\rightarrow
\text{Modes}
\rightarrow
\text{Time Response}
\rightarrow
\text{Independent Checks}.
$$
