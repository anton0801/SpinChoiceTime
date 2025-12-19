import SwiftUI

struct CreateWheelView: View {
    @ObservedObject var appData: AppData
    @State private var name: String = ""
    @State private var category: String = categories[0]
    @State private var colorTheme: String = colorThemes[0]
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAddOptions = false
    @State private var newWheel: Wheel?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Wheel Details").foregroundColor(.white)) {
                    TextField("Wheel name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    Picker("Color Theme", selection: $colorTheme) {
                        ForEach(colorThemes, id: \.self) { Text($0) }
                    }
                }
                
                Button("Create Wheel") {
                    let wheel = Wheel(id: UUID(), name: name.isEmpty ? "New Wheel" : name, category: category, colorTheme: colorTheme, options: [])
                    appData.wheels.append(wheel)
                    appData.saveData()
                    newWheel = wheel
                    showingAddOptions = true
                }
                .foregroundColor(.neonYellow)
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
                }
            }
        }
        .sheet(item: $newWheel) { wheel in
            AddOptionsView(appData: appData, wheel: wheel)
        }
    }
}
