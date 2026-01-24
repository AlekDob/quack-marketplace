---
name: flow-news-writer
description: This skill helps write professional, multilingual announcement posts for C&C's internal Flow platform. Use this skill when announcing new apps, features, updates, or dev achievements to C&C employees across 8 European countries. Generates clear, engaging content in Italian, French, and English with consistent tone, structure, and formatting optimized for the Flow News section.
---

# Flow News Writer

## Overview

This skill assists in crafting professional announcement posts for C&C's internal communication platform **Flow**, specifically for the **News section**. It provides writing guidelines, templates, and ready-to-publish examples for communicating development updates, new apps, features, and technical achievements to C&C employees across 8 European countries.

**When to use this skill:**
- Announcing new mobile/web applications (Flow POS, C&C Team, etc.)
- Communicating feature updates or improvements
- Sharing development milestones and achievements
- Explaining technical changes in user-friendly language
- Writing multilingual posts (Italian 🇮🇹, French 🇫🇷, English 🇬🇧)
- Ensuring consistent tone and formatting across announcements

**Target Audience:**
- C&C employees (retail staff, management, HQ teams, developers)
- 8 countries: Italy, France, Sweden, Estonia, Lithuania, Finland, Denmark, and more
- Mixed technical literacy (from retail staff to developers)
- Primary language: Italian, with full French and English support

## Quick Start

### Step 1: Identify Your Announcement Type

**Choose the appropriate template:**

#### For MAJOR App Launches (First releases, strategic apps):
→ **Comprehensive App Launch Template** - Full article with feature sections, installation guide, screenshots
→ See: `references/comprehensive-app-launch-template.md`
→ Examples: C&C Me, C&C Team, Flow POS first launches

#### For Standard Announcements:
1. **App Launch** (New mobile/web app) → Template 1 or 2
2. **Feature Update** (New functionality) → Template 3
3. **Performance Improvement** (Speed, stability) → Template 4
4. **Design Refresh** (UI/UX updates) → Template 5
5. **Integration** (New system connections) → Template 6
6. **Security/Privacy Update** → Template 7
7. **Bug Fix** (Major fixes) → Template 8
8. **Deprecation/Sunset** → Template 9
9. **Milestone/Achievement** → Template 10

**See:** `references/post-templates.md` for all templates

### Step 2: Follow the Standard Structure

**Every post should include (5-7 sentences):**

```
1. 🎯 Hook (1 sentence)
   → Start with the main benefit

2. 📝 Context (2-3 sentences)
   → Explain what it is and why it matters

3. ✨ Key Features (2-4 bullet points)
   → List concrete benefits

4. 🚀 Call to Action (1 sentence)
   → What to do now or when available

5. 🏷️ Label
   → Flow / Retail / Service / Company / etc.
```

### Step 3: Generate All 3 Languages

**Always provide:**
- 🇮🇹 Italian (primary language)
- 🇫🇷 French
- 🇬🇧 English

**Important:** Adapt naturally to each language - don't translate literally!

## Core Writing Principles

### Tone & Style Guidelines

**✅ DO:**
- Be clear and concise (5-7 sentences max)
- Use professional but friendly tone
- Start with the main benefit
- Use inclusive language ("noi", "il nostro team")
- Highlight practical benefits for users
- Keep paragraphs short (2-3 lines max)

**❌ DON'T:**
- Use excessive technical jargon
- Write long paragraphs
- Be overly formal or bureaucratic
- Assume everyone knows acronyms
- Forget availability/rollout timeline

### Example: Technical → User-Friendly

**❌ Too Technical:**
```
Abbiamo deployato la nuova architettura MVVM con Combine per il reactive state management e implementato il Liquid Glass design system con glassmorphism effect usando .ultraThinMaterial su SwiftUI.
```

**✅ Just Right:**
```
Abbiamo lanciato una nuova app con un'interfaccia moderna e fluida. La nuova tecnologia rende l'app più veloce e reattiva, migliorando l'esperienza d'uso quotidiana.
```

## Common Use Cases

### Use Case 1: Major App Launch (Comprehensive)

**User Request:** *"Write a post announcing C&C Me launch"*

