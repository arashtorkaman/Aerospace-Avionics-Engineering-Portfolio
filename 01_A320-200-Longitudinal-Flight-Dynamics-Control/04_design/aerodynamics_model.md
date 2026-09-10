# Aerodynamics Model

**Project:** A320-200 Longitudinal Flight Dynamics and Control  
**Document ID:** DES-AERO-001  
**Revision:** 0.1  
**Status:** Draft engineering design  
**Date:** 2026-09-10  

## 1. Purpose

This document defines the longitudinal aerodynamic model used by the A320-200 Research Model.

The aerodynamic model converts aircraft state, atmospheric state, and equivalent elevator input into aerodynamic coefficients, forces, and pitching moment suitable for:

- trim analysis;
- longitudinal equations of motion;
- small-disturbance linearization;
- stability-derivative derivation;
- open-loop simulation;
- pitch-control design;
- verification.

The model is a public-data research representation. It is not an Airbus proprietary aerodynamic database.

## 2. Applicable Requirements

This design primarily supports:

- `SYS-010` — Longitudinal Dynamics Representation;
- `SYS-011` — Longitudinal State Set;
- `SYS-012` — Longitudinal Control Input;
- `SYS-013` — Coordinate Consistency;
- `SYS-014` — SI Computational Units;
- `SYS-020` through `SYS-023` — Trim;
- `SYS-030` through `SYS-033` — Linearization;
- `MDL-020` through `MDL-022` — Atmosphere;
- `MDL-030` through `MDL-035` — Aerodynamics;
- `MDL-040` through `MDL-044` — Trim support;
- `MDL-052` through `MDL-057` — Linearization and dimensional consistency.

## 3. Inputs and Outputs

### 3.1 Inputs

The baseline longitudinal aerodynamic model accepts:

$$
V,\quad
\alpha,\quad
q,\quad
\delta_e,\quad
\rho
$$

and the controlled aircraft parameters:

$$
S,\quad
\bar{c}.
$$

Where required, additional terms may include:

$$
\dot{\alpha}.
$$

### 3.2 Outputs

The model shall provide at minimum:

$$
C_L,\quad
C_D,\quad
C_m,
$$

followed by aerodynamic loads:

$$
L,\quad
D,\quad
M.
$$

If the equations of motion are implemented in body axes, the model shall additionally provide:

$$
X_A,\quad
Z_A,
$$

where the subscript $A$ denotes aerodynamic force.

## 4. Data Provenance

Numerical parameters shall be obtained only through the controlled files:

- `../03_data/aircraft_parameters.csv`;
- `../03_data/aerodynamic_coefficients.csv`;
- `../03_data/source_register.csv`.

The current research coefficient set is marked `PROPOSED`, not `BASELINED`.

The current candidate dataset contains, among other quantities:

$$
C_{L_\alpha},\quad
C_{m_\alpha},\quad
C_{L_q},\quad
C_{m_q},\quad
C_{L_{\delta_e}},\quad
C_{m_{\delta_e}},
$$

plus candidate $\dot{\alpha}$ derivatives.

These values shall not be used in final verification until source condition, normalization, and sign conventions have been reviewed.

## 5. Coordinate and Sign Convention

The body-axis convention is defined in `../01_docs/coordinate_systems.md`.

For the research model:

- $+X_B$ points forward;
- $+Z_B$ points downward;
- positive pitching moment $M$ is nose-up;
- positive elevator deflection $\delta_e$ is defined as trailing-edge down.

The literature source convention for elevator deflection must be reconciled before control derivatives are baselined.

## 6. Airspeed and Angle of Attack

For the longitudinal case with negligible sideslip:

$$
V
=
\sqrt{u^2+w^2}.
$$

Angle of attack is defined as

$$
\alpha
=
\tan^{-1}\left(\frac{w}{u}\right).
$$

For small perturbations about a trim condition:

$$
u = U_0 + \Delta u
$$

and

$$
w = W_0 + \Delta w.
$$

If the trim condition has small $W_0$ and the perturbations remain small, then:

$$
\Delta\alpha
\approx
\frac{\Delta w}{U_0}.
$$

This approximation shall be used only in the linear model, not as a replacement for the nonlinear angle calculation when the nonlinear reference model is available.

## 7. Atmospheric Dynamic Pressure

Dynamic pressure is defined as

$$
\bar{q}
=
\frac{1}{2}\rho V^2.
$$

The same atmospheric state shall be used consistently by trim, aerodynamic-force calculation, and dimensional-derivative conversion.

## 8. Lift Coefficient Model

The baseline candidate lift model is

$$
C_L
=
C_{L_0}
+
C_{L_\alpha}\alpha
+
C_{L_q}\frac{q\bar{c}}{2V}
+
C_{L_{\delta_e}}\delta_e.
$$

If the selected literature source supports an angle-of-attack-rate term, the model may be extended to

$$
C_L
=
C_{L_0}
+
C_{L_\alpha}\alpha
+
C_{L_q}\frac{q\bar{c}}{2V}
+
C_{L_{\dot{\alpha}}}
\frac{\dot{\alpha}\bar{c}}{2V}
+
C_{L_{\delta_e}}\delta_e.
$$

