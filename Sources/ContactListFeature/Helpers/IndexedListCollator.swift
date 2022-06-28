import UIKit
import XXModels

public protocol IndexableItem {
    var indexedOn: NSString { get }
}

class IndexedListCollator<Item: IndexableItem> {
    private final class CollationWrapper: NSObject {
        let value: Any
        @objc let indexedOn: NSString

        init(value: Any, indexedOn: NSString) {
            self.value = value
            self.indexedOn = indexedOn
        }

        func unwrappedValue<UnwrappedType>() -> UnwrappedType {
            return value as! UnwrappedType
        }
    }

    public init() {}

    public func sectioned(items: [Item]) -> (sections: [[Item]], collation: UILocalizedIndexedCollation) {
        let collation = UILocalizedIndexedCollation.current()
        let selector = #selector(getter: CollationWrapper.indexedOn)

        let wrappedItems = items.map { item in
            CollationWrapper(value: item, indexedOn: item.indexedOn)
        }

        let sortedObjects = collation.sortedArray(from: wrappedItems, collationStringSelector: selector) as! [CollationWrapper]

        var sections = collation.sectionIndexTitles.map { _ in [Item]() }
        sortedObjects.forEach { item in
            let sectionNumber = collation.section(for: item, collationStringSelector: selector)
            sections[sectionNumber].append(item.unwrappedValue())
        }

        return (sections: sections.filter { !$0.isEmpty }, collation: collation)
    }
}

extension Contact: IndexableItem {
    public var indexedOn: NSString {
        guard let nickname = nickname else {
            return "\(username!.first!)" as NSString
        }

        return "\(nickname.first!)" as NSString
    }
}
