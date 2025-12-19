import SwiftUI

struct AddOptionsView: View {
    @ObservedObject var appData: AppData
    let wheel: Wheel
    @State private var newOption: String = ""
    @State private var options: [String] = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(options, id: \.self) { option in
                        Text(option)
                    }
                    .onDelete { indices in
                        options.remove(atOffsets: indices)
                    }
                }
                
                HStack {
                    TextField("New option", text: $newOption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("+ Add option") {
                        if !newOption.isEmpty {
                            options.append(newOption)
                            newOption = ""
                        }
                    }
                    .foregroundColor(.neonBlue)
                }
                .padding()
                
                Button("Save Options") {
                    if let index = appData.wheels.firstIndex(where: { $0.id == wheel.id }) {
                        appData.wheels[index].options = options
                        appData.saveData()
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.headline)
                .foregroundColor(.neonYellow)
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
            }
            .background(Color.themeGradient(wheel.colorTheme).ignoresSafeArea())
            .navigationTitle("Add Options")
        }
        .onAppear {
            options = wheel.options
        }
    }
}

