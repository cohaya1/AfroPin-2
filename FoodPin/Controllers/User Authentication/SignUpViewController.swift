//
//  SignUpViewController.swift
//  FoodPin
//
//  Created by Makaveli Ohaya on 5/25/20.
//  Copyright © 2020 Makaveli Ohaya. All rights reserved.
//
import FirebaseAuth
import UIKit
import Firebase
class SignUpViewController: UIViewController {
    @IBOutlet weak var firstNameTextField: UITextField!
       
       @IBOutlet weak var lastNameTextField: UITextField!
       
       @IBOutlet weak var emailTextField: UITextField!
       
       @IBOutlet weak var passwordTextField: UITextField!
       
       @IBOutlet weak var signUpButton: UIButton!
       
       @IBOutlet weak var errorLabel: UILabel!
    var spinner = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
     setUpElements()
        // Do any additional setup after loading the view.
    }
    func setUpElements() {
       
           // Hide the error label
           errorLabel.alpha = 0
       
           // Style the elements
           Utilities.styleTextField(firstNameTextField)
           Utilities.styleTextField(lastNameTextField)
           Utilities.styleTextField(emailTextField)
           Utilities.styleTextField(passwordTextField)
           Utilities.styleFilledButton(signUpButton)
       }
    func validateFields() -> String? {
           
           // Check that all fields are filled in
           if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
               lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
               emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
               passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
               
               return "Please fill in all fields."
           }
           
           // Check if the password is secure
           let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
           
           if Utilities.isPasswordValid(cleanedPassword) == false {
               // Password isn't secure enough
               return "Please make sure your password is at least 8 characters, contains a special character and a number."
           }
           
           return nil
       }
       
    
@IBAction func signUpTapped(_ sender: Any) {
    spinner.style = .gray
           spinner.hidesWhenStopped = true
           view.addSubview(spinner)
           
           // Define layout constraints for the spinner
           spinner.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([ spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150.0),
                                         spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
           
           // Activate the spinner
           spinner.startAnimating()
    // Validate the fields
            let error = validateFields()
            
            if error != nil {
                
                // There's something wrong with the fields, show error message
                showError(error!)
                spinner.stopAnimating()
            }
            else {
                
                // Create cleaned versions of the data
                let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Create the user
                Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                    
                    // Check for errors
                    if err != nil {
                       
                        // There was an error creating the user
                        self.showError("Error creating user")
                         self.spinner.stopAnimating()
                    }
                    else {
                        
                        // User was created successfully, now store the first name and last name
                        let db = Firestore.firestore()
                        
                        db.collection("users").addDocument(data: ["firstname":firstName, "lastname":lastName, "uid": result!.user.uid ]) { (error) in
                             self.spinner.stopAnimating()
                            if error != nil {
                                // Show error message
                                self.showError("Error saving user data")
                                 self.spinner.stopAnimating()
                            }
                        }
                        
                        // Transition to the home screen
                        self.transitionToHome()
                         self.spinner.stopAnimating()
                    }
                    
                }
                
                
                
            }
        }
        
        func showError(_ message:String) {
            
            errorLabel.text = message
            errorLabel.alpha = 1
        }
        
        func transitionToHome() {
            
            let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController)
            self.navigationController?.pushViewController(homeViewController!, animated: true)
            view.window?.rootViewController = homeViewController
            view.window?.makeKeyAndVisible()
            
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


