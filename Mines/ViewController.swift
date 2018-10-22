//
//  ViewController.swift
//  Mines
//
//  Created by Usman Rashid on 10/9/18.
//  Copyright © 2018 Usman Rashid. All rights reserved.
//

import UIKit

func * (lhs: Int, rhs: CGFloat) -> CGFloat { return CGFloat (lhs) * rhs }
func * (lhs: CGFloat, rhs: Int) -> CGFloat { return lhs * CGFloat (rhs) }
func / (lhs: CGFloat, rhs: Int) -> CGFloat { return lhs / CGFloat (rhs) }

class ViewController: UIViewController {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var squareCount: UILabel!
    @IBOutlet weak var lblPlayClock: UILabel!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var btnNew: UIButton!
    @IBOutlet weak var btnRestart: UIButton!
    @IBOutlet weak var lblMessage: UILabel!
    
    // Initial state = No game
    var isGameOver = true
    
    var timer = Timer()
    var isTimerPaused = false
    var playTime = 0     // Play Clock Counter
    let maxTime = 3600  // One hour time limit

    var board = Board (rows: 0, cols: 0, mines: 0)

    // Margin between tiles on game board
    let margin: CGFloat = 2

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        squareCount.text = "00"
        lblPlayClock.text = "00:00"
        
        btnNew.layer.cornerRadius = 5
        btnNew.layer.borderWidth = 1
        btnNew.layer.borderColor = UIColor.lightGray.cgColor
        
        btnPlayPause.layer.cornerRadius = 5
        btnPlayPause.layer.borderWidth = 1
        btnPlayPause.layer.borderColor = UIColor.lightGray.cgColor
        // Only enable after the game starts
        btnPlayPause.isEnabled = false

        btnRestart.layer.cornerRadius = 5
        btnRestart.layer.borderWidth = 1
        btnRestart.layer.borderColor = UIColor.lightGray.cgColor
        btnRestart.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBtnNew(_ sender: UIButton)
    {
        let ctrlNewGame = UIAlertController(title: "Start New Game",
                                            message: "Choose a board",
                                            preferredStyle: .actionSheet)

        let game6x6 = UIAlertAction(title: "6 x 6 (5 Mines)",
                                    style: .default,
                                    handler: {(action) -> Void in
                                        self.board = Board(rows: 6, cols: 6, mines: 5)
                                        self.board.reset()
                                        self.startNewGame()
        })

        let  game8x8 = UIAlertAction(title: "8 x 8 (10 Mines)",
                                     style: .default,
                                     handler: {(action) -> Void in
                                        self.board = Board(rows: 8, cols: 8, mines: 10)
                                        self.board.reset()
                                        self.startNewGame()
        })

        let  game10x10 = UIAlertAction(title: "10 x 10 (15 Mines)",
                                     style: .destructive,
                                     handler: {(action) -> Void in
                                        self.board = Board(rows: 10, cols: 10, mines: 15)
                                        self.board.reset()
                                        self.startNewGame()
        })
        
        let gameCancel = UIAlertAction(title: "Cancel",
                                       style: .cancel,
                                       handler: {(action) -> Void in
                                        print("Cancel button tapped")
        })

        ctrlNewGame.addAction(game6x6)
        ctrlNewGame.addAction(game8x8)
        ctrlNewGame.addAction(game10x10)
        ctrlNewGame.addAction(gameCancel)

        self.present(ctrlNewGame, animated: true, completion: nil)
    }


    @IBAction func onBtnRestart(_ sender: Any) {
        // Reset game board (no change to rows, cols, mines)
        board.reset()
        startNewGame()
    }
    
