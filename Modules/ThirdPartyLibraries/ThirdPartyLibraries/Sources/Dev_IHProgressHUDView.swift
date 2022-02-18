//
//  Dev_IHProgressHUDView.swift
//  Alamofire
//
//  Created by Muhammad Muizzsudin on 15/02/22.
//

#if DEBUG

import UIKit
import LivePreviewer

final class Dev_IHProgressHUDView: UIView {
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        IHProgressHUD.show(withStatus: nil)
    }
}

import SwiftUI

@available(iOS 13.0, *)
struct Dev_IHProgressHUDView_Preview: PreviewProvider {
    static var previews: some View {
        Dev_IHProgressHUDView().preview()
            .background(Color.blue)
    }
}
#endif
