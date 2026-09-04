# Kasoku Design System

Derived from the Writebook stylesheets in `app/assets/stylesheets/`. This document
describes the conventions, tokens, and component patterns those files establish, so
new CSS for Kasoku fits the same system.

## 1. Principles

- **Vanilla CSS, no preprocessor.** Propshaft serves the files as-is. Use native
  CSS nesting (`&`), custom properties, `:is()`, `:where()`, `:has()`,
  container queries, `@starting-style`, and `light-dark()`. Target evergreen
  browsers; no vendor fallbacks except `-webkit-` where there is no standard yet
  (`-webkit-mask`, `-webkit-line-clamp`, autofill).
- **Logical properties only.** `inline-size`, `block-size`, `margin-inline`,
  `padding-block`, `inset-block-start`, `border-block-end`, etc. Never `width`,
  `height`, `left`, `top`, `margin-left`. (Exceptions in the source are bugs,
  not a pattern.)
- **Units carry meaning.**
  - `ch` for horizontal (inline) spacing and text measure.
  - `rem` for vertical (block) spacing.
  - `em` inside components so they scale with `font-size`.
  - `lh` for vertical rhythm tied to line height (`margin-block: 0.65lh`).
  - `cqi` for fluid sizing inside a container (`clamp(1rem, 2.5cqi, 1.4rem)`).
  - `dvh`/`dvw` for viewport-sized overlays.
- **One file per concern**, loaded alphabetically by `stylesheet_link_tag :app`.
  `_reset.css` sorts first; `utilities.css` sorts last so utilities win the
  cascade. Any new file must not accidentally sort after `utilities.css`.
- **Low specificity by default.** Wrap element and structural selectors in
  `:where()` so component classes and utilities can override without `!important`.
  Avoid IDs in new code; the source uses `#main`, `#header`, `#toolbar`,
  `#footer` only for the singleton page regions.
- **Components expose a custom-property API.** Instead of many modifier classes,
  a component reads `var(--component-thing, default)` and variants or parents
  set those properties (`--btn-background`, `--input-border-color`,
  `--panel-size`, `--hover-size`).
- **State lives in the DOM, not in JS classes**, where possible. Checkbox/radio
  toggles drive UI via `:has(input:checked)`; dialogs via `[open]`; disabled via
  `[disabled]`; hidden via the `hidden` attribute.
- **Dark mode is automatic.** Colour is expressed as OKLCH triplets that are
  redefined under `@media (prefers-color-scheme: dark)`. Components never branch
  on dark mode themselves except for icon inversion.

## 2. Naming

BEM-flavoured, two levels max:

| Pattern          | Meaning                       | Example                          |
|------------------|-------------------------------|----------------------------------|
| `.block`         | Component root                | `.btn`, `.panel`, `.switch`      |
| `.block__part`   | Child that only makes sense inside the block | `.switch__btn`, `.panel__close` |
| `.block--variant`| Modifier on the root          | `.btn--negative`, `.input--file` |
| `.utility`       | Single-purpose, verb/noun     | `.pad-block-half`, `.txt-subtle` |
| `.state-verb`    | Behavioural hook for `:has()` | `.disable-when-empty`, `.no-print` |

Utility suffixes: `-half`, `-double` for scale; `-start`, `-end` for logical
sides; `--responsive` for fluid variants. Prefer `-none` (e.g. `.margin-none`)
over `no-`/`un-` for zeroing, except the established `.unpad` and `.borderless`.

## 3. Colour

### 3.1 Raw palette (`colors.css`)

Raw colours are OKLCH triplets (`L% C H`) without the `oklch()` wrapper so alpha
can be added at the call site: `oklch(var(--lch-red) / 0.1)`.

