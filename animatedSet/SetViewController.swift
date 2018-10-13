//
//  ViewController.swift
//  graphicalSet
//
//  Created by Apple Macbook on 29/03/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import UIKit

class SetViewController: UIViewController, UIDynamicAnimatorDelegate {
    private var game = SetModel()
    private var cardsViews = [SetCardView]()
    lazy private var grid = Grid(layout: Grid.Layout.aspectRatio(Consts.cardAspectRatio), frame: gridView.frame)
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var lowButtons: [UIView]!
    @IBOutlet weak var scoreLabelSuperView: UIStackView!
    @IBOutlet weak var dealCardsSuperView: UIStackView!
    @IBOutlet weak var dealNewCardsButton: UIButton!
    @IBAction func add3Cards() {
        game.add3Cards(userWants: true)
        updateViewFromModel()
    }
    @IBOutlet weak var lowStackView: UIStackView!
    private lazy var animator = UIDynamicAnimator(referenceView: view)
    private lazy var cardBehavior = CardRemoveBehavior(in: animator, scoreLabelFrame: scoreLabelFrame)
    private var flyingCards: [SetCardView] = []
    @IBAction func newGame() {
        game = SetModel()
        removeAllCardsViews()
        updateViewFromModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        grid.frame = gridView.frame
        //if its first time VC loaded create new game
        if cardsViews.count == 0 {
            newGame()
        } else {
            updateCardsFrames(animated: false)
        }
        //needed!!
        cardBehavior.scoreLabelFrame = scoreLabelFrame
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        cardBehavior.removeSnapBehavior()
        flyingCards.forEach{card in
            animateFlip(cardView: card, completion: {_ in
                card.removeFromSuperview()
            })
        }
        flyingCards = []
    }
    