The $\dot{\alpha}$ term shall remain disabled until its normalization is confirmed.

## 9. Drag Coefficient Model

The initial candidate drag model is a parabolic drag polar:

$$
C_D
=
C_{D_0}
+
K C_L^2.
$$

This representation is adequate for the initial research trim and longitudinal analysis only if its source applicability is confirmed.

The model does not initially represent:

- compressibility drag rise;
- flap-dependent drag increments;
- landing-gear drag increments;
- spoiler drag;
- Reynolds-number scheduling;
- Mach-dependent wave drag.

If the chosen nominal operating point makes any omitted effect material, the model shall be revised before baseline.

## 10. Pitching-Moment Coefficient Model

The baseline candidate pitching-moment model is

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

If justified by the selected literature model, an angle-of-attack-rate term may be added:

$$
C_m
=
C_{m_0}
+
C_{m_\alpha}\alpha
+
C_{m_q}\frac{q\bar{c}}{2V}
+
C_{m_{\dot{\alpha}}}
\frac{\dot{\alpha}\bar{c}}{2V}
+
C_{m_{\delta_e}}\delta_e.
$$

## 11. Aerodynamic Loads

Lift is

$$
L
=
\bar{q}SC_L.
$$

Drag is

$$
D
=
\bar{q}SC_D.
$$

Pitching moment about the adopted reference point is

$$
M_A
=
\bar{q}S\bar{c}C_m.
$$

The moment reference and center-of-gravity relationship must be documented before final trim analysis.

## 12. Wind-Axis to Body-Axis Transformation

For zero sideslip and the body-axis convention used by the project, aerodynamic force components are formed from lift and drag using angle of attack.

A candidate transformation is

$$
X_A
=
-D\cos\alpha
+
L\sin\alpha,
$$

$$
Z_A
=
-D\sin\alpha
-
L\cos\alpha.
$$

This transformation shall be verified using limiting cases.

At

$$
\alpha=0,
$$

the equations reduce to

$$
X_A=-D
$$

and

$$
Z_A=-L.
$$

Because $+Z_B$ is downward and lift acts upward, the sign of $Z_A$ is therefore negative in positive-lift level flight.

## 13. Propulsive Contribution

The initial aerodynamic model does not include detailed engine dynamics.

Where trim requires propulsion, the total body-axis force may be represented as

$$
X
=
X_A+X_T,
$$

$$
Z
=
Z_A+Z_T,
$$

and pitching moment as

$$
M
=
M_A+M_T.
$$

For the first longitudinal baseline, thrust may be treated as an equivalent trim variable if the thrust-line geometry is not required by the selected model.

Detailed CFM56/V2500 transient behavior and FADEC logic remain outside scope.

## 14. Gravity Is Not Aerodynamics

Gravity shall not be included inside aerodynamic coefficients.

Aerodynamic loads are generated by the aerodynamic model. Gravity is introduced separately in the rigid-body equations of motion.

This separation is required so that:

$$
\text{Aerodynamics}
+
\text{Propulsion}
+
\text{Gravity}
=
\text{Rigid-Body Dynamics}.
$$

## 15. Trim Use

At steady trim:

$$
q_0=0,
$$

and, for steady level flight,

$$
\dot{u}_0=0,
\qquad
\dot{w}_0=0,
\qquad
\dot{q}_0=0.
$$

The trim solver will determine values such as

$$
\alpha_0,\quad
\theta_0,\quad
\delta_{e0},\quad
T_0
$$

subject to the selected operating condition.

The aerodynamic model shall not hard-code these values.

## 16. Small-Disturbance Aerodynamic Expansion

For a generic aerodynamic quantity $C$,

$$
C
=
C_0
+
\frac{\partial C}{\partial \alpha}\Delta\alpha
+
\frac{\partial C}{\partial q}\Delta q
+
\frac{\partial C}{\partial \delta_e}\Delta\delta_e
+
\cdots.
$$

The coefficient derivatives are local sensitivities.

For example:

$$
C_{m_\alpha}
=
\frac{\partial C_m}{\partial\alpha},
$$

$$
C_{m_q}
=
\frac{\partial C_m}
{\partial\left(q\bar{c}/2V\right)},
$$

$$
C_{m_{\delta_e}}
=
\frac{\partial C_m}{\partial\delta_e}.
$$

This distinction is important when converting nondimensional derivatives into dimensional state-space coefficients.

## 17. Dimensional Derivative Path

The aerodynamic coefficients are not inserted directly into $A_L$ and $B_L$ without conversion.

The derivation path is:

$$
C_L,\ C_D,\ C_m
\rightarrow
L,\ D,\ M
\rightarrow
X,\ Z,\ M
\rightarrow
X_u,\ X_w,\ Z_u,\ Z_w,\ M_u,\ M_w,\ M_q,\ldots
\rightarrow
A_L,\ B_L.
$$

For example, a pitching-moment derivative with respect to angle of attack can be related to the coefficient derivative by a form such as

$$
M_\alpha
=
\frac{\bar{q}S\bar{c}}{I_y}
C_{m_\alpha}
$$

