//
//  PagerView.swift
//
//  Created by Julio Rodríguez on 7/9/23.
//

import SwiftUI

public struct PagerView: View {
    @Environment(\.scrollInfo) var scrollInfo
    let axis: PagerViewAxis
    let content: [AnyView]
    let transitionStyle: PagerViewTransition

    @Binding var index: Int
    @State private var offset: CGFloat = .zero
    @State private var translation: CGFloat = .zero
    @State private var size: CGSize = .zero
    private var infinityScroll: Bool = false
    private var animation: Animation
    private var clipScrollEnd: Bool

    public init<Views>(axis: PagerViewAxis = .horizontal,
                       transition: PagerViewTransition = .cube,
                       index: Binding<Int> = .constant(.zero),
                       animation: Animation = .default,
                       clipScrollEnd: Bool = true,
                       @ViewBuilder content: () -> TupleView<Views>
    ) {
        self.content = content().getViews
        self.axis = axis
        self.transitionStyle = transition
        self.animation = animation
        self.clipScrollEnd = clipScrollEnd
        self._index = index
    }

    func isAbleToMove(geometry: GeometryProxy, gesture: DragGesture.Value) -> Bool {
        guard clipScrollEnd else { return true }
        let size = axis == .horizontal
        ? geometry.size.width
        : geometry.size.height
        let maxValue = -size * CGFloat(content.count - 1)
        let translationOffset = axis == .horizontal
        ? gesture.translation.width
        : gesture.translation.height
        let newOffset = offset - translation + translationOffset
        let correctRange = (maxValue...0.0)
        return correctRange ~= newOffset
    }

    var pagerOffset: CGSize {
        CGSize(width: axis == .horizontal ? offset : .zero,
               height: axis == .vertical ? offset : .zero)
    }

    @ViewBuilder
    func subViews(geometry: GeometryProxy) -> some View {
        ForEach(content.indices) {
            content[$0]
                .frame(width: geometry.size.width, height: geometry.size.height)
                .contentShape(Rectangle())
                .pagerTransition(transition: transitionStyle, index: $0, offset: offset, geometry: geometry, axis: axis)
        }
    }

    @ViewBuilder
    func container(geometry: GeometryProxy) -> some View {
        if axis == .horizontal {
            LazyHStack(spacing: 0) {
                subViews(geometry: geometry)
            }
        } else {
            LazyVStack(spacing: 0) {
                subViews(geometry: geometry)
            }
        }
    }

    func onChangedScroll(gesture: DragGesture.Value, geometry: GeometryProxy) {
        guard scrollInfo.scrolling == nil || scrollInfo.scrolling == axis else {
            offset -= translation
            translation = .zero
            return
        }
        
        // Check clip
        guard isAbleToMove(geometry: geometry, gesture: gesture) else { return }

        if scrollInfo.scrolling == nil {
            if abs(gesture.translation.height) > 20, axis == .vertical {
                scrollInfo.scrolling = .vertical
            } else if abs(gesture.translation.width) > 20, axis == .horizontal {
                scrollInfo.scrolling = .horizontal
            }
        }
        offset -= translation
        if axis == .horizontal {
            translation = gesture.translation.width
        } else {
            translation = gesture.translation.height
        }
        offset += translation
    }

    func onEndedScroll(value: DragGesture.Value, geometry: GeometryProxy) {
        guard !infinityScroll else {
            translation = .zero
            return
        }
        let currentOffset = offset
        let position: CGFloat
        if axis == .horizontal {
            position = currentOffset / geometry.size.width * -1
        } else {
            position = currentOffset / geometry.size.height * -1
        }

        var newIndex: CGFloat = position.rounded()
        if newIndex >= CGFloat(content.count) {
            newIndex -= 1
        } else if newIndex < .zero {
            newIndex = .zero
        }

        let newOffset: CGFloat
        if axis == .horizontal {
            newOffset = geometry.size.width * newIndex * -1
        } else {
            newOffset = geometry.size.height * newIndex * -1
        }

        withAnimation(animation) {
            self.offset = newOffset
        }
        translation = .zero
        scrollInfo.scrolling = nil
        index = Int(newIndex)
    }

