---
name: 2126-brand-guidelines
description: This skill provides the official brand guidelines for 2126.ai and its products. Use this skill when building websites, landing pages, UI components, or any visual design work for 2126.ai or its products (Quack, etc.). Ensures consistent visual identity across all 2126 projects with proper typography, colors, spacing, and tone of voice.
---

# Studio Futuro Brand Guidelines

**Domain:** 2126.ai / studiofuturo.ai
**Name:** Studio Futuro
**Tagline:** "Laboratorio di futuri possibili" / "Laboratory of Possible Futures"

## Brand Philosophy

Studio Futuro is a software studio building AI-powered automation tools for businesses. The domain 2126.ai represents thinking 100 years ahead - building tools today that will still be relevant in 2126.

The brand fuses three cultural currents:

### 1. Cosmismo Russo (Russian Cosmism)
Soviet optimism toward space - the future as a collective, utopian but achievable project. AI is treated as "the new space exploration" - optimistic, human, not cold.

### 2. Enzo Mari / Radical Italian Design
Flat silhouettes with organic marbled textures. Reference: Serie della Natura (Danese Milano, 1960s-70s). Design as political and cultural project, not mere decoration.

### 3. Superhumanity (e-flux)
Design as redefinition of the human - not decoration, but political and cultural project.

---

## Visual Identity

### Typography

**Primary Font: Cormorant Garamond**

Intellectual, Italian, elegant but warm. A serif that conveys trust and sophistication while remaining approachable.

```
Font Family: "Cormorant Garamond", Georgia, serif
Weights:     300 (Light), 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)
Styles:      Normal, Italic
Source:      Google Fonts
CSS Variable: --font-cormorant
```

**Secondary Font: JetBrains Mono**

For code blocks, technical labels, eyebrow text, and monospace UI elements.

```
Font Family: "JetBrains Mono", monospace
Weights:     400 (Regular), 600 (SemiBold)
Source:      Google Fonts
CSS Variable: --font-jetbrains
```

**Font Usage:**
- Headings: Cormorant Garamond SemiBold/Bold (600-700)
- Body text: Cormorant Garamond Regular (400)
- Eyebrow labels: JetBrains Mono Medium, uppercase, tracking-[0.2em]
- Code blocks: JetBrains Mono Regular

**Type Scale (Major Third - 1.25):**
```css
'xs':   ['0.64rem', { lineHeight: '1rem' }]
'sm':   ['0.8rem', { lineHeight: '1.25rem' }]
'base': ['1rem', { lineHeight: '1.5rem' }]
'lg':   ['1.25rem', { lineHeight: '1.75rem' }]
'xl':   ['1.563rem', { lineHeight: '2rem' }]
'2xl':  ['1.953rem', { lineHeight: '2.25rem' }]
'3xl':  ['2.441rem', { lineHeight: '2.5rem' }]
'4xl':  ['3.052rem', { lineHeight: '3rem' }]
'5xl':  ['3.815rem', { lineHeight: '1.1' }]
'6xl':  ['4.768rem', { lineHeight: '1.1' }]
```

### Color Palette

**Core Palette (Space Theme - Dark):**
```css
/* Base */
nightSky:     #0A1628    /* Primary background */
deepNavy:     #0D1F3C    /* Card backgrounds, depth */
deepBlack:    #050B14    /* Darkest areas */
spaceGradient: #1a1a3e   /* Gradient highlights */

/* Text */
white:        #FFFFFF    /* Primary text, stars */
white/90:     rgba(255,255,255,0.9)  /* Headings */
white/80:     rgba(255,255,255,0.8)  /* Subheadings */
white/70:     rgba(255,255,255,0.7)  /* Body text */
white/60:     rgba(255,255,255,0.6)  /* Muted text */
white/50:     rgba(255,255,255,0.5)  /* Labels */
white/40:     rgba(255,255,255,0.4)  /* Watermark */

/* Borders */
white/10:     rgba(255,255,255,0.1)  /* Default borders */
white/20:     rgba(255,255,255,0.2)  /* Hover borders */
```

**Accent Colors (Product/Feature):**
```css
/* Primary */
brightOrange: #FF6B35    /* CTAs, Quack, energy */
volcanicRed:  #C44536    /* Automation, warmth */

/* Secondary */
purple:       #9D4EDD    /* AI/tech, philosophy */
cyan:         #00D4FF    /* Torch glow, FlowBI */
pink:         #FF3366    /* Native apps, CodeNinja */
yellow:       #FFB800    /* Web apps */
```

**Usage Rules:**
- Background is ALWAYS deep space (nightSky to deepBlack gradient)
- Text hierarchy through opacity (90% → 70% → 50%)
- Accent colors for highlights, not backgrounds
- Each product/service has a dedicated accent color

