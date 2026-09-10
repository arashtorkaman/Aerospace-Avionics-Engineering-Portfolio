# System Requirements

**Project:** A320-200 Longitudinal Flight Dynamics and Control  
**Document ID:** REQ-SYS-001  
**Revision:** 0.1  
**Status:** Draft for engineering review  
**Date:** 2026-09-10  

## 1. Purpose

This document defines the system-level requirements for the A320-200 Research Model longitudinal flight-dynamics and pitch-control project.

The requirements describe **what the engineering system shall accomplish**. Detailed mathematical implementation requirements are defined in `model_requirements.md`, and pitch-control requirements are defined in `control_requirements.md`.

The project is an educational engineering research model based on public Airbus data, traceable literature inputs, derived quantities, and declared assumptions. It is not an Airbus production model or certified flight-control system.

## 2. Requirement Language

The keyword **shall** identifies a mandatory requirement.

Each requirement has a stable identifier in the form:

```text
SYS-xxx
```

Requirements are intended to be:

- necessary;
- unambiguous;
- feasible;
- individually identifiable;
- verifiable;
- traceable to design and verification evidence.

Where an acceptance value has not yet been responsibly established, the value is marked `TBD`. A `TBD` requirement shall not be declared verified until the value has been baselined.

## 3. Applicable Project Documents

The following documents define constraints on these requirements:

- [`../01_docs/aircraft_definition.md`](../01_docs/aircraft_definition.md)
- [`../01_docs/coordinate_systems.md`](../01_docs/coordinate_systems.md)
- [`../01_docs/modeling_assumptions.md`](../01_docs/modeling_assumptions.md)
- [`../01_docs/data_provenance.md`](../01_docs/data_provenance.md)
- [`../01_docs/model_limitations.md`](../01_docs/model_limitations.md)

## 4. System Context

The engineering workflow is:

$$
\text{Source Data}
\rightarrow
\text{Aircraft Definition}
\rightarrow
\text{Trim}
\rightarrow
\text{Linearization}
\rightarrow
\text{Stability Analysis}
\rightarrow
\text{Pitch Control}
\rightarrow
\text{Verification}.
$$

The modeled longitudinal system uses the perturbation state vector

$$
x_L
=
\begin{bmatrix}
\Delta u \\
\Delta w \\
\Delta q \\
\Delta\theta
\end{bmatrix},
$$

with equivalent elevator perturbation input

$$
\Delta\delta_e.
$$

## 5. Aircraft and Configuration Requirements

### SYS-001 — Reference Aircraft

The system shall represent an **A320-200 Research Model** based on the aircraft configuration defined in `aircraft_definition.md`.

**Rationale:** Establishes an unambiguous reference configuration.  
**Verification:** Document inspection.

### SYS-002 — Configuration Identification

The system shall identify the aircraft configuration applicable to every baselined simulation dataset, including at minimum:

- aircraft variant;
- wing-tip configuration;
- flap/slat configuration;
- landing-gear configuration;
- propulsion representation;
- aircraft mass;
- center-of-gravity condition;
- altitude;
- airspeed or Mach number.

**Verification:** Inspection of configuration and source records.

### SYS-003 — Data Provenance

Every numerical aircraft parameter used by the system shall have a provenance classification and source record consistent with `data_provenance.md`.

**Verification:** Source-register audit.

### SYS-004 — Controlled Parameter Baseline

Final verification results shall use only parameters whose source status is `BASELINED`.

**Verification:** Configuration audit.

## 6. Longitudinal Dynamics Requirements

### SYS-010 — Longitudinal Dynamics Representation

The system shall represent the longitudinal rigid-body response of the A320-200 Research Model about one documented nominal trim condition.

**Verification:** Analysis and simulation.

### SYS-011 — Longitudinal State Set

The initial system shall represent, at minimum:

$$
\Delta u,\qquad
\Delta w,\qquad
\Delta q,\qquad
\Delta\theta.
$$

**Verification:** Model inspection.

### SYS-012 — Longitudinal Control Input

The system shall represent equivalent elevator deflection as the primary longitudinal control input.

**Verification:** Model inspection and input-response test.

### SYS-013 — Coordinate Consistency

The system shall implement the body-axis and sign conventions defined in `coordinate_systems.md`.

**Verification:** Sign-convention test procedure.

### SYS-014 — SI Computational Units

The system shall use SI units internally for all flight-dynamics calculations.

**Verification:** Unit inspection and dimensional-consistency analysis.

## 7. Trim Requirements

### SYS-020 — Nominal Operating Point

The system shall define one nominal longitudinal operating point before linearization is performed.

The operating point shall identify at minimum:

$$
h_0,\quad
V_0,\quad
M_0,\quad
m_0,\quad
x_{CG,0},
$$

where applicable to the selected dataset.

**Verification:** Inspection of configuration baseline.

### SYS-021 — Trim Solution

The system shall determine or import a dynamically consistent trim condition for the nominal operating point.

The trim condition shall define, as applicable:

$$
\alpha_0,\quad
\theta_0,\quad
\delta_{e0},\quad
T_0.
$$

**Verification:** Trim analysis.

