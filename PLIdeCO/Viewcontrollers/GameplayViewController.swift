//
//  ViewController.swift
//  PLIdeCO
//
//  Created by Aleksey Efimov on 28.09.2023.
//

import UIKit

final class GameplayViewController: UIViewController, UICollisionBehaviorDelegate {
    
    
    @IBOutlet var timeProgressView: UIProgressView!
    
    @IBOutlet var live1Image: UIImageView!
    @IBOutlet var live2Image: UIImageView!
    @IBOutlet var live3Image: UIImageView!
    @IBOutlet var live4Image: UIImageView!
    
    var timer = Timer()
    var gameTimer = 20
    let indexProgressBar = 20
    
    var tapGesture = UITapGestureRecognizer()
    var firstContact = false
    
    var animator: UIDynamicAnimator!
    var gravity: UIGravityBehavior!
    var collision: UICollisionBehavior!
    var snap: UISnapBehavior!
    
    var life = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        startGame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    

    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        timer.invalidate()
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
            timer.invalidate()
            finishTheGame(isWin: true)
        }
    }
    
    
    private func startGame() {
        let ballcenter = getBallCircle()
        view.addSubview(ballcenter)
        timeProgressView.progress = 1.0
        
        animator = UIDynamicAnimator(referenceView: view)
        
        collision = UICollisionBehavior()
        collision.addBoundary(withIdentifier: "ball" as NSCopying,
                              for: UIBezierPath(rect: ballcenter.frame))
        collision.collisionDelegate = self
        animator.addBehavior(collision)
    
        startTimer()
    }
    
    private func getBallCircle() -> UIView {
        let ballcenter = UIView(frame: CGRect(x: Int(view.frame.width) / 2 - 50,
                                              y: Int(view.frame.height) / 2 - 50,
                                              width: 100,
                                              height: 100))
        ballcenter.layer.borderColor = UIColor.green.cgColor
        ballcenter.layer.borderWidth = 2
        ballcenter.layer.cornerRadius = ballcenter.frame.width / 2
        return ballcenter
    }
    
    
    //MARK: -  generate enemy
    
    private func createEnemy() {
        let typeEnemy = Enemy.getRandomEnemy()
        
        let enemyImageView  = UIImageView(image: UIImage(named: typeEnemy.image))
        enemyImageView.frame = typeEnemy.size
        enemyImageView.center = getCenterEnemy(widthEnemy: enemyImageView.frame.width)
        enemyImageView.layer.cornerRadius = enemyImageView.frame.width / 2

        view.addSubview(enemyImageView)
        enemyImageView.isUserInteractionEnabled = true
        enemyImageView.addGestureRecognizer(tapGesture)
        collision.addItem(enemyImageView)
        snap = UISnapBehavior(item: enemyImageView, snapTo: view.center)
        snap.damping = 20
        animator.addBehavior(snap)

    }
    
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
            timer.invalidate()
        }
    }
    
    private func finishTheGame(isWin: Bool) {
        let endView = UIImageView()
        
        endView.image = isWin ? UIImage(named: "win") : UIImage(named: "gameOver")
        endView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 60, height: view.frame.height - 100)
        endView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 )
        endView.isUserInteractionEnabled = true
        endView.addGestureRecognizer(tapGesture)
        self.view.addSubview(endView)
    }
    
    private func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        let collidingView = item as! UIView
        collidingView.removeFromSuperview()
        lossOfLife()
        
    }
}


