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
    
    let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableViewProjects: UITableView!
    
    var currentOpenTasks:[Task] = [];
    
    var fixedProjects:[Project] = [];
    
    var currentProjects:[Project] = [];
    
    var segueCurrentProject: Project! = nil;
    
    @IBAction func handleAbout(_ sender: Any) {
        print("INFOS : MainViewController : De quoi parle cette application ?");
    }
    
    @IBAction func handleAllProjectEdit(_ sender: Any) {
        print("INFOS : MainViewController : veut editer tous les projets !");
    }
    
    @IBAction func handleAddProject(_ sender: Any) {
        performSegue(withIdentifier: "addNewProject", sender: self);
    }
    
    @IBAction func handleQuickStart(_ sender: Any) {
        print("INFOS : MainViewController : veut une nouvelle tache dans single tache avec un 'chrono' qui se débute immédiatement");
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
            print("INFOS : MainViewController : sur une tâche en cours : "+self.currentOpenTasks[indexPath.row].name!);
        }
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "showAllTasks", sender: self);
            }
            if indexPath.row == 1 {
                self.segueCurrentProject = self.fixedProjects[indexPath.row];
                performSegue(withIdentifier: "showDetailProject", sender: self);
            }
            print("INFOS : MainViewController : sur fixed project : "+self.fixedProjects[indexPath.row].name!);
        }
        if indexPath.section == 2 {
            self.segueCurrentProject = self.currentProjects[indexPath.row];
            performSegue(withIdentifier: "showDetailProject", sender: self);
            print("INFOS : MainViewController : sur user project : "+self.currentProjects[indexPath.row].name!);
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl();
        
        refreshControl.addTarget(self, action: #selector(MainViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged);
        
        refreshControl.tintColor = UIColor.blue;
        return refreshControl;
    }();
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl){
        self.loadDataInCoreData();
        self.tableViewProjects.reloadData();
        refreshControl.endRefreshing();
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        loadDataInCoreData();
        self.tableViewProjects.reloadData();
    }
    
    func loadDataInCoreData() {
        //        createMoocData();
        getFixedProjectsList();
        getUserProjectsList();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view, typically from a nib.
        self.tableViewProjects.dataSource = self;
        self.tableViewProjects.delegate = self;
        self.tableViewProjects.addSubview(self.refreshControl);
        
        loadDataInCoreData();
        self.totalTimeLabel.title = "Total 0:00";
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
            print("ERROR : MainViewController : problème rencontré lors de la récupération des projets 'fixes'.");
        }
        
        if results.count == 0 {
            print("INFOS : MainViewController : Si premier allumage, les projets 'fixent' n'existent pas et doivent être créés.");
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
            print("ERROR : MainViewController : problème rencontré lors de la récupération des projets utilisateurs.");
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
        } catch {
            print("ERROR : MainViewController : problème rencontré lors de la suppression des projets.");
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveData() -> Void {
        do {
            try context.save()
            print("INFOS : MainViewController : Save in database CoreData successful")
        } catch {
            print("ERROR : MainViewController : Error while saving with CoreData : \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailProject" {
            let destView = segue.destination as! DetailProjectViewController;
            destView.currentProject = self.segueCurrentProject;
        }
    }
}

