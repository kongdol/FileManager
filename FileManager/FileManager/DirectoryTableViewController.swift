//
//  DirectoryTableViewController.swift
//  FileManager
//
//  Created by yk on 2/24/25.
//

import UIKit

class DirectoryTableViewController: UITableViewController {
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var currentDirectoryUrl: URL?
    var contents = [Content]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            if let vc = segue.destination as? DirectoryTableViewController {
                vc.currentDirectoryUrl = contents[indexPath.row].url
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "directorySegue" {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                return contents[indexPath.row].type == .directory
            }
        }
        return true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentDirectoryUrl == nil {
            currentDirectoryUrl = URL(fileURLWithPath: NSHomeDirectory())
        }
        
        setupMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshContents()
        updateNavigationTitle()
    }
    
    func showNameInputAlert() {
        let inputAlert = UIAlertController(title: "새 디렉토리", message: nil, preferredStyle: .alert)
        
        inputAlert.addTextField { nameField in
            nameField.placeholder = "디렉토리 이름을 입력해주세요"
            nameField.clearButtonMode = .whileEditing
            nameField.autocapitalizationType = .none
            nameField.autocorrectionType = .no
        }
        
        let createAction = UIAlertAction(title: "추가", style: .default) { _ in
            if let name = inputAlert.textFields?.first?.text {
                self.addDirectory(named: name)
            }
        }
        inputAlert.addAction(createAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        inputAlert.addAction(cancelAction)
        
        present(inputAlert, animated: true)
    }
    
    func addDirectory(named: String){
        guard let url = currentDirectoryUrl?.appendingPathComponent(named, isDirectory: true) else {
            return
        }
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            
        } catch {
            print(error)
        }
        
        refreshContents()
    }
    
    func addTextFile() {
        let content = Date.now.description
        
        guard let targetUrl = currentDirectoryUrl?.appendingPathComponent("current-time").appendingPathExtension("txt") else {
            return
        }
        do {
            try content.write(to: targetUrl, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
        
        refreshContents()
    }
    
    func addImagefile() {
        let name = Int.random(in: 1 ... 30)
        guard let imageUrl = URL(string: "https://kxcodingblob.blob.core.windows.net/mastering-ios/\(name).jpg") else {
            return
        }
        
        guard let targetUrl = currentDirectoryUrl?.appendingPathComponent("\(name)").appendingPathExtension("jpg") else {
            return
        }
        
        // 다운로드 백그라운드 스레드
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: imageUrl)
                try data.write(to: targetUrl, options: .atomic)
            } catch {
                print(error)
            }
            
            DispatchQueue.main.async {
                self.refreshContents()
            }
        }
    }
    
    func setupMenu() {
        menuButton.menu = UIMenu(children: [
            UIAction(title: "새 디렉토리", image: UIImage(systemName: "folder"), handler: { _ in
                self.showNameInputAlert()
            }),
            UIAction(title: "새 텍스트 파일", image: UIImage(systemName: "doc.text"), handler: { _ in
                self.addTextFile()
            }),
            UIAction(title: "새 이미지 파일", image: UIImage(systemName: "photo"), handler: { _ in
                self.addImagefile()
            })
            
        ])
    }
    
    
    func updateNavigationTitle() {
        guard let url = currentDirectoryUrl else {
            navigationItem.title = "???"
            return
        }
        do {
            let values = try url.resourceValues(forKeys: [.localizedNameKey])
            navigationItem.title = values.localizedName
        } catch {
            print(error)
        }
    }
    
    func refreshContents() {
        contents.removeAll()
        
        defer {
            tableView.reloadData()
        }
        
        guard let url = currentDirectoryUrl else {
            fatalError()
        }
        
        do {
            let properties: [URLResourceKey] = [.localizedNameKey, .isDirectoryKey, .fileSizeKey, .isExcludedFromBackupKey]
            
            let currentContentUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: properties, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            for url in currentContentUrls {
                let content = Content(url: url)
                contents.append(content)
            }
            
            contents.sort { (lhs, rhs)-> Bool in
                if lhs.type == rhs.type {
                    // 이름 오름차순 정렬
                    return lhs.name.lowercased() < rhs.name.lowercased()
                }
                
                // 디렉토리부터 표시됨
                return lhs.type.rawValue < rhs.type.rawValue
            }
        } catch {
            print(error)
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let target = contents[indexPath.row]
        cell.imageView?.image = target.image
        
        switch target.type {
        case .directory:
            cell.textLabel?.text = "[\(target.name)]"
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .disclosureIndicator
        case .file:
            cell.textLabel?.text = target.name
            cell.detailTextLabel?.text = target.sizeString
            cell.accessoryType = .none
        
        }
        // 백업대상이 아니라면 secondart=y 대상이라면 기본컬러
        if target.isExcludedFromBackup {
            cell.textLabel?.textColor = .secondaryLabel
        } else {
            cell.textLabel?.textColor = .label
        }
        // 오른쪽텍스트컬러를 왼쪽과 똑같이
        cell.detailTextLabel?.textColor = cell.textLabel?.textColor
        
        return cell
    }
    
    
    
}


