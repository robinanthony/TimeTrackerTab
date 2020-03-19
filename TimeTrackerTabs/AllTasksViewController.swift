//
//  AllTasksViewController.swift
//  TimeTrackerTabs
//
//  Created by tpxcode on 09/03/2020.
//  Copyright © 2020 RenaultRobin. All rights reserved.
//

import UIKit
import CoreData

class AllTasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableViewAllTasks: UITableView!
    
    var allProjects: [Project] = [];
    var allTasks: [Project: [Task]] = [:];
    
    @IBAction func handleOverview(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMain", sender: self);
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // le nombre de section / projets
        return allProjects.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // le nombre de sous-section pour une section : le nombre de tâche par projet
        return self.allTasks[self.allProjects[section]]!.count;
//        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Paramétrage de la cellule par rapport à un 'indexPath'
        let cell = tableViewAllTasks.dequeueReusableCell(withIdentifier: "tableViewAllTasksCell", for: indexPath);
        
        let currentTask = self.allTasks[self.allProjects[indexPath.section]]![indexPath.row];
        
        cell.textLabel?.text = currentTask.name;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Paramétrage des entêtes des sections
        let currentProject = self.allProjects[section];
        return currentProject.name;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // gestion des clics sur une cellule
        let currentProject = self.allProjects[indexPath.section];
        let currentTask = self.allTasks[currentProject]![indexPath.row];
        
        print("INFOS : AllTasksViewController : Clic sur la tâche : "+currentTask.name!+" du projet : "+currentProject.name!);
    }
    
    func loadDataInCoreData(){
        var resultProject: [Project] = [];
        
        let requete:NSFetchRequest<Project> = Project.fetchRequest();
        requete.returnsObjectsAsFaults = false;
        do {
            requete.predicate = NSPredicate(format: "name == %@", "Single Tasks");
            resultProject.append(contentsOf: try context.fetch(requete));
        }
        catch {
            resultProject = [];
            print("ERROR : AllTasksViewController : problème rencontré lors de la récupération du projet 'Single Task'.");
        }
        
        let requeteBis:NSFetchRequest<Project> = Project.fetchRequest();
        requeteBis.returnsObjectsAsFaults = false;
        do {
            requeteBis.predicate = NSPredicate(format: "type == %@", "user");
            resultProject.append(contentsOf: try context.fetch(requeteBis));
        }
        catch {
            resultProject = [];
            print("ERROR : AllTasksViewController : problème rencontré lors de la récupération des projets utilisateurs.");
        }
        
        self.allProjects = resultProject;
//        self.allTasks = Dictionary(uniqueKeysWithValues: zip(resultProject, []));
        
        // TODO : Récuperer la liste de tâches pour chaque projets du dico
        for p in self.allProjects {
            var resultTask: [Task] = [];
            let requeteTask:NSFetchRequest<Task> = Task.fetchRequest();
            requeteTask.returnsObjectsAsFaults = false;
            do {
                requeteTask.predicate = NSPredicate(format: "project.name == %@", p.name!);
                resultTask.append(contentsOf: try context.fetch(requeteTask));
            }
            catch {
                resultTask = [];
                print("ERROR : AllTasksViewController : problème rencontré lors de la récupération des tasks du projet "+p.name!+".");
            }
            self.allTasks[p] = resultTask;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableViewAllTasks.dataSource = self;
        tableViewAllTasks.delegate = self;
        
        loadDataInCoreData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
