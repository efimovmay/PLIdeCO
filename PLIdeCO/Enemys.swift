//
//  Enemys.swift
//  PLIdeCO
//
//  Created by Aleksey Efimov on 29.09.2023.
//

import Foundation

struct Enemy {
    let image: String
    let size: CGRect
    let life: Int
    let speed: Double
    
    
    static func getRandomEnemy() -> Enemy {
        let enemys = ["fast", "standart", "strong"]
        let enemy = enemys.randomElement()
        
        switch enemy {
        case "fast":
           return Enemy(image: "enemy3",
                  size: CGRect(x: 0, y: 0, width: 15, height: 15),
                  life: 1,
                  speed: 3.0)
        case "standart":
           return  Enemy(image: "enemy2",
                  size: CGRect(x: 0, y: 0, width: 30, height: 30),
                  life: 1,
                  speed: 6.0)
        default:
            return Enemy(image: "enemy1",
                  size: CGRect(x: 0, y: 0, width: 50, height: 50),
                  life: 2,
                  speed: 10.0)
        }
    }
}

