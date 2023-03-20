import SwiftUI

public enum StatusConversation<Element, OtherType> {
  case none // by default
  case empty
  case loading
  case loadMore
  case refresh
  case error
  case data(Element)
  case other(OtherType)
}

extension StatusConversation: Equatable where Element: Equatable, OtherType: Equatable {}

public struct MConversation<
  Collection,
  OtherType,
  Background: View,
  HeaderContent: View,
  FooterContent: View,
  HeaderRowContent: View,
  FooterRowContent: View,
  RowContent: View,
  EmptyContent: View,
  InputContent: View
>: View where Collection : RandomAccessCollection, Collection.Element: Identifiable, Collection.Element: Equatable, Collection.Element: Hashable {

  private var items: Collection

  private let headerContent: () -> HeaderContent
  private let footerContent: () -> FooterContent
  private let headerRowContent: () -> HeaderRowContent
  private let footerRowContent: () -> FooterRowContent
  private var rowListView: (Collection.Element) -> RowContent
  private let emptyListView: () -> EmptyContent
  private let inputContent: () -> InputContent
  private var background: () -> Background

  @Binding private var scrollTo: ScrollToPosition<Collection.Element?>

  @Binding private var statusConversation: StatusConversation<Collection, OtherType>

  public init(
    items: Collection,
    scrollTo: Binding<ScrollToPosition<Collection.Element?>>,
    statusConversation: Binding<StatusConversation<Collection, OtherType>>,
    @ViewBuilder background: @escaping () -> Background,
    @ViewBuilder headerContent: @escaping () -> HeaderContent,
    @ViewBuilder footerContent: @escaping () -> FooterContent,
    @ViewBuilder headerRowContent: @escaping () -> HeaderRowContent,
    @ViewBuilder footerRowContent: @escaping () -> FooterRowContent,
    @ViewBuilder rowListView: @escaping (Collection.Element) -> RowContent,
    @ViewBuilder emptyListView: @escaping () -> EmptyContent,
    @ViewBuilder inputContent: @escaping () -> InputContent
  ) {
    self.items = items
    self._scrollTo = scrollTo
    self._statusConversation = statusConversation
    self.background = background
    self.headerContent = headerContent
    self.footerContent = footerContent
    self.headerRowContent = headerRowContent
    self.footerRowContent = footerRowContent
    self.rowListView = rowListView
    self.emptyListView = emptyListView
    self.inputContent = inputContent
  }

  @ViewBuilder
  public var body: some View {
    ZStack(alignment: .bottom) {
      background()
      VStack(alignment: .center, spacing: 0) {
        if items.isEmpty {
          Spacer()
          emptyListView()
          Spacer()
        } else {
          ScrollViewReader { proxy in
            ZStack {
              VStack(spacing: 0) {
                headerContent()
                content()
                footerContent()
              }
            }
            .onChange(of: scrollTo) { value in
              withAnimation {
                print(value)
                DispatchQueue.main.async {
                  switch value {
                    case .top:
                      proxy.scrollTo("TOP", anchor: .bottom)
                    case .bottom:
                      proxy.scrollTo("BOTTOM", anchor: .top)
                    case .toID(let id):
                      guard let id else { return }
                      proxy.scrollTo(id.id, anchor: .center)
                    case .none:
                      return
                  }
                  self.scrollTo = .none
                }
              }
            }
          }
        }
        inputContent()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
  }
}

extension MConversation {

  func content() -> some View {
    ScrollView {
      LazyVStack(alignment: .center, spacing: 0, pinnedViews: .sectionHeaders) {
        Color.clear
          .frame(width: 0, height: 0, alignment: .center)
          .onAppear {
            print("Scroll to BOTTOM")
          }

        // MARK: Footer Row Content
        footerRowContent()
          .id("BOTTOM")
          .rotationEffect(Angle(radians: Double.pi)) // rotate each item
          .scaleEffect(x: -1, y: 1, anchor: .center) // and flip it so we can flip the container to keep the scroll indicators on the right

        // MARK: Content View
        ForEach(items, id: \.id) { item in
          rowListView(item)
            .id(item.id)
            .rotationEffect(Angle(radians: Double.pi)) // rotate each item
            .scaleEffect(x: -1, y: 1, anchor: .center) // and flip it so we can flip the container to keep the scroll indicators on the right
        }

        // MARK: Header Row Content
        headerRowContent()
          .id("TOP")
          .rotationEffect(Angle(radians: Double.pi)) // rotate each item
          .scaleEffect(x: -1, y: 1, anchor: .center) // and flip it so we can flip the container to keep the scroll indicators on the right
        Color.clear
          .frame(width: 0, height: 0, alignment: .center)
          .onAppear {
            print("Scroll to TOP")
          }
      }
    }
    .rotationEffect(Angle(radians: Double.pi)) // rotate the whole ScrollView 180º
    .scaleEffect(x: -1, y: 1, anchor: .center) // flip it so the indicator is on the right
  }
}

public enum ScrollToPosition<ID> {
  case top
  case bottom
  case toID(ID)
  case none

  public var id: ID? {
    guard case .toID(let iD) = self else {
      return nil
    }
    return iD
  }
}

extension ScrollToPosition: Equatable where ID: Equatable {}
