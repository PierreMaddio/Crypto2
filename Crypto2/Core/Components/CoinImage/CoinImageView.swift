
import SwiftUI

struct CoinImageView: View {
    
    let coin: Coin
    
    var body: some View {
        AsyncImage(url: URL(string: coin.image)) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            Image(systemName: "questionmark")
                .foregroundColor(Color.theme.secondaryText)
        }
    }
}

struct CoinImageView_Previews: PreviewProvider {
    static var previews: some View {
        CoinImageView(coin: dev.coin)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
