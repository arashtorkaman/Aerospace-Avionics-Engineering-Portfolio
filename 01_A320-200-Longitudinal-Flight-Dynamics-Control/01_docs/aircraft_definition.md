# Aircraft Definition

**Project:** A320-200 Longitudinal Flight Dynamics and Control  
**Document ID:** DOC-AIRCRAFT-001  
**Revision:** 0.1  
**Status:** Draft engineering baseline  
**Date:** 2026-09-10  

## 1. Purpose

This document defines the reference aircraft configuration used by the longitudinal flight-dynamics and pitch-control research model.

The project uses an **Airbus A320-200-inspired engineering model**. Public Airbus data is used where it is available and suitable. Parameters that are not publicly available from Airbus are obtained from cited technical literature, derived from documented data, or introduced as explicit engineering assumptions.

The model is not intended to reproduce Airbus proprietary aerodynamic databases, production flight-control laws, or certified aircraft software.

## 2. Reference Aircraft

The reference aircraft is the Airbus A320-200, a twin-engine, single-aisle transport aircraft in the Airbus A320 family.

For consistency, the initial geometric baseline is the **A320-200 with wing-tip fences**. Airbus's current Aircraft Characteristics publication shows:

| Quantity | Symbol | Baseline value | Classification |
|---|---:|---:|---|
| Overall length | $L$ | 37.57 m | OEM-PUBLIC |
| Geometric wingspan, wing-tip fence configuration | $b$ | 34.10 m | OEM-PUBLIC |
| Fuselage width | — | 3.95 m | OEM-PUBLIC |
| Wheelbase | — | 12.64 m | OEM-PUBLIC |
| Main landing-gear track | — | 7.59 m | OEM-PUBLIC |

The A320-200 is available in multiple certified weight variants. Therefore, maximum takeoff weight is **not** used as the simulation mass by default. A specific analysis mass must be selected and frozen with the nominal trim condition.

Airbus publications show A320-200 compatibility with CFM56-series and IAE V2500-series engines. The propulsion configuration for the longitudinal model remains **TBD** until the trim model and source dataset are selected. Initial longitudinal work may use an equivalent total thrust input rather than an engine transient model.

## 3. Research Model Designation

Within this repository, the simulated aircraft shall be referred to as:

**A320-200 Research Model**

This designation prevents confusion between the portfolio model and an Airbus production or certification model.

## 4. Intended Engineering Use

The model is intended to support:

- longitudinal rigid-body flight-dynamics analysis;
- trim analysis at a documented operating point;
- linearization about that trim condition;
- longitudinal state-space model generation;
- short-period and phugoid mode analysis;
- pitch-control and pitch-damping design;
- MATLAB and Simulink implementation;
- requirements-based verification;
- sensitivity and robustness studies.

## 5. Initial State and Input Definition

The initial small-disturbance longitudinal state vector is

```math
x =
\begin{bmatrix}
u & w & q & \theta
\end{bmatrix}^{T},
```

where:

- $u$: perturbation in body-axis forward velocity [m/s];
- $w$: perturbation in body-axis vertical velocity [m/s];
- $q$: pitch rate [rad/s];
- $\theta$: pitch-attitude perturbation [rad].

The initial control input is an equivalent elevator command:

```math
u_c = \delta_e.
```

The exact sign convention for $\delta_e$ is defined in `coordinate_systems.md`.

The linearized aircraft will be represented as

```math
\dot{x} = A x + B \delta_e.
```

The numerical $A$ and $B$ matrices shall not be frozen until the nominal flight condition, mass properties, aerodynamic derivative set, and sign conventions have been established.

## 6. Nominal Flight Condition

The nominal operating point is deliberately not fixed in this revision.

The following quantities must be established before linearization:

