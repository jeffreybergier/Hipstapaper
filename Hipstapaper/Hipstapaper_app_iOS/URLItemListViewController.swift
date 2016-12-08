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
        self.quickReload(sortedBy: .modificationDate, ascending: false)
    }
    
    @objc private func reloadButtonTapped(_ sender: NSObject?) {
        self.fullReload(sortedBy: .modificationDate, ascending: false)
    }
    
    @objc private func addButtonTapped(_ sender: NSObject?) {
        
    }
    
    private func quickReload(sortedBy: URLItem.Sort, ascending: Bool) {
        self.dataSource.sync(sortedBy: sortedBy, ascending: ascending, quickResult: { quick in
            DispatchQueue.main.async {
                switch quick {
                case .success(let sortedIDs):
                    self.sortedIDs = sortedIDs
                case .error(let errors):
                    self.sortedIDs = []
                    NSLog("Errors During Quick Update: \(errors)")
                }
                self.adapter.reloadData(completion: .none)
            }
        }, fullResult: .none)
    }
    
    private func fullReload(sortedBy: URLItem.Sort, ascending: Bool) {
        self.dataSource.sync(sortedBy: .modificationDate, ascending: false, quickResult: .none, fullResult: { full in
            DispatchQueue.main.async {
                switch full {
                case .success(let sortedIDs):
                    self.sortedIDs = sortedIDs
                case .error(let errors):
                    self.sortedIDs = []
                    NSLog("Errors During Quick Update: \(errors)")
                }
                self.adapter.reloadData(completion: .none)
            }

        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: .none, completion: { context in
            self.adapter.reloadData(completion: .none)
        })
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
        let section = self.adapter.section(for: sectionController)
        let id = self.sortedIDs[section]
        self.dataSource.readItem(withID: id, quickResult: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let item):
                    let webVC = URLItemWebViewController(urlItem: item)
                    self.navigationController?.pushViewController(webVC, animated: true)
                case .error(let errors):
                    NSLog("Unable to open Item with ID: \(id), Error: \(errors)")
                }
            }
        }, fullResult: .none)
    }
    
}
