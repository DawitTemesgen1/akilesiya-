# Theme Integration - Current Status & Next Steps

## ✅ COMPLETED:

### 1. ThemeProvider
- ✅ Color constants for light/dark themes
- ✅ Helper methods for getting theme colors
- ✅ Toggle functionality

### 2. Home Screen Container (home_screen.dart)
- ✅ ModernAppBar with theme toggle (sun/moon icon)
- ✅ AppBottomNavBar theme-aware
- ✅ Navigation components theme-aware

### 3. Profile Screen (profile_screen.dart)
- ✅ Drawer added and functional
- ✅ AppBar with theme toggle
- ✅ Background, TabBar, FAB theme-aware
- ✅ Header (avatar, name) theme-aware
- ✅ Method signatures updated to accept theme colors
- ⚠️ **PARTIAL**: Tab content cards still use old constants

## ⚠️ CURRENT ISSUE:

The profile screen tab builder methods have been updated to accept theme color parameters, but the **internal card colors** still use hardcoded constants:
- `kCardColor` (dark card background)
- `kGoldColor` (gold accent)
- `kTextGrey` (grey text)
- `Colors.white` (white text)

These need to be replaced with the passed parameters:
- `surfaceColor` (instead of kCardColor)
- `primaryColor` (instead of kGoldColor)
- `textColor` (instead of Colors.white)
- `subtleText` (instead of kTextGrey)

## 🔧 MANUAL FIX NEEDED:

Due to file encoding/search issues, please manually update the following in `profile_screen.dart`:

### In `_buildStatusTab` method (around line 310-450):
```dart
// FIND and REPLACE:
color: kCardColor          → color: surfaceColor
color: kGoldColor          → color: primaryColor
color: Colors.white        → color: textColor
color: kTextGrey           → color: subtleText
color: Colors.white10      → color: isDark ? Colors.white10 : Colors.black12
progressColor: kGoldColor  → progressColor: primaryColor
```

### In `_buildPersonalTab` method (around line 500-515):
```dart
// FIND and REPLACE:
color: kCardColor          → color: surfaceColor
color: Colors.white10      → color: isDark ? Colors.white10 : Colors.black12
```

### In `_buildSpiritualTab` method (similar pattern)
### In `_buildEducationTab` method (similar pattern)

### In `_buildDetailRow` method:
Replace all color constants with the theme parameters

### In `_buildCourseItem` method:
Replace all color constants with the theme parameters

## 🚨 SPLASH SCREEN ISSUE:

**Problem**: Theme toggle is showing splash screen

**Solution**: Check `main.dart` - the app should NOT restart on theme change. The MaterialApp should rebuild but not show splash.

**What to check**:
1. Ensure splash screen is only shown on app startup
2. Theme changes should only trigger MaterialApp rebuild
3. Check if there's a `runApp()` call in theme toggle

## 📋 REMAINING SCREENS:

After fixing profile screen cards:
1. Homepage (homepage.dart) - Started, needs completion
2. Private Homepage (private_homepage.dart) - Not started
3. Learning Screen (learning_screen.dart) - Not started

## 🎯 PRIORITY:

1. **FIX**: Splash screen appearing on theme toggle
2. **FIX**: Profile screen card colors (manual replacement needed)
3. **THEN**: Continue with other screens

## 💡 RECOMMENDATION:

The framework is solid. The remaining work is mostly find-and-replace of color constants. Consider using your IDE's find-and-replace feature to batch update:
- `kCardColor` → `surfaceColor`
- `kGoldColor` → `primaryColor`  
- `Colors.white` → `textColor` (carefully, check context)
- `kTextGrey` → `subtleText`
