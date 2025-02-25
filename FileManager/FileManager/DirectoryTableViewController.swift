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
                
                do {
                    let url = contents[indexPath.row].url
                    // 정상접근할수 있으면 ture 리턴
                    let reachable = try url.checkResourceIsReachable()
                    if !reachable {
                        return false
                    }
                } catch {
                    print(error)
                    return false
                }
                
                
                
                // return이 true이면 실행이니까
                return contents[indexPath.row].type == .directory
            }
        }
        
    
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 실행됬을때 루트디렉토리 위치 변수에 저장
        if currentDirectoryUrl == nil {
            currentDirectoryUrl = URL(fileURLWithPath: NSHomeDirectory())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshContents()
        updateNavigationTitle()
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
        
        // 메소드 실행 끝나면 항상 테이블뷰 업데이트
        defer {
            tableView.reloadData()
        }
        
        guard let url = currentDirectoryUrl else {
            fatalError("empry url")
        }
        
        do {
            let properties: [URLResourceKey] = [.localizedNameKey, .isDirectoryKey, .fileSizeKey, .isExcludedFromBackupKey]
            
            // 특정 폴더의 파일 목록 가져오기
            let currentContentUrls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: properties, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) // 숨겨진 파일들 결과에서 제외
            
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
        
        if contents.isEmpty {
            let label = UILabel(frame: .zero)
            label.text = "빈 디렉토리"
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
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
            cell.textLabel?.text = "[ \(target.name) ]"
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .disclosureIndicator
        case .file:
            cell.textLabel?.text = target.name
            cell.detailTextLabel?.text = "\(target.size)"
            cell.accessoryType = .none
        }
        
        if target.isExcludedFromBackup {
            cell.textLabel?.textColor = .secondaryLabel
        } else {
            cell.textLabel?.textColor = .label
        }
        
        cell.detailTextLabel?.textColor = cell.textLabel?.textColor
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
