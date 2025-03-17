//
//  Asynchronous Sequences with AsyncStream.swift
//  
//
//  Created by Apple on 17/03/25.
//

import Foundation

var phrase = "Hello, world!"
var index = phrase.startIndex
let stream = AsyncStream<String> {
  guard index < phrase.endIndex else { return nil }
  do {
    try await Task.sleep(nanoseconds: 1_000_000_000)
  } catch {
return nil

}

  let result = String(phrase[phrase.startIndex...index])
  index = phrase.index(after: index)
  return result
}

for try await item in stream {
  print(item)
}

H
He
Hel
Hell
Hello
Hello,
Hello,
Hello, w
Hello, wo
Hello, wor
Hello, worl
Hello, world
Hello, world!
