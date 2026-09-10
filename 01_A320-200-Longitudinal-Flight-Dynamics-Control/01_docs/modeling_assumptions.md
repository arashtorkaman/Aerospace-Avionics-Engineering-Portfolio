# Modeling Assumptions

**Project:** A320-200 Longitudinal Flight Dynamics and Control  
**Document ID:** DOC-ASSUMP-001  
**Revision:** 0.1  
**Status:** Draft engineering baseline  
**Date:** 2026-09-10  

## 1. Purpose

This document records the assumptions that define the validity domain of the A320-200 Research Model.

An assumption is not treated as a hidden simplification. Each assumption is identified, its engineering consequence is stated, and later verification or model extensions may retire or refine it.

## 2. Assumption Classification

Assumptions are grouped as:

- **AIRFRAME** — structural and rigid-body assumptions;
- **AERODYNAMIC** — aerodynamic representation;
- **FLIGHT-CONDITION** — operating-point assumptions;
- **PROPULSION** — thrust representation;
- **ENVIRONMENT** — atmosphere and disturbances;
- **SENSOR/ACTUATOR** — hardware representation;
- **CONTROL** — controller-development assumptions;
- **NUMERICAL** — implementation and solver assumptions.

## 3. Baseline Assumptions

| ID | Category | Assumption | Engineering consequence |
|---|---|---|---|
| ASM-001 | AIRFRAME | Aircraft is a rigid body. | Structural flexibility and aeroelastic modes are excluded. |
| ASM-002 | AIRFRAME | Mass is constant during one simulation run. | Fuel burn is neglected within a run. |
| ASM-003 | AIRFRAME | Pitch inertia $I_y$ is constant during one simulation run. | Loading changes are represented by separate cases, not continuous inertia updates. |
| ASM-004 | FLIGHT-CONDITION | Initial linear model represents one nominal trimmed operating point. | Results are local and cannot be generalized to the full flight envelope. |
| ASM-005 | AERODYNAMIC | Small-perturbation theory is valid for the linear stability model. | High-angle-of-attack and large-maneuver behavior are outside validity. |
| ASM-006 | AERODYNAMIC | Longitudinal and lateral-directional dynamics are decoupled initially. | Cross-axis coupling is omitted from the first model. |
| ASM-007 | AERODYNAMIC | Aerodynamic derivatives are locally constant about the trim point. | Derivative scheduling with Mach, altitude, angle of attack, or configuration is initially omitted. |
| ASM-008 | ENVIRONMENT | Baseline atmosphere is ISA-based. | Non-standard temperature/pressure is excluded from the nominal case. |
| ASM-009 | ENVIRONMENT | Baseline verification contains no turbulence or gust disturbance. | Disturbance robustness is tested separately, not in the nominal baseline. |
| ASM-010 | ENVIRONMENT | Local gravitational acceleration is constant. | Earth-curvature and gravity variation are neglected. |
| ASM-011 | ENVIRONMENT | Flat-Earth approximation is sufficient for the initial short-duration dynamics analysis. | Long-range navigation effects are excluded. |
| ASM-012 | PROPULSION | Initial propulsion is represented as equivalent thrust required for trim. | Detailed CFM56/V2500 spool dynamics and FADEC behavior are excluded. |
| ASM-013 | SENSOR/ACTUATOR | Initial state-feedback analysis uses ideal state availability. | Sensor noise, bias, latency, and estimation are deferred. |
| ASM-014 | SENSOR/ACTUATOR | Initial elevator model is static unless an actuator model is explicitly enabled. | Hydraulic actuator bandwidth/rate dynamics are omitted initially. |
| ASM-015 | CONTROL | Controller is a research control law, not an Airbus flight-control law. | Results must not be interpreted as A320 production control behavior. |
| ASM-016 | NUMERICAL | Internal calculations use SI units and radians. | Source data in other units must be converted before use. |
| ASM-017 | NUMERICAL | MATLAB and Simulink implementations shall share one parameter baseline. | Duplicate uncontrolled parameter definitions are prohibited. |
| ASM-018 | DATA | Imported derivatives are valid only for the source condition or an explicitly justified nearby condition. | Mixing derivative sets across unrelated flight conditions is prohibited. |

