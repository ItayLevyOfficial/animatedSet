//
//  ConcentrationThemeChooserViewController.swift
//  animatedSet
//
//  Created by Apple Macbook on 03/09/2018.
//  Copyright © 2018 Apple Macbook. All rights reserved.
//

import UIKit

class ConcentrationThemeChooserViewController: UIViewController, UISplitViewControllerDelegate {
    //cvc == concentrationViewController
    private var lastSeguedToCvc: ConcentrationViewController?
    @IBAction func changeTheme(_ sender: UIButton) {
        if let cvc = splitViewControllerDetailCvc{
            setCvcTheme(sender: sender, cvc: cvc)
        }
        else if let lastCvc = lastSeguedToCvc {
            setCvcTheme(sender: sender, cvc: lastCvc)
            navigationController!.pushViewController(lastCvc, animated: true)
        }
        else {
            performSegue(withIdentifier: "chooseTheme", sender: sender)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func awakeFromNib() {
        splitViewController!.delegate = self
    }
    private var splitViewControllerDetailCvc: ConcentrationViewController?{
        return splitViewController?.viewControllers.last as? ConcentrationViewController
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        let cvc = secondaryViewController as! ConcentrationViewController
        if cvc.theme == .sports {
            return true
        } else {
            return false
        }
    }
    
    fileprivate func setCvcTheme(sender: UIButton,cvc: ConcentrationViewController) {
        let theme = Theme(rawValue: sender.currentTitle!)!
        cvc.theme = theme
        lastSeguedToCvc = cvc
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cvc = segue.destination as! ConcentrationViewController
        setCvcTheme(sender: sender as! UIButton, cvc: cvc)
    }
}
enum Theme: String {
    case animals = "Animals", sports = "Sports", faces = "Faces", veichles = "Veichles", flags = "Flags", fruits = "Fruits"
}
