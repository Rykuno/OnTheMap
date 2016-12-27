//
//  TableVC.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/20/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import UIKit

class TableVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var locationTableView: UITableView!
    var studentsArray = [StudentInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTableView.delegate = self
        locationTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        studentsArray = StudentInformationModel.sharedInstance().getStudentInformation()
        locationTableView.reloadData()
    }
    
    //logs user out of Udacity account
    @IBAction func logoutButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            UdacityClient.sharedInstance().deleteSession(completionHandler: { (success, error) in
                DispatchQueue.main.async {
                    if success{
                        print("success logging out")
                    }else if let error = error{
                        self.displayError(title: "Uh-Oh!", message: error)
                    }
                }
            })
        }
    }
    
    //Reloads map and annotations
    @IBAction func refreshButtonPressed(_ sender: Any) {
        loadMapViewAndAnnotations()
        locationTableView.reloadData()
    }
    
    //Creates a pin on the map.
    @IBAction func createPin(_ sender: Any) {
        let arrayOfStudents = StudentInformationModel.sharedInstance().getStudentInformation()
        let userObjectID = UdacityClient.sharedInstance().accountKey
        var userPresetLocation = String()
        var studentExists = false
        var studentObjectId = String()
        
        //Determine if the student has already created a pin
        for student in arrayOfStudents {
            if student.uniqueKey == userObjectID {
                studentExists = true
                if let objectId = student.objectId, let userLocation = student.mapString {
                    userPresetLocation = userLocation
                    studentObjectId = objectId
                }
            }
        }
        
        //if the student has a pin, ask to override and preload current details on editing VC
        if studentExists{
            let alert = UIAlertController(title: "Pin already exists", message: "Override current Pin?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "PinEditorVC") as! PinEditorVC
                controller.presetUserLocation = userPresetLocation
                controller.studentUniqueId = studentObjectId
                controller.method = Constants.HTTPMethods.put
                self.present(controller, animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            
            present(alert, animated: true, completion: nil)
            
        //if the student does NOT have a pin, segue the PinEditor VC
        }else{
            let controller = storyboard?.instantiateViewController(withIdentifier: "PinEditorVC") as! PinEditorVC
            controller.studentUniqueId = userObjectID
            controller.method = Constants.HTTPMethods.post
            self.present(controller, animated: true, completion: nil)
        }
    }
     
    //loads annotations onto map
    func loadMapViewAndAnnotations(){
        activityIndicatoryShowing(showing: true, view: self.view)
        StudentInformationModel.sharedInstance().downloadDataAndParse { (success, error) in
            DispatchQueue.main.async {
                if success{
                    self.activityIndicatoryShowing(showing: false, view: self.view)
                    self.studentsArray = StudentInformationModel.sharedInstance().getStudentInformation()
                }else if let error = error {
                    self.displayError(title: "Oh-No!", message: error)
                    self.activityIndicatoryShowing(showing: false, view: self.view)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "LocationCell"
        let student = studentsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)! as UITableViewCell
        
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        cell.detailTextLabel?.text = student.mediaURL
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentsArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlToOpen = studentsArray[indexPath.row].mediaURL
        self.openUrlInBrowser(url: urlToOpen)
    }
    
    
    
}
