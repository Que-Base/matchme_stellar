//
//  CuddlePointView.swift
//  cuddleme.mobile_swift
//
//  Created by Gideon Adewuyi on 07/09/2024.
//

import SwiftUI

struct CuddlePointView: View {
  var header: String
  var pointBody: String
  
  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      Image("point_icon")
      VStack(alignment: .leading, spacing: 8) {
        Text(header)
          .cuddleFont(size: 16, weight: .medium)
        
        Text(pointBody)
          .cuddleFont(size: 12)
          .foregroundStyle(.grey76)
      }
    }
  }
}


extension CuddlePointView {
  init(header: String? = nil, pointBody: String? = nil) {
    self.header = header ?? "Lorem ipsum seit aduis"
    self.pointBody = pointBody ?? "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa"
  }
}
