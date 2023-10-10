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
    @IBOutlet var centerBall: UIImageView!
    
    private var timer = Timer()
    private var gameTimer = 20
    private let indexProgressBar = 20
    
    private var animator: UIDynamicAnimator!
    private var collision: UICollisionBehavior!
    private var snap: UISnapBehavior!
    private var dynamic: UIDynamicItemBehavior!
    lazy var gravity: UIFieldBehavior = {
        let gravity = UIFieldBehavior.springField()
        gravity.strength = 0.005
        return gravity
    }()
    
    private var life = 4
    private var enemys: [Enemy] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startGame()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gravity.position = view.center

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
            finishTheGame(isWin: true)
        }
    }
    //MARK: -  Start
    
    private func startGame() {

        timeProgressView.progress = 1.0
        
        animator = UIDynamicAnimator(referenceView: view)
        
        settingCollision()
        animator.addBehavior(gravity)
        
        startTimer()
    }
    
    private func settingCollision() {
        collision = UICollisionBehavior()
        let xPointCenter = (view.frame.width / 2) - (centerBall.frame.width / 2)
        let yPointCenter = (view.frame.height / 2) - (centerBall.frame.height / 2)
        let sizeBounrary = CGRect(x: xPointCenter ,
                                  y: yPointCenter,
                                  width: centerBall.frame.width,
                                  height: centerBall.frame.height)
        collision.addBoundary(withIdentifier: "ball" as NSCopying, for: UIBezierPath(ovalIn: sizeBounrary))
        collision.collisionDelegate = self
        animator.addBehavior(collision)
    }
    
    //MARK: -  generate enemy
    
    private func createEnemy() {
        let enemy = Enemy.getRandomEnemy()
        enemys.append(enemy)
        let enemyView = CustomBallView(image: UIImage(named: enemy.image))
        enemyView.frame = enemy.size
        enemyView.center = getCenterEnemy(widthEnemy: enemyView.frame.width)
        view.addSubview(enemyView)
        

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnEnemy(_:)))
        enemyView.isUserInteractionEnabled = true
        enemyView.addGestureRecognizer(tapGesture)
        tapGesture.view?.tag = enemys.count - 1
        
        collision.addItem(enemyView)
        gravity.addItem(enemyView)
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
    //MARK: - live manager
    
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
    //MARK: - finish game
    
    //MARK: -  finsh
    
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
        guard let collidingView = item as? UIImageView else { return }
        collidingView.removeFromSuperview()
        lossOfLife()
    }
}