### SYS-022 — Trim Residual

The system shall calculate and report the trim residual rather than relying solely on solver convergence status.

A numerical trim acceptance threshold shall be baselined as:

```text
TRIM_RESIDUAL_TOLERANCE = TBD
```

before final verification.

**Verification:** Automated residual test.

### SYS-023 — Trim Reproducibility

Using the same baselined configuration and solver settings, the system shall reproduce the nominal trim solution within the defined numerical tolerance.

**Verification:** Repeatability test.

## 8. Linearization Requirements

### SYS-030 — Linear Model Generation

The system shall generate or construct a longitudinal linear model about the nominal trim condition.

The model shall have the form

$$
\Delta\dot{x}_L
=
A_L\Delta x_L
+
B_L\Delta\delta_e.
$$

**Verification:** Model inspection and numerical test.

### SYS-031 — Matrix Dimensions

For the baseline four-state, single-input model:

$$
A_L \in \mathbb{R}^{4\times4},
\qquad
B_L \in \mathbb{R}^{4\times1}.
$$

**Verification:** Automated dimension test.

### SYS-032 — Operating-Point Identification

Every reported $A_L$ and $B_L$ matrix shall identify the operating point and parameter baseline from which it was obtained.

**Verification:** Report inspection.

### SYS-033 — Linearization Reproducibility

The system shall reproduce the same nominal $A_L$ and $B_L$ matrices within a baselined numerical tolerance when executed with the same input configuration.

**Verification:** Regression test.

## 9. Open-Loop Stability Requirements

### SYS-040 — Eigenvalue Analysis

The system shall calculate the eigenvalues of the nominal longitudinal state matrix:

$$
\lambda_i = \operatorname{eig}(A_L).
$$

**Verification:** Independent numerical comparison.

### SYS-041 — Eigenvector Analysis

The system shall calculate or otherwise evaluate mode-shape information sufficient to support physical mode identification.

**Verification:** Analysis review.

### SYS-042 — Short-Period Identification

The system shall identify the longitudinal mode associated with the short-period response using eigenvalue characteristics and state participation or equivalent mode-shape evidence.

**Verification:** Engineering analysis.

### SYS-043 — Phugoid Identification

The system shall identify the longitudinal mode associated with the phugoid response using eigenvalue characteristics and state participation or equivalent mode-shape evidence.

**Verification:** Engineering analysis.

### SYS-044 — Modal Metrics

For every oscillatory complex-conjugate longitudinal mode, the system shall calculate:

- natural frequency $\omega_n$;
- damping ratio $\zeta$;
- damped frequency $\omega_d$;
- oscillation period $T$ where applicable.

For

$$
\lambda=\sigma\pm j\omega_d,
$$

the calculations shall include

$$
\omega_n=\sqrt{\sigma^2+\omega_d^2}
$$

and

$$
\zeta=-\frac{\sigma}{\omega_n}.
$$

**Verification:** Independent equation-based calculation.

### SYS-045 — Open-Loop Baseline

The system shall record an open-loop baseline before closed-loop controller performance is assessed.

The baseline shall include, at minimum:

- eigenvalues;
- identified modes;
- damping ratios;
- natural frequencies;
- time-response plots;
- selected response metrics.

**Verification:** Results-package inspection.

## 10. Time-Domain Analysis Requirements

### SYS-050 — Elevator Response

The system shall simulate the longitudinal response to a defined small elevator perturbation.

**Verification:** Simulation test.

### SYS-051 — Pitch-Rate Disturbance

The system shall simulate the response to a defined initial pitch-rate perturbation.

**Verification:** Simulation test.

### SYS-052 — Forward-Velocity Disturbance

The system shall simulate the response to a defined initial forward-velocity perturbation.

**Verification:** Simulation test.

### SYS-053 — State Recording

For applicable time-domain tests, the system shall record at minimum:

$$
\Delta u(t),\quad
\Delta w(t),\quad
\Delta q(t),\quad
\Delta\theta(t).
$$

**Verification:** Output-data inspection.

### SYS-054 — Plot Units

Every published engineering plot shall identify the plotted variable and its physical unit.

**Verification:** Figure review.

## 11. Pitch-Control Requirements

### SYS-060 — Pitch-Damping Capability

The system shall include a research pitch-rate damping function intended to increase damping of the selected short-period mode.

Detailed requirements are defined in `control_requirements.md`.

**Verification:** Closed-loop modal analysis.

### SYS-061 — Closed-Loop Stability

The selected nominal controller configuration shall result in stable closed-loop longitudinal poles for the baselined operating point.

For continuous-time analysis, nominal closed-loop stability requires

$$
\operatorname{Re}(\lambda_i)<0
$$

for every closed-loop eigenvalue.

**Verification:** Eigenvalue analysis.

### SYS-062 — Short-Period Damping Improvement

The selected controller shall produce a short-period damping ratio greater than the corresponding open-loop damping ratio:

$$
\zeta_{SP,CL}>\zeta_{SP,OL}.
$$

A stronger quantitative target may be baselined later as:

```text
ZETA_SP_TARGET = TBD
```

**Verification:** Open-loop versus closed-loop comparison.

