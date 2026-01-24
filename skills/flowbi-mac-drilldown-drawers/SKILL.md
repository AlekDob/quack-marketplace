---
name: flowbi-mac-drilldown-drawers
description: "This skill defines the standard pattern for drill-down drawers on macOS in Flow BI. Use this skill when implementing new detail drawers (Store, Agent, Brand, Category, etc.) that need to replace the right column on macOS, handle close/drill-up behavior, and sync breakdown data with the NetworkGraphView. Ensures consistency across all drawer types."
---

# Flow BI Mac Drill-Down Drawers Pattern

This skill documents the standard implementation pattern for drill-down drawers on macOS in the Flow BI app. All entity detail drawers (Store, Agent, Brand, Category, etc.) MUST follow this pattern for consistency.

## When to Use This Skill

- Implementing a new detail drawer for any entity type
- Fixing issues with existing drawer behavior on macOS
- Adding drill-down functionality to the NetworkGraphView
- Ensuring drawer consistency across the app

## Architecture Overview

### Key Components

```
DashboardView.swift
├── macRightPanel (ZStack) - Conditional rendering of drawer vs dashboard
├── selectedEntity state variables - Track which entity is selected
├── closeEntityDrawerAndDrillUp() - Handle drawer close + graph navigation
└── handleGraphFilterPathChange() - Skip data sync during drill-down

EntityDetailDrawer.swift
├── drawerContent - Platform-specific layout (#if os(macOS))
├── macOSHeader - Title + close button (X)
├── onClose callback - Triggers closeEntityDrawerAndDrillUp()
└── onBreakdownLoaded callback - Sync breakdown data to graph
```

## Implementation Pattern

### 1. State Variables in DashboardView

For each drill-down entity, define two state variables:

```swift
// Store drill-down
@State private var selectedStoreRevenue: StoreRevenue?
@State private var selectedStoreNode: GraphNode?

// Agent drill-down
@State private var selectedAgent: AgentRevenueItem?
@State private var selectedAgentNode: GraphNode?

// [New Entity] drill-down
@State private var selectedEntity: EntityType?
@State private var selectedEntityNode: GraphNode?
```

**IMPORTANT**: Both variables are required:
- `selectedEntity` - Opens the drawer (used in macRightPanel condition)
- `selectedEntityNode` - Required for `onBreakdownLoaded` callback to update the graph

### 2. macRightPanel Structure (ZStack)

The right panel uses a ZStack with conditional rendering. Entity drawers **REPLACE** the dashboard column, they don't overlay it:

```swift
private var macRightPanel: some View {
    ZStack {
        if let storeRevenue = selectedStoreRevenue {
            // Store drawer replaces dashboard
            StoreDetailDrawer(
                storeRevenue: storeRevenue,
                currencyCode: TenantManager.shared.selectedTenant.currencyCode,
                onBreakdownLoaded: { breakdownData in
                    if let storeNode = selectedStoreNode {
                        graphViewModel.updateStoreBreakdown(breakdownData, for: storeNode)
                    }
                },
                onClose: {
                    closeStoreDrawerAndDrillUp()
                }
            )
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            ))
        } else if let agent = selectedAgent {
            // Agent drawer replaces dashboard
            AgentDetailDrawer(
                agent: agent,
                currencyCode: TenantManager.shared.selectedTenant.currencyCode,
                onBreakdownLoaded: { breakdownData in
                    if let agentNode = selectedAgentNode {
                        graphViewModel.updateAgentBreakdown(breakdownData, for: agentNode)
                    }
                },
                onClose: {
                    closeAgentDrawerAndDrillUp()
                }
            )
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            ))
        } else {
            // Default: show dashboard content
            NavigationStack {
                dashboardContent
                    .navigationTitle(LocalizedKeys.tabDashboard.localized)
            }
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.98)),
                removal: .opacity
            ))
        }
    }
    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedStoreRevenue?.id)
    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: selectedAgent?.id)
}
```

**KEY POINTS**:
- Use `else if` chain - only one drawer at a time
- Each drawer has the same transition animation
- Add `.animation()` modifier for each entity type

### 3. Close and Drill-Up Function

Each entity needs a close function that:
1. Clears the state variables (closes drawer)
2. Navigates back in the graph if entity was in filterPath

```swift
private func closeEntityDrawerAndDrillUp() {
    print("📊 [Dashboard] Closing entity drawer")

    let filterPath = graphViewModel.graphState.filterPath

    // Animate drawer closing
    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
        selectedEntity = nil
        selectedEntityNode = nil
    }

    // Drill up in graph if entity was in filterPath
    if let lastNode = filterPath.last, lastNode.type == .entityType {
        let targetIndex = filterPath.count - 1
        graphViewModel.navigateToBreadcrumb(index: targetIndex)
    }
}
```

### 4. Skip Data Sync During Drill-Down

In `handleGraphFilterPathChange()`, add a check to skip data sync when in drill-down mode:

