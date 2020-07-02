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

        // 第一次进来刷新
        updateList()
    }
}

extension ViewController {
    // 创建列表式UICollectionView
    func makeCollectionView() -> UICollectionView {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        // 列表布局
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
            // cell的内容通过contentConfiguration配置
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

            // 左侧滑动添加
            cell.leadingSwipeActionsConfiguration = UISwipeActionsConfiguration(
                actions: [UIContextualAction(
                    style: .normal,
                    title: "Add",
                    handler: { [weak self] _, _, completion in
                        self?.addCity(city: City(name: "芜湖"), indexPath: indexPath)
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
    // 删除数据
    func deleteCity(city: City, indexPath: IndexPath) {
        if indexPath.section == 0 {
            firstCities.remove(at: firstCities.firstIndex(of: city)!)
        } else {
            secondCities.remove(at: secondCities.firstIndex(of: city)!)
        }
    }

    // 增加数据
    func addCity(city: City, indexPath: IndexPath) {
        if indexPath.section == 0 {
            firstCities.append(city)
        } else {
            secondCities.append(city)
        }
    }
}

extension ViewController {
    // 配置数据源
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, City> {
        UICollectionViewDiffableDataSource<Section, City>(
            collectionView: collectionView,
            cellProvider: { view, indexPath, item in
                view.dequeueConfiguredReusableCell(
                    using: self.makeCellRegistration(),
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
        // 添加两个分组
        snapshot.appendSections(Section.allCases)
        // 分别往两个分组添加数据
        snapshot.appendItems(firstCities, toSection: .first)
        snapshot.appendItems(secondCities, toSection: .second)
        dataSource.apply(snapshot)
    }
}
