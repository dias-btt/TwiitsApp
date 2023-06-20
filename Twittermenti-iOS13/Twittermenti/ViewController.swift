import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    let swifter = Swifter(consumerKey: "WToyfi3RlB8AsI4GLHxVGIOFf", consumerSecret: "udjbcr4cz72MsumeU6DMN1OiAp1CWO3zgn61pwEAw35sh3c24U")

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func predictPressed(_ sender: Any) {
        if let searchText = textField.text{
            swifter.searchTweet(using: searchText, lang: "en", count: 100, tweetMode: .extended, success: {(results, metaData) in
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0...100{
                    if let tweet = results[i]["full_text"].string{
                        let tweetClassified = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetClassified)
                    }
                }
                
                do{
                    let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
                    var scoreOfSentiment = 0
                    for pred in predictions{
                        if pred.label == "Pos"{
                            scoreOfSentiment += 1
                        } else if pred.label == "Neg"{
                            scoreOfSentiment -= 1
                        }
                    }
                    
                    if scoreOfSentiment >= 20{
                        self.sentimentLabel.text = "🤩"
                    } else if scoreOfSentiment > 10{
                        self.sentimentLabel.text = "🙂"
                    } else if scoreOfSentiment == 0{
                        self.sentimentLabel.text = "😐"
                    } else if scoreOfSentiment < -10{
                        self.sentimentLabel.text = "🙁"
                    } else if scoreOfSentiment < -20{
                        self.sentimentLabel.text = "😠"
                    }
                } catch {
                    print("Error predicting Tweets")
                }
            }) { error in
                print("Error with Twitter API request \(error)")
            }
        }
    
    }
    
}