| Token               | Light             | Dark              |
|---------------------|-------------------|-------------------|
| `--lch-black`       | `0% 0 0`          | `100% 0 0`        |
| `--lch-white`       | `100% 0 0`        | `0% 0 0`          |
| `--lch-gray-light`  | `96% 0.005 96`    | `25.2% 0 0`       |
| `--lch-gray`        | `92% 0.005 96`    | `30.12% 0 0`      |
| `--lch-gray-dark`   | `75% 0.005 96`    | `44.95% 0 0`      |
| `--lch-blue`        | `54% 0.15 255`    | `72.25% 0.16 248` |
| `--lch-blue-light`  | `95% 0.03 255`    | `28.11% 0.053 248`|
| `--lch-blue-dark`   | `80% 0.08 255`    | `42.25% 0.07 248` |
| `--lch-red`         | `51% 0.2 31`      | `73.8% 0.184 29.18` |
| `--lch-green`       | `65.59% 0.234 142.49` | `75% 0.21 141.89` |
| `--lch-green-light` | `95% 0.03 142.49` | `28.11% 0.02 142.49` |
| `--lch-yellow`      | `92.62% 0.1 91.5` | `40.9% 0.06 88.9` |
| `--lch-orange`      | `70% 0.2 44`      | (unchanged)       |
| `--lch-always-black`| `0% 0 0`          | (unchanged)       |
| `--lch-always-white`| `100% 0 0`        | (unchanged)       |

Note `black`/`white` swap in dark mode; `always-*` do not.

### 3.2 Semantic tokens

Write components against these, never against `--lch-*` directly (except for
alpha blends).

| Token                    | Maps to            | Use for                                        |
|--------------------------|--------------------|------------------------------------------------|
| `--color-bg`             | white              | Page and panel background                      |
| `--color-ink`            | black              | Body text, primary borders on filled buttons    |
| `--color-ink-reversed`   | white              | Text on `ink`, `link`, `positive`, `negative` fills |
| `--color-link`           | blue               | Links, caret, primary action, "on" switch       |
| `--color-selected`       | blue-light         | Selection, focused-row background, autofill     |
| `--color-selected-dark`  | blue-dark          | Focused input border / ring                     |
| `--color-subtle-light`   | gray-light         | Sidebar/shaded fills, code background           |
| `--color-subtle`         | gray               | Hairline borders, code border, progress track   |
| `--color-subtle-dark`    | gray-dark          | Stronger borders (inputs, buttons, `hr`, tables), hover ring, muted text |
| `--color-positive`       | green              | Success                                         |
| `--color-positive-light` | green-light        | Success background                              |
| `--color-negative`       | red                | Destructive / error                             |
| `--color-highlight`      | yellow             | `mark`, search highlights                       |
| `--color-marker`         | orange             | Spare accent (unused so far)                    |
| `--color-always-black`   | always black       | Backdrops, shadows                              |
| `--color-always-white`   | always white       | Text over imagery                               |

Rules:

- Muted text is `--color-subtle-dark` (`.txt-subtle`). There is no separate
  "secondary text" colour.
- Error/deletion tint: `oklch(var(--lch-red) / 0.1)`; success tint:
  `oklch(var(--lch-green) / 0.1)` (see `del`/`ins` in `text.css`).
- Shadows use `--lch-always-black` with alpha so they stay dark in dark mode.
- Monochrome icon images are inverted for dark mode with
  `filter: invert(1)` under `prefers-color-scheme: dark`; on a filled button the
  inversion flips. Prefer inline SVG with `fill: currentColor` for new icons to
  avoid the filter dance.
- `.colorize--white` / `.colorize--black` force an image to render white/black
  in both schemes.

## 4. Typography

### 4.1 Families (`base.css`)

```css
--font-sans:  system-ui;
--font-serif: ui-serif, serif;
--font-mono:  ui-monospace, monospace;
```

Body uses `--font-sans`, `line-height: 1.4`, antialiased smoothing,
`text-size-adjust: none`. Code uses `--font-mono` at `0.85em`.

### 4.2 Scale

Fixed sizes (`utilities.css`):

| Class            | Size    |
|------------------|---------|
| `.txt-small`     | 0.8rem  |
| `.txt-medium`    | 1rem    |
| `.txt-large`     | 1.4rem  |
| `.txt-x-large`   | 1.8rem  |
| `.txt-xx-large`  | 2.4rem  |

Fluid sizes, driven by the nearest `container-type: inline-size` ancestor
(`#main` is a container):

| Token / class                         | Value                        |
|---------------------------------------|------------------------------|
| `--font-small-responsive`   / `.txt-small--responsive`   | `clamp(0.8rem, 2cqi, 1rem)`   |
| `--font-medium-responsive`  / `.txt-medium--responsive`  | `clamp(1rem, 2.5cqi, 1.4rem)` |
| `--font-large-responsive`   / `.txt-large--responsive`   | `clamp(1.3rem, 4cqi, 1.8rem)` |
| `--font-x-large-responsive` / `.txt-x-large--responsive` | `clamp(1.8rem, 5cqi, 3.2rem)` |

