# Airbus A320-200 Longitudinal Flight Dynamics and Control

## Engineering Portfolio Project

This repository documents the development of an **Airbus A320-200-inspired longitudinal flight-dynamics and pitch-control research model** using requirements-based, verification-oriented aerospace engineering practices.

The project is structured to demonstrate the complete engineering chain around a control implementation:

```math
\text{Requirements}
\rightarrow
\text{Aircraft Data}
\rightarrow
\text{Mathematical Design}
\rightarrow
\text{Implementation}
\rightarrow
\text{Verification}
\rightarrow
\text{Traceability}
```

The objective is not simply to produce a working MATLAB or Simulink model. The objective is to demonstrate how flight-control software and analysis are supported by controlled assumptions, source data, mathematical derivation, configuration discipline, verification evidence, and documented limitations.

---

## 1. Project Objective

The project develops a longitudinal A320-200 research model suitable for:

- nominal trim analysis;
- small-disturbance longitudinal dynamics;
- state-space model generation;
- short-period and phugoid mode analysis;
- pitch-rate damping design;
- open-loop and closed-loop verification;
- MATLAB and Simulink implementation;
- model-to-model comparison;
- parameter sensitivity studies;
- requirements traceability.

The initial longitudinal state vector is

```math
x_L
=
\begin{bmatrix}
\Delta u \\
\Delta w \\
\Delta q \\
\Delta\theta
\end{bmatrix},
```

with equivalent elevator perturbation input

```math
\Delta\delta_e.
```

The target linear model is

```math
\Delta\dot{x}_L
=
A_L\Delta x_L
+
B_L\Delta\delta_e.
```

---

## 2. Engineering Scope

The current repository focuses on longitudinal rigid-body aircraft dynamics near one documented nominal operating point.

The engineering workflow includes:

1. aircraft configuration definition;
2. coordinate and sign conventions;
3. modeling assumptions;
4. controlled aircraft-data provenance;
5. aerodynamic coefficient modeling;
6. nonlinear longitudinal equations of motion;
7. trim analysis;
8. linearization;
9. state-space model construction;
10. open-loop stability analysis;
11. short-period and phugoid identification;
12. pitch-rate damping control design;
13. actuator constraint handling;
14. MATLAB/Simulink consistency verification;
15. sensitivity analysis;
16. requirements-to-test traceability.

---

## 3. Reference Aircraft

The reference platform is the **Airbus A320-200**.

The repository uses the term:

> **A320-200 Research Model**

to distinguish the portfolio model from an Airbus production, proprietary, or certification model.

The current aircraft configuration baseline uses the A320-200 with wing-tip fences where the manufacturer geometry requires a configuration choice.

Public Airbus data is used where available.

Aircraft-specific data not available from Airbus public documentation is handled using the controlled provenance classes defined below.

---

## 4. Data Provenance Policy

Every numerical aircraft parameter is assigned one of the following classifications:

| Classification | Meaning |
|---|---|
| `OEM-PUBLIC` | Publicly documented by Airbus |
| `REGULATORY` | Published by an applicable regulatory authority |
| `LITERATURE` | Obtained from traceable engineering or academic literature |
| `DERIVED` | Calculated from registered source data |
| `ASSUMED` | Explicit engineering assumption |
| `TBD` | Required value not yet accepted into the model |

A central project rule is:

> **No numerical aircraft parameter enters the executable model without a source classification, units, and traceable record.**

The controlled data files are:

```text
data/
├── aircraft_parameters.csv
├── aerodynamic_coefficients.csv
└── source_register.csv
```

Literature-derived aerodynamic coefficients are not described as Airbus OEM data.

---

## 5. Mathematical Model

The nonlinear longitudinal rigid-body research equations are derived from Newton-Euler dynamics.

The current longitudinal form is:

```math
\dot{u}
=
\frac{X_A+X_T}{m}
-g\sin\theta
-qw,
```

```math
\dot{w}
=
\frac{Z_A+Z_T}{m}
+g\cos\theta
+qu,
```

```math
\dot{q}
=
\frac{M_A+M_T}{I_y},
```

```math
\dot{\theta}
=
q.
```

Aerodynamic loads are generated from coefficient models such as

```math
L
=
\bar{q}SC_L,
```

```math
D
=
\bar{q}SC_D,
```

```math
M_A
=
\bar{q}S\bar{c}C_m,
```

where dynamic pressure is

```math
\bar{q}
=
\frac{1}{2}\rho V^2.
```

A candidate research lift model is

```math
C_L
=
C_{L_0}
+
C_{L_\alpha}\alpha
+
C_{L_q}\frac{q\bar{c}}{2V}
+
C_{L_{\delta_e}}\delta_e,
```

