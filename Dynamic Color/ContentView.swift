//
//  ContentView.swift
//  Dynamic Color
//
//  Created by Joseph Albanese on 10/18/24.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.currentColorSpace) private var currentColorSpace

    @State private var red: Double = 0.98
    @State private var green: Double = 0.9
    @State private var blue: Double = 0.2
    @State private var opacity: Double = 1.0
    @State private var selectedTextBlendMode: BlendMode = .normal
    @State private var selectedBgBlendMode: BlendMode = .normal
    @State private var isDarkMode: Bool = false
    @State private var cellBGOpacity: Double = 0.2
    @State private var textBlackOpacity: Double = 0.5
    @State private var textWhiteOpacity: Double = 0.3
    
    
    var bgColor: Color {
        Color(red: red, green: green, blue: blue)
    }
    
    var pixelColor: Color {
        let brightness = ((0.2126 * red) + (0.7152 * green) + (0.0722 * blue))
        return brightness >= 0.5 ? .black.opacity(0.75) : .white.opacity(0.75)
    }
    
    var textColor: Color {
        let brightness = ((0.2126 * red) + (0.7152 * green) + (0.0722 * blue))
        return brightness >= 0.5 ? .black.opacity(textBlackOpacity) : .white.opacity(textWhiteOpacity)
    }
    
    var textBlendMode: BlendMode {
        let brightness = ((0.2126 * red) + (0.7152 * green) + (0.0722 * blue))
        return brightness > 0.5 ? .plusDarker : .plusLighter
    }
    
    var bgBlendMode: BlendMode {
        let brightness = ((0.2126 * red) + (0.7152 * green) + (0.0722 * blue))
        return brightness > 0.5 ? .plusLighter : .plusDarker
    }
    
    func assignRandomColor() {
        withAnimation(.spring){
            red = Double.random(in: 0...1)
            green = Double.random(in: 0...1)
            blue = Double.random(in: 0...1)
        }
    }
    
    var body: some View {
        NavigationSplitView {
            
            
            ZStack {
                VisualEffectView(material: .menu, blendingMode: .behindWindow)
                                  .ignoresSafeArea()
                VStack(alignment: .leading){
                    
                    Text("Color Controls")
                        .font(.system(size: 18, design: .monospaced))
                        .padding(.bottom)
                    
                    
                    
                    Text("Red: \(red, specifier: "%.2f")")
                    Slider(value: $red, in: 0...1)
                        .accentColor(.red)
                    
                    
                    Text("Green: \(green, specifier: "%.2f")")
                    Slider(value: $green, in: 0...1)
                        .accentColor(.green)
                    
                    
                    Text("Blue: \(blue, specifier: "%.2f")")
                    Slider(value: $blue, in: 0...1)
                        .accentColor(.blue)
                    
                    HStack(alignment: .center, spacing: 16){
                        Button("White") {
                            withAnimation(.spring){
                                red = 1.0
                                green = 1.0
                                blue = 1.0
                            }
                        }
                        Button("Black") {
                            withAnimation(.spring){
                                red = 0.0
                                green = 0.0
                                blue = 0.0
                            }
                        }
                    }
                    .padding(.top)
                    Spacer()
                }
                .font(.system(size: 13, design: .monospaced))
                .padding()
                .frame(minWidth: 200)
            }
        } detail: {
            ZStack{
                Rectangle()
                    .foregroundStyle(.clear)
                
                VStack{
                    Spacer()
                    ZStack{
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .foregroundStyle(bgColor.opacity(cellBGOpacity).blendMode(bgBlendMode))
                        HStack {
                            Text("Color")
                            Spacer()
                            Image(systemName: "heart.fill")
                        }
                        .foregroundStyle(textColor.blendMode(textBlendMode))
                        .font(.system(size: 17, weight: .semibold, design: .default))
                        .padding(.horizontal, 16)
                        
                    }
                    .frame(height: 56)
                    .frame(maxWidth: 358)
                    Spacer()
                    HStack{
                        
                        Spacer()
                        VStack {
                            Divider()
                                .padding(.bottom)

                            HStack (alignment: .bottom){
                                VStack(alignment: .leading, spacing: 6){
                                    Text("text color: \(textColor)")
                                    Text("text blend: \(textBlendMode)")
                                    Text("bg color: \(bgColor)")
                                    Text("bg color: \(bgBlendMode)")
                                    Text("color scheme: \(colorScheme)")
                                    Text("color space: \(currentColorSpace.localizedName ?? currentColorSpace.description)")
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 6){
                                    Text("qewie.app")
                                    Text("x.com/josephpalbanese")
                                }
                                
                            }
                        }
                    }
                    .foregroundStyle(textColor)
                    .blendMode(textBlendMode)
                    .font(.system(size: 13, design: .monospaced))
                    .padding()
                }

            }
            .background(bgColor.opacity(0.5))
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear(perform: setDisplayP3ColorSpace)
            .keyboardShortcut(.space, modifiers: [])
              .onAppear {
                  NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                      if event.keyCode == 49 { // 49 is the key code for spacebar
                          assignRandomColor()
                          return nil
                      }
                      return event
                  }
              }
        }
    }
    
    func setDisplayP3ColorSpace() {
        if let window = NSApplication.shared.windows.first {
            window.colorSpace = NSColorSpace.displayP3
        }
    }
}


#Preview {
    ContentView()
}

struct ColorSpaceKey: EnvironmentKey {
    static let defaultValue: NSColorSpace = .displayP3
}


extension EnvironmentValues {
    var currentColorSpace: NSColorSpace {
        get { self[ColorSpaceKey.self] }
        set { self[ColorSpaceKey.self] = newValue }
    }
}


struct ColorSpaceModifier: ViewModifier {
    @State private var colorSpace: NSColorSpace = .displayP3
    
    func body(content: Content) -> some View {
        content
            .environment(\.currentColorSpace, colorSpace)
            .onAppear {
                if let window = NSApplication.shared.windows.first,
                   let windowColorSpace = window.colorSpace {
                    colorSpace = windowColorSpace
                }
            }
    }
}


extension View {
    func withColorSpace() -> some View {
        self.modifier(ColorSpaceModifier())
    }
}


struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
