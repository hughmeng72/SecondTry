//
//  FlowDetailViewController.swift
//  PerkingOpera
//
//  Created by admin on 12/4/16.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss
import UIKit

class FlowDetailViewController: UITableViewController, XMLParserDelegate {
    
    @IBOutlet weak var flowNameLabel: UILabel!
    @IBOutlet weak var flowNoLabel: UILabel!
    @IBOutlet weak var depNameLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var createDateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var projectNameLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var amountLeftLabel: UILabel!
    @IBOutlet weak var amountBeingPaidProcurementLabel: UILabel!
    @IBOutlet weak var amountPaidProcurementLabel: UILabel!
    @IBOutlet weak var amountBeingPaidReimbursementLabel: UILabel!
    @IBOutlet weak var amountPaidReimbursementLabel: UILabel!
    
    var itemId: Int!
    
    private let soapMethod = "GetFlowDetail"
    
    private var elementValue: String?
    
    private var item: Flow?
    
    private var steps = [FlowStep]()
    
    private var attachments = [FlowDoc]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48
        
        guard let user = Repository.sharedInstance.user
            else {
                print("Failed to get user object")
                return
        }
        
        let parameters = "<token>\(user.token)</token>"
            + "<flowId>\(itemId!)</flowId>"
        
        let request = SoapHelper.getURLRequest(method: soapMethod, parameters: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("network error: \(error)")
                return
            }
            
            let parser = XMLParser(data: data)
            parser.delegate = self
            guard parser.parse() else {
                print("parsing error: \(parser.parserError)")
                return
            }
            
            // if we've gotten here, update the UI
            DispatchQueue.main.async {
                if self.item == nil {
                    let controller = UIAlertController(
                        title: "没有检索到相关数据",
                        message: "", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(
                        title: "Ok",
                        style: .cancel, handler: nil)
                    
                    controller.addAction(cancelAction)
                    
                    self.present(controller, animated: true, completion: nil)
                    
                    return
                }
                
                self.flowNameLabel.text = self.item?.flowName
                self.flowNoLabel.text = self.item?.flowNo
                self.depNameLabel.text = self.item?.depName
                self.creatorLabel.text = self.item?.creator
                self.createDateLabel.text = self.item?.createTime
                self.amountLabel.text = "\(self.item!.amount)"
                self.remarkLabel.text = self.item?.remark
                self.itemNameLabel.text = self.item?.itemName
                self.projectNameLabel.text = self.item?.projectName
                self.totalAmountLabel.text = "\(self.item!.totalAmount)"
                self.amountLeftLabel.text = "\(self.item!.amountLeft)"
                self.amountBeingPaidProcurementLabel.text = "\(self.item!.amountToBePaidProcurement)"
                self.amountPaidProcurementLabel.text = "\(self.item!.amountPaidProcurement)"
                self.amountBeingPaidReimbursementLabel.text = "\(self.item!.amountToBePaidReimbursement)"
                self.amountPaidReimbursementLabel.text = "\(self.item!.amountPaidReimbursement)"
                
                self.tableView.reloadData()
            }
        }
        
        task.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if item != nil && item?.attachments != nil {
                return item!.attachments!.count
            }
            else {
                return 0
            }
        case 1:
            if item != nil && item?.steps != nil {
                return item!.steps!.count
            }
            else {
                return 0
            }
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "附件" : "审批进度"
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentCell", for: indexPath)
            
            let item = attachments[indexPath.row]
            
            cell.textLabel?.text = item.fileName
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath)
            
            let item = steps[indexPath.row]
            
            cell.textLabel?.text = item.stepName
            cell.detailTextLabel?.text = item.description
        }
        
        return cell
    }
    
    // MARK: - XML Parser
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "\(soapMethod)Result" {
            elementValue = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        elementValue? += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "\(soapMethod)Result" {
            print(elementValue ?? "Not got any data from ws.")
            
            let result = convertStringToDictionary(text: elementValue!)
            print(result ?? "Not got any data from ws.")
            
            guard let resultObject = ResponseResultList<Flow>(json: result!) else {
                print("DECODING FAILURE :(")
                return
            }
            
            self.item = resultObject.list[0]
            
            if let a = self.item?.attachments {
                self.attachments = a
            }
            
            if let s = self.item?.steps {
                self.steps = s
            }
            
            elementValue = nil;
        }
    }
    
    func convertStringToDictionary(text: String) -> JSON? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? JSON
            } catch let error as NSError {
                print(error)
            }
        }
        
        return nil
    }
    
}
