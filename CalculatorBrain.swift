//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Danielle Zegelstein on 12/21/16.
//  Copyright © 2016 Danielle Zegelstein. All rights reserved.
//

import Foundation

class CalculatorBrain {
  
  private var accumulator = 0.0
  
  func setOperand(operand: Double) {
    accumulator = operand
  }
  
  private var operations: Dictionary<String, Operation> = [
    "π": Operation.Constant(M_PI),
    "e": Operation.Constant(M_E),
    "±": Operation.UnaryOperation({ -$0 }),
    "√": Operation.UnaryOperation(sqrt),
    "cos": Operation.UnaryOperation(cos),
    "tan": Operation.UnaryOperation(tan),
    "sin": Operation.UnaryOperation(sin),
    "log": Operation.UnaryOperation(log),
    "×": Operation.BinaryOperation({ $0 * $1 }),
    "÷": Operation.BinaryOperation({ $0 / $1 }),
    "+": Operation.BinaryOperation({ $0 + $1 }),
    "−": Operation.BinaryOperation({ $0 - $1 }),
    "=": Operation.Equals,
    "c": Operation.Clear
  ]
  
  private enum Operation {
    case Constant(Double)
    case UnaryOperation((Double) -> Double)
    case BinaryOperation((Double, Double) -> Double)
    case Equals
    case Clear
  }
  func performOperation(symbol: String) {
    if let operation = operations[symbol] {
      switch operation {
      case .Constant(let value):
        accumulator = value
      case .UnaryOperation(let function):
        // Doesn't allow the square root of negative numbers
        if symbol == "√" && accumulator < 0 {
          return
        }
        accumulator = function(accumulator)
      case .BinaryOperation(let function):
        executePendingBinaryOperation()
        pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
      case .Equals:
        executePendingBinaryOperation()
      case .Clear:
        pending = nil
        accumulator = 0.0
      }
    }
  }
  
  private func executePendingBinaryOperation() {
    if pending != nil {
      accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
      pending = nil
    }
  }
  
  private var pending: PendingBinaryOperationInfo?
  
  private struct PendingBinaryOperationInfo {
    var binaryFunction: (Double, Double) -> Double
    var firstOperand: Double
  }
  
  var result: Double {
    get {
      return accumulator
    }
  }
  
}
