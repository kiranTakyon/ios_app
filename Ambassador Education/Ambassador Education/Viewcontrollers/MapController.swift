//
//  MapController.swift
//  Ambassador Education
//
//  Created by    Kp on 24/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController,MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapNameButton: UIButton!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    
    var latitude : Double?
    var longitude : Double?

    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.title = "Set My Location"
        topHeaderView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        if let lat = latitude{
            if let long = longitude{
            setLocationAnnotation(lat: lat, long: long)
            }
        }
        else{
            showAlertController(kAppName, message: "Error in fetching your location", cancelButton: alertOk, otherButtons: [], handler: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setLocationAnnotation(lat : Double,long :Double){
        let coordinate = CLLocationCoordinate2DMake(lat, long)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion.init(center: coordinate, span: span)
        self.mapView.setRegion(region, animated:true)
        
        self.mapView.delegate = self
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Your saved location"
        annotation.subtitle = "This is your current saved location"
        self.mapView.addAnnotation(annotation)
        mapNameButton.setTitle("NORMAL", for: .normal)
    }
    
    @IBAction func sateliteSwapButtonAction(_ sender: Any) {
        
        let button = sender as! UIButton
        
        if button.titleLabel?.text == "SATELITE"{
            button.setTitle("NORMAL", for: UIControl.State.normal)
            mapView.mapType = .satellite


            
        }else{
            button.setTitle("SATELITE", for: UIControl.State.normal)
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
            pinView?.isDraggable = true
            pinView?.pinTintColor = UIColor.appOrangeColor()
           // pinView?.image = UIImage(named:"pin")
            
//            let rightButton: AnyObject! = UIButton(type: UIButtonType.detailDisclosure)
//            pinView?.rightCalloutAccessoryView = rightButton as? UIView
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print(#function)
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "toTheMoon", sender: self)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        if newState == MKAnnotationView.DragState.ending {
            let droppedAt = view.annotation?.coordinate
            self.latitude = droppedAt?.latitude
            self.longitude = droppedAt?.longitude
            print("new location is:",droppedAt ?? 00.00)
        }
    }
  
    func getUdidOfDevide() -> String{
        return  UIDevice.current.identifierForVendor!.uuidString
    }
    
    @IBAction func saveLocationAction(_ sender: Any) {
        
        self.startLoadingAnimation()
        
        var dictionary = [String: String]()
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        dictionary[UserIdKey().id] = userId
        dictionary[LocationUpdate().latitude] = "\(self.latitude!)"
        dictionary[LocationUpdate().longitude] = "\(self.longitude!)"
        dictionary[PasswordChange.client_ip] = getUdidOfDevide()

        let url = APIUrls().updateLocatoin
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {

            if result["StatusCode"] as? Int == 1{
                
                
                    self.stopLoadingAnimation()
                    
                    SweetAlert().showAlert(kAppName, subTitle: "Location Updated SuccessFully", style: .success, buttonTitle: alertOk, action: { (index) in
                        if index {
                         //   self.backAction(UIButton())
                        }
                        
                    })
                    
            }
            else{
                self.stopLoadingAnimation()
                if let msg = result["StatusMessage"] as? String{

                SweetAlert().showAlert(kAppName, subTitle: msg, style: .warning)
                }
                
            }
        }
        }

        
    }
    
    // MARK: - Navigation
    
    @IBAction func didReturnToMapViewController(_ segue: UIStoryboardSegue) {
        print(#function)
    }
    
    @IBAction func backAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }

}


extension MapController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
        print("")
    }
    
    func searchButtonClicked(_ button: UIButton) {
        self.startLoadingAnimation()
        
        var dictionary = [String: String]()
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        dictionary[UserIdKey().id] = userId
        dictionary[LocationUpdate().latitude] = "\(self.latitude!)"
        dictionary[LocationUpdate().longitude] = "\(self.longitude!)"
        dictionary[PasswordChange.client_ip] = getUdidOfDevide()
        
        let url = APIUrls().updateLocatoin
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                
                if result["StatusCode"] as? Int == 1{
                    
                    
                    self.stopLoadingAnimation()
                    
                    SweetAlert().showAlert(kAppName, subTitle: "Location Updated SuccessFully", style: .success, buttonTitle: alertOk, action: { (index) in
                        if index {
                            //   self.backAction(UIButton())
                        }
                        
                    })
                    
                }
                else{
                    self.stopLoadingAnimation()
                    if let msg = result["StatusMessage"] as? String{
                        
                        SweetAlert().showAlert(kAppName, subTitle: msg, style: .warning)
                    }
                    
                }
            }
        }
    }
    
}
