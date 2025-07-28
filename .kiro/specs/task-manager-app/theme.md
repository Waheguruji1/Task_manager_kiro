# Task Manager App Theme Specification

## Overview

This document defines the comprehensive theme and visual design system for the Task Manager Flutter app. The app follows a minimalist dark theme approach with a grey/black/white color scheme and boxy design style with smooth rounded corners for a modern, comfortable user experience.

## Color Palette

### Primary Colors

- **Background Dark Grey**: `#121212` (Dark Grey)
  - Used for: Main app background, screen backgrounds
  - Usage: Primary background color across all screens

- **Surface Grey**: `#2A2A2A` (Dark Grey)
  - Used for: Container backgrounds, task containers, elevated surfaces
  - Usage: Task containers, dialog backgrounds, card backgrounds

### Text Colors

- **Primary Text**: `#FFFFFF` (Pure White)
  - Used for: Main headings, primary content, important text
  - Usage: User greetings, task titles, primary labels, tab text

- **Secondary Text**: `#E0E0E0` (Light Grey)
  - Used for: Secondary information, subtitles, descriptions
  - Usage: Date labels, task descriptions, helper text

- **Disabled Text**: `#9E9E9E` (Medium Grey)
  - Used for: Disabled states, placeholder text
  - Usage: Input placeholders, disabled buttons

### Accent Colors

- **Grey Primary**: `#4A4A4A` (Medium Grey)
  - Used for: Interactive elements, buttons, emphasis
  - Usage: Plus icon background, button backgrounds, active states

- **Grey Light**: `#6A6A6A` (Light Grey)
  - Used for: Hover states, pressed states
  - Usage: Button hover effects, active touch feedback

- **Grey Dark**: `#2A2A2A` (Dark Grey)
  - Used for: Container backgrounds, subtle emphasis
  - Usage: Task container backgrounds, input field backgrounds

### UI Element Colors

- **Border White**: `#FFFFFF` (Pure White)
  - Used for: Container borders, dividers, emphasis borders
  - Usage: Task container borders (1px), input field borders (2px), plus icon borders (2px)

- **Icon Primary**: `#FFFFFF` (Pure White)
  - Used for: Primary icons, navigation icons, plus icon
  - Usage: Tab icons, action icons, general UI icons, plus icon

- **Icon Background**: `#4A4A4A` (Medium Grey)
  - Used for: Icon backgrounds, button backgrounds
  - Usage: Plus icon circular background

## Typography

### Font Family
- **Primary Font**: `Sour Gummy`
- **Fallback Fonts**: `Roboto`, `Arial`, `sans-serif`

### Font Weights and Sizes

- **Heading Large**: 
  - Size: 24px
  - Weight: 600 (Semi-bold)
  - Usage: Welcome screen title, main headings

- **Heading Medium**:
  - Size: 20px
  - Weight: 500 (Medium)
  - Usage: Section titles, tab labels

- **Body Large**:
  - Size: 16px
  - Weight: 400 (Regular)
  - Usage: Task titles, primary content

- **Body Medium**:
  - Size: 14px
  - Weight: 400 (Regular)
  - Usage: Task descriptions, secondary content

- **Caption**:
  - Size: 12px
  - Weight: 400 (Regular)
  - Usage: Date labels, helper text

## Component Styling

### Task Containers
- **Background**: Surface Grey (`#2A2A2A`)
- **Border**: 1px solid Border White (`#FFFFFF`)
- **Border Radius**: 12px (smooth rounded corners for boxy design)
- **Padding**: 16px
- **Margin**: 8px vertical

### Task Items (within containers)
- **Background**: Surface Grey (`#2A2A2A`)
- **Border**: None (inherits container styling)
- **Border Radius**: 8px (boxy design with smooth corners)
- **Padding**: 12px
- **Margin**: 4px vertical between items

### Routine Task Labels
- **Background**: Grey Primary (`#4A4A4A`)
- **Border**: 1px solid Border White (`#FFFFFF`)
- **Border Radius**: 6px (boxy design)
- **Text**: Primary Text (`#FFFFFF`)
- **Padding**: 4px horizontal, 2px vertical
- **Font Weight**: 500 (Medium) for prominence

### Plus Icon Button
- **Background**: Grey Primary (`#4A4A4A`)
- **Border**: 2px solid Border White (`#FFFFFF`)
- **Border Radius**: 50% (circular)
- **Icon Color**: Primary Text (`#FFFFFF`)
- **Size**: 48px x 48px
- **Icon Size**: 24px

### Primary Buttons
- **Background**: Grey Primary (`#4A4A4A`)
- **Text**: Primary Text (`#FFFFFF`)
- **Border**: 2px solid Border White (`#FFFFFF`)
- **Border Radius**: 8px (boxy design)
- **Padding**: 12px horizontal, 8px vertical

### Secondary Buttons
- **Background**: Transparent
- **Border**: 2px solid Border White (`#FFFFFF`)
- **Text**: Primary Text (`#FFFFFF`)
- **Border Radius**: 8px (boxy design)

### Input Fields
- **Background**: Surface Grey (`#2A2A2A`)
- **Border**: 2px solid Border White (`#FFFFFF`)
- **Border Radius**: 8px (boxy design)
- **Text Color**: Primary Text (`#FFFFFF`)
- **Placeholder Color**: Disabled Text (`#9E9E9E`)

### Checkboxes
- **Unchecked**: 2px solid Border White (`#FFFFFF`)
- **Checked**: Background Grey Primary (`#4A4A4A`) with 2px solid Border White
- **Checkmark**: Primary Text (`#FFFFFF`)
- **Border Radius**: 4px (slightly boxy)

### Tabs
- **Active Tab**: Primary Text (`#FFFFFF`)
- **Inactive Tab**: Secondary Text (`#E0E0E0`)
- **Tab Indicator**: Border White (`#FFFFFF`)
- **Tab Background**: Transparent
- **Tab Border Radius**: 8px (boxy design for consistency)

## Spacing System

### Padding and Margins
- **Extra Small**: 4px
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **Extra Large**: 32px

### Component Spacing
- **Screen Padding**: 16px horizontal
- **Container Margin**: 8px vertical
- **Element Spacing**: 12px between related elements
- **Section Spacing**: 24px between sections

## Elevation and Shadows

### Task Containers
- **Elevation**: 2dp
- **Shadow Color**: `#000000` with 10% opacity
- **Shadow Offset**: (0, 2)
- **Shadow Blur**: 4px

### Buttons
- **Elevation**: 1dp
- **Shadow Color**: `#000000` with 8% opacity
- **Shadow Offset**: (0, 1)
- **Shadow Blur**: 2px

## Accessibility

### Contrast Ratios
- **Primary Text on Dark Grey Background**: 21:1 (AAA compliant)
- **Secondary Text on Dark Grey Background**: 12:1 (AAA compliant)
- **White on Grey Background**: 8.2:1 (AAA compliant)
- **Grey on Black Background**: 4.5:1 (AA compliant)

### Touch Targets
- **Minimum Size**: 44px x 44px
- **Recommended Size**: 48px x 48px for primary actions

## Implementation Notes

- All colors should be defined as constants in a theme configuration file
- Use Flutter's ThemeData to implement consistent theming
- Ensure proper color contrast for accessibility compliance
- Test theme on different screen sizes and orientations
- Consider system-level accessibility settings (high contrast, large text)