`#main` sets `font-size: var(--font-medium-responsive)`, so components inside it
should size themselves in `em` and inherit.

### 4.3 Headings (`text.css`)

`h1`–`h6` and `.h1`–`.h6`: weight 800, `line-height: 1.1`,
`letter-spacing: -0.02ch`, `text-wrap: balance`, `hyphens: auto`. Sizes are the
browser defaults in `em` (2 / 1.5 / 1.17 / 1 / 0.83 / 0.67). Real heading
elements get `margin-block: 0.65em`; `.hN` classes get none, so use the class
when you want the look without the rhythm.

### 4.4 Body copy

- Block elements (`p, ul, ol, dl, blockquote, pre, figure, table, hr`) get
  `margin-block: 0.65lh` and `text-wrap: pretty`.
- `p`: `hyphens: auto`, `letter-spacing: -0.005ch`.
- `b, strong, th`: weight 700. Emphasis weights in the system: 600 (buttons),
  700 (strong), 750 (titles), 800 (headings), 900 (display).
- `hr`: 1px top border in `--color-subtle-dark`, `margin: 2lh auto`.
- Bare links (`a:not([class])`) are `--color-link`, underlined, no hover ring.
  Any link with a class is undecorated and opts into component styling.
- `ul[role=list]` / `ol[role=list]` are unstyled lists.
- `::selection` uses `--color-selected`.

### 4.5 Text utilities

`.txt-align-{center,start,end}`, `.txt-ink`, `.txt-reversed`, `.txt-negative`,
`.txt-subtle`, `.txt-undecorated`, `.txt-tight-lines` (1.2), `.txt-normal`
(weight 400, no italic), `.txt-nowrap`, `.txt-uppercase`.

## 5. Spacing

Two axes, two base tokens (`utilities.css`):

```css
--inline-space: 1ch;   /* half: 0.5ch, double: 2ch */
--block-space:  1rem;  /* half: 0.5rem, double: 2rem */
```

All layout padding/margin/gap utilities derive from these. Component internals
use `em` instead so they scale with the component's font size (e.g. button
padding `0.5em 1.1em`, input padding `0.5em 0.8em`).

Utilities (each exists for `pad`/`margin`, and mostly for `block`/`inline`,
`start`/`end`, `half`/`double`):

- `.pad`, `.pad-double`, `.pad-block[-start|-end][-half]`,
  `.pad-inline[-start|-end|-half|-double]`, `.unpad`
- `.margin`, `.margin-block[-start|-end][-half|-double]`,
  `.margin-inline[-start|-end][-half|-double]`,
  `.margin-none[-block|-inline][-start|-end]`
- `.center` (`margin-inline: auto`), `.center-block`
- `.gap` (`--column-gap`/`--row-gap` override, defaults to the two tokens), `.gap-half`

Larger page-level spacing is fluid:
`clamp(var(--inline-space), 5%, calc(var(--inline-space) * 3))`.

## 6. Shape, borders, elevation

| Element                | Radius   | Border                                  |
|------------------------|----------|-----------------------------------------|
| Buttons                | `2em` (pill) | `1px solid --color-subtle-dark`     |
| Inputs, `pre`, toolbars| `0.5em`  | `1px solid --color-subtle-dark`         |
| Inline `code`, thumbnails, small badges | `0.3em` | `1px solid --color-subtle` |
| Panels / cards         | `1em`    | `1px solid --color-subtle` (dark mode: `--color-subtle-dark`) |
| Circles (icon buttons, switch knob) | `50%` | —                             |

Utilities: `.border`, `.border-top` (read `--border-size`, `--border-color`),
`.borderless`, `.border-radius` (reads `--border-radius`, default 1em),
`.separator` (vertical hairline in `--color-subtle-dark`).

Fills: `.fill` (bg), `.fill-black`, `.fill-white`, `.fill-shade`
(`--color-subtle-light`), `.fill-selected`, `.fill-transparent`,
`.translucent` (`--opacity`, default 0.5).

Elevation: one shadow recipe, `.shadow`, a six-layer stack of
`oklch(var(--lch-always-black) / α)` with alphas 0.02–0.6 in light mode and
0.42–1 in dark mode. Reuse the class rather than inventing new shadows.

## 7. Interaction states (`base.css`)

One global rule styles every `a, button, input, textarea, .switch`. Components
tune it through custom properties rather than re-declaring states.

