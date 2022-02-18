// https://github.com/tifoaudii/TifoKit/blob/master/Sources/TifoKit/Core%20UI/LivePreviewer.swift

//
//  LivePreviewer.swift
//  SwiftyKit
//
//  Created by ruangguru on 03/06/21.
//
import Foundation

#if DEBUG
import SwiftUI

@available(iOS 13, *)
public extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController

        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }

    func preview() -> some View {
        Preview(viewController: self)
    }
}

@available(iOS 13, *)
public extension UIView {
    private struct Preview: UIViewRepresentable {
        let view: UIView
        
        func makeUIView(context: Context) -> UIView {
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            
        }
    }

    func preview() -> some View {
        Preview(view: self)
    }
    
    func previewWithIntrinsic() -> some View {
        Preview(view: self)
            .frame(
                width: self.intrinsicContentSize.height,
                height: self.intrinsicContentSize.width,
                alignment: .center
            )
    }
}

#endif
