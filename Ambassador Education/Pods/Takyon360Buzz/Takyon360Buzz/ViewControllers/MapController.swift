//
//  MapController.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 24/07/17.
//  Copyright © 2017 InApp. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController,MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    var delegate : BussProtocol?
    var inboxMessages : BusMsgModel?
    var updateBusLocationTimer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMapAddress()
    }

    override func viewWillAppear(_ animated: Bool) {
        fireTimer()
    }
    
    func fireTimer(){
        updateBusLocationTimer = Timer.scheduledTimer(timeInterval: TimeInterval(30), target: self, selector: #selector(getMapAddress), userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        updateBusLocationTimer?.invalidate()
    }
    
    func setMapView(){
        mapView.delegate = self
        var userLat = 0.0
        var userLong = 0.0
        if inboxMessages != nil{
            if let mapAddress = inboxMessages?.map{
                if mapAddress.count > 0{
                    let obj = mapAddress[0] as? Maps
                    if  inboxMessages?.userLatitude  != "" {
                        userLat = (inboxMessages?.userLatitude.safeValue.toDouble())!
                    }
                  
                    if  inboxMessages?.userLongitude  != ""{
                        userLong = (inboxMessages?.userLongitude.safeValue.toDouble())!
                    }

                    let sourceAnnotation = MKPointAnnotation()
                    let destinationAAnnotation = MKPointAnnotation()
                    
                    let sourceLocation = CLLocationCoordinate2D(latitude : userLat,longitude :userLong)
                    let destinationLocation = CLLocationCoordinate2D(latitude: ((obj?.latitude.safeValue)?.toDouble())!, longitude:  ((obj?.longitude.safeValue)?.toDouble())!)

                    let userLoc = CityLocation(title: "User Location", coordinate: CLLocationCoordinate2D(latitude: sourceLocation.latitude, longitude:sourceLocation.longitude), img: #imageLiteral(resourceName: "User-1"))
                    let busLoc = CityLocation(title: "Bus Location", coordinate: CLLocationCoordinate2D(latitude: destinationLocation.latitude, longitude:destinationLocation.longitude), img: #imageLiteral(resourceName: "Bus"))

                
                    let sourceLocations = CLLocationCoordinate2D(latitude : userLat,longitude :userLong)
                    let destinationLocations = CLLocationCoordinate2D(latitude: ((obj?.latitude.safeValue)?.toDouble())!, longitude:  ((obj?.longitude.safeValue)?.toDouble())!)
                    
                    let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
                    let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
                    
                    
                    let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
                    let destinationMapItem = MKMapItem(placemark: destinationPlaceMark)
                    
                    
                    DispatchQueue.main.async {

                        self.mapView.addAnnotation(userLoc)
                        self.mapView.addAnnotation(busLoc)
                        self.mapView.addAnnotations([userLoc, userLoc])
                        
                        if let location = sourcePlaceMark.location{
                            sourceAnnotation.coordinate = location.coordinate
                        }
                        
                        if let location = destinationPlaceMark.location{
                            destinationAAnnotation.coordinate = location.coordinate
                        }
                        
                        let center = CLLocationCoordinate2D(latitude: destinationLocation.latitude, longitude: destinationLocation.longitude)
                        
                        var region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                     //®   region.center = self.mapView.userLocation.coordinate
                        self.mapView.setRegion(region, animated: true)
                        
                     //   self.mapView.showAnnotations([self.sourceAnnotation,self.destinationAAnnotation], animated: true )
                        
                        let directionRequest = MKDirectionsRequest()
                        directionRequest.source = sourceMapItem
                        directionRequest.destination = destinationMapItem
                        directionRequest.transportType = .automobile
                        
                        let direction = MKDirections(request: directionRequest)
                        
                        direction.calculate { (response, error) in
                            guard let response = response
                                else {
                                if let error = error {
                                    print("Error: \(error)")
                                }
                                return
                            }
                            let route = response.routes[0]
                            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
                            
                        }
                        if self.inboxMessages?.userLatitude  != "" &&  self.inboxMessages?.userLongitude  != "" {
                            self.distanceLabel.text = "Distance : " + self.findMyDistance(myLoc: sourceLocations, busLoc: destinationLocations)
                       }
                        else{
                            self.distanceLabel.text = "Distance : " + "-"
                        }
                    }
                }
            }
        }
    
    }
    
    func findMyDistance(myLoc : CLLocationCoordinate2D,busLoc: CLLocationCoordinate2D) -> String{
        var distance = ""
        let myLocation = CLLocation(latitude: myLoc.latitude, longitude: myLoc.longitude)
        let myBusLocation = CLLocation(latitude: busLoc.latitude, longitude: busLoc.longitude)
        let distanceObtained = myLocation.distance(from: myBusLocation)
        let temp = distanceObtained / 1000.0
        let rounded = String(format: "%.2f", temp)
       distance =  rounded + " KM(s)"
        return distance
    }
  
    @IBAction func sateliteSwapButtonAction(_ sender: Any) {
        
        let button = sender as! UIButton
        
        if button.titleLabel?.text == "SATELITE"{
            button.setTitle("NORMAL", for: UIControlState.normal)
            mapView.mapType = .satellite


            
        }else{
            button.setTitle("SATELITE", for: UIControlState.normal)
            mapView.mapType = .standard


        }
        
        self.mapView.reloadInputViews()
    }
    
    // MARK: - MKMapView delegate
    
    // Called when the region displayed by the map view is about to change
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print(#function)
    }
    
    // Called when the annotation was added
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            return nil
//        }
//                let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
//        if annotation == userLocAnn{
//              annotationView.image = #imageLiteral(resourceName: "User-1")
//        }
//        else{
//              annotationView.image = #imageLiteral(resourceName: "Bus")
//        }
//                return annotationView
//    }
//
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print(#function)
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "toTheMoon", sender: self)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == MKAnnotationViewDragState.ending {
            let droppedAt = view.annotation?.coordinate
            print(droppedAt)
        }
    }
    
    func getMapAddress(){
        
        self.startLoadingAnimation()
        let url  = APIUrls().busMsgsList
        
        print("communicate send urk :- ",url)
        
        var dictionary = [String: Any]()
        dictionary["UserId"] = UserDefaultsManager.manager.getUserId()
        dictionary["MapId"] = branchId
        dictionary["TripId"] = tripId
        dictionary["StaffId"] = staffId
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result,data) in
            
            
            if result["StatusCode"] as? Int == 1{
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                    
                    let list = self.setDecoderForParsingDataFromAPIResponse(data: data as Data)
                    if list.statusCode == -300{
                        SweetAlert().showAlert(kAppName, subTitle: "No locations available", style: .warning)
                    }else{
                        self.inboxMessages = list
                        self.etaLabel.text = "ETA : " + (self.inboxMessages?.eTA.safeValue).safeValue
                        
                        self.setMapView()
                    }
                }
                
            }else{
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                }
            }
            
        }
    }
    
   
    func setDecoderForParsingDataFromAPIResponse(data : Data) -> BusMsgModel {
        var  responseModel : BusMsgModel?
        do{
            let jsonDecoder = JSONDecoder()
            responseModel = try jsonDecoder.decode(BusMsgModel.self, from: data)
            return responseModel!
        }catch let error as NSError {
            print(error.debugDescription)
        }
        return BusMsgModel(status : -300)
    }
    
    
    @IBAction func composeAction(_ sender: UIButton) {
        self.delegate?.getBackToParentView!(value: "compose")

    }
    
   

}

class CityLocation: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var image : UIImage?
    
    init(title: String, coordinate: CLLocationCoordinate2D,img : UIImage) {
        self.title = title
        self.coordinate = coordinate
        self.image = img
    }
}


