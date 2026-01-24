# SwiftUI Transforms Reference

Guida completa alle trasformazioni geometriche in SwiftUI: scaleEffect, offset, rotationEffect e loro interazioni.

## Indice
1. [Ordine delle Trasformazioni](#ordine-delle-trasformazioni)
2. [scaleEffect](#scaleeffect)
3. [offset](#offset)
4. [Zoom/Pan Canvas Centering](#zoompan-canvas-centering)
5. [Anchor Points](#anchor-points)
6. [Animazioni con Trasformazioni](#animazioni-con-trasformazioni)

---

## Ordine delle Trasformazioni

In SwiftUI, l'ordine dei modifier è **fondamentale**. Le trasformazioni vengono applicate **dal basso verso l'alto** (dall'ultimo al primo nella catena di modifier).

```swift
// L'ordine conta!
view
    .offset(x: 50, y: 0)      // 3. Applicato per ultimo
    .scaleEffect(0.5)          // 2. Applicato secondo
    .rotationEffect(.degrees(45)) // 1. Applicato per primo
```

### Ordine Comune per Zoom/Pan
```swift
.scaleEffect(zoomScale)  // Prima scala
.offset(offset)          // Poi sposta
```

---

## scaleEffect

### Comportamento Fondamentale

`scaleEffect` scala la view dal suo **anchor point** (default: centro del frame).

```swift
// Scala dal centro (default)
view.scaleEffect(0.5)

// Scala da un punto specifico
view.scaleEffect(0.5, anchor: .topLeading)
view.scaleEffect(0.5, anchor: .bottomTrailing)
view.scaleEffect(0.5, anchor: UnitPoint(x: 0.3, y: 0.7))
```

### Formula di Trasformazione

Quando applichi `scaleEffect(zoom)` con anchor al centro, ogni punto P nel frame si trasforma così:

```
P_after = anchor + (P - anchor) * zoom
```

Per anchor al centro (default):
```
P_after = frameCenter + (P - frameCenter) * zoom
```

**Esempio numerico:**
- Frame: 1000x1000, center = (500, 500)
- Punto P = (700, 300)
- Zoom = 0.5

```
P_after.x = 500 + (700 - 500) * 0.5 = 500 + 100 = 600
P_after.y = 500 + (300 - 500) * 0.5 = 500 - 100 = 400
P_after = (600, 400)
```

Il punto si è mosso VERSO il centro del frame.

---

## offset

`offset` sposta la view dopo tutte le altre trasformazioni geometriche.

```swift
.offset(x: 100, y: 50)
// oppure
.offset(CGSize(width: 100, height: 50))
```

### offset vs position

| Modifier | Comportamento |
|----------|---------------|
| `offset` | Sposta relativamente alla posizione attuale |
| `position` | Posiziona assolutamente nel parent container |

---

## Zoom/Pan Canvas Centering

### Il Problema Comune

Quando hai un canvas grande con elementi in una regione specifica e vuoi centrare la vista su quegli elementi con zoom:

```swift
// Setup tipico
let canvasSize = CGSize(width: viewSize.width * 3, height: viewSize.height * 3)

canvas
    .frame(width: canvasSize.width, height: canvasSize.height)
    .scaleEffect(zoomScale)
    .offset(offset)
```

### Soluzione Corretta

Per centrare su un punto target specifico:

```swift
private func centerOnPoint(
    targetPoint: CGPoint,
    viewSize: CGSize,
    canvasSize: CGSize,
    zoomScale: CGFloat
) -> CGSize {
    // 1. Il pivot di scaleEffect è il centro del canvas
    let canvasCenter = CGPoint(
        x: canvasSize.width / 2,
        y: canvasSize.height / 2
    )

    // 2. Calcola dove finisce targetPoint dopo lo scaling
    let targetAfterScale = CGPoint(
        x: canvasCenter.x + (targetPoint.x - canvasCenter.x) * zoomScale,
        y: canvasCenter.y + (targetPoint.y - canvasCenter.y) * zoomScale
    )

    // 3. Calcola offset per portare targetAfterScale al centro della view
    let viewCenter = CGPoint(
        x: viewSize.width / 2,
        y: viewSize.height / 2
    )

    return CGSize(
        width: viewCenter.x - targetAfterScale.x,
        height: viewCenter.y - targetAfterScale.y
    )
}
```

### Errori Comuni

#### Errore 1: Ignorare il pivot di scaleEffect
```swift
// SBAGLIATO
offset = viewCenter - targetPoint * zoomScale
```

#### Errore 2: Centrare il canvas invece del contenuto
```swift
// SBAGLIATO - centra il canvas geometrico
let scaledCanvasSize = canvasSize * zoomScale
offset = (viewSize - scaledCanvasSize) / 2
```

#### Errore 3: Applicare offset prima di scale
```swift
// SBAGLIATO - ordine invertito
.offset(offset)
.scaleEffect(zoomScale)
```

### Esempio Completo: Mappa Interattiva

```swift
struct InteractiveMapView: View {
    @State private var zoomScale: CGFloat = 0.5
    @State private var offset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let canvasSize = CGSize(
                width: geometry.size.width * 3,
                height: geometry.size.height * 3
            )

            MapContent(canvasSize: canvasSize)
                .frame(width: canvasSize.width, height: canvasSize.height)
                .scaleEffect(zoomScale)
                .offset(offset)
                .onAppear {
                    // Centra su un punto specifico della mappa
                    let targetPoint = CGPoint(
                        x: canvasSize.width * 0.5,  // Centro X del contenuto
                        y: canvasSize.height * 0.48 // Centro Y del contenuto
                    )
                    offset = centerOnPoint(
                        targetPoint: targetPoint,
                        viewSize: geometry.size,
                        canvasSize: canvasSize,
                        zoomScale: zoomScale
                    )
                }
                .gesture(dragGesture)
                .gesture(magnificationGesture)
        }
    }
}
```

---

## Anchor Points

### UnitPoint Predefiniti

| UnitPoint | Coordinate |
|-----------|------------|
| `.topLeading` | (0, 0) |
| `.top` | (0.5, 0) |
| `.topTrailing` | (1, 0) |
| `.leading` | (0, 0.5) |
| `.center` | (0.5, 0.5) |
| `.trailing` | (1, 0.5) |
| `.bottomLeading` | (0, 1) |
| `.bottom` | (0.5, 1) |
| `.bottomTrailing` | (1, 1) |

### Custom Anchor

```swift
// Anchor personalizzato
.scaleEffect(scale, anchor: UnitPoint(x: 0.3, y: 0.7))
```

### Zoom Verso il Cursore (Pinch-to-Zoom)

Per zoomare verso il punto del gesto:

```swift
.gesture(
    MagnificationGesture()
        .onChanged { value in
            // Calcola anchor point basato sulla posizione del gesto
            let gestureLocation = ... // Posizione del gesto
            let anchor = UnitPoint(
                x: gestureLocation.x / canvasSize.width,
                y: gestureLocation.y / canvasSize.height
            )
            // Applica zoom con anchor dinamico
        }
)
```

---

## Animazioni con Trasformazioni

### Animare Zoom e Pan

```swift
withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
    zoomScale = 1.0
    offset = calculateCenterOffset()
}
```

### Transizioni Smooth

```swift
.animation(.easeInOut(duration: 0.3), value: zoomScale)
.animation(.easeInOut(duration: 0.3), value: offset)
```

### Gesture + Animation

```swift
@GestureState private var magnificationState: CGFloat = 1.0

var magnificationGesture: some Gesture {
    MagnificationGesture()
        .updating($magnificationState) { value, state, _ in
            state = value
        }
        .onEnded { value in
            withAnimation(.spring()) {
                zoomScale = min(max(zoomScale * value, minZoom), maxZoom)
            }
        }
}
```

---

## Riferimenti

- Apple Documentation: [scaleEffect(_:anchor:)](https://developer.apple.com/documentation/swiftui/view/scaleeffect(_:anchor:)-7q7as)
- Apple Documentation: [offset(_:)](https://developer.apple.com/documentation/swiftui/view/offset(_:))
- Flow BI NetworkGraphView implementation
- Project skill: `.claude/skills/swiftui-zoom-pan-centering.md`
