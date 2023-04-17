//
//  ViewController.swift
//  API
//
//  Created by student on 3/1/23.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var searchResponse = [Dog]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        print(NSLocalizedString("tableview_title", comment: ""))
        makeAPICall { searchResponse in
            self.searchResponse = searchResponse
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let item = searchResponse[indexPath.row]
        cell.textLabel?.text = "\(item.name): \(item.bredFor), located at: \(item.origin)"
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResponse.count
    }
    
    func makeAPICall(completion: @escaping ([Dog]) -> Void) {
        print("start API call")
        
        let domain = "https://api.thedogapi.com/v1/"
        let searchQuery = "breeds?limit=10&page=0"
        
        
        guard let url = URL(string:"\(domain)\(searchQuery)") else {
            completion([])
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            var searchResponse = [Dog]()
            defer {completion(searchResponse)}
            if let error = error {
                print("Error with API call: \(error)")
                return
            }
//            200 means that it's connected
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
            else {
                print("Error with the response (\(String(describing: response))")
                return
            }
//            this code returns a long unstructured string
//            if let data = data,
//               let dataString = String(data: data, encoding: String.Encoding.utf8){
//                print(dataString)
//            }
//
            if let data = data{
                do{
                    let response = try JSONDecoder().decode([Dog].self, from: data)
                    print("success")
                    searchResponse = response
                    print(response.first?.name)
                }catch let error{
                    print(error)
                    print("Something is wrong with decoding, probably.")
                }
            }
        }
        task.resume()
    }
}

struct Dog: Codable {
    let name: String
    let bredFor: String
    let origin: String
    
//      just type "CodingKey" for this to show
    enum CodingKeys: String, CodingKey {
        case name
        case bredFor = "bred_for"
        case origin
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.bredFor = try container.decodeIfPresent(String.self, forKey: .bredFor) ?? "No info"
        self.origin = try container.decodeIfPresent(String.self, forKey: .origin) ?? "Unknown"
    }
}
