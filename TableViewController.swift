//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Donny Blaine on 12/20/16.
//  Copyright © 2016 RyStudios. All rights reserved.
//

import UIKit

struct cellData{
    let cell : Int!
    let name: String!
    let url: String!
}

class TableViewController: UITableViewController {

    var arrayOfCellData = [StudentInformation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arrayOfCellData = StudentInformationArray.sharedInstance().getStudentInformation()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfCellData.count
    }

     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let student = arrayOfCellData[indexPath.row]
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "CellFromNib")
       let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell
        cell.nameLabel.text = "\(student.firstName) \(student.lastName)"
        cell.urlLabel.text = student.mediaURL
        return cell
    }
    




}
