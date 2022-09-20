
import SwiftUI

struct XMarkButton: View {
    @State var isDismiss: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            isDismiss(true)
        }, label: {
            Image(systemName: "xmark")
                .font(.headline)
        })
    }
}

struct XMarkButton_Previews: PreviewProvider {
    static var previews: some View {
        XMarkButton(isDismiss: {_ in })
    }
}
