import Foundation
import CoreLocation
import MapKit
import Contacts

@objc(LocalSearchManager)
class LocalSearchManager: RCTEventEmitter {
  private let typesToEat: [MKPointOfInterestCategory] = [.restaurant]

  var searchCompleter = MKLocalSearchCompleter()
  var searchLocationResolver: RCTPromiseResolveBlock?
  var searchLocationRjecter: RCTPromiseRejectBlock?
  
  override init() {
    super.init()
    searchCompleter.delegate = self
  }
  
  @objc
  func searchLocationsAutocomplete(_ text: String!) {
    DispatchQueue.main.async {
      self.searchCompleter.queryFragment = text
    }
  }

  @objc
  func searchPointsOfInterest(_ near: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    guard let nearDictionary = near as? [String: Any] else {
        return
    } 

    let latitude = nearDictionary["latitude"] as! Double
    let longitude = nearDictionary["longitude"] as! Double
    let latitudeDelta = nearDictionary["latitudeDelta"] as! Double
    let longitudeDelta = nearDictionary["longitudeDelta"] as! Double

    let region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), 
      span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    )
    let poiRequest: MKLocalPointsOfInterestRequest = MKLocalPointsOfInterestRequest(center: region.center, radius: 3_000)
    
    // Add a filter on the Category of the place
    var allTypes = typesToEat
    
    let filter = MKPointOfInterestFilter(including: allTypes)     
    poiRequest.pointOfInterestFilter = filter

    let poiSearch: MKLocalSearch = MKLocalSearch(request: poiRequest)
    
    poiSearch.start(completionHandler: {(response, error) in
      guard let response = response else {
        if let error = error {
            print("\(error.localizedDescription)")
            reject("noPlacesFound", error.localizedDescription, nil)
        }
        return
      }

      let result: NSMutableArray = []
      for item in response.mapItems {
        let location: NSMutableDictionary = [:]
        location["name"] = item.name
        location["latitude"] = (item.placemark.location?.coordinate.latitude)!
        location["longitude"] = (item.placemark.location?.coordinate.longitude)!
        location["altitude"] = (item.placemark.location?.altitude)!
        location["isCurrentLocation"] = item.isCurrentLocation
        location["pointOfInterestCategory"] = (item.pointOfInterestCategory?.rawValue)!
        result.add(location)
      }
      
      resolve(result);
    })
  }

  
  @objc
  func searchLocations(_ query: String!, near: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    guard let nearDictionary = near as? [String: Any] else {
        return
    } 

    let latitude = nearDictionary["latitude"] as! Double
    let longitude = nearDictionary["longitude"] as! Double
    let latitudeDelta = nearDictionary["latitudeDelta"] as! Double
    let longitudeDelta = nearDictionary["longitudeDelta"] as! Double

    let region = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), 
      span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    )

    // Create the request
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query

    // Define the region to search
    request.region = region

    // Define what you want in the result
    request.resultTypes.insert(.pointOfInterest)

    // Add a filter on the Category of the place
    var allTypes = typesToEat
    
    let filter = MKPointOfInterestFilter(including: allTypes)     
    request.pointOfInterestFilter = filter
    
    // show only points of interest
    request.resultTypes = MKLocalSearch.ResultType([.pointOfInterest])

    let search = MKLocalSearch(request: request)
    search.start(completionHandler: {(response, error) in
      guard let response = response else {
        if let error = error {
            print("\(error.localizedDescription)")
            reject("noPlacesFound", error.localizedDescription, nil)
        }
        return
      }

      let result: NSMutableArray = []
      for item in response.mapItems {
        let location: NSMutableDictionary = [:]
        location["name"] = item.name
        location["latitude"] = (item.placemark.location?.coordinate.latitude)!
        location["longitude"] = (item.placemark.location?.coordinate.longitude)!
        location["altitude"] = (item.placemark.location?.altitude)!
        location["isCurrentLocation"] = item.isCurrentLocation
        location["pointOfInterestCategory"] = (item.pointOfInterestCategory?.rawValue)!
        result.add(location)
      }
      
      resolve(result);
    })
  }
  
  @objc
  override func supportedEvents() -> [String]! {
    return ["onUpdatedLocationResults"]
  }
  
  @objc
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}

extension LocalSearchManager: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    let results = completer.results.compactMap { (result) -> [String: String] in
      return ["title": result.title, "subtitle": result.subtitle]
    }
    return sendEvent(withName: "onUpdatedLocationResults", body: results)
  }
}