| Knob               | Default                     | Meaning                                  |
|--------------------|-----------------------------|------------------------------------------|
| `--hover-size`     | `0.15rem`                   | Thickness of the hover ring (`box-shadow`). Set `0` to disable. |
| `--hover-color`    | `--color-subtle-dark`       | Ring colour.                              |
| `--hover-filter`   | `brightness(1)`             | Filter applied on focus for inputs.       |
| `--outline-size`   | `max(2px, 0.08em)`          | Focus-visible outline width.              |
| `--outline-color`  | `currentColor`              | Focus-visible outline colour; filled buttons set it to their fill. |
| `--outline-offset` | `calc(var(--outline-size) * 2)` | Focus outline offset; 0 while pressed. |

Behaviour:

- **Hover** (pointer devices only, `@media (any-hover: hover)`): ring via
  `box-shadow: 0 0 0 var(--hover-size) var(--hover-color)`. Not applied while
  `:active`.
- **Focus-visible**: outline using the knobs above. No ring for mouse focus.
- **Disabled**: `cursor: not-allowed`, `filter: brightness(0.75)`. Buttons
  additionally drop to `opacity: 0.3` and `pointer-events: none`.
- **Transitions**: `box-shadow, outline-offset, background-color, opacity,
  filter` at `150ms ease`.
- `touch-action: manipulation` and `caret-color: var(--color-link)` everywhere.

Inputs on focus swap the hover ring to `--color-selected-dark` and suppress the
outline, so a focused field shows a blue ring, not a black outline.

## 8. Motion

- Micro-interactions: `150ms ease` (rings, switches, dialogs).
- Colour/opacity changes on buttons and toolbars: `300ms ease`.
- Layout slides: `0.2s ease-out`.
- No page-level view transitions; navigation is instant (Turbo).
- Overlays animate with `transition: display … allow-discrete, overlay …
  allow-discrete` plus `@starting-style` for entry. Dialog enters with
  `translateY(50%) → 0` and fade; popover fades only; backdrop fades to
  `opacity: 0.5` (dialog) / `0.75` blurred (lightbox).
- Available keyframes: `fade-out`, `pulse`, `shake`, `wiggle`, `submitting`
  (three-dot loader), `success`, `zoom-fade`. Helper classes `.shake`,
  `.wiggle`, `.spinner`.
- `prefers-reduced-motion: reduce` collapses all animations and transitions to
  0.01ms globally (`_reset.css`). Do not add per-component reduced-motion rules.

## 9. Layout

- `body` is a single-column CSS grid with named areas
  `header / toolbar / main / footer`. (Writebook added a `sidebar` column at
  `70ch`; that was removed. If Kasoku needs a sidebar, add a second column and
  `"sidebar header" …` areas back under a `min-width: 70ch` query.)
- **Breakpoint: `70ch`.** It is the only breakpoint in the system. Below it,
  `#main` is full-width with `--inline-space` gutters.
- **Measure: `#main` is `min(67ch, 75vw)`**, centred, `text-align: center` by
  default (content blocks opt back in with `text-align: start`). It is a
  container (`container-type: inline-size`) so `cqi` units work inside it.
- `#header`, `#toolbar`, `#footer`: full-width bands padded
  `var(--block-space-half) var(--inline-space)`, children are centred flex rows
  with `gap: 1ch`. `#toolbar` is sticky at the top.
- Chrome (`#header, #toolbar, #footer`, `.btn`, `.no-print`) is hidden in
  print; `#main` becomes 11pt, justified, `@page { margin: 1in }`.
- `turbo-frame { display: contents }` so frames never affect layout.
- Flex/grid utilities: `.flex`, `.flex-inline`, `.flex-column`, `.flex-wrap`,
  `.justify-{start,center,end,space-between}`, `.align-{start,center,end}`,
  `.align-self-start`, `.flex-item-{grow,shrink,no-shrink}`,
  `.flex-item-justify-{start,end}` (auto margins).
- Sizing: `.full-width`, `.half-width`, `.min-width` (min-inline-size 0),
  `.max-width` / `.max-inline-size` (100%), `.min-content`, `.contain`.
- Overflow: `.overflow-x` / `.overflow-y` (scroll-snap), `.overflow-clip`,
  `.overflow-ellipsis`, `.overflow-line-clamp` (`--lines`, default 2),
  `.overflow-hide-scrollbar`.
