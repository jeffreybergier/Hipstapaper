//
//  URLItemListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/4/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import UIKit

class URLItemListViewController: UIViewController {
    
    @IBOutlet private weak var collectionView: UICollectionView?
    fileprivate let dataSource: DoubleSourcePersistenceType = CombinedURLItemSyncingController()
    fileprivate var sortedIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.quickReload()
    }
    
    @IBAction private func reloadButtonTapped(_ sender: NSObject?) {
        self.fullReload()
    }
    
    private func quickReload() {
        self.dataSource.sync(quickResult: { quick in
            DispatchQueue.main.async {
                self.sortedIDs = Array(self.dataSource.ids)
                self.collectionView?.reloadData()
            }
        }, fullResult: .none)
    }
    
    private func fullReload() {
        self.dataSource.sync(quickResult: .none, fullResult: { full in
            DispatchQueue.main.async {
                self.sortedIDs = Array(self.dataSource.ids)
                self.collectionView?.reloadData()
            }
        })
    }
}

extension URLItemListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sortedIDs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "URLItemCell", for: indexPath)
        let castedCell = cell as? URLItemCollectionViewCell
        let id = self.sortedIDs[indexPath.row]
        castedCell?.id = id
        self.dataSource.readItem(withID: id, quickResult: { quick in
            DispatchQueue.main.async {
                switch quick {
                case .error(let errors):
                    NSLog("Error Loading Item With ID: \(id): Error: \(errors)")
                    castedCell?.id = .none
                    castedCell?.urlItem = .none
                case .success(let item):
                    castedCell?.urlItem = item
                }
            }
        
        }, fullResult: .none)
        return cell
    }
}

extension URLItemListViewController: UICollectionViewDelegate {
    
}