### SYS-063 — Control Constraint Handling

The control implementation shall enforce baselined elevator position limits.

The numerical limits shall remain `TBD` until a defensible research value is baselined.

**Verification:** Boundary-value tests.

### SYS-064 — Other-Mode Stability

Pitch-rate damping shall not render another modeled longitudinal mode unstable at the nominal operating point.

**Verification:** Full closed-loop eigenvalue analysis.

## 12. Implementation Consistency Requirements

### SYS-070 — MATLAB Reference Implementation

The system shall include a MATLAB implementation capable of reproducing the nominal aircraft model, stability analysis, and verification calculations.

**Verification:** Execution test.

### SYS-071 — Simulink Implementation

The system shall include a Simulink implementation of the longitudinal plant and pitch-control loop.

**Verification:** Model execution test.

### SYS-072 — Shared Parameter Baseline

MATLAB and Simulink shall use the same controlled aircraft-parameter baseline.

**Verification:** Configuration inspection.

### SYS-073 — MATLAB/Simulink Agreement

For identical initial conditions, inputs, parameter data, and numerical settings, MATLAB and Simulink outputs shall agree within a baselined comparison tolerance:

```text
MODEL_COMPARISON_TOLERANCE = TBD
```

**Verification:** Automated cross-implementation comparison.

## 13. Robustness and Sensitivity Requirements

### SYS-080 — Parameter Sensitivity

The system shall evaluate the sensitivity of selected longitudinal stability and control metrics to at least one uncertain aircraft parameter.

Candidate parameters include:

$$
m,\quad
I_y,\quad
C_{m_\alpha},\quad
C_{m_q}.
$$

**Verification:** Parameter-sweep analysis.

### SYS-081 — Sensitivity Reporting

The sensitivity analysis shall identify:

- varied parameter;
- nominal value;
- variation range;
- affected eigenvalues;
- affected damping ratios;
- closed-loop stability result.

**Verification:** Results review.

### SYS-082 — Nominal Versus Off-Nominal Separation

Nominal verification results and off-nominal sensitivity results shall be stored and reported separately.

**Verification:** Repository inspection.

## 14. Verification and Traceability Requirements

### SYS-090 — Requirement Verification

Every requirement intended for the current project release shall have an assigned verification method.

**Verification:** Requirements audit.

### SYS-091 — Requirements Traceability

Every verified requirement shall trace to:

$$
\text{Requirement}
\rightarrow
\text{Design}
\rightarrow
\text{Implementation}
\rightarrow
\text{Verification Case}
\rightarrow
\text{Result}.
$$

**Verification:** Requirements Traceability Matrix review.

### SYS-092 — Verification Evidence

Verification results shall include sufficient objective evidence to determine PASS, FAIL, or NOT VERIFIED status.

**Verification:** Verification-package inspection.

### SYS-093 — Failed Verification

A failed verification case shall not be silently removed or reclassified as successful.

Any correction shall be recorded through the project change history and the affected test shall be rerun.

**Verification:** Configuration and test-record audit.

## 15. Reproducibility and Configuration Requirements

### SYS-100 — Reproducible Execution

The repository shall provide a defined execution path that reproduces the nominal analysis without requiring undocumented manual parameter entry.

**Verification:** Clean-run execution test.

### SYS-101 — Tool Identification

The project shall record MATLAB, Simulink, toolbox, and relevant numerical-solver versions used for baselined results.

**Verification:** Configuration record inspection.

### SYS-102 — Change History

Changes affecting requirements, model equations, parameters, controller gains, or verification criteria shall be recorded in the project change history.

**Verification:** Change-log inspection.

### SYS-103 — Result Identification

Every baselined result set shall be associated with a specific configuration or revision identifier.

**Verification:** Result-package inspection.

## 16. System-Level Verification Matrix

| Requirement group | Primary verification method |
|---|---|
| SYS-001 to SYS-004 | Inspection / audit |
| SYS-010 to SYS-014 | Analysis / model inspection |
| SYS-020 to SYS-023 | Analysis / test |
| SYS-030 to SYS-033 | Analysis / regression test |
| SYS-040 to SYS-045 | Analysis |
| SYS-050 to SYS-054 | Simulation test |
| SYS-060 to SYS-064 | Analysis / test |
| SYS-070 to SYS-073 | Execution / comparison test |
| SYS-080 to SYS-082 | Sensitivity analysis |
| SYS-090 to SYS-093 | Traceability / audit |
| SYS-100 to SYS-103 | Configuration / execution audit |

## 17. Open TBD Register

| TBD | Description | Closure point |
|---|---|---|
| `TRIM_RESIDUAL_TOLERANCE` | Numerical equilibrium acceptance tolerance | Before trim verification |
| `ZETA_SP_TARGET` | Optional quantitative short-period damping target | Before final controller selection |
| Elevator position limits | Research-model actuator limits | Before control boundary testing |
| `MODEL_COMPARISON_TOLERANCE` | MATLAB/Simulink numerical agreement tolerance | Before cross-model verification |

No requirement containing an unresolved acceptance-critical `TBD` shall be marked PASS.
