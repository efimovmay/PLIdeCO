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
        
    //    collision.collisionDelegate = self
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        startTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animator = UIDynamicAnimator(referenceView: view)
        

        let typeEnemy = Enemy.getRandomEnemy()
        
        let enemyImageView  = UIImageView(image: UIImage(named: typeEnemy.image))
        enemyImageView.frame = typeEnemy.size
        enemyImageView.center = getCenterEnemy(widthEnemy: enemyImageView.frame.width)
        enemyImageView.isUserInteractionEnabled = true
        enemyImageView.addGestureRecognizer(tapGesture)
        view.addSubview(enemyImageView)
        
        //centerball
        let ballcenter = UIView(frame: CGRect(x: Int(view.frame.width) / 2 - 50,
                                              y: Int(view.frame.height) / 2 - 50,
                                        width: 100,
                                        height: 100))
        
        ballcenter.layer.borderColor = UIColor.green.cgColor
        ballcenter.layer.borderWidth = 2
        ballcenter.layer.cornerRadius = ballcenter.frame.width / 2
        
        view.addSubview(ballcenter)
        //gravity
//        gravity = UIGravityBehavior(items: [enemyImageView])
//        gravity.magnitude = 20
//        gravity.gravityDirection = CGVector.zero
        


        collision = UICollisionBehavior(items: [ballcenter, enemyImageView])
        
        let rect = CGRect(x: 0, y: 0, width: 256, height: 256)
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: 50)
        let circle = UIBezierPath(ovalIn: rect)
        collision.addBoundary(withIdentifier: "ball" as NSCopying, for: UIBezierPath(rect: ballcenter.frame))
        collision.collisionDelegate = self
        
        snap = UISnapBehavior(item: enemyImageView, snapTo: ballcenter.center)
        snap.damping = 20
        
        animator.addBehavior(collision)
        animator.addBehavior(snap)
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
        timeProgressView.progress = 1.0
    }
    
    @objc func timerAction() {
        //createEnemy()
        gameTimer -= 1
        
        let currentProgress =  Float(gameTimer) / Float(indexProgressBar - 1)
        timeProgressView.setProgress(currentProgress, animated: true)
        
        if gameTimer == 0 {
            timer.invalidate()
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
         
        UIView.animate(withDuration: 3.0, delay: 0.0, options: .allowUserInteraction, animations: {
            enemyImageView.alpha = 0.05
        }, completion: { b in
            if b {
                enemyImageView.removeFromSuperview()
            }
        })
        
        UIView.animate(withDuration: typeEnemy.speed, delay: 0.0, options: [.allowUserInteraction, .curveLinear] ) {
            enemyImageView.center = self.view.center
        } completion: { _ in
            enemyImageView.removeFromSuperview()
            self.lossOfLife()
        }
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
    
    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        let collidingView = item as! UIView
        collidingView.removeFromSuperview()
        lossOfLife()
        
    }
}