**Claude Response:**
- Generates **3 separate files** (one per language)
- Full article structure with:
  - Opening paragraph + ecosystem context
  - Dedicated section per feature (5-6 features)
  - How to check updates section
  - Step-by-step installation guide with certificate instructions
  - Support contact information
  - Labels and dev team credit
- Screenshot placeholders per feature
- Enterprise certificate installation steps (for iOS apps)

**Reference:** `references/comprehensive-app-launch-template.md`

### Use Case 2: Standard App Launch (Short)

**User Request:** *"Write a quick post announcing Flow POS update"*

**Claude Response:**
- Generates trilingual post (IT/FR/EN)
- Hook about revolutionizing store management
- Context about retail team collaboration
- 4-6 key features with benefits
- Clear availability and feedback call
- Labels: Flow, Retail

**Reference:** `assets/launch-examples.md` → "Flow POS - Complete Launch Post"

### Use Case 3: Performance Update

**User Request:** *"Announce that we optimized the app speed by 3x"*

**Claude Response:**
- Generates trilingual post
- Hook about 3x performance boost
- Measured improvements (startup, search, battery)
- Technical details as user benefits
- Automatic update notification
- Labels: Flow

**Reference:** `assets/launch-examples.md` → "Performance Optimization Announcement"

### Use Case 4: New Security Feature

**User Request:** *"Announce biometric authentication"*

**Claude Response:**
- Generates trilingual post
- Hook about faster, more secure access
- How it works (Face ID/Touch ID)
- Security benefits (user-friendly)
- Setup instructions
- Labels: Flow

**Reference:** `assets/launch-examples.md` → "Biometric Authentication Announcement"

## Writing Workflow

### Step-by-Step Process

**1. Gather Information**
- What's being announced?
- Who benefits?
- When is it available?
- What's the main benefit?

**2. Choose Template**
- Match type to template (1-10)
- Review similar examples
- Note emoji, label, structure

**3. Draft Italian First**
- Compelling hook
- Context (2-3 sentences)
- 3-4 concrete benefits
- Clear call to action
- Appropriate label

**4. Adapt to French**
- Professional tone
- Use "vous" form
- Natural idioms
- Same structure

**5. Adapt to English**
- Active voice
- Direct and concise
- American spelling
- Same structure

**6. Review Checklist**
- [ ] Benefit clear in first sentence
- [ ] Technical terms explained
- [ ] Concrete examples
- [ ] Call to action
- [ ] Label selected
- [ ] All 3 languages complete
- [ ] Consistent meaning
- [ ] Max 3 emojis
- [ ] Mobile-readable

## Labels & Categories

Use appropriate labels to help users filter content:

- **Flow** 🔵 - Platform updates, new features
- **Retail** 🟠 - Store operations, POS systems
- **Service** 🔷 - Technical support, IT updates
- **Company** 🟢 - Company-wide news, policies
- **Edu** 🟡 - Training, best practices
- **B2B** ⚫ - Business solutions
- **Promo** 🟣 - Promotions, campaigns

**Best Practice:**
- Always include "Flow" for platform updates
- Add domain label (Retail, Company, Service)
- Maximum 2-3 labels per post

## Emoji Guidelines

### Recommended Emojis

**Launches:** 🚀 📱 ✨
**Performance:** ⚡ 🎯
**Security:** 🔒 🔗
**Team:** 👥 📢 🎉
**Actions:** 💡 🛠️

**Rules:**
- Max 3 per post
- One in title/hook
- One in call to action
- No faces or gestures

## Language-Specific Tips

### Italian (Primary)
**Tone:** Caldo, professionale, diretto

**Key Phrases:**
- "Siamo entusiasti di..."
- "Ora puoi..."
- "Abbiamo migliorato..."

**Avoid:**
- ❌ "implementato" → ✅ "aggiunto"
- ❌ "feature" → ✅ "funzionalità"

### French
**Tone:** Professionnel, élégant

**Key Phrases:**
- "Nous sommes ravis de..."
- "Vous pouvez désormais..."
- "Nous avons amélioré..."

**Avoid:**
- ❌ "Feature" → ✅ "Fonctionnalité"
- ❌ "Feedback" → ✅ "Retour"

