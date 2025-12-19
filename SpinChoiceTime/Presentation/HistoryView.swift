
import SwiftUI

struct HistoryView: View {
    @ObservedObject var appData: AppData
    
    var body: some View {
        ZStack {
            Color.themeGradient("Blue-Yellow")
                .ignoresSafeArea()
            
            List(appData.history) { item in
                VStack(alignment: .leading) {
                    Text(item.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(item.wheelName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(item.selectedOption)
                        .font(.body)
                        .foregroundColor(.neonYellow)
                }
                .listRowBackground(Color.black.opacity(0.3))
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
        }
        .navigationTitle("History")
    }
}
