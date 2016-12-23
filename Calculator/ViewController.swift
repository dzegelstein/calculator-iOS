//
//  ViewController.swift
//  Calculator
//
//  Created by Danielle Zegelstein on 12/22/16.
//  Copyright © 2016 Danielle Zegelstein. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var display: UILabel!
  
  private var userIsInTheMiddleOfTyping = false
  
  @IBAction func digitTouched(_ sender: UIButton) {
    let digit  = sender.currentTitle!
    if (digit == "." && (display.text?.contains("."))!) || (digit == "0" && displayValue == 0) {
      return
    } else if digit == "." || userIsInTheMiddleOfTyping {
      
      let textCurrentlyInDisplay = display.text
      display.text = textCurrentlyInDisplay! + digit
    } else {
      display.text = digit
    }
    userIsInTheMiddleOfTyping = true
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
  
  private var brain = CalculatorBrain()
  
  @IBAction func operationButtonTouched(_ sender: UIButton) {
    if userIsInTheMiddleOfTyping {
      brain.setOperand(operand: displayValue)
      userIsInTheMiddleOfTyping = false
    }
    if let mathematicalSymbol = sender.currentTitle {
      brain.performOperation(symbol: mathematicalSymbol)
    }
    displayValue = brain.result
  }
}