## 4. Trim Assumptions

The nominal trim case is expected to represent steady, symmetric flight.

The initial target conditions are:

```math
\dot{u}_0 = 0,\qquad
\dot{w}_0 = 0,\qquad
\dot{q}_0 = 0.
```

For steady non-turning flight:

```math
q_0 = 0.
```

The exact flight-path angle may be zero for level-flight work or nonzero if a later approach-condition dataset is selected. The chosen condition shall be documented before trim is solved.

Trim residuals shall be reported numerically rather than described only as "converged."

## 5. Linearization Assumptions

The nonlinear dynamics are conceptually written as

```math
\dot{x}=f(x,u).
```

Around the equilibrium point $(x_0,u_0)$,

```math
\Delta\dot{x}
\approx
A\Delta x+B\Delta u,
```

with

```math
A=
\left.
\frac{\partial f}{\partial x}
\right|_{x_0,u_0},
\qquad
B=
\left.
\frac{\partial f}{\partial u}
\right|_{x_0,u_0}.
```

The approximation neglects higher-order perturbation terms. Therefore, validation shall include a stated perturbation range within which the linear model remains acceptably close to the nonlinear/reference implementation.

## 6. Aerodynamic Assumptions

The initial aerodynamic representation may use locally linear coefficient expansions such as

```math
C_L =
C_{L_0}
+
C_{L_\alpha}\alpha
+
C_{L_q}\frac{q\bar c}{2V}
+
C_{L_{\delta_e}}\delta_e
```

and

```math
C_m =
C_{m_0}
+
C_{m_\alpha}\alpha
+
C_{m_q}\frac{q\bar c}{2V}
+
C_{m_{\delta_e}}\delta_e.
```

Additional terms such as $C_{L_{\dot\alpha}}$ or $C_{m_{\dot\alpha}}$ may be introduced if supported by the selected literature model.

The project shall not add terms merely to make the response "look more realistic." Every included term must have a defined source or derivation.

## 7. Mass and Inertia Assumptions

A320-200 certified weight variants do not directly provide the actual mass used by a specific aircraft at a specific flight condition.

Therefore:

- MTOW shall not be substituted for operating mass unless the modeled case specifically represents MTOW;
- the nominal simulation mass shall be selected from, or made consistent with, the aerodynamic derivative source;
- $I_y$ shall be literature-derived, derived from a declared approximation, or assumed with uncertainty bounds;
- sensitivity to mass and inertia uncertainty shall be evaluated later.

## 8. Control-Surface Assumptions

The initial pitch-control input is represented as an equivalent elevator deflection.

This is a simplification of the real A320 fly-by-wire architecture.

The project does not model:

- sidestick command shaping;
- Airbus normal/alternate/direct law logic;
- flight-envelope protections;
- control-law gain scheduling;
- stabilizer trim logic;
- hydraulic redundancy;
- actuator monitoring.

Those functions are outside this project's initial longitudinal-control scope.

## 9. Atmosphere Assumptions

Atmospheric density, pressure, speed of sound, and temperature shall be obtained from an ISA-based model unless the selected source condition specifies otherwise.

Dynamic pressure is

```math
\bar q = \frac{1}{2}\rho V^2.
```

A consistent atmosphere state shall be used for both trim and derivative conversion.

## 10. Assumption Review Rule

An assumption shall be revised when:

- a higher-quality source becomes available;
- verification demonstrates that the assumption materially invalidates the intended analysis;
- project scope expands beyond the assumption's validity;
- a later model introduces the previously neglected physics.

Changes shall be recorded in `CHANGELOG.md`.

## 11. Verification Consequences

The verification plan shall explicitly test at least:

- nominal trim residuals;
- dimensional consistency;
- small-perturbation response;
- controller behavior under positive and negative disturbances;
- actuator limits when introduced;
- sensitivity to at least one uncertain mass/aerodynamic parameter;
- MATLAB/Simulink agreement.

Assumptions that are not directly testable shall remain documented limitations.