| Quantity | Symbol | Status |
|---|---:|---|
| Pressure altitude | $h_0$ | TBD |
| True airspeed | $V_0$ | TBD |
| Mach number | $M_0$ | TBD |
| Aircraft mass | $m_0$ | TBD |
| Center-of-gravity location | $x_{CG,0}$ | TBD |
| Flight-path angle | $\gamma_0$ | TBD |
| Angle of attack | $\alpha_0$ | TO BE SOLVED |
| Pitch attitude | $\theta_0$ | TO BE SOLVED |
| Elevator trim | $\delta_{e0}$ | TO BE SOLVED |
| Equivalent thrust | $T_0$ | TO BE SOLVED |

The flight condition will be selected to match the chosen aerodynamic/stability-derivative source whenever possible. This avoids combining derivatives from one operating condition with geometry, mass, or trim data from another.

## 7. Geometry and Reference Quantities

The following quantities are required by later aerodynamic calculations:

- wing reference area $S$;
- mean aerodynamic chord $\bar{c}$;
- wingspan $b$;
- aerodynamic reference point;
- center-of-gravity reference;
- tail reference quantities where required.

Only $b$ and general external dimensions are frozen from the Airbus source at this stage. Values for $S$, $\bar c$, inertia properties, and aerodynamic derivatives will be added only after they are entered in the project source register.

## 8. Mass Properties

The model requires, at minimum:

```math
m,\qquad I_y
```

for the first longitudinal analysis.

A complete six-degree-of-freedom extension would additionally require

```math
I_x,\qquad I_z,\qquad I_{xz}.
```

Airbus public airport-planning documentation does not provide the complete inertia tensor needed for this research model. Any inertia values used later shall therefore be identified as `LITERATURE`, `DERIVED`, or `ASSUMED`, never `OEM-PUBLIC` unless an Airbus source explicitly supports them.

## 9. Aerodynamic Data Required

The first longitudinal model is expected to require a subset of coefficients or dimensional stability derivatives corresponding to:

- axial-force response to velocity and angle of attack;
- normal-force/lift response to velocity and angle of attack;
- pitching-moment response to angle of attack;
- pitch-rate damping;
- elevator effectiveness;
- optional $\dot{\alpha}$ derivatives;
- thrust contribution where included.

Representative coefficient notation may include:

```math
C_{L_\alpha},\quad
C_{L_q},\quad
C_{L_{\delta_e}},\quad
C_{m_\alpha},\quad
C_{m_q},\quad
C_{m_{\delta_e}}.
```

No numerical value shall enter the executable model until its source and applicability have been reviewed.

## 10. Configuration Baseline

The initial configuration baseline is:

| Item | Baseline |
|---|---|
| Aircraft family | Airbus A320 |
| Model | A320-200 |
| Wing-tip device | Wing-tip fence |
| Landing gear | Retracted for airborne dynamics |
| Flap/slat configuration | TBD with trim dataset |
| Engine representation | Equivalent thrust; detailed engine dynamics out of scope initially |
| Control-law representation | Research longitudinal controller, not Airbus production law |
| Atmosphere | ISA-based baseline |
| Structural model | Rigid body |
| Flight condition | Single nominal trim point, TBD |

Any change to these items after the first model baseline shall be recorded in the project change log.

## 11. Model Identity Versus Real Aircraft

The following distinction is mandatory throughout the repository:

> The A320-200 Research Model is an educational engineering representation constructed from public manufacturer data, public technical literature, derived quantities, and declared assumptions. It is not an Airbus-authorized aerodynamic model and does not represent Airbus proprietary flight-control software.

## 12. References

1. Airbus, **A320ceo**, aircraft product page:  
   https://www.aircraft.airbus.com/en/aircraft/a320-family/a320ceo

2. Airbus, **A320 Aircraft Characteristics — Airport and Maintenance Planning**, revision dated 15 July 2025:  
   https://www.aircraft.airbus.com/sites/g/files/jlcbta126/files/2025-07/AC_A320_20250715.pdf

3. EASA, **EASA.A.064 — Airbus A318, A319, A320, A321 Single Aisle**, Type Certificate Data Sheet listing:  
   https://www.easa.europa.eu/en/document-library/type-certificates
