//
//  AddNewTemplateViewController.swift
//  CredenceSchool
//
//  Created by IE14 on 28/05/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import UIKit
import RichEditorView

protocol AddNewTemplateDelegate: AnyObject {
   func refreshTemplates()
}

class AddNewTemplateViewController: UIViewController {
    
    @IBOutlet weak var templateTitleTextField: UITextField!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    @IBOutlet weak var editorView: RichEditorView!
    @IBOutlet weak var toolBar: RichEditorToolbar!
    var isComeForEdit: Bool = false
    var templates: Template?
    weak var delegate: AddNewTemplateDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        topHeaderView.title = "Add New Template"
        setRichToolbarProporties()
        if isComeForEdit {
            setData()
        }
    }
    
    func setData() {
        topHeaderView.title = "Edit Template"
        editorView.html = templates?.templateMessage ?? ""
        templateTitleTextField.text = templates?.templateName ?? ""
    }
    
    func setRichToolbarProporties(){
        toolBar.tintColor = UIColor.white
        toolBar.barTintColor = UIColor(named: "9CDAE7")
        toolBar.options = RichEditorDefaultOption.all
        toolBar.delegate = self
        toolBar.editor = self.editorView
        editorView.placeholder = "Compose Email"
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        validateAndSubmitTemplate()
    }

    func validateAndSubmitTemplate() {
        guard let title = templateTitleTextField.text, !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert("Template title is required.")
            return
        }

        let body = editorView.contentHTML
        if body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || body == "<br>" {
            showAlert("Template body cannot be empty.")
            return
        }

        if isComeForEdit {
            editTemplateData()
        } else {
            addTemplateData()
        }
    }
    
    func showAlert(_ message: String) {
        SweetAlert().showAlert(
            "Validation Failed",
            subTitle: message,
            style: .warning,
            buttonTitle: "OK",
            buttonColor: UIColor.systemRed
        )
    }
}

extension AddNewTemplateViewController: RichEditorToolbarDelegate {
    
    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }
    
    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        // toolbar.editor?.insertImage("https://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22", alt: "Gravatar")
        
        //
    }
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        //        if toolbar.editor?.hasRangeSelection == true {
        //            //     toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
        //        }
    }
    
    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }
    
}


extension AddNewTemplateViewController: TopHeaderDelegate {
    
    func backButtonClicked(_ button: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func searchButtonClicked(_ button: UIButton) {
        
    }
    
    func secondRightButtonClicked(_ button: UIButton) {
        
    }
    
    func thirdRightButtonClicked(_ button: UIButton) {
        
    }
}

extension AddNewTemplateViewController{
    
    func getUdidOfDevide() -> String{
        return  UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    func editTemplateData() {
        let userId  = UserDefaultsManager.manager.getUserId()
        let bodyText = self.editorView.contentHTML
        var dictionary = [String:Any]()
        dictionary["UserId"] = userId
        dictionary["client_ip"] = getUdidOfDevide()
        dictionary["TempName"] = templateTitleTextField.text
        dictionary["TempMsg"] = bodyText
        dictionary["TempId"] = templates?.templateID ?? ""
        let url = APIUrls().editTemplate
        self.startLoadingAnimation()
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "",typingCountVal: typingCount, requestParameters: dictionary) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let status = result["StatusCode"] as? Int,
                   status == 1 {
                    self.delegate?.refreshTemplates()
                    self.navigationController?.popViewController(animated: true)
                }
                else{
                    self.showAlert("Failed to edit template. Please try again.")
                }
            }
        }
    }
    
    func addTemplateData() {
        let userId  = UserDefaultsManager.manager.getUserId()
        let bodyText = self.editorView.contentHTML
        var dictionary = [String:Any]()
        dictionary["UserId"] = userId
        dictionary[PasswordChange.client_ip] = getUdidOfDevide()
        dictionary["tempname"] = templateTitleTextField.text
        dictionary["tempmsg"] = bodyText
        let url = APIUrls().addTemplate
        self.startLoadingAnimation()
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                if let message = result["status"] as? Int,
                      message == 202 {
                    self.delegate?.refreshTemplates()
                    self.navigationController?.popViewController(animated: true)
                }
                else{
                    self.showAlert("Failed to add template. Please try again.")
                }
            }
        }
    }
}