### English
**Tone:** Professional, friendly

**Key Phrases:**
- "We're excited to..."
- "You can now..."
- "We've improved..."

**Style:**
- Active voice
- Short sentences
- American spelling

## Technical Translation Guide

Translate technical achievements to user benefits:

| Technical | Italian | French | English |
|-----------|---------|--------|---------|
| Implemented caching | L'app è più veloce | L'app est plus rapide | The app is faster |
| Optimized queries | Risultati istantanei | Résultats instantanés | Instant results |
| Added biometric auth | Accesso più sicuro | Accès plus sûr | More secure access |

## Reference Documentation

### Comprehensive Guidelines
**`references/writing-guidelines.md`**
- Platform overview
- Tone and style for each language
- Content structure templates
- Label system
- Emoji best practices
- Quality checklist
- Tips for dev updates

### Ready-to-Use Templates
**`references/post-templates.md`**
- 10 complete templates
- When to use each
- Full structure with placeholders
- Examples in all 3 languages
- Customization tips

### Real Examples
**`assets/launch-examples.md`**
- Flow POS launch (trilingual)
- C&C Team launch (trilingual)
- Performance optimization
- Design system announcement
- Biometric auth announcement

## Best Practices

### For Dev Announcements

**Structure:**
1. What we built (simple terms)
2. Why it matters (business value)
3. What users notice (concrete changes)
4. What's next (future improvements)

**Example:**
```
🔒 Accesso più sicuro con Face ID

Abbiamo aggiunto l'autenticazione biometrica.
Ora puoi accedere più velocemente e in modo più sicuro.

✨ Vantaggi:
• Accesso istantaneo
• Massima sicurezza
• Esperienza fluida

Attivazione automatica al prossimo accesso.

🏷️ Flow
```

### Length Guidelines

- **Title:** 40-60 chars (IT), 45-65 (FR), 35-55 (EN)
- **Body:** 5-7 sentences (100-150 words)
- **Bullets:** 2-4 items
- **CTA:** 1 clear sentence

**Why:**
- Mobile-friendly
- Under 1 minute read
- Skimmable for busy staff

## Tips for Success

1. **Benefits over features**
   - ❌ "Abbiamo implementato multi-cart"
   - ✅ "Ora puoi servire più clienti contemporaneamente"

2. **Concrete examples**
   - ❌ "L'app è più veloce"
   - ✅ "L'app si apre in < 1 secondo (prima 3s)"

3. **Keep it short**
   - ❌ 300-word essay
   - ✅ 100-150 words with bullets

4. **Think mobile-first**
   - Short paragraphs
   - Scannable bullets
   - Clear hierarchy

5. **Test readability**
   - Read aloud
   - Would retail staff understand?
   - Natural in each language?

## Getting Help

**For specific scenarios:**
- App launches → `references/post-templates.md` + `assets/launch-examples.md`
- Feature updates → `references/post-templates.md` Template 3
- Performance → Template 4 + launch examples
- Security → Template 7 + launch examples

**For writing guidelines:**
- General principles → `references/writing-guidelines.md`
- Language tips → Writing guidelines → "Language-Specific"
- Technical translation → Writing guidelines → "Tips for Dev Updates"

**For ready examples:**
- All examples → `assets/launch-examples.md`

**For comprehensive app launches:**
- Template → `references/comprehensive-app-launch-template.md`
- Real example (C&C Me) → Check project `.claude/docs/flow-news-announcement-*.md`

## Comprehensive vs Short Templates

| Scenario | Template Type | Output |
|----------|--------------|--------|
| First iOS app launch | Comprehensive | 3 separate files (IT/FR/EN) |
| New app with 3+ features | Comprehensive | Full article per language |
| Enterprise cert required | Comprehensive | Includes installation guide |
| Feature update | Short | Single trilingual post |
| Performance improvement | Short | Single trilingual post |
| Bug fix | Short | Single trilingual post |

**Rule of Thumb:**
- If the app has **dedicated feature sections** → Use Comprehensive
- If you can describe it in **5-7 sentences** → Use Short

---

*This skill is designed for C&C's internal Flow platform across 8 European countries.*
