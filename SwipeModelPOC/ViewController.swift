//
//  ViewController.swift
//  SwipeModelPOC
//
//  Created by Nutdanai Vankrua on 19/2/2563 BE.
//  Copyright © 2563 AceQuery. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    enum State {
        case expand, collapse

        var change: State {
            switch self {
            case .expand: return .collapse
            case .collapse: return .expand
            }
        }
    }

    // MARK: Views

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.clipsToBounds = true
        return view
    }()

    // MARK: Panel Properties

    private let startPanelHeight: CGFloat = 200
    private var state: State = .collapse
    private var heightConstraint: NSLayoutConstraint!

    // MARK: Animation Properties

    private lazy var animator: UIViewPropertyAnimator = {
        UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut)
    }()
    private var animationProgress: CGFloat = 0

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(containerView)

        heightConstraint = containerView.heightAnchor.constraint(equalToConstant: startPanelHeight)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightConstraint,
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        let modalController = ModalViewController()
        modalController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(modalController)
        containerView.addSubview(modalController.view)
        modalController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            modalController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            modalController.view.heightAnchor.constraint(equalToConstant: view.frame.height),
            modalController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            modalController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        containerView.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onDrag))
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        containerView.addGestureRecognizer(panGesture)
    }

    // MARK: Gestures

    @objc func onTapped(_ sender: Any) {
        togglePanel()
    }

    @objc func onDrag(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            togglePanel()
            animator.pauseAnimation()
            animationProgress = animator.fractionComplete
        case .changed:
            let translation = recognizer.translation(in: containerView)
            var fraction = -translation.y / view.frame.height
            if state == .expand {
                fraction *= -1
            }
            animator.fractionComplete = fraction + animationProgress
        case .ended:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            break
        }
    }

}

// MARK: - Animations

extension ViewController {

    private func togglePanel() {
        switch state {
        case .expand:
            collapse()
        case .collapse:
            expand()
        }
    }

    private func expand() {
        animator.addAnimations {
            self.heightConstraint.constant = self.view.frame.height
            self.view.layoutIfNeeded()
        }

        animator.addCompletion { position in
            switch position {
            case .end:
                self.state = self.state.change
            default:
                break
            }
        }

        animator.startAnimation()
    }

    private func collapse() {
        animator.addAnimations {
            self.heightConstraint.constant = self.startPanelHeight
            self.view.layoutIfNeeded()
        }

        animator.addCompletion { position in
            switch position {
            case .end:
                self.state = self.state.change
            default:
                break
            }
        }

        animator.startAnimation()
    }

}

// MARK: - Sub-View Controller

class ModalViewController: UIViewController {

    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .green
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue

        view.addSubview(cardView)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

}
