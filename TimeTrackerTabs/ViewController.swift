//
//  ViewController.swift
//  TimeTrackerTabs
//
//  Created by tpxcode on 07/03/2020.
//  Copyright © 2020 RenaultRobin. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var totalTimeLabel: UIBarButtonItem!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBAction func handleNewProject(_ sender: Any) {
        let currentDate = Date();
        print("Ajout d'un nouveau projet ! ");
        print(currentDate);
    }
    
    @IBAction func handleAbout(_ sender: Any) {
        print("De quoi parle cette application ?");
    }
    
    @IBAction func handleAllProjectEdit(_ sender: Any) {
        print("Ze veut editer tous les projets !");
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let newProject = Project(context: context);
        newProject.name = "Single Tasks";
        
        saveData();
        
        totalTimeLabel.title = "Total 0:00";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveData() -> Void {
        do {
            try context.save()
            print("Save in database CoreData successful")
        } catch {
            print("Error while saving with CoreData : \(error)")
        }
    }

}

