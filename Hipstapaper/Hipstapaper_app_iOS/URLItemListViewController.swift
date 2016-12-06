//
//  URLItemListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/4/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import IGListKit
import UIKit

class URLItemListViewController: UIViewController, IGListAdapterDataSource, IGListSingleSectionControllerDelegate {
    
    @IBOutlet private weak var collectionView: IGListCollectionView? {
        didSet {
            self.collectionView?.collectionViewLayout = UICollectionViewFlowLayout()
        }
    }
    private lazy var adapter: IGListAdapter = IGListAdapter(updater: IGListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    
    private let dataSource: DoubleSourcePersistenceType = CombinedURLItemSyncingController()
    private var sortedIDs = [String]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Hipstapaper"
        
        // configure bar button items
        let reloadBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reloadButtonTapped(_:)))
        reloadBarButtonItem.style = .done // I thought this made bar button items thicker, but it appears to make it thinner
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped(_:)))
        addBarButtonItem.style = .plain // I thought this made bar buttom items thinner, but it appears to make it thicker
        self.navigationItem.leftBarButtonItem = reloadBarButtonItem
        self.navigationItem.rightBarButtonItem = addBarButtonItem
        
        // configure IGListKit
        self.adapter.collectionView = self.collectionView
        self.adapter.dataSource = self
       
        // load the data from realm/cloudkit
        self.quickReload()
    }
    
    @objc private func reloadButtonTapped(_ sender: NSObject?) {
        self.fullReload()
    }
    
    @objc private func addButtonTapped(_ sender: NSObject?) {
        self.fullReload()
    }
    
    private func quickReload() {
        self.dataSource.sync(quickResult: { quick in
            self.sort(ids: self.dataSource.ids) { sortedIDs in
                DispatchQueue.main.async {
                    self.sortedIDs = sortedIDs
                    self.adapter.reloadData(completion: .none)
                }
            }
        }, fullResult: .none)
    }
    
    private func fullReload() {
        self.dataSource.sync(quickResult: .none, fullResult: { full in
            self.sort(ids: self.dataSource.ids) { sortedIDs in
                DispatchQueue.main.async {
                    self.sortedIDs = sortedIDs
                    self.adapter.reloadData(completion: .none)
                }
            }
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: .none, completion: { context in
            self.adapter.reloadData(completion: .none)
        })
    }
    
    private func sort(ids: Set<String>, completionHandler: (([String]) -> Void)?) {
        var results = [Result<URLItemType>]() {
            didSet {
                if results.count == ids.count {
                    let unsortedItems = results.mapSuccess()
                    let sortedItems = unsortedItems.sorted(by: { $0.0.modificationDate >= $0.1.modificationDate })
                    let sortedIDs = sortedItems.map({ $0.realmID })
                    completionHandler?(sortedIDs)
                }
            }
        }
        
        for id in ids {
            self.dataSource.readItem(withID: id, quickResult: { quick in
                results.append(quick)
            }, fullResult: .none)
        }
    }
    
    //MARK: - IGListAdapterDataSource
    
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return self.sortedIDs as [IGListDiffable]
    }
    
    func listAdapter(_ listAdapter: IGListAdapter, sectionControllerFor object: Any) -> IGListSectionController {
        let configureBlock = { (item: Any, cell: UICollectionViewCell) in
            guard let cell = cell as? URLItemCollectionViewCell, let itemID = item as? String else { return }
            cell.id = itemID
            self.dataSource.readItem(withID: itemID, quickResult: { quick in
                DispatchQueue.main.async {
                    switch quick {
                    case .error(let errors):
                        NSLog("DataLoadErrorForID: \(itemID) - Error: \(errors)")
                        cell.item = .none
                    case .success(let item):
                        cell.item = item
                    }
                }
            }, fullResult: .none)
        }
        
        let sizeBlock = { (item: Any, context: IGListCollectionContext?) -> CGSize in
            guard let context = context else { return CGSize() }
            return CGSize(width: context.containerSize.width, height: 75)
        }
        let sectionController = IGListSingleSectionController(nibName: URLItemCollectionViewCell.nibName,
                                                              bundle: .none,
                                                              configureBlock: configureBlock,
                                                              sizeBlock: sizeBlock)
        sectionController.selectionDelegate = self
        
        return sectionController
    }
    
    func emptyView(for listAdapter: IGListAdapter) -> UIView? { return nil }
    
    // MARK: - IGListSingleSectionControllerDelegate
    
    func didSelect(_ sectionController: IGListSingleSectionController) {
        let section = adapter.section(for: sectionController) + 1
        let alert = UIAlertController(title: "Section \(section) was selected \u{1F389}", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
