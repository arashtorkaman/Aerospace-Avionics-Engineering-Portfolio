# Data Provenance and Source-Control Policy

**Project:** A320-200 Longitudinal Flight Dynamics and Control  
**Document ID:** DOC-DATA-001  
**Revision:** 0.1  
**Status:** Draft engineering baseline  
**Date:** 2026-09-10  

## 1. Purpose

This document defines how numerical aircraft data enters the A320-200 Research Model.

The project shall preserve the distinction between manufacturer-published data, external literature data, values derived by the project, and explicit engineering assumptions.

The core rule is:

> **No numerical aircraft parameter may enter MATLAB, Simulink, C++, or a verification script until it is registered with a source classification and units.**

## 2. Provenance Classes

Every parameter shall be assigned exactly one primary provenance class.

### `OEM-PUBLIC`

Data published by Airbus in a publicly accessible manufacturer document or Airbus web resource.

Examples:

- external dimensions;
- certified or published weight limits;
- engine-family applicability;
- general aircraft configuration.

`OEM-PUBLIC` does **not** imply that a value is valid for every A320-200 weight variant or configuration.

### `REGULATORY`

Data published in an applicable regulatory certification source such as an EASA Type Certificate Data Sheet.

Regulatory data is used primarily for aircraft/model identification, approved configurations, and certification context.

### `LITERATURE`

Data from a traceable technical paper, thesis, textbook, university report, conference paper, or other engineering publication.

Examples may include:

- aerodynamic stability derivatives;
- estimated inertia properties;
- research trim conditions;
- published state-space matrices.

Literature values shall never be relabeled as Airbus proprietary or Airbus-validated data.

### `DERIVED`

A value calculated by this project from one or more registered inputs.

Examples:

```math
\bar q = \frac{1}{2}\rho V^2
```

or a dimensional derivative computed from a nondimensional aerodynamic coefficient.

A derived value shall identify the equation or script used to calculate it.

### `ASSUMED`

A value deliberately selected because sufficiently authoritative public data is not available.

An assumed value must include:

- engineering rationale;
- intended validity range;
- sensitivity/uncertainty treatment where relevant.

### `TBD`

A required parameter that has not yet been accepted into the model baseline.

`TBD` values shall not be replaced silently with guessed numbers in executable code.

## 3. Source Hierarchy

When multiple candidate values exist, the default preference order is:

1. Airbus public technical documentation;
2. applicable EASA regulatory documentation;
3. peer-reviewed or academically supervised A320-specific literature;
4. other traceable A320 research models;
5. derived engineering approximation;
6. explicit assumption.

Higher source rank does not automatically make a value usable. Applicability to the modeled variant, configuration, units, and flight condition must also be checked.

## 4. Source Register

The repository shall contain:

`data/source_register.csv`

Recommended columns:

```text
parameter_id,
parameter_name,
symbol,
value,
units,
provenance_class,
source_title,
source_organization,
source_year,
source_url_or_doi,
source_page_or_section,
aircraft_variant,
flight_condition,
configuration,
original_units,
conversion_applied,
uncertainty_or_range,
status,
review_notes
```

## 5. Parameter Identification

Each significant model parameter shall receive a stable identifier.

Examples:

```text
GEO-001  Overall aircraft length
GEO-002  Wing span
GEO-003  Wing reference area
MASS-001 Nominal analysis mass
INER-001 Pitch moment of inertia
AERO-001 CL_alpha
AERO-002 Cm_alpha
AERO-003 Cm_q
CTRL-001 Cm_delta_e
ATM-001  Nominal density
```

IDs shall remain stable even if numerical values change.

## 6. Current Manufacturer Baseline

The initial manufacturer-supported entries are:

| ID | Parameter | Value | Unit | Class | Applicability |
|---|---|---:|---|---|---|
| GEO-001 | Overall length | 37.57 | m | OEM-PUBLIC | A320-200 |
| GEO-002 | Geometric wingspan | 34.10 | m | OEM-PUBLIC | A320-200, wing-tip fence |
| GEO-004 | Fuselage width | 3.95 | m | OEM-PUBLIC | A320-200 |
| GEO-005 | Wheelbase | 12.64 | m | OEM-PUBLIC | A320-200 |
| GEO-006 | Main landing-gear track | 7.59 | m | OEM-PUBLIC | A320-200 |

Airbus also documents multiple A320-200 weight variants, including variants with MTOW values ranging across several approved configurations. For this reason, a single MTOW is not adopted as the model mass.