and the corresponding pitching-moment model is

```math
C_m
=
C_{m_0}
+
C_{m_\alpha}\alpha
+
C_{m_q}\frac{q\bar{c}}{2V}
+
C_{m_{\delta_e}}\delta_e.
```

All coefficient normalizations and sign conventions must be reviewed before the research coefficient set is promoted from `PROPOSED` to `BASELINED`.

---

## 6. Trim and Linearization

The nonlinear model is represented abstractly as

```math
\dot{x}
=
f(x,u).
```

A nominal trim point satisfies the defined steady-flight conditions, including

```math
\dot{u}_0
\approx
0,
```

```math
\dot{w}_0
\approx
0,
```

```math
\dot{q}_0
\approx
0.
```

The linearized model is obtained around the operating point:

```math
A_L
=
\left.
\frac{\partial f_L}{\partial x_L}
\right|_{x_0,u_0},
```

```math
B_L
=
\left.
\frac{\partial f_L}{\partial \delta_e}
\right|_{x_0,u_0}.
```

The resulting matrices are not treated as universal A320 matrices. Every reported $A_L$ and $B_L$ pair must identify the operating condition and parameter baseline from which it was generated.

---

## 7. Stability Analysis

Open-loop stability is evaluated from

```math
\lambda_i
=
\operatorname{eig}(A_L).
```

For a complex-conjugate mode

```math
\lambda
=
\sigma
\pm
j\omega_d,
```

the natural frequency is

```math
\omega_n
=
\sqrt{\sigma^2+\omega_d^2},
```

and the damping ratio is

```math
\zeta
=
-\frac{\sigma}{\omega_n}.
```

The project identifies the:

- short-period mode;
- phugoid mode;

using modal frequency, damping, and state participation or equivalent eigenvector evidence.

Mode labels are not assigned only from visual inspection of plots.

---

## 8. Pitch-Control Design

The initial research controller is a pitch-rate damper.

The baseline signed-gain form is

```math
\Delta\delta_{e,\mathrm{damp}}
=
K_q\Delta q.
```

For

```math
C_q
=
\begin{bmatrix}
0 & 0 & 1 & 0
\end{bmatrix},
```

the closed-loop state matrix is

```math
A_{CL}
=
A_L
+
B_LK_qC_q.
```

The sign and magnitude of $K_q$ are not assumed in advance.

They are selected using:

- the adopted elevator convention;
- the sign of the control derivative;
- pole migration;
- short-period damping;
- stability of all modeled longitudinal modes;
- elevator demand;
- time-domain response.

The controller is accepted only after the feedback direction and closed-loop behavior are verified.

---

## 9. Requirements-Based Development

The repository separates requirements into:

```text
requirements/
├── system_requirements.md
├── model_requirements.md
└── control_requirements.md
```

Requirement identifiers follow:

```text
SYS-xxx
MDL-xxx
CTL-xxx
```

The intended traceability chain is:

```math
\text{Requirement}
\rightarrow
\text{Design}
\rightarrow
\text{Implementation}
\rightarrow
\text{Verification Case}
\rightarrow
\text{Result}.
```

A result is not considered verified simply because a simulation executes or a plot appears reasonable.

---

## 10. Verification Philosophy

The planned verification approach includes:

- source-data review;
- sign-convention checks;
- dimensional-consistency checks;
- trim residual verification;
- state-space matrix dimension checks;
- finite-difference Jacobian comparison;
- open-loop eigenvalue verification;
- mode identification;
- positive and negative disturbance testing;
- actuator boundary tests;
- MATLAB-versus-Simulink comparison;
- parameter sensitivity analysis;
- regression testing;
- requirements coverage review.

Verification results shall be classified as:

```text
PASS
FAIL
NOT VERIFIED
```

Failed tests are retained as engineering evidence and must be rerun after corrective changes.

---

## 11. Repository Structure

```text
A320-200-Longitudinal-Flight-Dynamics-Control/
│
├── README.md
├── CHANGELOG.md
│
├── 01_docs/
│   ├── aircraft_definition.md
│   ├── coordinate_systems.md
│   ├── modeling_assumptions.md
│   ├── data_provenance.md
│   └── model_limitations.md
│
├── 02_requirements/
│   ├── system_requirements.md
│   ├── model_requirements.md
│   └── control_requirements.md
│
├── 03_data/
│   ├── aircraft_parameters.csv
│   ├── aerodynamic_coefficients.csv
│   └── source_register.csv
│
├── 04_design/
│   ├── aerodynamics_model.md
│   ├── equations_of_motion.md
│   ├── trim_model.md
│   ├── linearization.md
│   ├── stability_analysis.md
│   └── pitch_damper_design.md
│
├── 05_matlab/
├── 06_simulink/
├── 07_verification/
├── 08_traceability/
├── 09_configuration/
└── 10_results/
```

