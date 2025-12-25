
import SwiftUI

struct HistoryView: View {
    @ObservedObject var appData: AppData
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.themeGradient("Blue-Yellow")
                    .ignoresSafeArea()
                
                List(appData.history) { item in
                    VStack(alignment: .leading) {
                        Text(item.date, style: .date)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.glowWhite)
                        
                        Text(item.wheelName)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(item.selectedOption)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.neonYellow)
                    }
                    .padding()
                    .background(Color.futuristicGray.opacity(0.4))
                    .cornerRadius(20)
                    .shadow(color: .neonBlue, radius: 10)
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
            }
            .navigationTitle("History")
        }
    }
}
