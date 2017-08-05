//
//  ViewController.swift
//  SeeFood
//
//  Created by Mariecris Banez on 14/07/2017.
//  Copyright © 2017 Mariecris Banez. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social
import TwitterKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    let apiKey = ibmWatsonAPIkey
    let version = ibmAPIversion
    
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var resultLabel: UILabel!

    @IBOutlet weak var twitterImage: UIImageView!
    
    @IBOutlet weak var shareButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isHidden = true
        twitterImage.isHidden = true
        imagePicker.delegate = self
              
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            imageView.image = image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            
            let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            
            
            let imageData = UIImageJPEGRepresentation(image, 0.01)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let fileURL = documentsURL.appendingPathComponent("tempImage.jpg")
            
            try? imageData?.write(to: fileURL, options: [])
            
            visualRecognition.classify(imageFile: fileURL, success: {
                (classifiedImages) in
                let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                self.classificationResults = []
                
                
                for index in 0..<classes.count {
                    self.classificationResults.append(classes[index].classification)
                }
                print(self.classificationResults)
                
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                    self.twitterImage.isHidden = false
                    
                    self.navigationItem.title = "Image Recognized!"
                    self.navigationController?.navigationBar.barTintColor = UIColor.green
                    self.navigationController?.navigationBar.isTranslucent = true

                    self.resultLabel.layer.backgroundColor = UIColor(red: 0/255, green: 159/255, blue: 184/255, alpha: 1.0).cgColor
                    
                    self.resultLabel.text = "this image can be " + self.classificationResults[0] + ", " + self.classificationResults[1] + " or " + self.classificationResults[2]
                }
                
                
            })
            
            
        }else {
            print("There was an error picking an image")
        }
    }
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    

    
    @IBAction func shareTapped(_ sender: UIButton) {

        if (Twitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
            // App must have at least one logged-in user to compose a Tweet
  
            let image = imageView.image
            
            let composer = TWTRComposerViewController(initialText: "According to my app, " + self.resultLabel.text! , image: image, videoURL: nil)
            
            composer.delegate = self as? TWTRComposerViewControllerDelegate
            
            present(composer, animated: true, completion: nil)
        } else {
            // Log in, and then check again
            Twitter.sharedInstance().logIn { session, error in
                if session != nil { // Log in succeeded
                    let composer = TWTRComposerViewController.emptyComposer()
                    self.present(composer, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "No Twitter Accounts Available", message: "You must log in before presenting a composer.", preferredStyle: .alert)
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
        
        
        
        
        
        
        
    
        
    }
    
    
    
    

    


}