    public var body: some View {
        GeometryReader { geometry in
            container(geometry: geometry)
            .mask { // This to keep the view in its correct size
                Color.black
            }
            .offset(pagerOffset)
            .onAppear {
                size = geometry.size
            }
            .simultaneousGesture(
                DragGesture(coordinateSpace: .global)
                .onChanged {
                    onChangedScroll(gesture: $0, geometry: geometry)
                }
                .onEnded {
                    onEndedScroll(value: $0, geometry: geometry)
                }
            )
            .onChange(of: index, perform: { newValue in
                guard content.indices.contains(newValue) else {
                    return
                }
                let currentIndex: CGFloat
                if axis == .horizontal {
                    currentIndex = offset / size.width * -1
                } else {
                    currentIndex = offset / size.height * -1
                }
                let currentIntegerIndex = Int(currentIndex.rounded())
                guard currentIntegerIndex != newValue else { return }
                print("different \(currentIntegerIndex) \(newValue) \(currentIndex)")
                var indexes: [Int] = []
                if currentIntegerIndex < newValue {
                    indexes = Array(currentIntegerIndex...newValue)
                } else {
                    indexes = Array(newValue...currentIntegerIndex).reversed()
                }
                indexes.removeFirst()
                for (index, value) in indexes.enumerated() {
                    let delay: CGFloat = 0.1 * CGFloat(index)
                    withAnimation(animation.delay(delay)) {
                        offset = size.width * -1 * CGFloat(value)
                    }
                }
            })
        }
    }
}

struct CustomTabView_Previews: PreviewProvider {
    struct CustomTestModifier: PagerViewCustomTransition {
        func opacity(index: Int, offset: CGFloat, geometry: GeometryProxy, axis: PagerViewAxis) -> CGFloat {
            let position: CGFloat
            switch axis {
            case .horizontal:
                position = offset / geometry.size.width * -1
            case .vertical:
                position = offset / geometry.size.height * -1
            }
            return (position.rounded(.down)...position.rounded(.up)) ~= CGFloat(index) ? 1 : 0
        }
        func getModifier<Content>(view: Content, index: Int, offset: CGFloat, geometry: GeometryProxy, axis: PagerViewAxis) -> any View where Content : View {
            view
                .background(index % 2 == 0 ? Color.gray : Color.orange)
                .opacity(opacity(index: index, offset: offset, geometry: geometry, axis: axis))
        }
    }

    struct Preview: View {
        @State var index: Int = .zero

        var body: some View {
            VStack {
                PagerView(index: $index, content: {
                    PagerView(axis: .vertical, transition: .smooth) {
                        Color.blue
                        Color.orange
                        Color.black
                    }
                    Color.yellow
                    PagerView(axis: .vertical, transition: .cube) {
                        VStack {
                            Text("2.1")
                        }
                        VStack {
                            Text("2.2")
                        }
                    }
                    PagerView(axis: .vertical,
                              transition: .custom(CustomTestModifier())) {
                        VStack {
                            Text("3.1")
                        }
                        VStack {
                            Text("3.2")
                        }
                        VStack {
                            Text("3.3")
                        }
                    }
                })
                .addPagerControl(alignment: .bottom) { index, content in
                    HStack {
                        ForEach(.zero..<content) { contentIndex in
                            Button(action: {
                                self.index = contentIndex
                            }, label: {
                                if contentIndex == index {
                                    Circle()
                                        .stroke()
                                        .foregroundColor(Color.white)
                                } else {
                                    Circle()
                                        .foregroundColor(Color.white)
                                }
                            })
                        }
                    }
                    .frame(width: 80)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.white.opacity(0.5))
                        
                    )
                    .padding()
                }
                Button("Change", action: {
                    index = index == .zero ? 2 : .zero
                })
            }
            
        }
    }
    static var previews: some View {
        Preview()
    }
}
