# Light Theme Integration Plan

## Objective
Add light theme support to 4 main screens while keeping existing dark theme, using attendance summary design paradigm.

## Screens to Update
1. Homepage (`home_screen.dart`)
2. Private Homepage (`private_home_screen.dart`)
3. Learning Screen (`learning_screen.dart`)
4. Profile Screen (`profile_screen.dart`)

## Changes Required

### 1. Theme Provider (✅ COMPLETED)
- Enhanced `theme_provider.dart` with color constants
- Dark theme colors (existing)
- Light theme colors (attendance summary style)
- Helper methods to get current theme colors

### 2. AppBar Updates (All 4 Screens)
- Replace notification icon with theme toggle icon
- Icon changes based on current theme (sun/moon)
- Calls `themeProvider.toggleTheme()` on tap

### 3. Color Updates (All 4 Screens)
For each screen, replace hardcoded colors with theme-aware colors:
- Background: `themeProvider.getBackgroundColor(context)`
- Surface/Cards: `themeProvider.getSurfaceColor(context)`
- Primary: `themeProvider.getPrimaryColor(context)`
- Text: `themeProvider.getOnSurfaceColor(context)`
- Subtle text: `themeProvider.getSubtleTextColor(context)`

### 4. Design Paradigm
Light theme should follow attendance summary style:
- Clean white surfaces
- Deep blue primary color
- Gold accents
- Subtle shadows and borders
- High contrast for readability

## Implementation Order
1. Homepage - Main entry point
2. Private Homepage - Similar to homepage
3. Profile Screen - User-facing
4. Learning Screen - Content-heavy

## Testing Checklist
- [ ] Theme toggle works on all screens
- [ ] Colors are readable in both themes
- [ ] Icons update correctly
- [ ] Theme persists across app restarts
- [ ] All UI elements visible in both themes
