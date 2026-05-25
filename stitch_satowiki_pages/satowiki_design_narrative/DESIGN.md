---
name: SatoWiki Design Narrative
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#dbc2ae'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#a38d7b'
  outline-variant: '#554335'
  surface-tint: '#ffb874'
  primary: '#ffb874'
  on-primary: '#4b2800'
  primary-container: '#f7931a'
  on-primary-container: '#603500'
  inverse-primary: '#8c4f00'
  secondary: '#c6c4df'
  on-secondary: '#2f2e43'
  secondary-container: '#47475d'
  on-secondary-container: '#b8b6d0'
  tertiary: '#53e16f'
  on-tertiary: '#003911'
  tertiary-container: '#30c456'
  on-tertiary-container: '#004a19'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdcbf'
  primary-fixed-dim: '#ffb874'
  on-primary-fixed: '#2d1600'
  on-primary-fixed-variant: '#6b3b00'
  secondary-fixed: '#e2e0fc'
  secondary-fixed-dim: '#c6c4df'
  on-secondary-fixed: '#1a1a2e'
  on-secondary-fixed-variant: '#45455b'
  tertiary-fixed: '#72fe88'
  tertiary-fixed-dim: '#53e16f'
  on-tertiary-fixed: '#002107'
  on-tertiary-fixed-variant: '#00531c'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  title-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  code-sm:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  margin-mobile: 16px
  margin-desktop: 64px
  gutter: 24px
  max-width-content: 800px
---

## Brand & Style
The design system for this project establishes a high-authority, technical editorial aesthetic tailored for the Bitcoin ecosystem. It positions the platform as the definitive "Orange Book" of digital sound money, blending the credibility of prestigious publications like *The Economist* with the functional precision of modern developer documentation.

The visual direction follows **Material Design 3 (Material You)** principles, modified for an editorial context. It utilizes a **Modern/Corporate** style characterized by:
- **Default Dark Mode:** A sophisticated "Midnight" environment that reduces eye strain for long-form reading.
- **Editorial Precision:** Strict typographic hierarchies and generous whitespace to ensure complex technical concepts remain digestible.
- **Functional Integrity:** Use of monospaced accents to honor the cryptographic roots of the subject matter.

## Colors
The palette is anchored by **Bitcoin Orange**, used strategically for primary actions and brand signifiers. To maintain an authoritative tone, the background defaults to a deep neutral (`#121212`), avoiding pure pitch black to allow for soft elevation layering.

- **Primary:** Reserved for call-to-actions, progress indicators, and key highlights.
- **Secondary:** Used for structural components like sidebars, navigation bars, and footer backgrounds to provide grounding.
- **Surface Strategy:** In dark mode, surfaces follow the Material 3 elevation model, where higher-level components (like cards or modals) use progressively lighter tints of the surface color (e.g., `#1E1E1E`) rather than drop shadows.

## Typography
The system uses **Inter** as the primary typeface for its exceptional legibility and neutral, modernist character. This provides the "technical magazine" feel when paired with the monospaced **JetBrains Mono**.

- **Display & Headlines:** High-weight Inter with slight negative letter-spacing for a compact, authoritative look.
- **Body Text:** Designed for deep reading. `body-lg` is preferred for main article content to mimic the comfortable tracking of print journalism.
- **Monospace Utility:** JetBrains Mono is utilized for hashes, transaction IDs, BIP references, and code snippets, signaling technical accuracy.

## Layout & Spacing
The layout philosophy centers on a **Fixed Grid** for content-heavy pages to ensure the "Orange Book" reading experience is never overwhelmed by ultra-wide screens.

- **Content Column:** Long-form text is restricted to a `800px` max-width container to maintain optimal line lengths (60-75 characters).
- **Grid:** A 12-column system on desktop with generous `24px` gutters.
- **Spacing Rhythm:** Based on an 8px baseline grid. Use `spacing-lg` (32px) and `spacing-xl` (48px) to separate major thematic sections, ensuring the "clean and generous whitespace" requested.
- **Mobile:** Transition to a single-column layout with `16px` side margins.

## Elevation & Depth
Consistent with Material 3, this design system eschews heavy, blurry shadows in favor of **Tonal Layers**.

- **Level 0 (Base):** Primary background (`#121212`).
- **Level 1 (Cards/Surface):** A slightly lighter gray (`#1E1E1E`). Used for article cards and secondary sections.
- **Level 2 (Navigation/Dialogs):** Further lightened surface color.
- **Outlines:** Use low-contrast `On Surface` outlines (1px, 10% opacity) for input fields and buttons to maintain structure without visual noise.
- **Interactions:** Subtle scale transforms (98%) are preferred over heavy glow effects for pressed states.

## Shapes
The shape language is **Soft (0.25rem)**. While Material 3 often uses very rounded corners, this design system utilizes a more restrained radius to preserve a serious, editorial tone. 

- **Standard Elements:** 4px (0.25rem) for buttons, inputs, and small components.
- **Large Containers:** 8px (0.5rem) for cards and modals.
- **Full-Bleed:** Article images and headers should remain sharp (0px) to maximize the "magazine" impact.

## Components
- **Buttons:** Primary buttons use `Primary Orange` with `On Surface (Light)` text for maximum contrast. High-emphasis buttons are rectangular with soft 4px corners.
- **Input Fields:** Outlined style with `JetBrains Mono` for the input text. Labels use `Inter` at `label-md`.
- **Cards:** No shadows. Use tonal elevation (`#1E1E1E`) and a subtle 1px border. Article cards should feature a prominent "time to read" label in monospace.
- **Material Symbols:** Use the "Outlined" variant exclusively. Stroke weight should be "Regular" (400) to match the Inter typeface weight.
- **Chips:** Used for tagging articles (e.g., #Mining, #Cryptography). These use the `Primary Container` background with Orange text to provide a pop of color in the dark UI.
- **BIP References:** A custom component—a small inline "tag" using JetBrains Mono with a secondary background, linking directly to technical documentation.