# Control Requirements

**Project:** A320-200 Longitudinal Flight Dynamics and Control  
**Document ID:** REQ-CTL-001  
**Revision:** 0.1  
**Status:** Draft for engineering review  
**Date:** 2026-09-10  

## 1. Purpose

This document defines the requirements for the research pitch-rate damping controller applied to the A320-200 Research Model.

The controller is intended to demonstrate requirements-based control-law development, gain selection, constraint handling, closed-loop stability analysis, implementation consistency, and verification.

It is **not** intended to reproduce Airbus production fly-by-wire control laws.

## 2. Requirement Identification

Control requirements use the identifier:

```text
CTL-xxx
```

These requirements are subordinate to the applicable system requirements and use the coordinate/sign conventions defined in:

- [`../01_docs/coordinate_systems.md`](../01_docs/coordinate_systems.md)
- [`../01_docs/modeling_assumptions.md`](../01_docs/modeling_assumptions.md)
- [`../01_docs/model_limitations.md`](../01_docs/model_limitations.md)

## 3. Control-System Boundary

The baseline pitch-rate damper receives pitch-rate perturbation and produces an incremental equivalent elevator command.

The conceptual relationship is

```math
\Delta\delta_{e,\mathrm{damp}}
=
K_q\Delta q,
```

where $K_q$ is a **signed design gain**.

The sign of $K_q$ shall be selected from the adopted aircraft/control sign convention and verified by closed-loop response. This document intentionally does not assume a positive numerical $K_q$ corresponds to negative feedback.

The total elevator perturbation may be represented as

```math
\Delta\delta_{e,\mathrm{total}}
=
\Delta\delta_{e,\mathrm{pilot/cmd}}
+
\Delta\delta_{e,\mathrm{damp}}.
```

For disturbance-rejection tests, the external command may be set to zero.

## 4. Functional Requirements

### CTL-001 — Pitch-Rate Input

The pitch-rate damper shall use longitudinal pitch-rate perturbation

```math
\Delta q
```

as its feedback input.

**Verification:** Interface inspection.

### CTL-002 — Elevator-Correction Output

The pitch-rate damper shall produce an incremental equivalent elevator command

```math
\Delta\delta_{e,\mathrm{damp}}.
```

**Verification:** Interface inspection.

### CTL-003 — Linear Feedback Law

Before saturation or actuator dynamics are applied, the baseline damping command shall be calculated as

```math
\Delta\delta_{e,\mathrm{damp}}
=
K_q\Delta q.
```

**Verification:** Unit test with analytically calculated inputs.

### CTL-004 — Zero-Input Behavior

For

```math
\Delta q=0,
```

the unsaturated pitch-damping correction shall satisfy

```math
\Delta\delta_{e,\mathrm{damp}}=0.
```

**Verification:** Unit test.

### CTL-005 — Signed Gain Definition

The controller configuration shall store $K_q$ as a signed quantity in units consistent with

```math
\frac{\mathrm{rad\ of\ elevator}}
{\mathrm{rad/s\ of\ pitch\ rate}}
=
\mathrm{s}.
```

**Verification:** Design and unit review.

### CTL-006 — Feedback Direction

The selected gain sign shall produce a control-induced pitching-moment tendency that opposes the pitch-rate perturbation for the nominal aircraft model.

The verification shall demonstrate damping action for both positive and negative $\Delta q$.

**Verification:** Positive/negative disturbance tests.

## 5. Closed-Loop Formulation Requirements

### CTL-010 — Pitch-Rate Selection Vector

For the baseline state ordering

```math
x_L
=
\begin{bmatrix}
\Delta u &
\Delta w &
\Delta q &
\Delta\theta
\end{bmatrix}^{\mathsf{T}},
```

the pitch-rate output selection vector shall be

```math
C_q
=
\begin{bmatrix}
0 & 0 & 1 & 0
\end{bmatrix}.
```

Thus,

```math
\Delta q=C_qx_L.
```

**Verification:** Analytical inspection.

### CTL-011 — Closed-Loop Matrix

When the unsaturated feedback law is represented as

```math
\Delta\delta_e=K_qC_qx_L,
```

the corresponding linear closed-loop state matrix shall be

```math
A_{CL}
=
A_L+B_LK_qC_q.
```

If a later implementation defines the law using an explicit negative sign, the algebra and stored gain convention shall be updated together so the physical feedback direction remains unchanged.

**Verification:** Independent matrix calculation.

### CTL-012 — Closed-Loop Pole Calculation

The controller-design process shall calculate

```math
\lambda_{CL,i}
=
\mathrm{eig}(A_{CL})
```

for every evaluated gain candidate.

**Verification:** Automated analysis.

## 6. Gain-Selection Requirements

### CTL-020 — Gain Sweep

The controller-design process shall evaluate more than one candidate $K_q$ value before the final nominal gain is selected.

**Verification:** Design-record inspection.

