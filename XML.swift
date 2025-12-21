import Foundation

class XMLNode {
    var tag: String
    var attributes: [String: String]
    var text: String?
    var children: [XMLNode] = []

    init(tag: String, attributes: [String: String], text: String? = nil) {
        self.tag = tag
        self.attributes = attributes
        self.text = text
    }
    
    func formattedLabel() -> String {
        var parts: [String] = []
        if let className = attributes["class"] {
            parts.append("Class: \(className)")
        }
        if let name = attributes["name"] {
            parts.append("Name: \(name)")
        }
        if let properties = attributes["properties"] {
            parts.append("Properties: \(properties)")
        }
        
        if parts.isEmpty {
            return tag
        } else {
            return "\(tag) (\(parts.joined(separator: ", ")))"
        }
    }
}

class XMLTreeParser: NSObject, XMLParserDelegate {
    private var rootNode: XMLNode?
    private var currentNode: XMLNode?
    private var nodeStack: [XMLNode] = []

    func parse(fileURL: URL) -> XMLNode? {
        if let parser = XMLParser(contentsOf: fileURL) {
            parser.delegate = self
            parser.parse()
        }
        return rootNode
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

        let newNode = XMLNode(tag: elementName, attributes: attributeDict)
        
        if let current = currentNode {
            current.children.append(newNode)
        } else {
            rootNode = newNode
        }
        
        nodeStack.append(newNode)
        currentNode = newNode
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentNode?.text = (currentNode?.text ?? "") + string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        nodeStack.popLast()
        currentNode = nodeStack.last
    }
}

func loadXMLFile(fileURL: URL) -> XMLNode? {
    let parser = XMLTreeParser()
    return parser.parse(fileURL: fileURL)
}