    // Set up and start a game with given parameters
    func startNewGame()
    {
        // Reset game parameters
        timer.invalidate()
        isTimerPaused = false
        isGameOver = false
        playTime = 0

        // Reset all display elements
        squareCount.text = String(board.squaresRemaining)
        lblPlayClock.text = "00:00"
        btnPlayPause.setTitle("Pause", for: .normal)

        // Hide game status message
        hideStatusMessage()

        // Remove all existing squares and labels
        for view in container.subviews {
            view.removeFromSuperview()
        }

        // Create labels for squares
        let rows = board.rows
        let cols = board.cols
        let width  = (container.frame.width  - (cols+1) * margin) / cols
        let height = (container.frame.height - (rows+1) * margin) / rows

        for row in 0..<rows {
            for col in 0..<cols {
                let x = margin + (width  + margin) * col
                let y = margin + (height + margin) * row

                let label = UILabel()
                label.frame = CGRect(x:x, y:y, width:width, height:height)
                label.font = UIFont(name: "AmericanTypewriter-Bold", size: 24)
                label.adjustsFontSizeToFitWidth = true
                label.numberOfLines = 1
                label.textAlignment = NSTextAlignment.center
                label.baselineAdjustment = .alignCenters
                label.tag = row * cols + col + 1
                label.text = String (label.tag)
                label.backgroundColor = UIColor.white
                label.textColor = UIColor.white
                label.isHidden = false
                
                container.addSubview(label)
            }
        }
        
        // Enable game controls
        btnRestart .isEnabled = true
        btnPlayPause.isEnabled = true
        
        // Start the Play Clock
        runTimer()
    }

    
    @IBAction func tap(_ sender: UITapGestureRecognizer)
    {
        // Only handle taps inside the container while the game is still active
        if isGameOver ||
            isTimerPaused ||
            container.point(inside: sender.location(in: container), with: nil) == false {
            print ("gmae over || timer paused || outside")
            return
        }

        let rows = board.rows
        let cols = board.cols
        let width  = (container.frame.width  - (cols+1) * margin) / cols
        let height = (container.frame.height - (rows+1) * margin) / rows
        
        let row = Int((sender.location(in: container)).y / (height + margin))
        let col = Int((sender.location(in: container)).x / (width + margin))
        print ("row = \(row), col = \(col), tag = \(row * cols + col + 1)")

        // Reveal the tapped square
        board.show (row: row, col: col)

        // Game over if it has a mine
        if board[row, col].hasMine() {
            gameOver(message:.Mined)

            // Mark the square as the culprit that ended the game
            board[row, col].value = .Done

            // Show all squares with mines
            board.showMines()
        }
        // Game is successfully completed when all squares
        // (except those with mines) have been revealed
        else if board.squaresRemaining == board.mines {
            gameOver(message: .Success)
        }
        // else nothing

        // Redraw the board
        refreshBoard()
    }

    // Display attributes for squares based on
    // their value (mine, neighbor count etc.)
    let BoardAttrs: [GameSquare.Value : (String, UIColor)] = [
        .Mine:     ("💣", UIColor.black),   // Color is ignored for this
        .Empty:    (" ",  UIColor.black),
        .One:      ("1",  UIColor.blue),
        .Two:      ("2",  UIColor.green),
        .Three:    ("3",  UIColor.red),
        .Four:     ("4",  UIColor.purple),
        .Five:     ("5",  UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)),
        .Six:      ("6",  UIColor.cyan),
        .Seven:    ("7",  UIColor.black),
        .Eight:    ("8",  UIColor.white),
        .Done:     ("💥", UIColor.white),   // Color is ignored for this
        ]
    
    // Update all squares and square count
    func refreshBoard ()
    {
        // Show contents of revealed squares
        for square in board.grid.enumerated() {
            if square.element.isRevealed() {
                if let label = container.viewWithTag(square.offset + 1) as? UILabel {
                    let attr = BoardAttrs[square.element.value]
                    label.backgroundColor = UIColor.lightGray
                    label.text = attr?.0
                    label.textColor = attr?.1
                }
            }
        }
        
        // Update count of un-revealed squares
        squareCount.text = String(board.squaresRemaining)
    }
    
    enum StatusMessage: String {
        case None    = ""
        case Paused  = "Paused"
        case Timeout = "Time's Up!"
        case Mined   = "Oops!"
        case Success = "You Won!"
    }

    let MesgColors: [StatusMessage : UIColor] = [
        .None:      UIColor.darkGray,
        .Paused:    UIColor.darkGray,
        .Timeout:   UIColor.red,
        .Mined:     UIColor.red,
        .Success:   UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0),
    ]

    func gameOver (message: StatusMessage)
    {
        print ("Game Over!: \(message.rawValue)")
        isGameOver = true
        timer.invalidate()
        btnPlayPause.isEnabled = false
        showStatus (message: message)
    }
    
    func showStatus (message: StatusMessage)
    {
        lblMessage.text = message.rawValue
        lblMessage.textColor = MesgColors[message]
        lblMessage.fadeIn()
    }
    
    func hideStatusMessage() {
        lblMessage.text = StatusMessage.None.rawValue
        lblMessage.textColor = MesgColors[.None]
        lblMessage.fadeOut()
    }
    
    func runTimer()
    {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                     selector: (#selector(self.updatePlayClock)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func updatePlayClock()
    {
        playTime += 1
        if playTime >= maxTime {
            gameOver(message: .Timeout)
        }
        else {
            lblPlayClock.text = timeString(time: TimeInterval(playTime))
        }
    }
    
    func timeString(time: TimeInterval) -> String
    {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    @IBAction func togglePausePlay(_ sender: UIButton)
    {
        if isTimerPaused == false {
            isTimerPaused = true
            btnPlayPause.setTitle("Resume", for: .normal)
            timer.invalidate()
            showStatus (message: .Paused)
        }
        else {
            isTimerPaused = false
            btnPlayPause.setTitle("Pause", for: .normal)
            runTimer()
            hideStatusMessage()
        }
    }
}
