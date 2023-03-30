//
//  File.swift
//  
//
//  Created by Erik Olsson on 2023-03-30.
//

import AppKit
import Down
import Highlighter

class MarkdownStyler: Styler {

  static let shared = MarkdownStyler()
  let highlighter = Highlighter()
  
  func style(code str: NSMutableAttributedString) {
    str.addAttributes([.foregroundColor: NSColor.orange,
                       .backgroundColor: NSColor.black],
                      range: NSRange(location: 0, length: str.length))
  }
  
  func style(codeBlock str: NSMutableAttributedString, fenceInfo: String?) {
    if let highlighter {
      highlighter.setTheme("atom-one-dark-reasonable")
      
      var string = str.string
      var prefix: String? = String(string.prefix { char in
        for scalar in char.unicodeScalars {
          if CharacterSet.whitespacesAndNewlines.contains(scalar) {
            return false
          }
        }
        return true
      })
      
      if let prefix, !prefix.isEmpty {
        string = string.replacing(prefix, with: "", maxReplacements: 1).trimmingCharacters(in: .whitespacesAndNewlines)
      }
      
      if !highlighter.supportedLanguages().contains(prefix ?? "") {
        prefix = nil
      }
      
      
      if let attributedString = highlighter.highlight(string, as: prefix) {
        str.setAttributedString(attributedString)
      }
    }

  }
  
  func style(text str: NSMutableAttributedString) {
    
  }
  
  func style(document str: NSMutableAttributedString) {
    
  }
  
  func style(strong str: NSMutableAttributedString) {
    
  }
  
  func style(emphasis str: NSMutableAttributedString) {
    
  }
  
  func style(paragraph str: NSMutableAttributedString) {
    
  }
  
  func style(htmlBlock str: NSMutableAttributedString) {
    
  }
  
  func style(lineBreak str: NSMutableAttributedString) {
    
  }
  
  func style(softBreak str: NSMutableAttributedString) {
    
  }
  
  func style(htmlInline str: NSMutableAttributedString) {
    
  }
  
  func style(customBlock str: NSMutableAttributedString) {
    
  }
  
  func style(customInline str: NSMutableAttributedString) {
    
  }
  
  func style(thematicBreak str: NSMutableAttributedString) {
    
  }
  
  func style(heading str: NSMutableAttributedString, level: Int) {
    
  }
  
  func style(listItemPrefix str: NSMutableAttributedString) {
    
  }
  
  func style(list str: NSMutableAttributedString, nestDepth: Int) {
    
  }
  
  func style(item str: NSMutableAttributedString, prefixLength: Int) {
    
  }
  
  func style(link str: NSMutableAttributedString, title: String?, url: String?) {
    
  }
  
  func style(image str: NSMutableAttributedString, title: String?, url: String?) {
    
  }
  
  func style(blockQuote str: NSMutableAttributedString, nestDepth: Int) {
    
  }
    
}
