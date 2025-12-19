import SwiftUI

struct TemplatesView: View {
    @ObservedObject var appData: AppData
    
    @State var alertVisible = false
    @State var alertMessage = ""
    
    var body: some View {
        ZStack {
            Color.themeGradient("Neon Mix")
                .ignoresSafeArea()
            
            List(templates) { template in
                HStack {
                    Text(template.name)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Use template") {
                        var newWheel = template
                        appData.wheels.append(newWheel)
                        appData.saveData()
                        alertMessage = "New wheel added in your list! Go to home and spin it!"
                        alertVisible = true
                    }
                    .foregroundColor(.neonBlue)
                }
                .listRowBackground(Color.black.opacity(0.3))
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
        }
        .navigationTitle("Templates")
        .alert(isPresented: $alertVisible) {
            Alert(title: Text("Wheel added"), message: Text(alertMessage))
        }
    }
}
