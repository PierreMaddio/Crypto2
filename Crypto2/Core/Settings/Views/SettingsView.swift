
import SwiftUI

struct SettingsView: View {
    let defaultURL = URL(string: "https://www.google.com")
    let linkedinURL = URL(string: "https://www.linkedin.com/in/pierremaddio/")
    let coinGeckoURL = URL(string: "https://www.coingecko.com/")
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // background layer
                Color.theme.background
                    .ignoresSafeArea()
            
                // content layer
                List {
                    developerSection
                        .listRowBackground(Color.theme.background.opacity(0.5))
                    coinGeckoSection
                        .listRowBackground(Color.theme.background.opacity(0.5))
                    applicationSection
                        .listRowBackground(Color.theme.background.opacity(0.5))
                }
            }
            .font(.headline)
            .accentColor(.blue)
            .listStyle(GroupedListStyle())
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    XMarkButton() { isTrue in
                        if isTrue {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

extension SettingsView {
    private var developerSection: some View {
        Section(header: Text("Developer")) {
            VStack(alignment: .leading) {
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("This application was developed as part of my OpenClassrooms course as my personal project.It uses MVVM architecture, Swift Concurrency, Combine and Core Data.")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.accent)
            }
            .padding(.vertical)
            if let linkedinURL = linkedinURL {
                Link("My Linkedin", destination: linkedinURL)
            }
        }
    }
    
    private var coinGeckoSection: some View {
        Section(header: Text("CoinGecko")) {
            VStack(alignment: .leading) {
                Image("coingecko")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                Text("The cryptoCurrency data that is used in this app comes from a free API from CoinGecko! Prices may be slightly delay.")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(Color.theme.accent)
            }
            .padding(.vertical)
            if let coinGeckoURL = coinGeckoURL {
                Link("Visit CoinGecko 🦎", destination: coinGeckoURL)
            }
        }
    }
    
    private var applicationSection: some View {
        Section(header: Text("Application")) {
            if let defaultURL = defaultURL {
                Link("Terms of service", destination: defaultURL)
                Link("Privacy Policy", destination: defaultURL)
                Link("Company Website", destination: defaultURL)
                Link("Learn More", destination: defaultURL)
            }
        }
    }
}
