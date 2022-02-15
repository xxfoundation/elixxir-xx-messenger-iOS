import Foundation

public extension NSMutableAttributedString {
    func addAttribute(_ name: NSAttributedString.Key, value: Any) {
        addAttribute(name, value: value, range: NSRange(string.startIndex..., in: string))
    }

    func addAttributes(_ attrs: [NSAttributedString.Key: Any]) {
        addAttributes(attrs, range: NSRange(string.startIndex..., in: string))
    }

    func setAttributes(attributes: [NSAttributedString.Key: Any], betweenCharacters: String) {
        let ranges: Array = findRangesWithCharaters(charactersToFind: betweenCharacters)
        for obj in ranges {
            let thisValue: NSValue = obj
            let range: NSRange = thisValue.rangeValue
            setAttributes(attributes, range: range)
        }
    }

    func addAttribute(name: NSAttributedString.Key, value: Any, betweenCharacters: String) {
        let ranges: Array = findRangesWithCharaters(charactersToFind: betweenCharacters)
        for obj in ranges {
            let thisValue: NSValue = obj
            let range: NSRange = thisValue.rangeValue
            addAttribute(name, value: value, range: range)
        }
    }

    func addAttributes(attributes: [NSAttributedString.Key: Any], betweenCharacters: String) {
        let ranges: Array = findRangesWithCharaters(charactersToFind: betweenCharacters)
        for obj in ranges {
            let thisValue: NSValue = obj
            let range: NSRange = thisValue.rangeValue
            addAttributes(attributes, range: range)
        }
    }

    func removeAttribute(name: NSAttributedString.Key, betweenCharacters: String) {
        let ranges: Array = findRangesWithCharaters(charactersToFind: betweenCharacters)
        for obj in ranges {
            let thisValue: NSValue = obj
            let range: NSRange = thisValue.rangeValue
            removeAttribute(name, range: range)
        }
    }

    func findRangesWithCharaters(charactersToFind: String) -> [NSValue] {
        let resultArray = NSMutableArray()
        var insideTheRange = false
        var startingRangeLocation: Int = 0

        while self.mutableString.range(of: charactersToFind).location != NSNotFound {
            let charactersLocation: NSRange = self.mutableString.range(of: charactersToFind)

            if !insideTheRange {
                startingRangeLocation = charactersLocation.location
                insideTheRange = true

                self.mutableString.deleteCharacters(in: charactersLocation)
            } else {
                let range: NSRange = NSRange(location: startingRangeLocation,
                                             length: charactersLocation.location - startingRangeLocation)
                insideTheRange = false

                resultArray.add(NSValue(range: range))
                self.mutableString.deleteCharacters(in: charactersLocation)
            }
        }

        guard let result = resultArray.copy() as? [NSValue] else { return [] }

        return result
    }
}
