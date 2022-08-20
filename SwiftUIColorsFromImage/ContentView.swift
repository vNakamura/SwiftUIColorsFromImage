//
//  ContentView.swift
//  SwiftUIColorsFromImage
//
//  Created by Vinicius Nakamura on 18/08/22.
//

import SwiftUI

struct ContentView: View {
    @Namespace var namespace
    @StateObject var thumbnails = PicsumList()
    @State var selected: SelectedPicture?
    @State var showingDetails = false

    var body: some View {
        ScrollView {
            switch thumbnails.status {
            case .idle, .loading:
                ProgressView()
                    .controlSize(.large)
                    .padding(.top, 100)
            case .error(let message):
                VStack(alignment: .center) {
                    Image(systemName: "x.square.fill")
                        .font(.title)
                        .imageScale(.large)
                        .padding(.top, 100)
                    Text(message)
                }
                .foregroundColor(.secondary)
            case .complete:
                grid
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            Text("My Gallery")
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(
                    .regularMaterial,
                    ignoresSafeAreaEdges: [.top]
                )
                .foregroundColor(.secondary)
                .font(.fancy(size: 36).bold())
        }
        .task(thumbnails.loadPage)
        .refreshable(action: thumbnails.loadPage)
        .overlay {
            if showingDetails, let selected {
                PhotoDetails(
                    isPresented: $showingDetails,
                    selection: selected,
                    namespace: namespace
                )
                .transition(.opacity)
            }
        }
    }

    var grid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 140), spacing: 0)],
            spacing: 0
        ) {
            ForEach(thumbnails.photos) { photo in
                PicsumAsyncImage(id: photo.id) { image in
                    VStack {
                        Color.black
                            .aspectRatio(1, contentMode: .fit)
                            .opacity(0.2)
                            .overlay {
                                image
                                    .resizable()
                                    .matchedGeometryEffect(id: photo.id, in: namespace)
                                    .scaledToFit()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        Text(photo.author)
                            .font(.fancy(size: 18))
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 10)
                    }
                    .onTapGesture {
                        selected = (photo, image)
                        withAnimation { showingDetails.toggle() }
                    }
                } placeholder: {
                    VStack {
                        ProgressView()
                            .frame(maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        Text(photo.author)
                            .font(.fancy(size: 18))
                            .padding(.horizontal, 10)
                            .padding(.bottom, 10)
                            .hidden()
                    }
                }
            }
        }
    }
}

extension Font {
    static func fancy(size: CGFloat) -> Font {
        Font.custom("Bodoni 72", size: size)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