when $M_\alpha$ is defined as an angular-acceleration derivative.

The exact dimensional-derivative definitions shall be stated in `equations_of_motion.md` and in the future linearization design document.

## 18. Static Longitudinal Stability Check

Under common conventions, a statically stable longitudinal research model is expected to exhibit a restoring pitching-moment tendency with increasing angle of attack.

This corresponds conceptually to

$$
C_{m_\alpha}<0.
$$

This sign check is necessary but not sufficient to validate the complete aircraft model.

## 19. Pitch-Rate Damping Check

Under common normalization and signs, pitch-rate damping is expected to provide a moment opposing pitch rate.

A candidate literature value with

$$
C_{m_q}<0
$$

is therefore qualitatively consistent with damping under the project body-axis moment convention.

The exact source normalization shall still be verified before the coefficient is baselined.

## 20. Elevator Effectiveness Check

The project defines

$$
\delta_e>0
$$

as trailing-edge down.

The sign of

$$
C_{m_{\delta_e}}
$$

shall be checked against the literature source convention before use.

No controller feedback sign shall be finalized until this check is complete.

## 21. Computational Architecture

The intended MATLAB structure is:

```text
load_aircraft_parameters.m
        |
        v
atmosphere_model.m
        |
        v
aerodynamic_model.m
        |
        +--> CL
        +--> CD
        +--> Cm
        +--> L
        +--> D
        +--> X_A
        +--> Z_A
        +--> M_A
```

A later Simulink implementation shall use the same baselined parameter source.

## 22. Proposed MATLAB Interface

The eventual MATLAB function may use an interface conceptually similar to:

```matlab
aero = aerodynamic_model(state, control, atmosphere, aircraft, coeffs);
```

Expected outputs:

```text
aero.CL
aero.CD
aero.Cm
aero.L_N
aero.D_N
aero.X_N
aero.Z_N
aero.M_Nm
```

The exact function implementation is not frozen by this design document.

## 23. Data Quality Gates

Before a coefficient becomes `BASELINED`, the following shall be complete:

- source identity confirmed;
- A320-200 applicability reviewed;
- flight condition recorded;
- normalization recorded;
- units recorded;
- elevator convention reconciled;
- coefficient sign reviewed;
- implementation equation reviewed;
- source register updated.

## 24. Aerodynamic Verification Cases

The future verification plan shall include at minimum:

### AERO-TC-001 — Dynamic pressure

Verify

$$
\bar{q}
=
\frac{1}{2}\rho V^2
$$

against an independent calculation.

### AERO-TC-002 — Zero-angle force transformation

For

$$
\alpha=0,
$$

verify

$$
X_A=-D,
\qquad
Z_A=-L.
$$

### AERO-TC-003 — Positive angle-of-attack sensitivity

Apply a small positive $\Delta\alpha$ and verify that the change in $C_L$ agrees with the adopted $C_{L_\alpha}$.

### AERO-TC-004 — Pitching-moment sensitivity

Apply a small positive $\Delta\alpha$ and verify that the change in $C_m$ agrees with the adopted $C_{m_\alpha}$.

### AERO-TC-005 — Pitch-rate damping term

Apply positive and negative $q$ values and verify the incremental $C_m$ contribution implied by $C_{m_q}$.

### AERO-TC-006 — Elevator derivative

Apply positive and negative $\delta_e$ after source sign reconciliation and verify the expected $C_L$ and $C_m$ increments.

### AERO-TC-007 — No non-finite output

For valid nominal inputs, verify that all aerodynamic outputs are finite.

## 25. Open Design Items

The following items remain open:

| Item | Status |
|---|---|
| Exact nominal altitude | TBD |
| Exact nominal airspeed/Mach | TBD |
| Nominal analysis mass | PROPOSED |
| Pitch inertia $I_y$ | PROPOSED |
| Wing reference area $S$ | PROPOSED |
| Reference chord $\bar{c}$ | PROPOSED |
| Aerodynamic derivative source normalization | TO REVIEW |
| Elevator sign conversion | TO REVIEW |
| $\dot{\alpha}$ derivative inclusion | TO DECIDE |
| Detailed thrust model | DEFERRED |
| CG/moment-reference definition | TO REVIEW |

## 26. Design Limitations

This model does not represent the full A320 aerodynamic envelope.

It does not currently include:

- nonlinear stall/post-stall aerodynamics;
- Mach scheduling of derivatives;
- high-lift-device schedules;
- ground effect;
- spoiler aerodynamics;
- aeroelastic effects;
- full propulsion/aerodynamic interaction;
- flight-test correction tables.

The model is intended for a traceable longitudinal research analysis near one documented operating point.

## 27. Design Acceptance Criteria

This aerodynamic design can be considered ready for implementation when:

- the nominal operating point is selected;
- the source coefficient set is reviewed;
- the coefficient sign conventions are reconciled;
- $S$, $\bar{c}$, $m$, and $I_y$ are accepted for the research model;
- all required parameters are present in the controlled data files;
- the force/moment equations pass analytical review.

Only then should the final MATLAB aerodynamic implementation be baselined.
