//
//  ViewController.swift
//  InAppPurchase
//
//  Created by Sergei Romanchuk on 15.07.2021.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController {
    
    // MARK: - Produc ID example "com.apple.InAppPurchase.PremiumInAppPurchase"
    private let productID = "com.yourbundle.appname.referancename"
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate which is send payment request =
        SKPaymentQueue.default().add(self)
        
        if self.isPurchase() {
            self.showPremiumQuotes()
        }
    }

    // MARK: - Table view data source methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isPurchase() ? quotesToShow.count : quotesToShow.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCellIdentifier", for: indexPath)

        if indexPath.row < quotesToShow.count {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.textLabel?.numberOfLines = .zero
            cell.textLabel?.lineBreakMode = .byWordWrapping
            cell.textLabel?.textColor = .black
            cell.accessoryType = .none
        } else {
            cell.textLabel?.text = "But more quotes"
            cell.textLabel?.textColor = .cyan
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    // MARK: - Table view delegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
            self.buyPremiumAccess()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - In-App Purchase Methods
    
    private func buyPremiumAccess() {
        if SKPaymentQueue.canMakePayments() {
            // You can make payments
            
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = self.productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            // You can not make payments
            print("User can't make payments")
        }
    }
    
    private func showPremiumQuotes() {
        UserDefaults.standard.set(true, forKey: productID)
        self.quotesToShow.append(contentsOf: premiumQuotes)
        self.tableView.reloadData()
    }
    
    private func isPurchase() -> Bool {
        let purchaseStatus = UserDefaults.standard.bool(forKey: self.productID)
        
        if purchaseStatus {
            print("Previously purchased")
        } else {
            print("Never purchased")
        }
        
        return purchaseStatus
    }

    // MARK: - UI Action methods
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

}

extension QuoteTableViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: do {
                
            }
            case .purchased: do {
                print("Transaction success!")
                
                self.showPremiumQuotes()

                SKPaymentQueue.default().finishTransaction(transaction)
            }
            case .failed: do {
                print("Faild")
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    print("Transaction faild: \(errorDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            case .restored: do {
                self.showPremiumQuotes()
                // or -> self.navigationItem.setRightBarButton(nil, animated: true)
                self.navigationItem.rightBarButtonItem = nil
                SKPaymentQueue.default().finishTransaction(transaction)
            }
            case .deferred: do {
                
            }
            @unknown default: do {
                
            }
            }
        }
    }
    
}
