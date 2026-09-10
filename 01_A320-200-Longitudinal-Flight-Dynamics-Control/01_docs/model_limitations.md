# Model Limitations

**Project:** A320-200 Longitudinal Flight Dynamics and Control  
**Document ID:** DOC-LIMIT-001  
**Revision:** 0.1  
**Status:** Draft engineering baseline  
**Date:** 2026-09-10  

## 1. Purpose

This document defines what the A320-200 Research Model does **not** establish.

The limitations are part of the engineering evidence. They prevent results from being interpreted outside the scope supported by the model, source data, and verification campaign.

## 2. Primary Limitation

The project is a public-data educational research model inspired by the Airbus A320-200.

It is not:

- an Airbus-authorized flight model;
- an Airbus production flight-control implementation;
- an aircraft-qualified software item;
- a certified aerodynamic database;
- a substitute for manufacturer engineering data.

## 3. Limitation Register

| ID | Limitation | Impact | Planned treatment |
|---|---|---|---|
| LIM-001 | Public data does not provide the full Airbus aerodynamic database. | Exact aircraft responses cannot be claimed. | Use cited literature plus sensitivity analysis. |
| LIM-002 | Exact A320 mass moments/products of inertia are not publicly baselined in this project. | Modal frequencies and control response depend on estimated/literature inertia. | Document source and vary inertia in robustness tests. |
| LIM-003 | Initial model is linearized at one trim point. | Results are local to that flight condition. | Add additional operating points in later work if needed. |
| LIM-004 | Initial dynamics are longitudinal only. | Roll/yaw coupling is excluded. | Address multivariable dynamics in a separate project. |
| LIM-005 | Small-perturbation assumptions are used. | Large maneuvers and high angle of attack are not represented reliably. | Compare with nonlinear model only within declared perturbation bounds. |
| LIM-006 | Airframe is rigid. | Structural and aeroelastic modes are excluded. | Keep outside scope unless structural data becomes available. |
| LIM-007 | Initial thrust model is simplified. | Engine transient effects on longitudinal response are not represented. | Introduce propulsion dynamics only with defensible data. |
| LIM-008 | Initial pitch control uses an equivalent elevator input. | Real A320 fly-by-wire command architecture is not reproduced. | Clearly label controller as research control law. |
| LIM-009 | Airbus flight-envelope protection laws are not modeled. | Results do not represent operational A320 Normal Law protections. | Outside scope. |
| LIM-010 | Sensor noise and state estimation are initially omitted. | Early controller results assume ideal state knowledge. | Introduce sensor/estimator effects in later work. |
| LIM-011 | Hydraulic actuator dynamics may initially be omitted. | High-frequency or rate-limited response may be optimistic. | Add saturation/rate/dynamic model before final control verification. |
| LIM-012 | Atmospheric turbulence is excluded from the baseline case. | Nominal response does not demonstrate gust robustness. | Add a dedicated disturbance test set. |
| LIM-013 | Parameter uncertainty exists in literature-derived derivatives. | Stability margins may vary with source/model assumptions. | Perform sensitivity analysis and record uncertainty. |
| LIM-014 | No handling-qualities certification assessment is claimed. | Modal results are descriptive, not certification findings. | Use standards only as clearly scoped comparative references if later required. |
| LIM-015 | No DO-178C compliance claim is made. | Repository artifacts are educational/certification-oriented only. | Keep certification claims explicit and conservative. |
| LIM-016 | No DO-254 compliance claim is made. | Hardware assurance is outside this model. | Deferred to separate hardware work. |
| LIM-017 | Verification is performed on a research computing environment. | Results do not constitute target-hardware qualification. | Later embedded project may add SIL/PIL/HIL evidence. |
| LIM-018 | Flight-test correlation is unavailable. | Model cannot be validated as an exact aircraft representation. | Validate internally and against published research only. |

## 4. Flight-Envelope Limitation

The initial state-space model is valid only in a neighborhood of its nominal trim condition.

Conceptually,

