//
//  ViewController.swift
//  DiffableDataSourceDemo
//
//  Created by 杨帆 on 2020/5/29.
//  Copyright © 2020 杨帆. All rights reserved.
//

import UIKit


enum Section: CaseIterable {
    case main
}

class ViewController: UIViewController {
    
    let cityNames = ["北京", "南京", "西安", "杭州", "苏州", "南通", "南阳", "苏州", "泰山", "黄山", "广州", "芜湖", "巢湖", "锦州", "湖州", "北海", "海口",  "安庆", "安顺"]
    
    @IBOutlet weak var tableView: UITableView!
    
    var cities: [City] = []
    
var dataSource: UITableViewDiffableDataSource<Section, City>!

override func viewDidLoad() {
    super.viewDidLoad()
    
    for name in cityNames {
        cities.append(City(name: name))
    }
    
    dataSource = UITableViewDiffableDataSource
        <Section, City>(tableView: tableView) {
            (tableView: UITableView, indexPath: IndexPath,
            city: City) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = city.name
            return cell
    }
    
    dataSource.defaultRowAnimation = .fade
}
    
    
    // 刚开始需要显示所有数据
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        performSearch(searchQuery: nil)
    }
    
    func performSearch(searchQuery: String?) {
        let filteredCities: [City]
        
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            filteredCities = cities.filter { $0.contains(query: searchQuery) }
        } else {
            filteredCities = cities
        }
        
var snapshot = NSDiffableDataSourceSnapshot<Section, City>()

snapshot.appendSections([.main])

snapshot.appendItems(filteredCities, toSection: .main)

dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch(searchQuery: searchText)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let city = dataSource.itemIdentifier(for: indexPath) {
            print("选择了\(city.name)")
        }
    }
}
