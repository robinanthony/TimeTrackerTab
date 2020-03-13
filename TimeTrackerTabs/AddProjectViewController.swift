//
//  AddProjectViewController.swift
//  TimeTrackerTabs
//
//  Created by tpxcode on 08/03/2020.
//  Copyright © 2020 RenaultRobin. All rights reserved.
//

import UIKit
import CoreData

class AddProjectViewController: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    
    @IBOutlet weak var newProjectName: UITextField!;
    
    @IBAction func handleCancel(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToMain", sender: self);
    }
    
    @IBAction func saveNewProject(_ sender: Any) {
        if newProjectName.text != "" {
            print("INFOS : AddProjectViewController : Création d'un nouveau projet : "+newProjectName.text!);
            
            let newProject = Project(context: context);
            newProject.name = newProjectName.text;
            newProject.type = "user";
            
            saveData();
            self.performSegue(withIdentifier: "unwindToMain", sender: self);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    
    func saveData() -> Void {
        do {
            try context.save();
            print("INFOS : Save in database CoreData successful");
        } catch {
            print("ERROR : AddProjectViewController : Error while saving with CoreData : \(error)");
        }
    }
}
