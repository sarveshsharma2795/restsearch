import UIKit
import GooglePlaces
import GoogleMaps
class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
  
    @IBAction func refreshPlaces(sender: AnyObject) {
      fetchNearbyPlaces(mapview.camera.target)

    }
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapview: GMSMapView!
  @IBOutlet weak var mapCenterPinImage: UIImageView!
  @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
  let dataProvider = GoogleDataProvider()
  let searchRadius: Double = 1000
  var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
  let locationmanager=CLLocationManager()
  override func viewDidLoad() {
    super.viewDidLoad()
    locationmanager.delegate=self
    locationmanager.requestWhenInUseAuthorization()
    mapview.delegate=self
  }
 
 
func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
     if status == .AuthorizedWhenInUse {
     locationmanager.startUpdatingLocation()
     mapview.myLocationEnabled = true
     mapview.settings.myLocationButton = true
      }
    }
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      if let location = locations.first {
        mapview.camera = GMSCameraPosition(target: location.coordinate, zoom: 25, bearing: 0, viewingAngle: 0)
      locationmanager.stopUpdatingLocation()
        fetchNearbyPlaces(location.coordinate)
      }
      
    }
  func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
    let geocoder = GMSGeocoder()
    geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
      if let address = response?.firstResult() {
        let lines = address.lines
        self.addressLabel.text = lines!.joinWithSeparator("\n")
        UIView.animateWithDuration(0.25) {
          self.view.layoutIfNeeded()
          self.addressLabel.unlock()
        }
      }
    }
  }
  func mapView(mapView: GMSMapView, idleAtCameraPosition position: GMSCameraPosition) {
    reverseGeocodeCoordinate(position.target)
  }
  func mapView(mapView: GMSMapView, willMove gesture: Bool) {
    addressLabel.lock()
    if (gesture) {
      mapCenterPinImage.fadeIn(0.25)
      mapView.selectedMarker = nil
    }
  }
  func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
    mapview.clear()
    dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
      for place: GooglePlace in places {
        let marker = PlaceMarker(place: place)
        marker.map = self.mapview
      }
    }
  }
  func mapView(mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
    
    let placeMarker = marker as! PlaceMarker
    
    
    if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
      
      infoView.nameLabel.text = placeMarker.place.name
      
      
      if let photo = placeMarker.place.photo {
        infoView.placePhoto.image = photo
      } else {
        infoView.placePhoto.image = UIImage(named: "generic")
      }
      
      return infoView
    } else {
      return nil
    }
  }
  func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
    mapCenterPinImage.fadeOut(0.25)
    return false
  }
  func didTapMyLocationButtonForMapView(mapView: GMSMapView) -> Bool {
    mapCenterPinImage.fadeIn(0.25)
    mapView.selectedMarker = nil
    return false
  }
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "Types Segue" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let controller = navigationController.topViewController as! TypesTableViewController
      controller.selectedTypes = searchedTypes
      controller.delegate = self
    }
  }
}

extension MapViewController: TypesTableViewControllerDelegate {
  func typesController(controller: TypesTableViewController, didSelectTypes types: [String]) {
    searchedTypes = controller.selectedTypes.sort()
    dismissViewControllerAnimated(true, completion: nil)
    fetchNearbyPlaces(mapview.camera.target)

  }
  }
