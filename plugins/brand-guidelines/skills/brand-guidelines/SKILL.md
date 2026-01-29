---
name: brand-guidelines
description: Quack's design system documenting the actual UI patterns, colors, typography, and component structures used throughout the application. Based on real implementation.
---

# Quack Design System

## Overview

Quack follows a minimal modern design philosophy focused on professionalism and clarity:
- Orange accent color (#f28c52) as the brand signature
- SVG icons preferred, with selective emoji for specific UI contexts
- Smooth animations with cubic-bezier easing
- Consistent drawer patterns with backdrop blur
- General Sans typography for modern feel
- Dark theme optimized for long coding sessions

## Core Colors

Primary orange: #f28c52
Background: #0f1115
Surface: rgba(18, 20, 27, 0.97)
Text primary: #e7ebf3
Text secondary: rgba(255, 255, 255, 0.7)
Border: rgba(128, 132, 150, 0.32)

## Typography

Font: General Sans, Inter, system-ui
Sizes: 18px (xl), 16px (lg), 14px (md), 13px (base), 12px (sm), 11px (xs)
Weights: 400 (regular), 500 (medium), 600 (semibold)

## Key Patterns

- Drawer: slide from right, backdrop blur 8px, cubic-bezier(0.4, 0, 0.2, 1)
- Buttons: primary (orange gradient), secondary (transparent), success (teal)
- Border radius: 4-12px range
- Shadows: subtle for cards, strong for drawers/modals
- Orange glow: 0 4px 12px rgba(242, 140, 82, 0.3)

## Rules

- SVG icons for core UI, emoji for labels/badges/tips
- No harsh borders (low opacity)
- Every interactive element needs hover feedback
- translateY(-1px) on hover for buttons
- WCAG AA contrast compliance