```swift
private func handleGraphFilterPathChange(_ newPath: [GraphNode]) {
    // Close drawer when navigating away (drill up)
    let currentlyOnEntity = newPath.last?.type == .entityType
    if selectedEntity != nil && !currentlyOnEntity {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            selectedEntity = nil
            selectedEntityNode = nil
        }
    }

    // CRITICAL: Skip sync during drill-down to prevent overwriting breakdown data
    if let lastNode = newPath.last, lastNode.type == .entityType {
        print("📊 [DashboardView] Entity drill-down active - skipping data sync")
        return
    }

    // ... rest of sync logic
}
```

### 5. Drawer View Structure (macOS)

Each detail drawer MUST follow this structure on macOS:

```swift
struct EntityDetailDrawer: View {
    let entity: EntityType
    let currencyCode: String
    var onBreakdownLoaded: ((EntityBreakdownData) -> Void)?
    var onClose: (() -> Void)?  // REQUIRED for macOS

    var body: some View {
        drawerContent
            .task {
                // Load data and call onBreakdownLoaded
            }
    }

    @ViewBuilder
    private var drawerContent: some View {
        #if os(macOS)
        VStack(spacing: 0) {
            macOSHeader      // Title + X button
            TabView(selection: $selectedTab) {
                statsTabContent.tag(DrawerTab.stats)
                documentsTabContent.tag(DrawerTab.documents)
            }
            bottomTabBar     // Stats | Documents tabs
        }
        .background(Color(nsColor: .windowBackgroundColor))
        #else
        // iOS uses NavigationStack with sheet presentation
        NavigationStack {
            // ... iOS implementation
        }
        .presentationDetents([.large])
        #endif
    }

    #if os(macOS)
    private var macOSHeader: some View {
        HStack {
            Text(entity.name)
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Button {
                onClose?()  // MUST call onClose, not dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            Rectangle()
                .fill(Color(nsColor: .windowBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    #endif
}
```

### 6. Header Section Pattern (Inside Drawer Content)

The header section inside the drawer content should follow this layout:

```swift
private var headerSection: some View {
    HStack(spacing: 12) {
        // Flag (large)
        Text(entity.countryFlag)
            .font(.system(size: 36))

        VStack(alignment: .leading, spacing: 4) {
            // Entity name
            Text(entity.name)
                .font(.headline.weight(.bold))

            // Type badge + info
            HStack(spacing: 6) {
                Text("TYPE")  // e.g., "APP", "AGENT", "BRAND"
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.green)  // or entity-specific color
                    .clipShape(Capsule())

                Text("additional info")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }

        Spacer()
    }
    .padding(14)
    .background {
        RoundedRectangle(cornerRadius: 14)
            .fill(.ultraThinMaterial)
    }
}
```

## Common Mistakes to Avoid

### 1. Using .macDrawer() Instead of macRightPanel

**WRONG** - Creates overlay drawer:
```swift
.macDrawer(item: $selectedAgent) { agent in
    AgentDetailDrawer(agent: agent)
}
```

**CORRECT** - Replaces column content:
```swift
// In macRightPanel ZStack
else if let agent = selectedAgent {
    AgentDetailDrawer(agent: agent, onClose: { ... })
}
```

### 2. Missing selectedEntityNode

**WRONG** - Only sets entity, graph can't update:
```swift
selectedAgent = agent
// Missing: selectedAgentNode = node
```

**CORRECT** - Sets both:
```swift
withAnimation {
    selectedAgentNode = node
    selectedAgent = agent
}
```

### 3. Using dismiss() on macOS

**WRONG** - Closes the entire window:
```swift
Button { dismiss() }  // Don't use on macOS!
```

**CORRECT** - Uses callback:
```swift
Button { onClose?() }  // Properly clears state + drill up
```

### 4. Not Skipping Data Sync During Drill-Down

**WRONG** - Breakdown data gets overwritten:
```swift
// Missing check in handleGraphFilterPathChange
// Data sync continues, overwrites breakdown
```

**CORRECT** - Early return during drill-down:
```swift
if let lastNode = newPath.last, lastNode.type == .agent {
    return  // Skip sync, preserve breakdown data
}
```

## Checklist for New Drill-Down Drawers

- [ ] Two state variables: `selectedEntity` and `selectedEntityNode`
- [ ] Added to `macRightPanel` ZStack with `else if`
- [ ] Transition animation: `.move(edge: .trailing).combined(with: .opacity)`
- [ ] Animation modifier: `.animation(..., value: selectedEntity?.id)`
- [ ] `closeEntityDrawerAndDrillUp()` function created
- [ ] Check added to `handleGraphFilterPathChange()` to skip sync
- [ ] Drawer has `onClose` callback parameter
- [ ] macOS uses `macOSHeader` with X button calling `onClose?()`
- [ ] macOS does NOT use NavigationStack (causes sidebar)
- [ ] `onBreakdownLoaded` callback wired to `graphViewModel.updateEntityBreakdown()`
- [ ] Header section follows Flag + Name + Badge pattern

## Reference Files

- `FlowBI/Features/Dashboard/Views/DashboardView.swift` - Main implementation
- `FlowBI/Features/Dashboard/Components/StoreDetailDrawer.swift` - Reference drawer
- `FlowBI/Shared/Components/AgentDetailDrawer.swift` - Agent drawer
- `FlowBI/Features/ReportBuilder/ViewModels/NetworkGraphViewModel.swift` - Graph sync
