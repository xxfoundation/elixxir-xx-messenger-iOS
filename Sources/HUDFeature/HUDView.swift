import AppResources
import Shared
import SwiftUI

struct HUDView: View {
  var model: HUDModel

  var body: some View {
    ZStack {
      Color(Asset.neutralDark.color.withAlphaComponent(0.9))
        .ignoresSafeArea()

      VStack(spacing: 20) {
        Spacer()

        if let title = model.title {
          Text(title)
            .foregroundColor(Color(Asset.neutralWhite.color))
            .font(Font(Fonts.Mulish.bold.font(size: 30.0)))
        }

        if let content = model.content {
          Text(content)
            .foregroundColor(Color(Asset.neutralWhite.color))
            .font(Font(Fonts.Mulish.regular.font(size: 15.0)))
        }

        if model.hasDotAnimation {
          DotAnimation.SwiftUIView(
            color: Asset.neutralWhite.color
          )
          .fixedSize()
          .frame(height: 20)
        }

        Spacer()

        if let actionTitle = model.actionTitle,
           let onTapClosure = model.onTapClosure {
          CapsuleButton.SwiftUIView(
            style: .seeThroughWhite,
            title: actionTitle,
            action: onTapClosure
          )
          .fixedSize(horizontal: false, vertical: true)
        }
      }
      .padding(.horizontal, 15)
      .padding(.bottom, 20)
    }
  }
}

#if DEBUG
struct HUDView_Previews: PreviewProvider {
  struct Preview: View {
    var hud: HUDView

    var body: some View {
      ZStack {
        LinearGradient(
          colors: [
            Color(UIColor(red: 122/255, green: 235/255, blue: 239/255, alpha: 1)),
            Color(UIColor(red: 56/255, green: 204/255, blue: 232/255, alpha: 1)),
            Color(UIColor(red: 63/255, green: 186/255, blue: 253/255, alpha: 1)),
            Color(UIColor(red: 98/255, green: 163/255, blue: 255/255, alpha: 1)),
          ],
          startPoint: .topTrailing,
          endPoint: .bottomLeading
        )
        .ignoresSafeArea()

        Image(uiImage: Asset.splash.image)

        hud
      }
    }
  }

  static var previews: some View {
    Preview(hud: HUDView(model: HUDModel(
      title: "Title",
      content: "Content",
      actionTitle: "Action title",
      hasDotAnimation: true,
      isAutoDismissable: true,
      onTapClosure: {}
    )))
  }
}
#endif
