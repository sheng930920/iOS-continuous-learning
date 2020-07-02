//
//  ViewController.swift
//  UICollectionViewBuildList
//
//  Created by 杨帆 on 2020/7/2.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var collectionView = makeCollectionView()
    private lazy var dataSource = makeDataSource()
    
    let cityNames = ["北京", "南京", "西安", "杭州", "苏州"]
    var firstCities: [City] = []
    var secondCities: [City] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        for name in cityNames {
            firstCities.append(City(name: name))
            secondCities.append(City(name: name))
        }
        
        collectionView.dataSource = dataSource
        view.addSubview(collectionView)
        
        updateList()
    }
}

extension ViewController {
    // 创建列表式UICollectionView
    func makeCollectionView() -> UICollectionView {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionView(frame: view.frame, collectionViewLayout: layout)
    }
}


extension ViewController {
    // 注册Cell
    func makeCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, City> {
        UICollectionView.CellRegistration { cell, indexPath, city in
            // Cell显示的内容
            var config = cell.defaultContentConfiguration()
            config.text = city.name
            config.secondaryText = city.name
            cell.contentConfiguration = config
            
            // 右侧滑动删除
            cell.trailingSwipeActionsConfiguration = UISwipeActionsConfiguration(
                actions: [UIContextualAction(
                    style: .destructive,
                    title: "Delete",
                    handler: { [weak self] _, _, completion in
                        self?.deleteCity(city: city, indexPath: indexPath)
                        self?.updateList()
                        
                        completion(true)
                    }
                )]
            )
            
            // 左侧滑动删除
            cell.leadingSwipeActionsConfiguration = UISwipeActionsConfiguration(
                actions: [UIContextualAction(
                    style: .destructive,
                    title: "Delete",
                    handler: { [weak self] _, _, completion in
                        self?.deleteCity(city: city, indexPath: indexPath)
                        self?.updateList()
                        
                        completion(true)
                    }
                )]
            )
            
            // AccessoryView
            cell.accessories = [.disclosureIndicator()]
        }
    }
}


extension ViewController {
    func deleteCity(city: City, indexPath: IndexPath) {
        if indexPath.section == 0  {
            firstCities.remove(at: firstCities.firstIndex(of: city)!)
        }
        else {
            secondCities.remove(at: secondCities.firstIndex(of: city)!)
        }
    }
}

extension ViewController {
    // 配置数据源
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, City> {
        let cellRegistration = makeCellRegistration()
        
        return UICollectionViewDiffableDataSource<Section, City>(
            collectionView: collectionView,
            cellProvider: { view, indexPath, item in
                view.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: item
                )
            }
        )
    }
}


enum Section: CaseIterable {
    case first
    case second
}

extension ViewController {
    func updateList() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, City>()
        snapshot.appendSections(Section.allCases)
        // 2个分组
        snapshot.appendItems(firstCities, toSection: .first)
        snapshot.appendItems(secondCities, toSection: .second)
        dataSource.apply(snapshot)
    }
}
