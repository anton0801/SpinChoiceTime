import SwiftUI

struct CategoriesView: View {
    @ObservedObject var appData: AppData
    
    var body: some View {
        ZStack {
            Color.themeGradient("Yellow-Purple")
                .ignoresSafeArea()
            
            List(categories, id: \.self) { category in
                NavigationLink(destination: WheelsInCategoryView(appData: appData, category: category)) {
                    Text(category)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.black.opacity(0.3))
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
        }
        .navigationTitle("Categories")
    }
}

struct WheelsInCategoryView: View {
    @ObservedObject var appData: AppData
    let category: String
    
    var filteredWheels: [Wheel] {
        appData.wheels.filter { $0.category == category }
    }
    
    var body: some View {
        List(filteredWheels) { wheel in
            NavigationLink(destination: WheelScreenView(appData: appData, wheel: wheel)) {
                WheelCard(wheel: wheel)
            }
        }
        .background(Color.themeGradient("Yellow-Purple").ignoresSafeArea())
        .navigationTitle(category)
    }
}
