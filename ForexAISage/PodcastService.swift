import Foundation

class PodcastService {
    static let shared = PodcastService()
    private let rssFeedURL = "https://anchor.fm/s/f0166ed0/podcast/rss"
    
    func fetchEpisodes() async throws -> [PodcastEpisode] {
        guard let url = URL(string: rssFeedURL) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let parser = XMLParser(data: data)
        let delegate = RSSParserDelegate()
        parser.delegate = delegate
        
        if parser.parse() {
            return delegate.episodes
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
}

class RSSParserDelegate: NSObject, XMLParserDelegate {
    var episodes: [PodcastEpisode] = []
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentDate = ""
    private var currentDuration = ""
    private var currentAudioURL = ""
    private var isItem = false
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "item" {
            isItem = true
            currentTitle = ""
            currentDescription = ""
            currentDate = ""
            currentDuration = ""
            currentAudioURL = ""
        }
        
        if elementName == "enclosure" {
            currentAudioURL = attributeDict["url"] ?? ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isItem {
            switch currentElement {
            case "title": currentTitle += string
            case "description": currentDescription += string
            case "pubDate": currentDate += string
            case "itunes:duration": currentDuration += string
            default: break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            isItem = false
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
            let date = dateFormatter.date(from: currentDate.trimmingCharacters(in: .whitespacesAndNewlines)) ?? Date()
            
            let episode = PodcastEpisode(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                description: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                date: date,
                duration: currentDuration.trimmingCharacters(in: .whitespacesAndNewlines),
                audioURL: URL(string: currentAudioURL) ?? URL(string: "https://example.com")!
            )
            
            episodes.append(episode)
        }
    }
} 