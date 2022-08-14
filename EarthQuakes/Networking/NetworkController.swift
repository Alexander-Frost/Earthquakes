import Foundation

final class NetworkController {
    
    private struct Config {
        static let ShowDataOnPastXDays = 30 /// past 30 days
        static let BaseUrl = URL(string: "https://earthquake.usgs.gov/fdsnws/event/1/query")!
    }
    
    // MARK: - Properties
    
    private let downloadQueue = DispatchQueue(label: "com.alex", attributes: .concurrent)
    private let semaphore = DispatchSemaphore(value: 5) /// let's only allow 5 simultaneous requests in the queue so we don't clog up system resources

    private var cache: [String: [Quake]] = [:] /// caching for an entire day because it takes time to load 30 days of data
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    
    // MARK: - Operations

    public func fetchQuakes(completion: @escaping (Result<[Quake], QuakeError>) -> Void) {
        let dateString = dateFormatter.string(from: Date())
        if let cachedEarthquakes = cache[dateString] {
            completion(.success(cachedEarthquakes))
        }
        
        /// Throw on a background thread
        downloadQueue.async {
            self.semaphore.wait()
            self.fetchQuakesData(completion: completion)
        }
    }
    
    private func fetchQuakesData(completion: @escaping (Result<[Quake], QuakeError>) -> Void) {
        guard let dateInterval = generateInterval() else { return completion(.failure(.dateMathError)) }
        var urlComponents = URLComponents(url: Config.BaseUrl, resolvingAgainstBaseURL: true)
        let startTime = dateFormatter.string(from: dateInterval.start)
        let endTime = dateFormatter.string(from: dateInterval.end)
        let dateString = dateFormatter.string(from: Date())
        
        let queryItems = [
            URLQueryItem(name: "starttime", value: startTime),
            URLQueryItem(name: "endtime", value: endTime),
            URLQueryItem(name: "format", value: "geojson")
        ]
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            return completion(.failure(.invalidURL))
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
            self?.semaphore.signal()
            
            if let _ = error {
                return completion(.failure(.general))
            }
            
            guard let data = data else {
                return completion(.failure(.noDataReturned))
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
                
                let quakeResults = try jsonDecoder.decode(QuakeResults.self, from: data)
                let quakes = quakeResults.features
                self?.cache[dateString] = quakes
                completion(.success(quakes))
            } catch {
                completion(.failure(.decodeError))
            }

        } .resume()
    }
    
    // MARK: - Date Interval
    
    /// 30 Days Back
    private func generateInterval() -> DateInterval? {
        let now = Date()
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.day = -Config.ShowDataOnPastXDays
        
        guard let start = Calendar.current.date(byAdding: dateComponents, to: now) else { return nil }
        return DateInterval(start: start, end: now)
    }
    
    
}

enum QuakeError: Int, Error {
    case invalidURL
    case noDataReturned
    case dateMathError
    case decodeError
    case general
}