- Position: `.position-relative`, `.position-sticky`.
- Visibility: `[hidden]`, `[contents]`, `.for-screen-reader`, `.no-print`.

## 10. Components

### 10.1 Button `.btn` (`buttons.css`)

Base: inline-flex, centred, `gap 0.5em`, weight 600, `font-size 1em`,
pill radius, 1px `--color-subtle-dark` border, transparent background.
`--btn-size: 2.65em` is the fixed height/width for circle buttons.

API:

| Property              | Default                  |
|-----------------------|--------------------------|
| `--btn-background`    | `transparent`            |
| `--btn-color`         | `--color-ink`            |
| `--btn-border-color`  | `--color-subtle-dark`    |
| `--btn-border-size`   | `1px`                    |
| `--btn-border-radius` | `2em`                    |
| `--btn-padding`       | `0.5em 1.1em`            |
| `--btn-gap`           | `0.5em`                  |
| `--btn-icon-size`     | `1.3em`                  |

Variants (set the API, and `--outline-color` to match the fill):

| Class            | Fill / text                         |
|------------------|-------------------------------------|
| `.btn--link`     | `--color-link` / reversed           |
| `.btn--positive` | `--color-positive` / reversed       |
| `.btn--negative` | `--color-negative` / reversed       |
| `.btn--reversed` | `--color-ink` / `--color-bg`        |
| `.btn--plain`    | no border, no padding, `0.5em` radius, icon fills button, no hover ring |
| `.btn--small`    | `font-size: 0.8em`                  |
| `.btn--circle`   | `--btn-size` square, `50%` radius, grid-stacked children |
| `.btn--placeholder` | invisible spacer                 |
| `.btn--success`  | plays `success` + icon `zoom-fade`  |

Behaviours:

- A button that contains only an icon plus `.for-screen-reader` text is
  automatically a circle.
- Filled variants set `--btn-border-color: var(--color-bg)` so adjacent filled
  buttons read as separate.
- Toggle buttons: put a visually-hidden `input[type=checkbox|radio]` inside a
  `.btn`; `:has(input:checked)` fills it with `--color-ink`. Use `img.checked`
  for a swap-in checked icon.
- Disabled (`[disabled]`, `:has([disabled])`, or a disabled submit) →
  `opacity 0.3`, no pointer events.
- Buttons are hidden in print.

### 10.2 Text input `.input` (`inputs.css`)

Full-width, `font-size: max(16px, 1em)` (prevents iOS zoom),
`line-height 1.2`, `0.5em` radius, 1px `--color-subtle-dark` border,
`resize: none`.

API: `--input-background`, `--input-color`, `--input-border-color`,
`--input-border-size`, `--input-border-radius`, `--input-padding`,
`--input-accent-color`.

Focus: border and ring become `--color-selected-dark`; outline suppressed.
Autofill is restyled to `--color-selected` background with `--color-ink` text.

Variants:

- `.input--textarea`: `field-sizing: content`, grows from 1lh to 10lh.
- `.input--file`: grid-stacked wrapper making a preview clickable, transparent
  native file input.
- `.input--actor`: a container that *looks* like the input (border, focus ring
  via `:focus-within`) while the inner `.input` is stripped bare. Use for
  inputs with inline buttons/adornments.

### 10.3 Switch `.switch` (`inputs.css`)

```html
<label class="switch">
  <input class="switch__input" type="checkbox">
  <span class="switch__btn"></span>
</label>
```

`3em × 1.75em` pill; knob `1.35em`, `--color-ink-reversed`; track
`--color-subtle-dark` off, `--color-link` on; `150ms` transitions; keyboard
focus draws a double ring (`--color-bg` then `--color-ink`).

### 10.4 Panel `.panel` (`panels.css`)

Card/modal body: `--color-bg` fill, `1em` radius, 1px border, padding
`calc(var(--block-space) * 2)`, `inline-size: var(--panel-size, 40ch)` capped to
viewport minus gutters. `.panel__close` is an absolutely positioned small button
in the top-end corner. API: `--panel-size`, `--panel-border-color`,
`--panel-border-radius`.

### 10.5 Dialog `.dialog`, popover `.popover`, lightbox `.lightbox`

Apply to a native `<dialog>`. `.dialog` has no border and animates in from
below with a 50% black backdrop (`--speed`, `--backdrop-speed`, `--panel-size`).
`.popover` is fade-only. `.lightbox` is full-viewport with a 66% translucent
page-colour fill and a heavily blurred 75% backdrop; children
`.lightbox__image` and `.lightbox__btn` stack in one grid cell.

