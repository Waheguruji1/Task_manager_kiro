# Task Manager App Theme Specification

## Overview

This document defines the comprehensive theme and visual design system for the Task Manager Flutter app. The app follows a dark theme approach with white UI elements and strategic purple accents for a modern, comfortable user experience.

## Color Palette

### Primary Colors

- **Background Dark**: `#121212`
  - Used for: Main app background, screen backgrounds
  - Usage: Primary background color across all screens

- **Surface Dark**: `#1E1E1E`
  - Used for: Card backgrounds, container backgrounds
  - Usage: Task containers, dialog backgrounds, elevated surfaces

### Text Colors

- **Primary Text**: `#FFFFFF` (Pure White)
  - Used for: Main headings, primary content, important text
  - Usage: User greetings, task titles, primary labels

- **Secondary Text**: `#E0E0E0` (Light Gray)
  - Used for: Secondary information, subtitles, descriptions
  - Usage: Date labels, task descriptions, helper text

- **Disabled Text**: `#9E9E9E` (Medium Gray)
  - Used for: Disabled states, placeholder text
  - Usage: Input placeholders, disabled buttons

### Accent Colors

- **Purple Primary**: `#8E44AD` (Medium Purple)
  - Used for: Primary actions, active states, emphasis
  - Usage: Active tab indicators, primary buttons, checked checkboxes

- **Purple Light**: `#A569BD` (Light Purple)
  - Used for: Hover states, pressed states
  - Usage: Button hover effects, active touch feedback

- **Purple Dark**: `#7D3C98` (Dark Purple)
  - Used for: Pressed states, shadows
  - Usage: Button pressed states, active shadows

### UI Element Colors

- **Border Color**: `#FFFFFF` with 20% opacity (`#33FFFFFF`)
  - Used for: Container borders, dividers
  - Usage: Task container borders, input field borders

- **Icon Primary**: `#FFFFFF` (Pure White)
  - Used for: Primary icons, navigation icons
  - Usage: Tab icons, action icons, general UI icons

- **Icon Accent**: `#8E44AD` (Purple Primary)
  - Used for: Active icons, special action icons
  - Usage: Plus icon for adding tasks, active tab icons

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
- **Background**: Surface Dark (`#1E1E1E`)
- **Border**: 1px solid Border Color (`#33FFFFFF`)
- **Border Radius**: 12px
- **Padding**: 16px
- **Margin**: 8px vertical

### Buttons
- **Primary Button**:
  - Background: Purple Primary (`#8E44AD`)
  - Text: Pure White (`#FFFFFF`)
  - Border Radius: 8px
  - Padding: 12px horizontal, 8px vertical

- **Secondary Button**:
  - Background: Transparent
  - Border: 1px solid Purple Primary (`#8E44AD`)
  - Text: Purple Primary (`#8E44AD`)
  - Border Radius: 8px

### Input Fields
- **Background**: Surface Dark (`#1E1E1E`)
- **Border**: 1px solid Border Color (`#33FFFFFF`)
- **Border Radius**: 8px
- **Text Color**: Primary Text (`#FFFFFF`)
- **Placeholder Color**: Disabled Text (`#9E9E9E`)

### Checkboxes
- **Unchecked**: Border Color (`#33FFFFFF`)
- **Checked**: Purple Primary (`#8E44AD`)
- **Checkmark**: Pure White (`#FFFFFF`)

### Tabs
- **Active Tab**: Purple Primary (`#8E44AD`)
- **Inactive Tab**: Secondary Text (`#E0E0E0`)
- **Tab Indicator**: Purple Primary (`#8E44AD`)

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
- **Primary Text on Dark Background**: 21:1 (AAA compliant)
- **Secondary Text on Dark Background**: 12:1 (AAA compliant)
- **Purple on Dark Background**: 4.8:1 (AA compliant)

### Touch Targets
- **Minimum Size**: 44px x 44px
- **Recommended Size**: 48px x 48px for primary actions

## Implementation Notes

- All colors should be defined as constants in a theme configuration file
- Use Flutter's ThemeData to implement consistent theming
- Ensure proper color contrast for accessibility compliance
- Test theme on different screen sizes and orientations
- Consider system-level accessibility settings (high contrast, large text)