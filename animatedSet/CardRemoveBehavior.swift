//
//  CardRemoveBehavior.swift
//  animatedSet
//
//  Created by Apple Macbook on 19/08/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import UIKit

class CardRemoveBehavior: UIDynamicBehavior {
    var scoreLabelFrame: CGRect
    private var snapBehavior: UISnapBehavior?
    private lazy var colissionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    private lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = Consts.flyingCardElasticity
        behavior.resistance = Consts.flyingCardResistence
        return behavior
    }()
    
    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        push.angle = (2*CGFloat.pi).arc4random
        push.magnitude = Consts.flyingCardPushMagnitude
        push.action = {[unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    private func snapToScoreLabel(item: UIDynamicItem) {
        snapBehavior = UISnapBehavior(item: item, snapTo: CGPoint(x: scoreLabelFrame.midX, y: scoreLabelFrame.midY))
        snapBehavior!.damping = Consts.cardSnapDamping
        addChildBehavior(snapBehavior!)
    }
    
    fileprivate func snapAndAdjustCardToScoreLabel(cardView: UIView) {
        self.snapToScoreLabel(item: cardView)
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Consts.cardBoundsChangeTime,
                                                       delay: 0,
                                                       options: [],
                                                       animations: {cardView.bounds = CGRect(x: 0, y: 0, width: self.scoreLabelFrame.width, height: self.scoreLabelFrame.height)})
    }
    
    fileprivate func removeCardBehaviors(from cardView: UIView) {
        self.colissionBehavior.removeItem(cardView)
        self.itemBehavior.removeItem(cardView)
    }
    
    fileprivate func cardFlysOnTheScreen(_ cardView: UIView) {
        colissionBehavior.addItem(cardView)
        itemBehavior.addItem(cardView)
        push(cardView)
    }
    
    fileprivate func cardSnapsToScoreLabel(_ cardView: UIView) {
        Timer.scheduledTimer(withTimeInterval: Consts.cardFlightTime, repeats: false) {timer in
            self.removeCardBehaviors(from: cardView)
            self.snapAndAdjustCardToScoreLabel(cardView: cardView)
        }
    }
    
    func addItem(_ cardView: UIView) {
        cardFlysOnTheScreen(cardView)
        cardSnapsToScoreLabel(cardView)
    }
    
    func removeSnapBehavior() {
        if let snap = snapBehavior {
            removeChildBehavior(snap)
            snapBehavior = nil
        }
    }
    
    init(in animator: UIDynamicAnimator, scoreLabelFrame: CGRect) {
        self.scoreLabelFrame = scoreLabelFrame
        super.init()
        addChildBehavior(colissionBehavior)
        addChildBehavior(itemBehavior)
        animator.addBehavior(self)
    }
}
extension CGFloat {
    var arc4random: CGFloat {
        return self * (CGFloat(arc4random_uniform(UInt32.max))/CGFloat(UInt32.max))
    }
}
