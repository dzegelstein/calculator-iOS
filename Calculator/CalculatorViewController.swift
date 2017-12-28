//
//  ViewController.swift
//  Calculator
//
//  Created by Danielle Zegelstein on 12/22/16.
//  Copyright © 2016 Danielle Zegelstein. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
  
  @IBOutlet weak var display: UILabel!
  @IBOutlet weak var equationDisplay: UILabel!
  private var userIsInTheMiddleOfTyping = false

  private var equationStack = Stack()
  private var resultStack = Stack()
  
  @IBAction func digitTouched(_ sender: UIButton) {
    let digit  = sender.currentTitle!
    if (digit == "." && (display.text?.contains("."))!) || (digit == "0" && displayValue == 0 && !(display.text?.contains("."))!) {
      return
    } else if digit == "." && !userIsInTheMiddleOfTyping {
      display.text = "0."
    } else if digit == "." || userIsInTheMiddleOfTyping {
      let textCurrentlyInDisplay = display.text
      display.text = textCurrentlyInDisplay! + digit
    } else {
      display.text = digit
    }
    userIsInTheMiddleOfTyping = true
    brain.userTyped = true
  }
  
  private var displayValue: Double {
    get {
      return Double(display.text!)!
    }
    set {
      if round(newValue) == newValue {
        display.text = String(Int(newValue))
      } else {
        display.text = String(newValue)
      }
    }
  }
  
  
  var savedProgram: CalculatorBrain.PropertyList?
  
  @IBAction func save() {
    savedProgram = brain.program
  }
  
  @IBAction func restore() {
    if savedProgram != nil {
      brain.program = savedProgram!
      displayValue = brain.result
    }
  }
  
  private var brain = CalculatorBrain()
  
  @IBAction func operationButtonTouched(_ sender: UIButton) {
    
    if userIsInTheMiddleOfTyping {
      brain.setOperand(operand: displayValue)
      userIsInTheMiddleOfTyping = false
    }
    if let mathematicalSymbol = sender.currentTitle {
      brain.performOperation(symbol: mathematicalSymbol)
      if mathematicalSymbol == "c" {
        equationStack.empty()
        resultStack.empty()
      }
    }
    resultStack.push(display.text!)
    equationStack.push(equationDisplay.text!)
    displayValue = brain.result
    equationDisplay.text = brain.description
    brain.userTyped = false
    
  }
  
  private func backspace() {
    if display.text!.count > 0 {
      display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
    }
    
    if display.text!.count == 0 {
      display.text = "0"
      userIsInTheMiddleOfTyping = false
    }
  }
  
  @IBAction func undo() {
    if userIsInTheMiddleOfTyping {
      backspace()
    } else {
      if !equationStack.isEmpty() {
        brain.description = equationStack.pop()
        equationDisplay.text = brain.description
      }
      
      if !resultStack.isEmpty() {
        display.text = resultStack.pop()
        brain.result = displayValue
      } else {
        displayValue = 0.0
      }
    }
  }
  
  private struct Stack {
    private var items = [String]()
    mutating func push(_ item: String) {
      items.append(item)
    }
    mutating func pop() -> String {
      return items.removeLast()
    }
    
    func isEmpty() -> Bool {
      return items.isEmpty
    }
    
    mutating func empty() {
      items.removeAll()
    }
  }

}