Folders may appear incrementally as implementation and verification artifacts are completed.

---

## 12. Current Project Status

### Completed

- project aircraft definition;
- coordinate-system definition;
- modeling assumptions;
- data-provenance policy;
- model limitations;
- system requirements;
- model requirements;
- control requirements;
- aircraft parameter register;
- aerodynamic coefficient register;
- source register;
- aerodynamic model design;
- equations-of-motion design.

### In Progress

- trim-model design;
- nominal operating-point selection;
- literature-source normalization review;
- elevator sign-convention reconciliation.

### Planned

- linearization design;
- stability-analysis design;
- pitch-damper design;
- MATLAB implementation;
- Simulink implementation;
- verification procedures;
- traceability matrix;
- final engineering results.

---

## 13. Open Engineering Items

The following items are intentionally unresolved and remain controlled engineering decisions:

| Item | Status |
|---|---|
| Nominal altitude $h_0$ | `TBD` |
| Nominal airspeed $V_0$ | `TBD` |
| Nominal Mach number $M_0$ | `TBD` |
| Analysis mass $m_0$ | `PROPOSED` |
| Pitch inertia $I_y$ | `PROPOSED` |
| Center-of-gravity convention | `TO REVIEW` |
| Aerodynamic derivative normalization | `TO REVIEW` |
| Elevator source sign convention | `TO REVIEW` |
| Trim tolerance | `TBD` |
| Linearization comparison tolerance | `TBD` |
| MATLAB/Simulink comparison tolerance | `TBD` |

These values are not silently guessed to make the model run.

---

## 14. Key Engineering Limitations

The project does not reproduce:

- Airbus proprietary aerodynamic databases;
- Airbus production flight-control software;
- Airbus Normal, Alternate, or Direct Law;
- certified handling-qualities results;
- a full A320 flight envelope;
- aeroelasticity;
- detailed propulsion dynamics;
- complete sensor and actuator architecture;
- production flight-control computers;
- aircraft qualification or certification.

The current model is intended for longitudinal research analysis near a controlled nominal operating condition.

See:

[`01_docs/model_limitations.md`](01_01_docs/model_limitations.md)

for the detailed limitation register.

---

## 15. Certification Position

This repository may use practices associated with aerospace software development, including:

- identified requirements;
- controlled data;
- design documentation;
- verification planning;
- test evidence;
- traceability;
- configuration records;
- change history.

These practices do **not** constitute DO-178C, ARP4754A, ARP4761A, CS-25, or other certification compliance by themselves.

The repository is an educational engineering portfolio project.

---

## 16. Tools

The planned engineering environment includes:

- MATLAB;
- Simulink;
- Control System Toolbox;
- Git;
- GitHub;
- Visual Studio Code.

Tool versions used for baselined verification results will be recorded under:

```text
configuration/
```

---

## 17. Reproducing the Project

Once implementation files are added, the intended workflow will be:

```text
1. Clone repository
2. Review controlled data
3. Load project parameters
4. Solve nominal trim condition
5. Generate longitudinal state-space model
6. Perform open-loop stability analysis
7. Design pitch-rate damper
8. Run verification suite
9. Generate engineering results
```

The final implementation shall avoid undocumented manual parameter entry.

---

## 18. Engineering Deliverables

The repository is intended to produce the following final evidence:

- aircraft/configuration definition;
- source and data register;
- modeling-assumption register;
- system/model/control requirements;
- aerodynamic design;
- rigid-body equations of motion;
- trim design and results;
- linearized $A_L$ and $B_L$ matrices;
- modal stability report;
- pitch-damper gain trade study;
- MATLAB reference implementation;
- Simulink implementation;
- verification cases and procedures;
- verification results;
- sensitivity analysis;
- requirements traceability matrix;
- configuration/change history;
- final technical report.

---

## 19. Portfolio Claim

The intended professional description of this work is:

> Developed an A320-200-inspired longitudinal flight-dynamics and pitch-control research model using public manufacturer data, traceable literature inputs, explicit engineering assumptions, requirements-based development, stability analysis, control-law design, and verification-oriented model traceability.

The repository does not claim development of Airbus production software or an Airbus-certified aerodynamic model.

---

## 20. References

Primary public manufacturer and regulatory references are tracked in:

[`03_data/source_register.csv`](03_03_data/source_register.csv)

Key source categories include:

- Airbus public aircraft documentation;
- Airbus A320 Aircraft Characteristics documentation;
- EASA aircraft certification documentation;
- traceable A320 research literature.

All aircraft-specific numerical inputs shall remain traceable through the source register.
