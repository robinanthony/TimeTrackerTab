//
//  DetailProjectViewController.swift
//  TimeTrackerTabs
//
//  Created by tpxcode on 09/03/2020.
//  Copyright © 2020 RenaultRobin. All rights reserved.
//

import UIKit
import CoreData

class DetailProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableViewTasks: UITableView!
    @IBOutlet weak var totalTimeLabel: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UINavigationItem!
    
    let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
    
    var currentProject: Project! = nil;
    var currentTasks: [Task] = [];
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentTasks.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewTasks.dequeueReusableCell(withIdentifier: "ProjectsTasksCell", for: indexPath);
        
        cell.textLabel?.text = self.currentTasks[indexPath.row].name;
        return cell;
    }
    
    @IBAction func addNewTask(_ sender: Any) {
        performSegue(withIdentifier: "addNewTask", sender: self);
    }
    
    @IBAction func handleOverview(_ sender: Any) {
        performSegue(withIdentifier: "unwindToMainWithSegue", sender: self);
    }
    
    func loadDataInCoreData(){
        // get dans CoreData la liste des tâches du projet donné
        let requete:NSFetchRequest<Task> = Task.fetchRequest();
        requete.returnsObjectsAsFaults = false;
        var results:[Task];
        do {
            requete.predicate = NSPredicate(format: "project == %@", currentProject!.name!);
            results = try context.fetch(requete);
        }
        catch {
            results = [];
            print("ERROR : DetailProjectViewController : problème rencontré lors de la récupération des tâches liés à un projet.");
        }
        
        self.currentTasks = results;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableViewTasks.dataSource = self;
        tableViewTasks.delegate = self;
        
        loadDataInCoreData();
        self.titleLabel.title = self.currentProject.name;
        self.totalTimeLabel.title = "Total 0:00";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToDetailProject(segue: UIStoryboardSegue) {
        loadDataInCoreData();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNewTask" {
            let destView = segue.destination as! AddTaskViewController;
            destView.originalSelectedProject = self.currentProject;
            destView.unwindIdentifier = "unwindToDetailProject";
        }
    }
}
