# Healio App - New Theme Design Documentation

## Overview
The Healio app has been updated with a clean, modern design inspired by the Healio reference image. The new theme features a light, professional appearance with improved visual hierarchy and consistency across all screens.

## Color Palette

### Primary Colors
- **Background**: `#F8F9FA` (Very light gray) - Used for screen backgrounds
- **Surface**: `#FFFFFF` (White) - Used for cards, app bars, and elevated surfaces
- **Primary Accent**: `#5FBB97` (Teal/Green) - Used for buttons, selected items, and highlights
- **Secondary Accent**: `#4CAF50` (Green) - Used for secondary highlights

### Text Colors
- **Heading/Primary Text**: `#2C4858` (Dark blue-gray) - Used for titles and important text
- **Secondary Text**: `#34495E` (Medium blue-gray) - Used for subtitles
- **Body Text**: `#5A6C7D` (Gray-blue) - Used for regular body text
- **Tertiary Text**: `#7B8794` (Light gray-blue) - Used for captions and hints
- **Disabled/Inactive**: `#9CA8B4` (Very light gray) - Used for unselected items

### Semantic Colors
- **Error**: `#E57373` (Light red) - Used for error states
- **Warning/Emergency**: `#E57373` (Light red) - Used for emergency features
- **Info**: `#4FC3F7` (Light blue) - Used for informational elements

## Theme Structure

### 1. App Bar
- **Background**: White (`#FFFFFF`)
- **Text Color**: Dark blue-gray (`#2C4858`)
- **Elevation**: 0 (flat design)
- **Title Style**: 
  - Font Size: 20-24px
  - Font Weight: Bold (600-700)
  - Letter Spacing: 0.5

### 2. Cards
- **Background**: White
- **Border Radius**: 16px
- **Shadow**: Subtle shadow with 0.04 opacity black, 10px blur, 2px offset
- **Padding**: 16px
- **Elevation**: 0 (shadow-only)

### 3. Icons
- **Size**: 24px (standard), 32px (feature icons), 16px (arrows)
- **Circle Background**: 
  - Size: 48px diameter
  - Background: Primary color at 0.1 opacity
  - Icon color: Primary color at full opacity

### 4. Bottom Navigation Bar
- **Background**: White
- **Elevation**: 0
- **Selected Color**: `#5FBB97` (Teal)
- **Unselected Color**: `#9CA8B4` (Light gray)
- **Type**: Fixed
- **Icons**: Outlined for unselected, filled for selected
- **Labels**: 
  - Selected: 12px, Font Weight 600
  - Unselected: 12px, Font Weight 400

### 5. Typography

#### Display Text (Hero Titles)
- **Large**: 32px, Bold, Dark blue-gray
- **Medium**: 28px, Bold, Dark blue-gray

#### Headers
- **H1**: 24px, Semi-bold (600), Dark blue-gray
- **H2**: 20px, Semi-bold (600), Dark blue-gray
- **H3**: 18px, Medium (500), Medium blue-gray

#### Body Text
- **Large**: 16px, Regular (400), Gray-blue
- **Medium**: 14px, Regular (400), Light gray-blue
- **Small**: 13px, Regular (400), Light gray-blue

## Screen-Specific Implementations

### Dashboard Screen
1. **Header Section** (White background):
   - Greeting: "Hi [Name]," - 28px, Bold
   - Subtitle: "Your health overview today" - 16px, Light gray
   
2. **Quick Stats Card**:
   - White card with rounded corners
   - Icons with semantic colors (heart = red, BP = blue)
   - Value text: 24px bold
   - Label text: 12px light gray

3. **Section Headers**:
   - "Health Services", "Health Tracking" - 20px, Semi-bold
   - Top margin: 24px

4. **Service Cards**:
   - White background
   - 48px icon circles
   - Title: 16px, Semi-bold
   - Subtitle: 13px, Light gray
   - Arrow: 16px, Very light gray

### Vitals Analysis Screen
- Same pattern as dashboard
- Uses PageHeader component (white background)
- StandardCard components for each vital
- Disclaimer box with 0.08 opacity background

### Profile Screen
- White app bar
- Profile picture section on white background
- Info cards with subtle shadows
- Consistent bottom navigation

### Login Screen
- Centered layout
- App logo: 120px height
- Title: "Healio" - 38px, Bold, Primary color
- Subtitle: 16px, Black54
- Input fields: White with 14px border radius
- Login button: Primary color background, white text, 52px height

## Implementation Notes

### Material 3
The app uses Material 3 design system with custom color scheme and components.

### Consistency Rules
1. All screens use `#F8F9FA` background
2. All cards use white with 16px border radius
3. All icons in circles use 0.1 opacity background with primary color
4. All bottom navigation bars use the same styling
5. All page headers use PageHeader widget
6. All list items use StandardCard widget

### Shadows
- Cards: `Color(0x0A000000)` (0.04 opacity black), 10px blur, 2px vertical offset
- Bottom nav: Same shadow but 20px blur, 5px vertical offset

### Border Radius
- Cards: 16px
- Buttons: 14px
- Input fields: 14px
- Icon circles: Full circle (50% of size)

## Component Library

### PageHeader Widget
```dart
PageHeader(
  title: 'Screen Title',
  subtitle: 'Optional subtitle',
  icon: Icons.icon_name,
)
```

### StandardCard Widget
```dart
StandardCard(
  icon: Icons.icon_name,
  title: 'Card Title',
  subtitle: 'Optional subtitle',
  iconColor: Color(0xFF5FBB97), // Optional
  onTap: () { /* navigation */ },
)
```

## Files Modified
- `lib/main.dart` - Complete theme overhaul
- `lib/widgets/page_header.dart` - Updated to white theme
- `lib/screens/dashboard.dart` - New layout matching Healio design
- All screen files - Updated colors and consistency
- 17 screen files updated with new color palette
- 3 files updated with new bottom navigation

## Migration from Old Theme

### Color Migrations
- `#4DB6AC` → `#5FBB97` (Primary teal)
- `#F5F5F5` / `#F5FBFA` → `#F8F9FA` (Background)
- `#2C2C2C` / `#2C3E50` → `#2C4858` (Dark text)
- Gradient backgrounds → Solid white backgrounds

### Component Updates
- Removed gradient app bars
- Updated all shadows to subtle 0.04 opacity
- Changed icon sizes to 24px standard
- Updated bottom navigation to outlined/filled pattern

## Testing Checklist
- [ ] All screens display correctly
- [ ] Bottom navigation works on all screens
- [ ] Colors are consistent across the app
- [ ] Shadows are subtle and consistent
- [ ] Text is readable with new colors
- [ ] Icons are properly sized
- [ ] Cards have proper spacing
- [ ] Theme works in light mode
- [ ] Navigation between screens preserves theme

## Future Enhancements
1. Add dark mode support
2. Add custom splash screen with new colors
3. Add animation transitions
4. Implement custom fonts if needed
5. Add theme toggle option
6. Create more specialized card components

## Maintenance Notes
- Always use theme colors from `ThemeData`
- Prefer using predefined widgets (PageHeader, StandardCard)
- Maintain 16px padding standard
- Keep shadows consistent
- Update this document when adding new components