The nominal flight-dynamics mass remains `TBD`.

## 7. Configuration Applicability

A parameter shall be rejected or quarantined if its configuration applicability is unknown and materially affects the analysis.

Examples requiring configuration checks include:

- wing-tip fence versus Sharklet geometry;
- flap/slat configuration;
- engine installation;
- weight variant;
- center-of-gravity position;
- Mach number;
- altitude;
- Reynolds number;
- trim angle of attack.

A derivative set at one condition shall not be combined with an unrelated condition merely because both sources say "A320."

## 8. Unit Conversion

All executable model parameters shall use SI units.

If a source provides another unit system:

1. preserve the source value and unit in the source register;
2. record the conversion equation;
3. store the converted value separately;
4. include an automated conversion test where practical.

Example:

```math
m_{\mathrm{kg}}
=
m_{\mathrm{lbm}}\times 0.45359237.
```

Angles used by computational equations shall be converted to radians.

## 9. Sign-Convention Conversion

Aerodynamic derivative signs are meaningful only with their source convention.

Before importing a derivative such as

```math
C_{m_{\delta_e}},
```

the following shall be identified:

- positive body-axis directions;
- positive pitch moment;
- positive angle of attack;
- positive elevator deflection;
- whether derivatives are dimensional or nondimensional.

If the source convention differs from the project convention, the conversion shall be recorded.

An unexplained sign change is not permitted.

## 10. Derived Data

For `DERIVED` values, provenance must trace through the calculation.

For example:

```text
AERO-DIM-003
Derived from:
- AERO-003 Cm_q
- GEO-003 wing area
- GEO-007 mean aerodynamic chord
- MASS-001 mass
- INER-001 Iy
- ATM-001 density
- FLT-001 trim airspeed

Derived by:
matlab/derive_dimensional_derivatives.m
```

This preserves traceability from final state-space terms back to source data.

## 11. Conflicting Sources

If two credible sources disagree:

1. do not average them automatically;
2. document both candidate values;
3. compare flight condition and sign convention;
4. determine which is more applicable;
5. record the selection rationale in a design-decision record;
6. use sensitivity analysis when uncertainty remains significant.

## 12. Source Status

Each parameter shall have one of these statuses:

- `PROPOSED`;
- `REVIEWED`;
- `BASELINED`;
- `REJECTED`;
- `SUPERSEDED`.

Only `BASELINED` parameters shall be used for final verification results.

Early exploratory scripts may use `PROPOSED` data only when clearly marked as exploratory.

## 13. Data Integrity

Model parameters shall be loaded from a controlled parameter file rather than copied into multiple scripts.

Preferred architecture:

```text
data/source_register.csv
        |
        v
data/aircraft_parameters.csv
        |
        v
matlab/load_aircraft_parameters.m
        |
        +--> trim
        +--> linearization
        +--> stability analysis
        +--> controller design
        +--> verification
```

This creates one authoritative computational baseline.

## 14. Required References

### Airbus manufacturer sources

Airbus, **A320ceo**  
https://www.aircraft.airbus.com/en/aircraft/a320-family/a320ceo

Airbus, **A320 Aircraft Characteristics — Airport and Maintenance Planning**, revision dated 15 July 2025  
https://www.aircraft.airbus.com/sites/g/files/jlcbta126/files/2025-07/AC_A320_20250715.pdf

### Regulatory source

EASA, **EASA.A.064 — Airbus A318, A319, A320, A321 Single Aisle**, Type Certificate Data Sheet listing  
https://www.easa.europa.eu/en/document-library/type-certificates

### Literature sources

A320-specific aerodynamic/stability literature will be entered here only after individual sources are reviewed for:

- variant;
- configuration;
- flight condition;
- coefficient definitions;
- sign conventions;
- dimensional consistency.

No literature-derived stability derivative is baselined in this document revision.

## 15. Review Checklist

Before accepting a numerical value, confirm:

- [ ] source exists and is retrievable;
- [ ] source organization/author is identified;
- [ ] aircraft variant is compatible;
- [ ] flight condition is known or irrelevant;
- [ ] configuration is compatible;
- [ ] units are known;
- [ ] sign convention is known;
- [ ] conversion is recorded;
- [ ] uncertainty is documented where relevant;
- [ ] source register entry exists;
- [ ] parameter status is appropriate.

A value that fails this checklist shall not be treated as model truth.
