//
//  ExpandingCellPresenter.swift
//  ExpandableCellPresenter
//
//  Created by Eigo Madaloja on 29.03.2023.
//

import UIKit

class ExpandingCellPresenter: UIView {
    enum Failure: Error {
        case tableViewHasNoParent
        case failedToSnapshot
        case notPresented
    }

    private struct Frames {
        let top: CGRect
        let middle: CGRect
        let bottom: CGRect
    }

    private struct ImageViews {
        let top: UIImageView
        let bottom: UIImageView

        func attach(to view: UIView, in parentView: UIView) {
            parentView.addSubview(top)
            top.autoPinEdge(.bottom, to: .top, of: view)
            top.autoAlignAxis(.vertical, toSameAxisOf: view)

            parentView.addSubview(bottom)
            bottom.autoPinEdge(.top, to: .bottom, of: view)
            bottom.autoAlignAxis(.vertical, toSameAxisOf: view)
        }

        func removeFromSuperview() {
            top.removeFromSuperview()
            bottom.removeFromSuperview()
        }
    }

    private let tableView: UITableView
    private let indexPath: IndexPath
    private var presentedView: UIView?
    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?

    private var frames: Frames {
        let cellRect = tableView.convert(
            tableView.rectForRow(at: indexPath),
            to: tableView
        )
        let middle = CGRect(
            origin: CGPoint(
                x: cellRect.origin.x,
                y: cellRect.origin.y - tableView.contentOffset.y
            ),
            size: cellRect.size
        )
        let top = CGRect(
            origin: .zero,
            size: CGSize(
                width: middle.size.width,
                height: middle.origin.y
            )
        )
        let bottom = CGRect(
            origin: CGPoint(
                x: 0,
                y: middle.maxY
            ),
            size: CGSize(
                width: middle.size.width,
                height: tableView.frame.height - middle.maxY
            )
        )

        return Frames(top: top, middle: middle, bottom: bottom)
    }

    init(tableView: UITableView, indexPath: IndexPath) {
        self.tableView = tableView
        self.indexPath = indexPath
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func presentView(_ view: UIView, animated: Bool = true) throws {
        guard let presentingView = tableView.superview else { throw Failure.tableViewHasNoParent }
        guard let snapshot = takeSnapshot(of: tableView) else { throw Failure.failedToSnapshot }

        let imageViews = makeImageViews(snapshot, rects: frames)

        presentingView.insertSubview(self, aboveSubview: tableView)
        autoPinEdge(.leading, to: .leading, of: tableView)
        autoPinEdge(.trailing, to: .trailing, of: tableView)
        autoPinEdge(.top, to: .top, of: tableView)
        autoPinEdge(.bottom, to: .bottom, of: tableView)

        addSubview(view)
        view.autoPinEdge(toSuperviewEdge: .leading)
        view.autoPinEdge(toSuperviewEdge: .trailing)
        topConstraint = view.autoPinEdge(toSuperviewEdge: .top, withInset: frames.middle.origin.y)
        bottomConstraint = view.autoPinEdge(toSuperviewEdge: .bottom, withInset: frames.bottom.height)

        imageViews.attach(to: view, in: self)

        layoutIfNeeded()

        topConstraint?.constant = 0
        bottomConstraint?.constant = 0

        if animated {
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: [.curveEaseOut])
            {
                self.layoutIfNeeded()
            } completion: { _ in
                imageViews.removeFromSuperview()
            }
        } else {
            imageViews.removeFromSuperview()
        }

        presentedView = view
    }

    func dismiss(animated: Bool = true, adjustingScrollView: UIScrollView? = nil) throws {
        guard let view = presentedView else { throw Failure.notPresented }
        guard let snapshot = takeSnapshot(of: tableView) else { throw Failure.failedToSnapshot }

        let imageViews = makeImageViews(snapshot, rects: frames)

        imageViews.attach(to: view, in: self)

        layoutIfNeeded()

        topConstraint?.constant = frames.middle.origin.y
        bottomConstraint?.constant = -frames.bottom.height

        adjustingScrollView?.setContentOffset(.zero, animated: animated)

        if animated {
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: [.curveEaseOut]) {
                    self.layoutIfNeeded()
                } completion: { _ in
                    self.removeFromSuperview()
                }
        } else {
            removeFromSuperview()
        }
    }

    private func setup() {
        clipsToBounds = true
    }

    private func takeSnapshot(of tableView: UITableView) -> CGImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(tableView.bounds.size, false, scale)
        defer { UIGraphicsEndImageContext() }

        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        context.translateBy(x: 0, y: -tableView.contentOffset.y)
        tableView.layer.render(in: context)

        return UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    }

    private func makeImageViews(_ image: CGImage, rects: Frames) -> ImageViews {
        let top = makeImageView(image, rect: rects.top) ?? makeEmptyImageView(width: image.width)
        let bottom = makeImageView(image, rect: rects.bottom) ?? makeEmptyImageView(width: image.width)

        return ImageViews(top: top, bottom: bottom)
    }

    private func makeImageView(_ image: CGImage, rect: CGRect) -> UIImageView? {
        let scale = UIScreen.main.scale
        let scaledRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.size.width * scale,
            height: rect.size.height * scale
        )

        guard let cropped = image.cropping(to: scaledRect) else { return nil }

        let image = UIImage(cgImage: cropped, scale: UIScreen.main.scale, orientation: .up)
        let imageView = UIImageView(image: image)
        imageView.autoSetDimensions(to: image.size)

        return imageView
    }

    private func makeEmptyImageView(width: Int) -> UIImageView {
        let imageView = UIImageView()
        imageView.autoSetDimensions(to: CGSize(width: width, height: 0))

        return imageView
    }
}
