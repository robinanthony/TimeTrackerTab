//
//  AddTaskViewController.swift
//  TimeTrackerTabs
//
//  Created by tpxcode on 09/03/2020.
//  Copyright © 2020 RenaultRobin. All rights reserved.
//

import UIKit
import CoreData

class AddTaskViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var pickerViewProjects: UIPickerView!
    @IBOutlet weak var newTaskName: UITextField!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var allProject: [Project] = [];
    
    var originalSelectedProject: Project! = nil;
    var currentSelectedProject: Int = 0;
    
    var unwindIdentifier: String = "";
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.allProject.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.allProject[row].name;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentSelectedProject = row;
    }
    
    @IBAction func handleCancel(_ sender: Any) {
        if self.unwindIdentifier != "" {
            performSegue(withIdentifier: self.unwindIdentifier, sender: self);
        }
    }
    
    @IBAction func handleSave(_ sender: Any) {
        if self.newTaskName.text != "" {
            print("INFOS : AddTaskViewController : ajout d'une tâche "+self.newTaskName.text!+" dans le projet "+self.allProject[self.currentSelectedProject].name!+".");
            
            let newTache = Task(context: self.context);
            newTache.name = self.newTaskName.text;
            
            var results:[Project] = [];
            let requete:NSFetchRequest<Project> = Project.fetchRequest();
            requete.returnsObjectsAsFaults = false;
            do {
                requete.predicate = NSPredicate(format: "name == %@", self.allProject[self.currentSelectedProject].name!);
                results.append(contentsOf: try context.fetch(requete));
            }
            catch {
                print("ERROR : AddTaskViewController : problème rencontré lors de la récupération du projet lors de l'ajout d'une tâche.");
            }
            
            if (results.count == 1){
                newTache.project = results[0];
                saveData();
                
                if self.unwindIdentifier != "" {
                    self.performSegue(withIdentifier: self.unwindIdentifier, sender: self);
                }
                else {
                    print("ERROR : AddTaskViewController : Aucun unwind précisé, retour vers le MainViewController.");
                    self.performSegue(withIdentifier: "unwindToMain", sender: self);
                }
            }
            else{
                print("ERROR : AddTaskViewController : plusieurs projets récupéré lors de la tentative d'ajout d'une tâche. Action impossible.");
            }
        }
    }
    
    func loadDataInCoreData(){
        // get dans CoreData la liste de tous les projets
        var results:[Project] = [];
        
        let requete:NSFetchRequest<Project> = Project.fetchRequest();
        requete.returnsObjectsAsFaults = false;
        do {
            requete.predicate = NSPredicate(format: "name == %@", "Single Tasks");
            results.append(contentsOf: try context.fetch(requete));
        }
        catch {
            print("ERROR : AddTaskViewController : problème rencontré lors de la récupération du projet 'Single Task'.");
        }
        
        let requeteBis:NSFetchRequest<Project> = Project.fetchRequest();
        requeteBis.returnsObjectsAsFaults = false;
        do {
            requeteBis.predicate = NSPredicate(format: "type == %@", "user");
            results.append(contentsOf: try context.fetch(requeteBis));
        }
        catch {
            print("ERROR : AddTaskViewController : problème rencontré lors de la récupération des projets utilisateurs.");
        }
        
        self.allProject = results;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        pickerViewProjects.delegate = self;
        pickerViewProjects.dataSource = self;
        
        loadDataInCoreData();
        
        // get l'id du self.originalSelectedProject pour set correctement self.currentSelectedProject
        for (index, testProject) in self.allProject.enumerated() {
            if testProject == self.originalSelectedProject {
                self.currentSelectedProject = index;
            }
        }
        
        pickerViewProjects.selectRow(self.currentSelectedProject, inComponent: 0, animated: true);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveData() -> Void {
        do {
            try context.save();
            print("INFOS : AddTaskViewController : Save in database CoreData successful");
        } catch {
            print("ERROR : AddTaskViewController : Error while saving with CoreData : \(error)");
        }
    }
}