```math
\Delta\dot{x}=A\Delta x+B\Delta u
```

is a first-order approximation to

```math
\dot{x}=f(x,u).
```

The approximation error generally increases as:

- $|\Delta \alpha|$ increases;
- control deflections become large;
- Mach number changes substantially;
- altitude/density changes substantially;
- aircraft configuration changes;
- mass or CG moves far from the nominal condition.

Therefore, the repository shall never label one $A,B$ pair as "the A320 state-space model" without identifying its operating point.

## 5. Aerodynamic-Data Limitation

A320-specific stability derivatives obtained from public literature are research-source data.

They may differ because of:

- different flight conditions;
- different aerodynamic models;
- different engine assumptions;
- different coefficient normalizations;
- different elevator conventions;
- different mass/CG configurations;
- author estimation methods.

The project shall preserve these differences rather than hiding them.

Where a derivative strongly affects stability or control design, a sensitivity sweep shall be preferred over false precision.

## 6. Control-Law Limitation

The designed pitch controller is intended to demonstrate:

- feedback-control derivation;
- pole/damping analysis;
- gain trade studies;
- actuator constraint handling;
- verification traceability.

It is not intended to reproduce Airbus:

- C* control law structure;
- sidestick mapping;
- Normal Law;
- Alternate Law;
- Direct Law;
- flare law;
- angle-of-attack protection;
- load-factor protection;
- pitch-attitude protection;
- high-speed protection;
- flight-control computer implementation.

Any similarity between research controller behavior and production aircraft behavior shall not be treated as evidence of equivalence.

## 7. Actuator Limitation

A static elevator command may be used during early model verification.

Before final controller verification, the model should contain at least:

- position saturation;
- rate limiting.

A first-order actuator dynamic may be added if a defensible bandwidth/time constant is available or explicitly introduced as an assumption.

## 8. Propulsion Limitation

The first trim model may use total thrust as an equivalent input.

This omits:

- spool dynamics;
- engine installation effects beyond static force/moment representation;
- FADEC logic;
- engine failure cases;
- throttle-to-thrust nonlinearities;
- altitude/Mach-dependent engine maps.

These are not required to demonstrate the initial longitudinal stability-analysis workflow.

## 9. Certification Limitation

The repository may use practices inspired by aerospace development, such as:

- identified requirements;
- design documentation;
- verification cases;
- requirements traceability;
- configuration records;
- change history.

These artifacts do not constitute DO-178C, ARP4754A, ARP4761A, CS-25, or other compliance by themselves.

Certification claims require controlled organizational processes, approved lifecycle data, independence where required, configuration management, quality assurance, verification objectives, target-environment evidence, and other activities beyond the scope of this portfolio.

## 10. Validation Strategy

Because exact Airbus flight-test truth data is not available, validation will use several layers:

1. dimensional and sign-consistency checks;
2. trim-equilibrium checks;
3. analytical checks of state-space construction;
4. mode identification from eigenvalues/eigenvectors;
5. comparison with published A320 research where compatible;
6. MATLAB-versus-Simulink numerical comparison;
7. sensitivity studies for uncertain parameters;
8. closed-loop requirement verification.

Passing these checks establishes internal engineering consistency, not exact correlation with a production A320.

## 11. Acceptable Portfolio Claim

Recommended wording:

> Developed an A320-200-inspired longitudinal flight-dynamics and pitch-control research model using public manufacturer data, traceable literature inputs, explicit engineering assumptions, stability analysis, requirements-based verification, and model traceability.

Avoid claims such as:

> Developed the Airbus A320 flight-control software.

or

> Built a certified A320 aerodynamic model.

## 12. Limitation Review

This document shall be reviewed whenever:

- a new aerodynamic dataset is accepted;
- the operating point changes;
- the model moves from linear to nonlinear dynamics;
- actuator or propulsion dynamics are added;
- the controller architecture changes;
- verification scope expands;
- a new certification-oriented artifact is added.

Closing a limitation requires objective evidence; it shall not be removed merely because later plots appear realistic.
