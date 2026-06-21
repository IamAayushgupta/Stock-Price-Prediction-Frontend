I have a Flutter stock prediction dashboard that currently looks good on Web/Desktop. I DO NOT want to change the existing Web UI at all.

Your task is to create a fully responsive Mobile Layout using LayoutBuilder while preserving all existing functionality, APIs, charts, state management, and business logic.

Requirements:

### Responsive Architecture
- Use LayoutBuilder as the primary responsive solution.
- Keep the existing desktop/web layout unchanged.
- Create a dedicated mobile layout when screen width is below 800px.
- Optionally add a tablet layout between 800px and 1200px.

Example:

LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 800) {
      return MobileDashboard();
    } else {
      return DesktopDashboard();
    }
  },
)

### Mobile Design Goals

The mobile UI should feel like a native Flutter app, not a compressed web page.

Current Problems:
- Desktop layout is squeezed into mobile width.
- Chart becomes difficult to read.
- Table is too wide for phone screens.
- Insights panel appears disconnected.
- Too much vertical scrolling.
- Cards are not optimized for mobile.

### Mobile Layout Structure

1. Header Section
- App logo and title.
- Search field below the title.
- Full-width search bar.

2. KPI Cards
- Show Latest Price, MA50, MA100, MA200.
- Display in a 2x2 grid.
- Equal card heights.
- Responsive spacing.

Example:

[ Latest Price ] [ MA50 ]
[ MA100       ] [ MA200 ]

3. Chart Section
- Chart occupies full screen width.
- Height around 300-350px.
- MA/LSTM toggle above chart.
- Legends displayed horizontally and scrollable if needed.

4. Model Insights Section
- Move directly below chart.
- Full-width card.
- Show insight cards stacked vertically.
- No fixed heights.
- Content should expand naturally.

5. Stock Data Table
- Place below insights.
- Use horizontal scrolling.
- Keep all columns visible.
- Preserve pagination.
- Pagination controls must remain inside the same card.

Structure:

┌────────────────────┐
│ Stock Data         │
│                    │
│ Horizontal Scroll  │
│ Table              │
│                    │
│ Pagination         │
└────────────────────┘

6. Spacing & Styling
- Consistent 16px horizontal padding.
- 12-16px spacing between sections.
- Maintain existing dark theme.
- Preserve current colors.
- Keep existing card styling.

### Important Rules

- DO NOT modify desktop/web layout.
- DO NOT change business logic.
- DO NOT modify APIs.
- DO NOT change chart calculations.
- DO NOT remove any features.
- Only refactor layout and responsiveness.
- Extract reusable widgets where necessary.
- Use LayoutBuilder and responsive widgets.
- Avoid code duplication.
- Ensure the mobile version feels like a professionally designed Flutter application.

Finally:
1. Explain the responsive architecture.
2. Show the widget tree for mobile.
3. Provide the complete Flutter code changes.
4. Keep desktop behavior exactly as it is today.