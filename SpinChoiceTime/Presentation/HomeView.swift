import SwiftUI

struct HomeView: View {
    @ObservedObject var appData: AppData
    @State private var showingCreate = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeGradient(appData.appTheme)
                    .ignoresSafeArea()
                
                VStack {
                    Text("Your Wheels")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Button(action: { showingCreate = true }) {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.neonYellow)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.3)))
                    }
                    .sheet(isPresented: $showingCreate) {
                        CreateWheelView(appData: appData)
                    }
                    
                    List(appData.wheels) { wheel in
                        NavigationLink(destination: WheelScreenView(appData: appData, wheel: wheel)) {
                            WheelCard(wheel: wheel)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct WheelCard: View {
    let wheel: Wheel
    
    var body: some View {
        HStack {
            Image(systemName: "circle.hexagongrid")
                .foregroundColor(.neonBlue)
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text(wheel.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(wheel.options.count) options")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .shadow(color: .neonPurple.opacity(0.3), radius: 5)
    }
}

