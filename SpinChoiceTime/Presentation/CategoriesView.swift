import SwiftUI

struct CategoriesView: View {
    @ObservedObject var appData: AppData
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeGradient("Yellow-Purple")
                    .ignoresSafeArea()
                
                List(categories, id: \.self) { category in
                    NavigationLink(destination: WheelsInCategoryView(appData: appData, category: category)) {
                        Text(category)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.futuristicGray.opacity(0.4))
                            .cornerRadius(20)
                            .shadow(color: .neonYellow, radius: 10)
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
            }
            .navigationTitle("Categories")
        }
    }
}

struct WheelsInCategoryView: View {
    @ObservedObject var appData: AppData
    let category: String
    
    var filteredWheels: [Wheel] {
        appData.wheels.filter { $0.category == category }
    }
    
    var body: some View {
        ZStack {
            Color.themeGradient("Yellow-Purple")
                .ignoresSafeArea()
            
            List(filteredWheels) { wheel in
                NavigationLink(destination: WheelScreenView(appData: appData, wheel: wheel)) {
                    WheelCard(wheel: wheel)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
        }
        .navigationTitle(category)
    }
}
