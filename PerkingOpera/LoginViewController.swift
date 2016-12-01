//
//  LoginViewController.swift
//  PerkingOpera
//
//  Created by admin on 28/11/2016.
//  Copyright © 2016 Wayne Meng. All rights reserved.
//

import Gloss
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, XMLParserDelegate {

    @IBOutlet weak var UserName: UITextField!
    @IBOutlet weak var Password: UITextField!

    var elementValue: String?
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss keyboard when user click anyplace else
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.view.endEditing(true)
//        
//        return true
//    }
    
    @IBAction func Login(_ sender: Any) {
        let userName = "manager"
        let password = "123456"
        
//        let userName = UserName.text!
//        let password = Password.text!
        
        let bodyString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" +
            "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" " +
            "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">" +
            "<soap:Body>" +
            "<GetTokenByUserNameAndPassword xmlns=\"http://test.freight-track.com/\">" +
            "<userName>\(userName)</userName>" +
            "<password>\(password)</password>" +
            "</GetTokenByUserNameAndPassword>" +
            "</soap:Body>" +
        "</soap:Envelope>"
        
        var request = URLRequest(url: URL(string: "http://test.freight-track.com/WebService/Perkingopera.asmx")!)
        request.httpMethod = "POST"
        request.httpBody = bodyString.data(using: .utf8)
        request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("http://test.freight-track.com/GetTokenByUserNameAndPassword", forHTTPHeaderField: "SOAPAction")
        
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
                if let user2 = self.user, user2.error.result != 1 {
                    let controller = UIAlertController(
                        title: self.user!.error.errorInfo,
                        message: "", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(
                        title: "Ok",
                        style: .cancel, handler: nil)
                    
                    controller.addAction(cancelAction)
                    
                    self.present(controller, animated: true, completion: nil)
                    
                    return
                }
                
                self.performSegue(withIdentifier: "showMain", sender: nil)
            }
        }
        task.resume()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "GetTokenByUserNameAndPasswordResult" {
            elementValue = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        elementValue? += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "GetTokenByUserNameAndPasswordResult" {
            print(elementValue ?? "Not got any data from ws.")

            let result = convertStringToDictionary(text: elementValue!)
           
            guard let user = User(json: result!) else {
                print("DECODING FAILURE :(")
                return
            }
            
            self.user = user;
            
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