### CSS Variables (globals.css)
```css
:root {
  --background: 0 0% 5%;              /* #0D0D0D */
  --foreground: 0 0% 98%;             /* #FAFAFA */
  --card: 0 0% 8%;                    /* #141414 */
  --card-foreground: 0 0% 98%;
  --primary: 0 0% 100%;               /* White buttons */
  --primary-foreground: 0 0% 0%;      /* Black text on white */
  --secondary: 0 0% 12%;              /* #1F1F1F */
  --muted: 0 0% 15%;
  --muted-foreground: 0 0% 55%;       /* #8C8C8C */
  --border: 0 0% 18%;                 /* #2E2E2E */
  --radius: 0;                        /* Sharp edges - Studio Futuro style */
}
```

### Tailwind Config
```typescript
colors: {
  quack: '#FF6B35',
  flowbi: '#00D4FF',
  codeninja: '#FF3366',
},
fontFamily: {
  sans: ['var(--font-cormorant)', 'Georgia', 'serif'],
  serif: ['var(--font-cormorant)', 'Georgia', 'serif'],
  mono: ['var(--font-jetbrains)', 'monospace'],
},
```

---

## Space Theme Elements

### Background Gradients

**Hero/Main Sections:**
```css
background: radial-gradient(ellipse at 30% 20%, #1a1a3e 0%, #0a0a1a 50%, #050510 100%);
```

**Card Sections:**
```css
background: radial-gradient(ellipse at center, #0D1F3C 0%, #0A1628 50%, #050B14 100%);
```

**Vignette Overlay:**
```css
background: radial-gradient(ellipse at center, transparent 40%, rgba(0,0,0,0.6) 100%);
```

### Animated Stars

Stars twinkle with CSS animation for performance:
```css
animation: twinkle 3s ease-in-out infinite;

@keyframes twinkle {
  '0%, 100%': { opacity: '0.2' },
  '50%': { opacity: '0.6' },
}
```

Generate stars with seeded random for SSR/client consistency:
```typescript
function seededRandom(seed: number) {
  const x = Math.sin(seed) * 10000
  return x - Math.floor(x)
}
```

### Floating Elements

**Gentle Float Animation:**
```css
@keyframes floatGentle {
  '0%, 100%': { transform: 'translate3d(0, 0, 0)' },
  '25%': { transform: 'translate3d(0, -10px, 0)' },
  '75%': { transform: 'translate3d(0, 10px, 0)' },
}
```

**Planets/Nebula**: Slow rotation (60-150s), gentle y-axis bob, parallax on mouse movement.

---

## Interactive Elements

### UFO Cursor (Desktop Only)
Custom cursor that replaces native cursor. UFO image (70px) follows mouse with spring physics.
- `stiffness: 300, damping: 25`
- Gentle hover animation: `y: [0, -2.5, 0]` over 1.5s
- Drop shadow: `drop-shadow(0 0 12px rgba(0,212,255,0.6))`

**Hide native cursor:**
```css
body {
  cursor: none;
}
```

### Mouse Torch Glow (Desktop Only)
Radial gradient glow follows cursor for "flashlight exploring space" effect.
- NO blur filters (performance)
- Multi-step gradient instead:
```css
background: radial-gradient(circle,
  rgba(0, 212, 255, 0.15) 0%,
  rgba(0, 212, 255, 0.1) 20%,
  rgba(255, 107, 53, 0.08) 40%,
  rgba(255, 107, 53, 0.03) 60%,
  transparent 80%
);
```

### Floating Astronaut
Astronaut image floats across viewport on continuous loop.
- Fixed position, z-index 9999
- Crosses screen in ~60s
- Gentle rotation (360deg per 40s)
- Size: 100px mobile → 220px desktop

---

## Component Patterns

### Eyebrow Label
```tsx
<span className="text-sm uppercase tracking-[0.2em] text-white/50 block mb-4 font-mono">
  {label}
</span>
```

### Section Header
```tsx
<h2 className="text-3xl sm:text-4xl lg:text-5xl font-serif font-bold text-white mb-4"
    style={{ textShadow: '0 0 40px rgba(255, 107, 53, 0.2)' }}>
  {headline}
</h2>
```

### Card with Accent Line
```tsx
<div className="relative h-full overflow-hidden rounded-xl border border-white/10 bg-[#0D1F3C] transition-[transform,border-color] duration-300 hover:-translate-y-1 hover:border-white/20">
  {/* Image */}
  <div className="relative aspect-[4/3] overflow-hidden">
    <Image ... />
    <div className="absolute inset-0 bg-gradient-to-t from-[#0D1F3C] via-transparent to-transparent" />
  </div>

  {/* Content */}
  <div className="p-5">
    <div className="h-0.5 rounded-full mb-4 w-[30%]"
         style={{ background: accentColor }} />
    <h3 className="text-xl sm:text-2xl font-serif font-bold text-white mb-3">{title}</h3>
    <p className="text-base sm:text-lg text-white/70 leading-relaxed">{description}</p>
  </div>
</div>
```

