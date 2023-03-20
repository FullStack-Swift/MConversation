//
//  ExamplesApp.swift
//  Examples
//
//  Created by Nguyen Phong on 3/20/23.
//

import SwiftUI

@main
struct ExamplesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


import SwiftUI
import PathBuilder

enum AlignmentCustomPath: CaseIterable {
  case topLeading
  case topTrailing
  case bottomLeading
  case bottomTrailing
}

struct CapsuleCustomShape: Shape {

  let cornerRadius: CGFloat
  let alignmentCustomPaths: [AlignmentCustomPath]

  func path(in rect: CGRect) -> Path {
    Path {
      if alignmentCustomPaths.contains(.topLeading) {
        Move(to: CGPoint(x: 0, y: cornerRadius))
        Arc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .radians(.pi), endAngle: .radians(-.pi/2), clockwise: false)
      } else {
        Move(to: CGPoint(x: 0, y: 0))
      }
      if alignmentCustomPaths.contains(.topTrailing) {
        Line(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        Arc(center: CGPoint(x: rect.width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .radians(.pi/2), endAngle: .radians(.zero), clockwise: false)
      } else {
        Line(to: CGPoint(x: rect.width, y: 0))
      }
      if alignmentCustomPaths.contains(.bottomTrailing) {
        Line(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        Arc(center: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius), radius: cornerRadius, startAngle: .radians(.zero), endAngle: .radians(.pi/2), clockwise: false)
      } else {
        Line(to: CGPoint(x: rect.width, y: rect.height))
      }
      if alignmentCustomPaths.contains(.bottomLeading) {
        Line(to: CGPoint(x: cornerRadius, y: rect.height))
        Arc(center: CGPoint(x: cornerRadius, y: rect.height - cornerRadius), radius: cornerRadius, startAngle: .radians(-.pi/2), endAngle: .radians(-.pi), clockwise: false)
      } else {
        Line(to: CGPoint(x: 0, y: rect.height))
      }
      Close()
    }
  }
}
