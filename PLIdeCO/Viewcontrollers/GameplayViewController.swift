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
    
    private var timer = Timer()
    private var gameTimer = 20
    private let indexProgressBar = 20
    
    private var animator: UIDynamicAnimator!
    private var collision: UICollisionBehavior!
    private var snap: UISnapBehavior!
    
    private var life = 4
    private var enemys: [Enemy] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startGame()
    }
    //MARK: -  Tap views
    
    @objc func tapEndGame(_ sender: UITapGestureRecognizer) {
        timer.invalidate()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let notificationsVC = storyboard.instantiateViewController(withIdentifier: "NotificationsViewController") as! NotificationsViewController
        notificationsVC.modalPresentationStyle = .fullScreen
        present(notificationsVC, animated: true)
    }
    
    @objc func tapOnEnemy(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        enemys[index].life -= 1
        if enemys[index].life == 1 {
            UIView.animate(withDuration: 0.1) {
                sender.view?.alpha = 0.2
            } completion: { _ in
                sender.view?.alpha = 1.0
            }
        } else {
            collision.removeItem(sender.view!)
            sender.view?.removeFromSuperview()
        }
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
    //MARK: -  Start
    
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

        ballcenter.layer.cornerRadius = ballcenter.frame.height / 2
        return ballcenter
    }
    
    
    //MARK: -  generate enemy
    
    private func createEnemy() {
        var enemy = Enemy.getRandomEnemy()
        enemys.append(enemy)

        let enemyImageView  = UIImageView(image: UIImage(named: enemy.image))
        enemyImageView.frame = enemy.size
        enemyImageView.center = getCenterEnemy(widthEnemy: enemyImageView.frame.width)
        view.addSubview(enemyImageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnEnemy(_:)))
        enemyImageView.isUserInteractionEnabled = true
        enemyImageView.addGestureRecognizer(tapGesture)
        tapGesture.view?.tag = enemys.count - 1
        
        collision.addItem(enemyImageView)
        snap = UISnapBehavior(item: enemyImageView, snapTo: view.center)
        snap.damping = enemy.speed
        animator.addBehavior(snap)

    }
    //MARK: - enemy start point
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
    
    private func finishTheGame(isWin: Bool) {
        timer.invalidate()
        collision.removeAllBoundaries()
        
        let endView = UIImageView()
        endView.image = isWin ? UIImage(named: "win") : UIImage(named: "gameOver")
        endView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 60, height: view.frame.height - 100)
        endView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2 )
        endView.alpha = 0.1
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapEndGame(_:)))
        endView.isUserInteractionEnabled = true
        endView.addGestureRecognizer(tapGesture)
        self.view.addSubview(endView)
        
        UIView.animate(withDuration: 1) {
            endView.alpha = 1.0
        }
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
        let collidingView = item as! UIView
        collidingView.removeFromSuperview()
        lossOfLife()
    }
}