### CTL-021 — Gain Sweep Range

The evaluated gain range and increment or sampling strategy shall be recorded in the controller design configuration.

**Verification:** Configuration inspection.

### CTL-022 — Candidate Metrics

For each candidate gain, the design process shall evaluate, at minimum:

- closed-loop eigenvalues;
- short-period damping ratio;
- short-period natural frequency;
- stability of all modeled longitudinal modes.

Where time-domain analysis is applicable, it shall additionally evaluate:

- settling behavior;
- overshoot or peak response;
- peak elevator demand.

**Verification:** Trade-study review.

### CTL-023 — Gain Selection Rationale

The selected $K_q$ shall be justified in a design-decision record.

The rationale shall identify the trade between damping improvement and control activity.

**Verification:** Design-decision review.

### CTL-024 — No Arbitrary Gain Acceptance

A gain shall not be baselined solely because a plotted response appears visually acceptable.

**Verification:** Design-review inspection.

## 7. Stability Requirements

### CTL-030 — Nominal Closed-Loop Stability

At the nominal operating point, the selected unsaturated linear controller shall produce

```math
\mathrm{Re}(\lambda_{CL,i})<0
```

for all modeled longitudinal eigenvalues.

**Verification:** Eigenvalue analysis.

### CTL-031 — Short-Period Damping Improvement

The selected controller shall satisfy

```math
\zeta_{SP,CL}
>
\zeta_{SP,OL}.
```

**Verification:** Modal comparison.

### CTL-032 — Baselined Damping Target

If a quantitative target is established, the selected controller shall satisfy

```math
\zeta_{SP,CL}
\geq
\zeta_{SP,\mathrm{target}}.
```

The value

```text
ZETA_SP_TARGET = TBD
```

shall be baselined before this requirement is used as a final acceptance criterion.

**Verification:** Modal calculation.

### CTL-033 — Other Longitudinal Modes

The selected controller shall not make the modeled phugoid or another modeled longitudinal mode unstable at the nominal operating point.

**Verification:** Full eigenvalue review.

## 8. Command-Limiting Requirements

### CTL-040 — Elevator Position Limiting

The controller implementation shall limit the total equivalent elevator command to the baselined research-model position limits:

```math
\delta_{e,\min}
\leq
\delta_{e,\mathrm{total}}
\leq
\delta_{e,\max}.
```

Numerical limits remain `TBD` until a defensible value or explicit research assumption is baselined.

**Verification:** Boundary tests.

### CTL-041 — Upper Saturation

For a calculated command above $\delta_{e,\max}$, the output shall be limited to

```math
\delta_{e,\max}.
```

**Verification:** Unit test.

### CTL-042 — Lower Saturation

For a calculated command below $\delta_{e,\min}$, the output shall be limited to

```math
\delta_{e,\min}.
```

**Verification:** Unit test.

### CTL-043 — In-Range Command

For

```math
\delta_{e,\min}
<
\delta_{e,\mathrm{cmd}}
<
\delta_{e,\max},
```

the position limiter shall not modify the command.

**Verification:** Unit test.

### CTL-044 — Rate Limiting

Before final controller verification, a decision shall be made whether elevator-rate limiting is included in the project baseline.

If included, the model shall satisfy

```math
|\dot{\delta}_e|
\leq
\dot{\delta}_{e,\max}.
```

The value remains:

```text
ELEVATOR_RATE_LIMIT = TBD
```

**Verification:** Rate-limit test when applicable.

## 9. Time-Domain Performance Requirements

### CTL-050 — Positive Pitch-Rate Disturbance

The controller shall be tested using a defined positive initial pitch-rate perturbation.

**Verification:** Simulation test.

### CTL-051 — Negative Pitch-Rate Disturbance

The controller shall be tested using a defined negative initial pitch-rate perturbation.

**Verification:** Simulation test.

### CTL-052 — Open/Closed Comparison

The controller verification shall compare open-loop and closed-loop responses using identical nominal plant configuration and initial disturbance.

**Verification:** Comparative simulation.

### CTL-053 — State Response Recording

Closed-loop verification shall record:

```math
\Delta u(t),\quad
\Delta w(t),\quad
\Delta q(t),\quad
\Delta\theta(t),
```

and the elevator-control history.

**Verification:** Results inspection.

### CTL-054 — Control Activity Reporting

The verification results shall report peak equivalent elevator demand for the selected controller case.

**Verification:** Automated metric extraction.

## 10. Robustness Requirements

### CTL-060 — Parameter Variation

The selected controller shall be evaluated for at least one off-nominal parameter variation affecting longitudinal dynamics.

Candidate variables include:

```math
m,\quad
I_y,\quad
C_{m_\alpha},\quad
C_{m_q}.
```

**Verification:** Sensitivity analysis.

### CTL-061 — Off-Nominal Stability