### 10.6 Small parts

- `.breadcrumbs`: flex row, `gap --inline-space-half`, each crumb ellipsised at
  `40ch`; an inline `input` uses `field-sizing: content`.
- `.spinner`: absolutely centred three-dot loader in `currentColor`, driven by
  the `submitting` keyframes.
- `.separator`: vertical hairline for toolbars.
- `pre`/`code` and `.pre`/`.code`: mono, `0.85em`, `--color-subtle-light` fill,
  `--color-subtle` border; blocks get `0.5em` radius and `0.5lh 2ch` padding.
- `table`, `th`, `td`: 1px `--color-subtle-dark` grid, `0.2lh 1ch` cell
  padding, `th` has a 3px bottom border.
- `blockquote`/`.quote`: italic, `margin: 0 3ch`.
- `mark`: `--color-highlight` background.
- `del`/`ins`: red/green text on a 10% tint.

## 11. Writing new CSS

1. **One file per component or concern**, named after the block
   (`todos.css`, `spaces.css`). Keep it alphabetically before `utilities.css`.
2. **Start with tokens.** Use the semantic colour, spacing, and font tokens.
   If you need a new value used in more than one place, add a token to the
   relevant `:root` block (colours in `colors.css`, spacing/type in
   `utilities.css`) rather than hard-coding.
3. **Expose knobs, not modifiers.** Read `var(--x, default)` for anything a
   parent or variant may want to change. Add a `--variant` class only when it
   sets several knobs at once.
4. **Lean on the global interaction rule.** Do not write your own `:hover` /
   `:focus-visible` for links, buttons, or inputs; set `--hover-size`,
   `--hover-color`, `--outline-color` instead. Add your element to the list in
   `base.css` if it is a new interactive primitive.
5. **Prefer `:has()` over JS classes** for toggled UI where a checkbox or
   `[open]` already carries the state.
6. **Use `:where()`** around element selectors and structural selectors inside
   components to keep specificity flat.
7. **Icons**: inline SVG with `fill: currentColor`, sized via
   `--btn-icon-size` or `1em`. Avoid `<img>` icons that require inversion.
8. **Dark mode**: only add `@media (prefers-color-scheme: dark)` for icon
   inversion or a shadow. Everything else must come free from the tokens.
9. **Motion**: use the durations in §8 and the existing keyframes; overlays use
   `allow-discrete` + `@starting-style`.
10. **Print**: hide chrome with `.no-print`; content styles must survive print.

Skeleton for a new component:

```css
/* todos.css */
.todo {
  --todo-padding: var(--block-space-half) var(--inline-space);

  align-items: center;
  border-block-end: 1px solid var(--color-subtle);
  display: flex;
  gap: var(--inline-space);
  padding: var(--todo-padding);
  transition: background-color 150ms ease;

  &:where(:has(.todo__toggle input:checked)) {
    .todo__name {
      color: var(--color-subtle-dark);
      text-decoration: line-through;
    }
  }
}

.todo__toggle {
  --btn-size: 1.75em;
}

.todo__name {
  flex-grow: 1;
  min-inline-size: 0;
  text-align: start;
}
```

Declaration order within a rule (as in the source): custom properties first,
blank line, then properties alphabetically, then nested rules and media queries.

## 12. Provenance

The stylesheets began as a copy of Basecamp's Writebook CSS. Files that only
served Writebook features were removed: `books`, `toc`, `arrangement`, `pages`,
`house` (Markdown editor), `syntax` (Rouge), `library`, `sidebar`, `qr-code`,
`translations`, `product`, and `search` (its `mark` rule moved to `text.css`).
The sidebar column, `.heading__link`, and view-transition animations were also
dropped, and dangling references (`--color-border-darker`, `--color-text`,
`pointer: course`, `.input--textara`) were fixed. Current files:

```
_reset.css     animation.css  application.css  base.css      breadcrumbs.css
buttons.css    colors.css     dialog.css       inputs.css    layout.css
lightbox.css   panels.css     popover.css      text.css      utilities.css
```

If a removed component turns out to be useful again, the full Writebook copy is
in this repo's history at commit `0453772` ("Add Writebook CSS stylesheets");
re-add it following §11 rather than copying verbatim.
