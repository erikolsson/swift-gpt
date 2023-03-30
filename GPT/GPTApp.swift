//
//  GPTApp.swift
//  GPT
//
//  Created by Erik Olsson on 2023-03-29.
//

import SwiftUI
import GPTApp
import ComposableArchitecture

@main
struct GPTApp: App {
    let store = Store(initialState: .init(),
                      reducer: GPTAppReducer())
    var body: some Scene {
        WindowGroup {
          GPTAppView(store: store)
            .task {
              let str = "Here is an implementation of Quick Sort algorithm in Swift:\n\n```\nfunc quicksort<T: Comparable>(_ array: [T]) -> [T] {\n    guard array.count > 1 else { return array }\n\n    let pivot = array[array.count/2]\n    let less = array.filter { $0 < pivot }\n    let equal = array.filter { $0 == pivot }\n    let greater = array.filter { $0 > pivot }\n\n    return quicksort(less) + equal + quicksort(greater)\n}\n\n// Example usage:\nlet unsortedArray = [3, 6, 1, 9, 2, 7]\nlet sortedArray = quicksort(unsortedArray)\nprint(sortedArray)\n```\n\nIn this implementation, the function takes an array of comparable elements as input and returns the sorted array. It first checks if the array has more than one element, and if not, returns the same array.\n\nIt then selects a pivot element (in this case, the middle element of the array) and partitions the remaining array into three sub-arrays: one with elements less than the pivot, one with elements equal to the pivot, and another with elements greater than the pivot.\n\nIt then recursively calls itself on the sub-arrays and concatenates the sorted sub-arrays to generate the final sorted array."
            }
        }
    }
}