    @IBAction func cheat(_ sender: UIButton) {
        if let set = game.setExistOnTheBoard(){
            colorIndexedCardsMargins(indexesToColor: set, inColor: Consts.cheatCardMarginColor)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLowButonsMargins()
        addSwipeDownGesture()
        //addRotationGesture()
        animator.delegate = self
    }
    
    @objc func shuffleCardsOnBoard(sender: UIRotationGestureRecognizer) {
        switch sender.state {
        case .ended:
            if sender.rotation > CGFloat.pi/2 || sender.rotation < -CGFloat.pi/2{
                game.shuffleCardsOnBoard()
                updateViewFromModel()
            }
        default:
            break
        }
    }
    
    private func updateViewFromModel() {
        updateCards()
        scoreLabel.text = "score: \(game.score)"
    }
    
    private func addTapGestures() {
        for cardIndex in cardsViews.indices {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardSelected))
            cardsViews[cardIndex].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func cardSelected(sender: UITapGestureRecognizer? = nil) {
        game.cardSelected(at: cardsViews.index(of: sender!.view as! SetCardView)!)
        updateViewFromModel()
    }
    
    private func addSwipeDownGesture() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(add3Cards))
        swipeGesture.direction = [.down]
        view.addGestureRecognizer(swipeGesture)
    }
    
    private func addRotationGesture() {
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(shuffleCardsOnBoard))
        view.addGestureRecognizer(rotationGesture)
    }
    
    private func removeAllCardsViews() {
        for sub in cardsViews{
            sub.removeFromSuperview()
        }
        cardsViews = []
    }
    private func spacedRect(for rect: CGRect) -> CGRect {
        return CGRect(x: rect.origin.x+spaceBetweenCards/2, y: rect.origin.y+spaceBetweenCards/2,width: rect.width - spaceBetweenCards,
                      height: rect.height - spaceBetweenCards)
    }
    
    private func assignCardAttributes(atIndex i: Int) {
        let card = game.cardsOnBoard[i]
        switch card.color{
        case .color1:
            cardsViews[i].shapeColor = Consts.shapeColor1
        case .color2:
            cardsViews[i].shapeColor = Consts.shapeColor2
        case .color3:
            cardsViews[i].shapeColor = Consts.shapeColor3
        }
        cardsViews[i].number = card.number
        cardsViews[i].shade = card.shade
        cardsViews[i].shape = card.shape
    }
    
    private func addCardAnimation(atIndex i: Int, cardsAmountBeforeAdding: Int) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Consts.dealCardMoveTime,
                                                              delay: TimeInterval(i-cardsAmountBeforeAdding)/2,
                                                              options: [],
                                                              animations: {
                                                                self.cardsViews[i].frame = self.spacedRect(for: self.grid[i]!)
                                                                },
                                                              completion: {position in
                                                                self.animateFlip(cardView: self.cardsViews[i])
        })
    }
    
    private func animateFlip(cardView: SetCardView, completion: ((Bool) -> Void)? = nil) {
        UIView.transition(with: cardView, duration: Consts.cardFlipingTime, options: [.transitionFlipFromLeft], animations: {cardView.isFaceUp = !cardView.isFaceUp}, completion: completion)
    }
    
    fileprivate func addMissingCardViews() {
        let cardsAmountBeforeAdding = cardsViews.count
        for i in cardsViews.count ..< game.cardsOnBoard.count {
            let card = SetCardView(frame: dealNewCardsFrame)
            cardsViews += [card]
            assignCardAttributes(atIndex: i)
            view.addSubview(card)
            addCardAnimation(atIndex: i,cardsAmountBeforeAdding: cardsAmountBeforeAdding)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardSelected))
            cardsViews[i].addGestureRecognizer(tapGesture)
        }
    }
    
    fileprivate func updateCardsFrames(animated: Bool) {
        for i in cardsViews.indices {
            if animated {
                UIViewPropertyAnimator.runningPropertyAnimator(withDuration: Consts.dealCardMoveTime,
                                                               delay: 0,
                                                               options: [],
                                                               animations: {self.updateCardFrame(at: i)},
                                                               completion: nil)
            }
            else {
                updateCardFrame(at: i)
            }
        }
    }
    
    private func updateCardFrame(at index: Int) {
        cardsViews[index].frame = spacedRect(for: grid[index]!)
    }
    
    fileprivate func updateCards(){
        grid.cellCount = game.cardsOnBoard.count
        updateCardsFrames(animated: true)
        addMissingCardViews()
        colorSelectedCardsMargins()
    }
    
    fileprivate func disapearExcistMargins() {
        cardsViews.forEach({card in
            card.layer.borderWidth = 0
        })
    }
    
    fileprivate func colorSelectedCardsMargins() {
        disapearExcistMargins()
        if game.selectedCardsIndexes.count == 3 {
            if game.isChosenIsSet() {
                for i in 0...2 {
                    let card = cardsViews.remove(at: game.selectedCardsIndexes[2-i])
                    cardBehavior.addItem(card)
                    flyingCards += [card]
                    card.gestureRecognizers?.forEach{recognizer in card.removeGestureRecognizer(recognizer)}
                }
                game.removeMatchedcards()
                updateViewFromModel()
            } else {
                colorIndexedCardsMargins(indexesToColor: game.selectedCardsIndexes, inColor: Consts.nonSetCardMarginColor)
            }
        } else {
            colorIndexedCardsMargins(indexesToColor: game.selectedCardsIndexes, inColor: Consts.selectedCardMarginColor)
        }
    }
    
    fileprivate func colorIndexedCardsMargins(indexesToColor cardsIndexes: [Int], inColor color: CGColor) {
        for i in cardsIndexes {
            cardsViews[i].addMargin(coloredIn: color)
        }
    }
    
    fileprivate func setLowButonsMargins() {
        for btn in lowButtons {
            btn.layer.cornerRadius = lowButtonsCornerRadius
            btn.clipsToBounds = true
        }
    }
}
extension SetViewController {
    var spaceBetweenCards: CGFloat {
        return (view.bounds.width*view.bounds.height)/(1000*CGFloat(game.cardsOnBoard.count))
    }
    var lowButtonsCornerRadius: CGFloat {
        return scoreLabel.bounds.height * 0.2
    }
    var dealNewCardsFrame: CGRect {
        return view.convert(dealNewCardsButton.frame, from: dealCardsSuperView)
    }
    var scoreLabelFrame: CGRect {
        return view.convert(scoreLabel.frame, from: scoreLabelSuperView)
    }
}
struct Consts {
    static let quickSetTime: TimeInterval = 3
    static let regularSetTime: TimeInterval = 5
    static let cheatScoreMinus = 3
    static let undoScoreMinus = 1
    static let setMistakeScoreMinus = 4
    static let scoreBonusQuickSet = 6
    static let scoreBonusRegularSet = 4
    static let scoreBonusSlowSet = 2
    static let flyingCardElasticity: CGFloat = 1
    static let flyingCardResistence : CGFloat = 0
    static let cardSnapDamping: CGFloat = 0.3
    static let cardFlightTime: TimeInterval = 2
    static let cardBoundsChangeTime: TimeInterval = 0.4
    static let dealCardMoveTime: TimeInterval = 0.3
    static let flyingCardPushMagnitude: CGFloat = 5
    static let cardFlipingTime: TimeInterval = 0.3
    static let selectedCardMarginColor: CGColor = #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)
    static let nonSetCardMarginColor: CGColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    static let setCardMarginColor: CGColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    static let cheatCardMarginColor: CGColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
    static let shapeColor1 = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    static let shapeColor2 = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    static let shapeColor3 = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
    static let cardAspectRatio: CGFloat = 0.65
}



