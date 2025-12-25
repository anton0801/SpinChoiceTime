import SwiftUI

struct CreateWheelView: View {
    @ObservedObject var appData: AppData
    @State private var name: String = ""
    @State private var category: String = categories[0]
    @State private var colorTheme: String = colorThemes[0]
    @Environment(\.presentationMode) var presentationMode
    @State private var newWheel: Wheel?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Wheel Details").font(.system(.headline, design: .rounded)).foregroundColor(.glowWhite)) {
                    TextField("Wheel name", text: $name)
                        .textFieldStyle(FuturisticTextFieldStyle())
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0).foregroundColor(.white) }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Picker("Color Theme", selection: $colorTheme) {
                        ForEach(colorThemes, id: \.self) { Text($0).foregroundColor(.white) }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Button("Create Wheel") {
                    let wheel = Wheel(id: UUID(), name: name.isEmpty ? "New Wheel" : name, category: category, colorTheme: colorTheme, options: [])
                    appData.wheels.append(wheel)
                    appData.saveData()
                    newWheel = wheel
                }
                .buttonStyle(FuturisticButtonStyle())
            }
            .background(Color.themeGradient("Purple-Blue").ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .navigationTitle("New Wheel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(FuturisticButtonStyle())
                }
            }
        }
        .sheet(item: $newWheel) { wheel in
            AddOptionsView(appData: appData, wheel: wheel)
        }
    }
}

struct FuturisticTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.futuristicGray.opacity(0.5))
            .cornerRadius(15)
            .shadow(color: .neonBlue, radius: 10)
            .foregroundColor(.white)
    }
}
