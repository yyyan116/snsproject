//
//  MessageContents5.swift
//  SNSProjectApp
//
//  Created by sphinx on 12/10/18.
//

import UIKit
import Alamofire

class MessageContents5: UIViewController {

    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var messageContent: UITextView!
    
    @IBOutlet weak var myImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTitle.text = messageTitles5[myIndex5]
        messageContent.text = messageContents5[myIndex5]
        messageContent.isEditable = false
        
        
        Alamofire.request(MyVariables.url + "/message_media?mid=" + messageMID5[myIndex5], method: .get, encoding: URLEncoding.default)
            .responseData{ response in
                
                print(response)
                print(response.data!)
                
                do{
                    let json = try JSON(data: response.data!)
                    let messages = json.array!
                    if(messages != []){
                        print("messages != []")
                        for each in messages{
                            print("in each")
                            if let decodedData = Data(base64Encoded: each["media"].stringValue, options: .ignoreUnknownCharacters) {
                                let image1 = UIImage(data: decodedData)
                                let test1:UIImageView = UIImageView(image: image1)
                                //self.myImageView = test1
                                test1.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
                                self.myImageView.addSubview(test1)
                            }
                        }
                    }
                }
                catch{
                    print("getData get JSON Failed")
                }
        }
    }

}
