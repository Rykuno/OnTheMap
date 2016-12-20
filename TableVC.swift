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
        studentsArray = StudentInformationModel.sharedInstance().getStudentInformation()
    }

    @IBAction func logoutButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            UdacityClient.sharedInstance().deleteSession(completionHandler: { (success, error) in
                DispatchQueue.main.async {
                    if success{
                        print("Success Logging out")
                    }else if let error = error{
                        self.displayError(title: "Uh-Oh!", message: error)
                    }
                }
            })
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        loadMapViewAndAnnotations()
        locationTableView.reloadData()
    }
    
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
