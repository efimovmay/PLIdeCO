//
//  ViewController.swift
//  PLIdeCO
//
//  Created by Aleksey Efimov on 28.09.2023.
//

import UIKit

class GameplayViewController: UIViewController {
    
    @IBOutlet var timeProgressView: UIProgressView!
    
    @IBOutlet var live1Image: UIImageView!
    @IBOutlet var live2Image: UIImageView!
    @IBOutlet var live3Image: UIImageView!
    @IBOutlet var live4Image: UIImageView!
    
    private var timer = Timer()
    private var gameTimer = 20
    private let indexProgressBar = 20
    
    private var tapGesture = UITapGestureRecognizer()
    
    private var life = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        timeProgressView.progress = 1.0
        startTimer()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let notificationsVC = storyboard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        notificationsVC.modalPresentationStyle = .fullScreen
        present(notificationsVC, animated: true)
    }
    
    //MARK: -  Timer
    @objc func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(timerAction),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func timerAction() {
        createEnemy()
        gameTimer -= 1
        
        let currentProgress =  Float(gameTimer) / Float(indexProgressBar - 1)
        timeProgressView.setProgress(currentProgress, animated: true)
        if gameTimer == 0 {
            finishTheGame(isWin: true)
        }
    }
    
    //MARK: -  generate enemy
    
    private func createEnemy() {
        let typeEnemy = Enemy.getRandomEnemy()
        
        let enemyImageView  = UIImageView(image: UIImage(named: typeEnemy.image))
        enemyImageView.frame = typeEnemy.size
        enemyImageView.center = getCenterEnemy(widthEnemy: enemyImageView.frame.width)
        enemyImageView.addGestureRecognizer(tapGesture)
        enemyImageView.isUserInteractionEnabled = true
        view.addSubview(enemyImageView)
        
        UIView.animate(withDuration: typeEnemy.speed, delay: 0.0, options: [.allowUserInteraction, .curveLinear] ) {
            enemyImageView.center = self.view.center
        } completion: { _ in
            enemyImageView.removeFromSuperview()
            self.lossOfLife()
        }
    }
    //MARK: -  inteface
    
    private func getCenterEnemy(widthEnemy: CGFloat) -> CGPoint {
        let side = ["left", "right", "top", "bottom"]
        let randomSide = side.randomElement()
        switch randomSide {
        case "left":
            return CGPoint(x: -widthEnemy,
                           y: CGFloat(arc4random_uniform(UInt32(view.frame.height))))
        case "right":
            return CGPoint(x: view.frame.width + widthEnemy,
                           y: CGFloat(arc4random_uniform(UInt32(view.frame.height))))
        case "top":
            return CGPoint(x: CGFloat(arc4random_uniform(UInt32(view.frame.width))),
                           y: -widthEnemy)
        default:
            return CGPoint(x: CGFloat(arc4random_uniform(UInt32(view.frame.width))),
                           y: view.frame.height + widthEnemy)
        }
    }
    
    private func lossOfLife() {
        life -= 1
        switch life {
        case 3:
            live4Image.alpha = 0.2
        case 2:
            live3Image.alpha = 0.2
        case 1:
            live2Image.alpha = 0.2
        default:
            live1Image.alpha = 0.2
        }
        if life == 0 {
            finishTheGame(isWin: false)
        }
    }
    
    //MARK: -  finsh
    
    private func finishTheGame(isWin: Bool) {
        timer.invalidate()
        
        let endView = UIImageView()
        endView.image = isWin ? UIImage(named: "win") : UIImage(named: "gameOver")
        endView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 60, height: view.frame.height - 100)
        endView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 )
        endView.isUserInteractionEnabled = true
        endView.addGestureRecognizer(tapGesture)
        self.view.addSubview(endView)
    }
}


