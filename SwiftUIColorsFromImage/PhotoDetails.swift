//
//  PhotoDetails.swift
//  SwiftUIColorsFromImage
//
//  Created by Vinicius Nakamura on 18/08/22.
//

import SwiftUI

struct PhotoDetails: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    var selection: SelectedPicture?
    var namespace: Namespace.ID
    
    var body: some View {
        if let (info, image, theme) = selection {
            let (backgroundColor, textColor) =
                colorScheme == .dark ? (
                    theme.bodyDark, theme.bodyLight
                ) : (
                    theme.bodyLight, theme.bodyDark
                )
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button { withAnimation {
                            isPresented.toggle()
                        }} label: {
                            Image(systemName: "chevron.left.circle.fill")
                        }
                        Spacer()
                    }
                    .foregroundColor(theme.contrastingTone.opacity(0.3))
                    .font(.system(size: 24))
                    .padding(12)
                    
                    image
                        .resizable()
                        .matchedGeometryEffect(id: info.id, in: namespace)
                        .scaledToFill()
                        .shadow(color: theme.contrastingTone.opacity(0.2), radius: 24)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity)
                }
                .background {
                    theme.averageColor
                        .ignoresSafeArea()
                        .offset(y: -48)
                }
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Label(info.author, systemImage: "camera.circle.fill")
                            .labelStyle(SpacedLabelStyle())
                            .padding(.vertical, 4)
                        Divider()
                        HStack {
                            Label(info.id, systemImage: "number.circle.fill")
                            Spacer()
                            Label(String(info.width), systemImage: "arrow.left.and.right.circle.fill")
                            Spacer()
                            Label(String(info.height), systemImage: "arrow.up.and.down.circle.fill")
                        }
                        .padding(.vertical, 4)
                        Divider()
                        LongText().font(.fancy(size: 16))
                    }
                    .padding(24)
                    
                    Spacer()
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    CTA(info: info, theme: theme)
                }
            }
            .font(.fancy(size: 24))
            .foregroundColor(textColor)
            .background { backgroundColor.ignoresSafeArea() }
        }
    }
}

struct CTA: View {
    var info: PictureInfo
    var theme: ColorTheme
    
    var body: some View {
        if let url = URL(string: info.url) {
            ShareLink(
                item: url
            ) {
                Label("Share Picture", systemImage: "square.and.arrow.up")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        theme.ctaColor
                            .border(theme.ctaContrast.opacity(0.3))
                    }
            }
            .foregroundColor(theme.ctaContrast)
            .padding(.horizontal, 12)
        }
    }
}

struct LongText: View {
    var body: some View {
        Text("""
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. **Et nemo nimium beatus est;** Quod non faceret, si in voluptate summum bonum poneret. _Quonam, inquit, modo?_ Ego vero isti, inquam, permitto. Hic nihil fuit, quod quaereremus. Sullae consulatum?
        
        Explanetur igitur. Ut aliquid scire se gaudeant? Duo Reges: constructio interrete. Quo modo autem philosophus loquitur? Quodsi ipsam honestatem undique pertectam atque absolutam. Quid sequatur, quid repugnet, vident. Igitur neque stultorum quisquam beatus neque sapientium non beatus.
        
        Sin tantum modo ad indicia veteris memoriae cognoscenda, curiosorum. **Inde igitur, inquit, ordiendum est.** Qui ita affectus, beatum esse numquam probabis; Aliter homines, aliter philosophos loqui putas oportere? Ut pulsi recurrant? Istam voluptatem perpetuam quis potest praestare sapienti?
        
        Idemque diviserunt naturam hominis in animum et corpus. _Vide, quantum, inquam, fallare, Torquate._ Quae contraria sunt his, malane? Ecce aliud simile dissimile. **Vide, quantum, inquam, fallare, Torquate.**
        """)
    }
}

typealias SelectedPicture = (
    info: PictureInfo,
    image: Image,
    theme: ColorTheme
)

struct SpacedLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
            Spacer()
            configuration.title
        }
    }
}

struct PhotoDetails_Previews: PreviewProvider {
    @Namespace static var namespace
    static let uiImage = UIImage(named: "picsum-sample")!
    static let selected = SelectedPicture(
        info: PictureInfo(
            id: "225",
            author: "Vee O",
            width: 1500,
            height: 979,
            url: "https://unsplash.com/photos/hGO27G5tZJ8"
        ),
        image: Image(uiImage: uiImage),
        theme: try! ColorTheme.generate(from: uiImage)
    )
    
    static var previews: some View {
        PhotoDetails(
            isPresented: .constant(true),
            selection: selected,
            namespace: namespace
        )
    }
}