### CTA Button (Primary)
```tsx
<button className="group flex items-center gap-2 px-8 py-4 bg-foreground text-background font-medium text-sm uppercase tracking-wider hover:bg-foreground/90 transition-colors duration-200">
  {text}
  <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform duration-200" />
</button>
```

### CTA Button (Outline)
```tsx
<button className="group flex items-center gap-2 px-8 py-4 border border-border text-foreground/80 font-medium text-sm uppercase tracking-wider hover:bg-foreground/5 transition-colors duration-200">
  <Icon className="w-4 h-4" />
  {text}
</button>
```

---

## Animation Guidelines

### Performance Rules

**DO:**
- Use CSS animations for repeating effects (twinkle, float)
- Use `will-change: transform` sparingly
- Use `transform: translate3d(0,0,0)` for GPU acceleration
- Use `transition-[property]` instead of `transition-all`
- Throttle mouse events with RAF
- Use `once: true` for scroll-triggered animations

**DO NOT:**
- Use `filter: blur()` on animated elements
- Use spring animations on scroll-triggered sections
- Animate multiple properties simultaneously
- Use continuous scroll-based re-renders (`once: false`)

### Animation Timings
```typescript
// Scroll reveal
duration: 0.6
ease: [0.25, 0.46, 0.45, 0.94]

// Hover states
duration: 0.2-0.3
ease: ease-out

// Spring physics (cursor/torch)
stiffness: 150-300
damping: 20-25

// Floating/ambient
duration: 6-15s
ease: easeInOut
repeat: Infinity
```

---

## Visual Signature: Watermark

**The Studio Futuro Watermark** appears on every page.

**Placement:** Fixed position, top-right corner
**Content:** Alternates between "2126" and "STUDIO FUTURO" every 4s
**Animation:** Subtle rotate (-3deg → 0 → 3deg) on text swap
**Colors:**
- Default: `rgba(255, 255, 255, 0.4)`
- Hover: Product accent color with glow

```tsx
<StudioFuturoWatermark accentColor="#FF6B35" />
```

---

## Mobile Optimization

### Viewport
```html
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
```

### Prevent Zoom
```css
html, body {
  touch-action: manipulation;
  -webkit-text-size-adjust: 100%;
  text-size-adjust: 100%;
  overflow-x: hidden;
}
```

### Responsive Image Sizes
```
Mobile:  100px-150px (astronaut, elements)
Tablet:  130px-180px
Desktop: 180px-220px
```

### Disable Desktop-Only Features
- UFO cursor: hidden on mobile (`cursor: auto`)
- Mouse torch: disabled
- Complex parallax: simplified or disabled

---

## Internationalization

**Supported Languages:** Italian (primary), English

**Locale Detection:**
- URL-based: `/it/`, `/en/`
- Default: Italian

**OpenGraph Locales:**
- Italian: `it_IT`
- English: `en_GB`

**Tone varies by language:**
- Italian: Warmer, more conversational
- English: Professional, direct

---

## Tone of Voice

### Writing Style

**Do:**
- Be direct and confident
- Use space metaphors naturally ("orbital factory", "laboratory of futures")
- Focus on benefits over features
- Show Italian heritage (Cheshire UK base, Italian founders)

**Do Not:**
- Use superlatives ("revolutionary", "amazing")
- Add filler words ("very", "really", "just")
- Use emoji in professional contexts
- Overclaim or hype

### Headlines
- Statement format preferred
- Max 8-10 words
- Optional text shadow for depth: `text-shadow: 0 4px 30px rgba(0,0,0,0.9)`

### Body Copy
- One idea per paragraph
- Max 2-3 sentences per paragraph
- Active voice always
- Opacity 70-80% for readability on dark backgrounds

---

## Checklist

Before shipping any Studio Futuro project, verify:

- [ ] Font is Cormorant Garamond (not Sora, not system font)
- [ ] Secondary font is JetBrains Mono for code/labels
- [ ] Background uses space gradients (nightSky → deepBlack)
- [ ] Text uses opacity hierarchy (90% → 70% → 50%)
- [ ] No emoji anywhere
- [ ] Accent colors match product/service
- [ ] UFO cursor works on desktop (hidden on mobile)
- [ ] Mouse torch uses gradients, NOT blur filters
- [ ] Animations use `once: true` for scroll reveals
- [ ] `overflow-x: hidden` on html/body
- [ ] Viewport prevents zoom on iOS
- [ ] Stars use seeded random (SSR-safe)
- [ ] **StudioFuturoWatermark component present** top-right
- [ ] Watermark alternates between "2126" and "STUDIO FUTURO"
- [ ] i18n supports IT and EN
- [ ] Images have appropriate aspect ratios and responsive sizes
