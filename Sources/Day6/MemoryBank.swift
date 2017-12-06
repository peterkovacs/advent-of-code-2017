struct MemoryBank {
  typealias Index = Array<Int>.Index
  let endIndex: Index
  var memory: Array<Int>

  init<S: Sequence>(memory m: S) where S.Element == Int {
    memory = Array(m)
    endIndex = memory.index(before: memory.endIndex)
  }

  var maxIndex: Index {
    return (memory.startIndex..<memory.endIndex).reduce(memory.startIndex) { result, i in 
      if memory[result] < memory[i] { 
        return i
      } else {
        return result
      }
    }
  }

  private func advance( index: Index ) -> Index {
    return memory.index( index, offsetBy: 1, limitedBy: endIndex ) ?? memory.startIndex
  }

  mutating func redistribute() {
    var index = maxIndex
    var value = memory[index]
    memory[index] = 0

    while value > 0 {
      index = advance( index: index )
      memory[index] += 1
      value -= 1
    }
  }
}

extension MemoryBank: Hashable {
  static func ==(lhs: MemoryBank, rhs: MemoryBank) -> Bool {
    return lhs.memory.elementsEqual(rhs.memory)
  }

  var hashValue: Int {
    return memory.reduce(0) { ($0 << 3) | $1 }
  }
}
