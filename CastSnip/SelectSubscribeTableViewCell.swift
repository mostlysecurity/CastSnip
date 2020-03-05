//
//  PremiumTableViewCell.swift
//  CastSnip
//
//  Created by ewuehler on 3/2/19.
//  Copyright © 2019 Eric Wuehler. All rights reserved.
//

import UIKit
import StoreKit

class SelectSubscribeTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var purchaseButton: UIButton!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    var buyButtonHandler: ((_ product: SKProduct) -> Void)?
    
    var product: SKProduct? {
        didSet {
            guard let product = product else { return }
            
            nameLabel.text = product.localizedTitle
            descriptionLabel.text = product.localizedDescription
            
            if CastSnipProducts.store.isProductPurchased(product.productIdentifier) {
                priceLabel.text = "Purchased"
                purchaseButton.isHidden = true
            } else if CastSnipIAP.canMakePayments() {
                SelectSubscribeTableViewCell.priceFormatter.locale = product.priceLocale
                priceLabel.text = SelectSubscribeTableViewCell.priceFormatter.string(from: product.price)
                purchaseButton.isHidden = false
                purchaseButton.removeTarget(nil, action: nil, for: .allEvents)
                purchaseButton.addTarget(self, action: #selector(SelectSubscribeTableViewCell.buyButtonTapped(_:)), for: .touchUpInside)
            } else {
                priceLabel.text = "Not available"
                purchaseButton.isHidden = true
            }
        }
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        textLabel?.text = ""
//        detailTextLabel?.text = ""
//        accessoryView = nil
//    }
    
//    func newBuyButton() -> UIButton {
//        let button = UIButton(type: .system)
//        button.setTitleColor(tintColor, for: .normal)
//        button.setTitle("Buy", for: .normal)
//        button.addTarget(self, action: #selector(PremiumTableViewCell.buyButtonTapped(_:)), for: .touchUpInside)
//        button.sizeToFit()
//
//        return button
//    }
    
    @objc func buyButtonTapped(_ sender: AnyObject) {
        buyButtonHandler?(product!)
    }
}
