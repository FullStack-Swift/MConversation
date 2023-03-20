//
//  ContentView.swift
//  Examples
//
//  Created by Nguyen Phong on 3/20/23.
//

import SwiftUI
import MConversation

struct MessageModel: Identifiable, Equatable, Hashable {
  var id = UUID().uuidString
  var message: String = ""
}

struct ContentView: View {

  @State private var messages: [MessageModel] = (1..<100).map({MessageModel(id: UUID().uuidString, message: String($0) + " " + UUID().uuidString)})

//  @State private var messages: [MessageModel] = []

  @State private var pins: [MessageModel] = []

  @State private var message: String = ""

  @State private var scrollTo: ScrollToPosition<MessageModel?> = .none
  @State private var statusConversation: StatusConversation<[MessageModel], Int> = .none

  @State private var selection: MessageModel? = nil

  var body: some View {
    content
  }

  @ViewBuilder
  var content: some View {
    MConversation(items: messageView, scrollTo: $scrollTo, statusConversation: $statusConversation) {
      Color.white
    }
    headerContent: {
      VStack {
        Button {
          self.scrollTo = .top
          print(self.scrollTo)
        } label: {
          Text("Header")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)

        ForEach(pins) { item in
          HStack {
            Text(item.message)
              .multilineTextAlignment(.leading)
              .padding(.horizontal, 16)
              .padding(.vertical, 8)
            Spacer(minLength: 48)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .clipShape(Rectangle())
          .onTapGesture {
            self.scrollTo = .toID(item)
            self.selection = item
          }
        }
      }
      .background(Color.green)
    } footerContent: {
      VStack {
        
        Button {
          self.scrollTo = .bottom
          print(self.scrollTo)
        } label: {
          Text("Footer")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
      }
      .background(Color.green)

    } headerRowContent: {
      ZStack {
        Color.red
        Text("TOP")
          .bold()
          .foregroundColor(.white)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
    } footerRowContent: {
      ZStack {
        Color.green
        Text("BOTTOM")
          .bold()
          .foregroundColor(.white)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
    } rowListView: { item in
      HStack {
        Text(item.message)
          .multilineTextAlignment(.leading)
          .padding(.horizontal, 16)
          .padding(.vertical, 8)
        Spacer(minLength: 48)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .clipShape(Rectangle())
//      if item.id == scrollTo.id {}
      .background(item == selection ? Color.red : Color.clear)
      .onTapGesture {
        if !pins.contains(where: {$0 == item}) {
          pins.append(item)
        } else {
          if self.selection != nil {
            self.selection = nil
          }
        }
      }

    } emptyListView: {
      Text("Empty")
    } inputContent: {
      VStack(alignment: .center, spacing: 0) {
        Divider()
        HStack(alignment: .center, spacing: 8) {
          TextField("Aa", text: $message)
          Button {
            withAnimation {
              let message = MessageModel(id: UUID().uuidString, message: message)
              messages.append(message)
              self.message = ""
              self.scrollTo = .bottom
            }
          } label: {
            Text("Send")
              .foregroundColor(message.isEmpty ? Color.gray : Color.blue)
          }
          .disabled(message.isEmpty)
        }
        .frame(height: 48)
        .padding()
      }
      .frame(height: 48)
      .padding()
    }
  }
}

extension ContentView {
  var messageView: [MessageModel] {
    return self.messages.reversed()
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
