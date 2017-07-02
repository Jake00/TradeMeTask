//
//  ListedItemDetailViewController.swift
//  JakesTradeMe
//
//  Created by Jake Bellamy on 2/07/17.
//  Copyright © 2017 Jake Bellamy. All rights reserved.
//

import UIKit
import BoltsSwift

class ListedItemDetailViewController: UIViewController, Loadable {
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerSubtitleLabel: UILabel!
    @IBOutlet weak var headerIdLabel: UILabel!
    @IBOutlet var loadingViews: [UIView]!
    
    var listedItemDetail: ListedItemDetail?
    
    var isLoading = false {
        didSet {
            loadingViews.forEach { $0.isHidden = !isLoading }
        }
    }
    
    // MARK: - Init
    
    let listedItemId: Int64
    let provider: RemoteDataProvider
    
    init(provider: RemoteDataProvider, listedItemId: Int64) {
        self.listedItemId = listedItemId
        self.provider = provider
        super.init(nibName: String(describing: ListedItemDetailViewController.self), bundle: nil)
    }
    
    @available(*, unavailable, message: "init(coder:) is not available. Use init(provider:) instead.")
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not available. Use init(provider:) instead.")
    }
    
    // MARK: - View controller
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if listedItemDetail == nil, !isLoading {
            updateViews()
            fetchListedItem()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutMargins.top = topLayoutGuide.length
    }
    
    // MARK: - UI updates
    
    func updateViews() {
        headerTitleLabel.text = listedItemDetail?.title
        headerSubtitleLabel.text = listedItemDetail?.subtitle
        let idFormat = NSLocalizedString("listed_item_detail.id_format",
                                         value: "Listing id: %ld",
                                         comment: "Listed item format for displaying the id. eg. 'Listing id: '5741282")
        headerIdLabel.text = listedItemDetail.map { String.localizedStringWithFormat(idFormat, $0.id) }
        headerImageView.setImage(url: listedItemDetail?.photos.first?.fullSize)
    }
    
    // MARK: - Fetching
    
    func fetchListedItem() {
        fetch(provider.getListedItem(id: listedItemId))
            .continueOnSuccessWith(.mainThread) { listedItemDetail in
                self.listedItemDetail = listedItemDetail
                self.updateViews()
        }
    }
}
