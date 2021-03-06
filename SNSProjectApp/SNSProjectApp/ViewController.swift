//
//  ViewController.swift
//  SNSProjectApp
//
//  Created by Yanran Qian on 9/29/18.
//
//


import UIKit
import MapKit
import Alamofire

struct MyVariables {
    static var url = "https://728c41de.ngrok.io"
}

class ViewController: UIViewController, UISearchBarDelegate,UIGestureRecognizerDelegate {
    
    private let locationManager = CLLocationManager()
    public var currentCoordinate : CLLocationCoordinate2D?
    
    var searchedLoc: CLLocationCoordinate2D = CLLocationCoordinate2D()

    @IBOutlet var searchBarMap: UISearchBar!
        
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarMap.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        configureLocationServices()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            //mapView.showsUserLocation = true
        }
        else{
            print("Location NOT ON!!!")
        }
        
        
        let lpgr = UILongPressGestureRecognizer(target: self, action:Selector(("handleLongPress:")))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        mapView.addGestureRecognizer(lpgr)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tripleTapped))
        tap.numberOfTapsRequired = 3
        mapView.addGestureRecognizer(tap)
        
        
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarMap.resignFirstResponder()
        let geocoder = CLGeocoder()
        let annotation = MKPointAnnotation()
        geocoder.geocodeAddressString(searchBarMap.text!) { (placemarks:[CLPlacemark]?,error:Error?) in
            if error == nil{
                let placemark = placemarks?.first
                annotation.coordinate = (placemark?.location?.coordinate)!
                annotation.title = self.searchBarMap.text!
                
                let span = MKCoordinateSpan.init(latitudeDelta: 0.075, longitudeDelta: 0.075)
                let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotation(annotation)
                self.mapView.selectAnnotation(annotation, animated: true)
                
                self.searchedLoc = annotation.coordinate
            }
            else {print (error?.localizedDescription ?? "error")}
        }
    }
    
    private func configureLocationServices() {
        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: locationManager)
        }
    }
    
    public func beginLocationUpdates (locationManager:CLLocationManager) {
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    public func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        
        let zoomRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        let annotation = MKPointAnnotation()
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            let touchLocation = gestureReconizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation,toCoordinateFrom: mapView)
            annotation.coordinate = locationCoordinate
            annotation.title = "\(locationCoordinate.latitude) long: \(locationCoordinate.longitude)"
            print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            return
        }
        if gestureReconizer.state != UIGestureRecognizer.State.began {
            return
        }
    }
    
    @objc func tripleTapped(gestureReconizer: UITapGestureRecognizer) {
        let annotation = MKPointAnnotation()
        let touchLocation = gestureReconizer.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation,toCoordinateFrom: mapView)
        annotation.coordinate = locationCoordinate
        annotation.title = "Lat: \(locationCoordinate.latitude),   Long: \(locationCoordinate.longitude)"
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        
        self.mapView.addAnnotation(annotation)
        self.mapView.selectAnnotation(annotation, animated: true)
        
        self.searchedLoc = annotation.coordinate
        
        return
    }
    
    @IBAction func setLoc(_ sender: Any) {
        let t = storyboard?.instantiateViewController(withIdentifier: "NewMessageViewController") as! NewMessageViewController
        print(String(self.searchedLoc.longitude))
        t.longField = String(self.searchedLoc.longitude)
        t.latField = String(self.searchedLoc.latitude)
        
        navigationController?.pushViewController(t, animated: true)
    }

    
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else {return}
        
        if currentCoordinate == nil {
            zoomToLatestLocation(with:latestLocation.coordinate)
        }
        currentCoordinate = latestLocation.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
        }
    }
}
extension String {
    
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
    
}



