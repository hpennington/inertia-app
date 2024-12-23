import Inertia
/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view showing donuts in a box.
*/

// Other comment

import SwiftUI

public struct DonutBoxView<Content: View>: View {
    var isOpen: Bool
    var content: Content
    
    public init(isOpen: Bool, @ViewBuilder content: () -> Content) {
        self.isOpen = isOpen
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            Image("box/Inside", bundle: .module)
                .resizable()
                .scaledToFit().inertiaEditable("97CB72F0-DC8C-4AE9-9357-9C2443566AE1")
            
            content
                .frame(width: 12, height: 12).inertiaEditable("FA710526-AF03-4EAD-B581-468A6911BE32")
            
            VStack {
                DonutBoxView2(isOpen: false)
                    .padding(.horizontal).inertiaEditable("C80EE32C-41D4-49E9-9A6C-805AFF11B2B0")
                VStack {
                    Text("testing1").inertiaEditable("CE2BADA3-51FE-4FE7-B099-164D7ADBAF48")
                    Spacer().inertiaEditable("EB28AC4A-1A9D-4288-942E-44ABE4E26F49")
                    Text("testing2").inertiaEditable("94F3CA05-FC28-419F-B5A6-077BD4FE4561")
                }.inertiaEditable("3DF5D55A-C518-4B40-B93D-C2F624E9E753")
                Spacer().inertiaEditable("DA088AB5-3EEB-43FF-B32C-89306AD31C89")
                Text("testing").inertiaEditable("3D13FFE9-82A3-42A9-8E7F-20A853A2E520")
            }.inertiaEditable("BF30D2B4-AA81-4A3C-B103-D7F75F7A5CBA")

            
        }.inertiaEditable("E60D92C2-C792-4E4D-85EF-8C9A87D6AF6C")
    }
}


public struct DonutBoxView2: View {
    public init(isOpen: Bool) {
        self.isOpen = isOpen
    }
    
    public var body: some View {
        VStack {
            Image("box/Bottom", bundle: .module)
                .resizable()
                .scaledToFit().inertiaEditable("5D2AD6CE-7A51-4AD1-9673-5D1CF69A15CB")
            Spacer().inertiaEditable("7504FE96-99CB-412D-BEDF-31975AC0B055")
            Text("testing").inertiaEditable("B4E38563-8F68-4500-95A4-097F82851512")
        }.inertiaEditable("DCBC606E-FD19-4BBE-A7F2-AF21139FE38E")
    }
}
