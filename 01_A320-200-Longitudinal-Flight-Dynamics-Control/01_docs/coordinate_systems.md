# Coordinate Systems and Sign Conventions

**Project:** A320-200 Longitudinal Flight Dynamics and Control  
**Document ID:** DOC-COORD-001  
**Revision:** 0.1  
**Status:** Draft engineering baseline  
**Date:** 2026-09-10  

## 1. Purpose

This document defines the coordinate systems, state-variable signs, aerodynamic angles, force and moment signs, and control-input conventions used by the A320-200 Research Model.

A single explicit convention is required because incorrect or inconsistent signs are a common source of errors in aircraft dynamics, linearization, and control-law implementation.

## 2. Body-Fixed Coordinate Frame

A right-handed aircraft body frame $\mathcal{F}_B$ is used.

Its origin is taken at the aircraft center of gravity for the rigid-body equations of motion.

The axes are:

- $+X_B$: forward along the fuselage;
- $+Y_B$: toward the right wing;
- $+Z_B$: downward.

The corresponding body-axis translational velocities are:

```math
\mathbf{V}_B =
\begin{bmatrix}
u \\ v \\ w
\end{bmatrix}.
```

Thus:

- $u>0$: forward velocity;
- $v>0$: velocity toward the right wing;
- $w>0$: downward body-axis velocity.

## 3. Angular Rates

The body angular-rate vector is

```math
\boldsymbol{\omega}_B =
\begin{bmatrix}
p \\ q \\ r
\end{bmatrix},
```

where:

- $p$: roll rate about $+X_B$;
- $q$: pitch rate about $+Y_B$;
- $r$: yaw rate about $+Z_B$.

Using the right-hand rule:

- $p>0$: right wing moves downward;
- $q>0$: nose pitches upward;
- $r>0$: nose yaws to the right.

## 4. Euler Attitude Angles

The Euler attitude angles are:

```math
\phi = \text{roll angle},
\qquad
\theta = \text{pitch angle},
\qquad
\psi = \text{yaw/heading angle}.
```

Positive directions follow the same right-hand convention as $p$, $q$, and $r$.

For the initial longitudinal model, the principal attitude variable is $\theta$.

Under the small-angle longitudinal approximation,

```math
\dot{\theta} \approx q.
```

This approximation shall be used only where its assumptions are valid and shall not be substituted for the full nonlinear attitude kinematics in a later 6-DOF model.

## 5. Local Earth / Navigation Frame

For trajectory quantities, a local North-East-Down frame may be used later:

- $+X_N$: north;
- $+Y_N$: east;
- $+Z_N$: down.

The initial small-disturbance longitudinal stability model does not require full Earth-frame navigation, but the convention is stated now to avoid later ambiguity.

## 6. Aerodynamic Angles

Total airspeed is defined as

```math
V = \sqrt{u^2+v^2+w^2}.
```

Angle of attack is defined as

```math
\alpha = \tan^{-1}\left(\frac{w}{u}\right)
```

for the longitudinal case.

For small perturbations about a trim speed $U_0$,

```math
\Delta \alpha \approx \frac{\Delta w}{U_0}
```

when the neglected higher-order terms are sufficiently small.

Sideslip angle may later be defined using the selected 6-DOF convention; it is outside the initial longitudinal scope.

## 7. Aerodynamic Forces

Body-axis aerodynamic and propulsive forces are represented as:

```math
\mathbf{F}_B =
\begin{bmatrix}
X \\ Y \\ Z
\end{bmatrix}.
```

The signs are:

- $X>0$: force forward;
- $Y>0$: force to the right;
- $Z>0$: force downward.

Lift $L$ is conventionally positive upward, so lift and body-axis $Z$ generally have opposite signs near level flight.

Drag $D$ is conventionally positive opposite the relative airflow.

Care must be taken when converting from wind-axis lift and drag to body-axis $X$ and $Z$.

## 8. Aerodynamic Moments

Moments about the body axes are:

```math
\mathbf{M}_B =
\begin{bmatrix}
L_m \\ M \\ N
\end{bmatrix},
```

where:

- $L_m$: rolling moment about $+X_B$;
- $M$: pitching moment about $+Y_B$;
- $N$: yawing moment about $+Z_B$.

The symbol $L_m$ is used in documentation when necessary to distinguish rolling moment from aerodynamic lift $L$.

For longitudinal dynamics:

```math
M>0
```

corresponds to a nose-up pitching moment.

## 9. Elevator Deflection Convention

For this research model:

```math
\delta_e > 0
```

is defined as **elevator trailing-edge down**.

This convention is a project modeling choice and must be applied consistently to aerodynamic coefficients, state-space matrices, Simulink blocks, controller gains, and test cases.

Because the sign of $C_{m_{\delta_e}}$ depends on the deflection convention used by a source, every literature derivative shall be checked before import.

If a source uses the opposite elevator convention, the imported derivative shall be converted and the conversion shall be recorded in `data_provenance.md` and the source register.

No pitch-damper feedback sign shall be frozen until the adopted elevator-control derivative has been verified under this convention.

## 10. Perturbation Variables

The longitudinal linear model uses perturbations around a trim state.

For any state $x$,

```math
x = x_0 + \Delta x.
```

The linear-model state symbols $u$, $w$, $q$, and $\theta$ may be used as perturbation variables when the context is unambiguous.

Formally:

```math
x_L =
\begin{bmatrix}
\Delta u \\
\Delta w \\
\Delta q \\
\Delta \theta
\end{bmatrix}.
```

The input is:

```math
\Delta\delta_e = \delta_e - \delta_{e0}.
```

## 11. Longitudinal State-Space Convention

The model shall use

```math
\Delta\dot{x}_L
=
A_L\Delta x_L
+
B_L\Delta\delta_e.
```

Rows of $A_L$ correspond to:

1. $\Delta\dot{u}$,
2. $\Delta\dot{w}$,
3. $\Delta\dot{q}$,
4. $\Delta\dot{\theta}$.

Columns correspond to:

1. $\Delta u$,
2. $\Delta w$,
3. $\Delta q$,
4. $\Delta\theta$.

The input matrix $B_L$ corresponds to the elevator perturbation under the convention defined above.

## 12. Units

Internal computational units shall be SI:

| Quantity | Unit |
|---|---|
| Length | m |
| Time | s |
| Mass | kg |
| Linear velocity | m/s |
| Linear acceleration | m/s² |
| Force | N |
| Moment | N·m |
| Angle | rad |
| Angular rate | rad/s |
| Angular acceleration | rad/s² |
| Density | kg/m³ |
| Pressure | Pa |

Degrees may be used for presentation only. Conversions shall occur explicitly at software boundaries or plotting functions.

## 13. Sign-Convention Verification

Before the first control law is accepted, the following checks shall be performed:

1. positive $q$ produces the expected nose-up motion;
2. positive pitching moment produces increasing $q$;
3. positive elevator deflection has the moment direction implied by the adopted $C_{m_{\delta_e}}$;
4. gravity terms in the linearized equations have the expected signs;
5. a small positive angle-of-attack perturbation produces the force and moment directions implied by the imported derivatives;
6. MATLAB and Simulink use identical conventions.

Any failed check blocks controller tuning until the sign inconsistency is resolved.

## 14. Reference

The body-axis convention follows standard aerospace right-handed body axes. Aircraft-specific dimensional information is documented separately in `aircraft_definition.md`.
