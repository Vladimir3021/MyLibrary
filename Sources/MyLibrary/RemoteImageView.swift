

import SwiftUI

public struct RemoteImageView<Content: View>: View {
  @ObservedObject var imageFetcher: RemoteImageFetcher
  var content: (_ image: Image) -> Content
  let placeHolder: Image

  @State var previousURL: URL? = nil
  @State var imageData: Data = Data()

  public init(
    placeHolder: Image,
    imageFetcher: RemoteImageFetcher,
    content: @escaping (_ image: Image) -> Content
  ) {
    self.placeHolder = placeHolder
    self.imageFetcher = imageFetcher
    self.content = content
  }

  public var body: some View {
    DispatchQueue.main.async {
      if (self.previousURL != self.imageFetcher.getUrl()) {
        self.previousURL = self.imageFetcher.getUrl()
      }

      if (!self.imageFetcher.imageData.isEmpty) {
        self.imageData = self.imageFetcher.imageData
      }
    }

    let uiImage = imageData.isEmpty ? nil : UIImage(data: imageData)
    let image = uiImage != nil ? Image(uiImage: uiImage!) : nil;

    return ZStack() {
      if image != nil {
        content(image!)
      } else {
        content(placeHolder)
      }
    }
    .onAppear(perform: loadImage)
  }

  private func loadImage() {
    imageFetcher.fetch()
  }
}

#if DEBUG

struct RemoteImageView_Previews: PreviewProvider {
  static var previews: some View {
    let imageFetcher = RemoteImageFetcher(
      url: URL(
        string: "https://koenig-media.raywenderlich.com/uploads/2019/12/sharpie.png"
      )!
    )

    return RemoteImageView(
      placeHolder: Image("sharpie"),
      imageFetcher: imageFetcher
    ) {
      $0
    }
  }
}
#endif
