//
//  ViewController.swift
//  TimeTrackerTabs
//
//  Created by tpxcode on 07/03/2020.
//  Copyright © 2020 RenaultRobin. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var totalTimeLabel: UIBarButtonItem!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableViewProjects: UITableView!
    
    var currentOpenTasks:[Task] = [];
    
    var fixedProjects:[Project] = [];
    
    var currentProjects:[Project] = [];
    
    @IBAction func handleAbout(_ sender: Any) {
        print("De quoi parle cette application ?");
    }
    
    @IBAction func handleAllProjectEdit(_ sender: Any) {
        print("Ze veut editer tous les projets !");
    }
    
    @IBAction func handleAddProject(_ sender: Any) {
        performSegue(withIdentifier: "addNewProject", sender: self);
    }
    
    @IBAction func handleQuickStart(_ sender: Any) {
        print("Ze veut une nouvelle tache dans single tache avec un 'chrono' qui se débute immédiatement");
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Le nombre de sections à avoir
        return 3;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Le nombre de sous-section pour une section 'section' donnée
        var count:Int?;
        
        if section == 0 {
            count = currentOpenTasks.count;
        }
        if section == 1 {
            count = fixedProjects.count;
        }
        if section == 2 {
            count = currentProjects.count;
        }
        return count!;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Paramétrage de la cellule par rapport à un 'indexPath' donné grâce à 'indexPath.section' et 'indexPath.row'
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewProjectsCell", for: indexPath);
        
        if indexPath.section == 0 {
            cell.textLabel?.text = self.currentOpenTasks[indexPath.row].name;
        }
        if indexPath.section == 1 {
            cell.textLabel?.text = self.fixedProjects[indexPath.row].name;
        }
        if indexPath.section == 2 {
            cell.textLabel?.text = self.currentProjects[indexPath.row].name;
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Paramétrage des entêtes des sections
        var title:String?;
        if section == 0 {
            title = "Open tasks";
        }
        if section == 1 {
            title = "Fixed projects";
        }
        if section == 2 {
            title = "All projects";
        }
        return title!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // gestion des clics sur une cellule
        if indexPath.section == 0{
            print("clic sur une tâche en cours : "+self.currentOpenTasks[indexPath.row].name!);
        }
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "showAllTasks", sender: self);
            }
            print("clic sur fixed project : "+self.fixedProjects[indexPath.row].name!);
        }
        if indexPath.section == 2 {
            print("clic sur user project : "+self.currentProjects[indexPath.row].name!);
        }
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        loadDataInCoreData();
    }
    
    func loadDataInCoreData() {
        //        createMoocData();
        getFixedProjectsList();
        getUserProjectsList();
        
        totalTimeLabel.title = "Total 0:00";
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view, typically from a nib.
        tableViewProjects.dataSource = self;
        tableViewProjects.delegate = self;
        
        loadDataInCoreData();
    }
    
    func getFixedProjectsList(){
        let requete:NSFetchRequest<Project> = Project.fetchRequest();
        requete.returnsObjectsAsFaults = false;
        var results:[Project];
        do {
            requete.predicate = NSPredicate(format: "type == %@", "fixed");
            requete.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)];
            results = try context.fetch(requete);
        }
        catch {
            results = [];
        }
        
        if results.count == 0 {
            print("Si premier allumage, les projets 'fixent' n'existent pas et doivent être créés.");
            let allTasks = Project(context: context);
            allTasks.name = "All Tasks";
            allTasks.type = "fixed";
            
            let singleTasks = Project(context: context);
            singleTasks.name = "Single Tasks";
            singleTasks.type = "fixed";
            
            results.append(allTasks);
            results.append(singleTasks);
            
            saveData();
        }
        
        self.fixedProjects = results;
    }
    
    func getUserProjectsList(){
        let requete:NSFetchRequest<Project> = Project.fetchRequest();
        requete.returnsObjectsAsFaults = false;
        var results:[Project];
        do {
            requete.predicate = NSPredicate(format: "type == %@", "user");
            results = try context.fetch(requete);
        }
        catch {
            results = [];
        }
        
        self.currentProjects = results;
    }
    
    func createMoocData(){
        deleteAllProjects();
        
        let newProject = Project(context: context);
        newProject.name = "IOS";
        newProject.type = "user";
        
        saveData();
    }
    
    func deleteAllProjects(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project");
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest);
        
        do {
            try context.execute(batchDeleteRequest);
        } catch {}
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