For every defined robustness case used as an acceptance case, the controller shall report whether all longitudinal closed-loop eigenvalues remain stable.

**Verification:** Automated eigenvalue sweep.

### CTL-062 — Robustness Scope Identification

The parameter range used in robustness testing shall be documented and shall not be presented as an Airbus-certified operating envelope.

**Verification:** Documentation inspection.

## 11. Implementation Requirements

### CTL-070 — MATLAB Controller Function

The MATLAB controller implementation shall calculate the pitch-damping command using the baselined gain and sign convention.

**Verification:** Unit test.

### CTL-071 — Simulink Controller Block

The Simulink implementation shall use the same baselined $K_q$, sign convention, and command limits as the MATLAB implementation.

**Verification:** Model/configuration inspection.

### CTL-072 — Single Gain Source

The nominal controller gain shall be stored in one controlled parameter definition rather than copied independently into multiple scripts/models.

**Verification:** Configuration inspection.

### CTL-073 — MATLAB/Simulink Controller Agreement

For the same sequence of pitch-rate inputs and identical controller settings, MATLAB and Simulink controller outputs shall agree within:

```text
CONTROLLER_COMPARISON_TOLERANCE = TBD
```

**Verification:** Automated comparison.

## 12. Failure and Boundary Test Requirements

### CTL-080 — Zero Pitch Rate

The controller shall be tested at

```math
\Delta q=0.
```

**Expected functional result:** zero unsaturated damping correction.

### CTL-081 — Positive Pitch Rate

The controller shall be tested at a positive $\Delta q$ within the normal test range.

**Expected functional result:** command direction consistent with damping action.

### CTL-082 — Negative Pitch Rate

The controller shall be tested at a negative $\Delta q$ within the normal test range.

**Expected functional result:** command direction consistent with damping action.

### CTL-083 — Upper Boundary

The controller shall be tested with an input that produces a command greater than the upper elevator limit.

**Expected functional result:** upper saturation.

### CTL-084 — Lower Boundary

The controller shall be tested with an input that produces a command less than the lower elevator limit.

**Expected functional result:** lower saturation.

### CTL-085 — Limit Equality

The controller shall be tested at values producing exactly the configured upper and lower command limits.

**Expected functional result:** no numerical discontinuity or limit overshoot.

### CTL-086 — Non-Finite Input Policy

Before software implementation is baselined, the project shall define the behavior for non-finite pitch-rate input such as `NaN` or infinity.

The policy remains:

```text
NON_FINITE_INPUT_POLICY = TBD
```

until the software interface design is established.

**Verification:** Negative test after closure.

## 13. Design Evidence Requirements

### CTL-090 — Controller Design Record

The project shall produce a controller design document containing:

- control objective;
- feedback variable;
- feedback-law equation;
- sign convention;
- gain candidates;
- pole movement;
- damping results;
- selected gain;
- selection rationale;
- known limitations.

**Verification:** Document review.

### CTL-091 — Gain Trade Study

The project shall retain the gain-sweep results used to select the nominal gain.

**Verification:** Results audit.

### CTL-092 — Traceability

Every control requirement intended for the release shall trace to a design element, implementation element, verification case, and result.

**Verification:** Requirements Traceability Matrix review.

## 14. Explicit Non-Requirements

This project does not require the controller to reproduce:

- Airbus Normal Law;
- Airbus Alternate Law;
- Airbus Direct Law;
- C* or C*-like production command logic;
- flight-envelope protections;
- alpha protection;
- high-speed protection;
- load-factor protection;
- flare law;
- autotrim logic;
- production flight-control computer scheduling.

These functions are outside the current research-controller boundary.

## 15. Control TBD Register

| TBD | Description | Closure point |
|---|---|---|
| `K_q` | Selected signed pitch-rate feedback gain | After gain trade study |
| `ZETA_SP_TARGET` | Quantitative short-period damping target, if used | Before final controller acceptance |
| $\delta_{e,\min}$ | Lower equivalent elevator limit | Before limiter verification |
| $\delta_{e,\max}$ | Upper equivalent elevator limit | Before limiter verification |
| `ELEVATOR_RATE_LIMIT` | Optional elevator-rate limit | Before final actuator-model baseline |
| `CONTROLLER_COMPARISON_TOLERANCE` | MATLAB/Simulink controller comparison tolerance | Before implementation comparison |
| `NON_FINITE_INPUT_POLICY` | Software behavior for invalid numerical input | Before software-interface verification |

## 16. Control Verification Logic

The controller shall be treated as verified only when the evidence demonstrates:

```math
\text{Feedback Direction}
\rightarrow
\text{Gain Selection}
\rightarrow
\text{Closed-Loop Stability}
\rightarrow
\text{Damping Improvement}
\rightarrow
\text{Constraint Handling}
\rightarrow
\text{Implementation Agreement}.
```

A visually smooth response alone is not sufficient evidence of successful control-law design.
