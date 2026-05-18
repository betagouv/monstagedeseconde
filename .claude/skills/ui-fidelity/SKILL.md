---
name: ui-fidelity
description: "Ensure any proposed UI code change preserves the existing visual system and interaction patterns of the project."
argument-hint: "Describe the UI changes or provide the relevant code snippet for evaluation"
user-invocable: true
---
# UI Fidelity Skill

## Purpose
Ensure any proposed UI code change preserves the existing visual system and interaction patterns of the project.

## Core Rule
This skill is designed to maintain visual consistency and user familiarity across the application.
Do not introduce a new visual language when extending existing screens. Match the current UI first, then improve only when explicitly requested.

## Required Checks Before Proposing UI Code
1. Spacing scale must follow existing spacing rhythm used in nearby components.
2. Button styles must reuse current button variants, colors, radius, padding, and hover or focus behavior.
3. Typography must match established font sizes, weights, line heights, and text color hierarchy.
4. Color usage must reuse existing palette and semantic intent for primary, secondary, danger, *success, muted states.
5. Border radius, shadows, and outlines must align with surrounding components.
6. Component states must be complete and consistent:
* default
* hover
* focus visible
* active
* disabled
* loading if relevant
7. Responsive behavior must match existing breakpoints and layout patterns.
8. Dark or light theme behavior must follow current project conventions where applicable.

## Implementation Guidelines
1. Prefer reusing existing partials, helpers, utility patterns, and component class recipes before creating new ones.
2. If a new class combination is needed, derive it from nearby patterns rather than inventing a new style system.
3. Keep visual changes minimal when solving functional issues.
4. If deviation is necessary, explicitly state:
* what changed
* why it is needed
* where it aligns with current design intent

## Forbidden Without Explicit Request
1. Introducing a new button style family.
2. Changing global spacing rhythm.
3. Rebranding color direction.
4. Replacing established interaction patterns with a different UI paradigm.

## Output Expectation For Proposals
Each UI proposal must include:

1. A short note describing which existing UI patterns were matched.
2. A short list of reused tokens or class patterns.
3. Any intentional deviation with justification.