//
//  Picker.swift
//  DoxMed
//
//  Created by Veena on 8/26/15.
//  Copyright (c) 2015 inapp. All rights reserved.
//

import UIKit
import Foundation

enum PickerType : NSInteger {
    case picker
    case datePicker
    case timePicker
    case textField
}

@objc protocol PickerDelegate {
    @objc optional func pickerSelector(_ selectedRow:Int)
    @objc optional func pickerSelected(_ picker: Picker,isFirst: Bool)
    @objc optional func pickerEditingDidBegin(_ picker:Picker)
    @objc optional func pickerEditingDidEnd(_ picker:Picker)
    @objc optional func selectedRow(_ picker:Picker)
    @objc optional func noDataFounded()
}

protocol DidSelectCategoryProtocol
{
    func didSelectCategoryAction(_ category : String,tag:NSInteger)
}

//@IBDesignable
class Picker: UIView , UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
  
    var delegate : PickerDelegate?
    var delegateCatgeory : DidSelectCategoryProtocol?
    var selectedIndex : Int?
    var inputIdArray =  [Int]()
    var selectedValue = ""
    var selectedTagValue = 0

    @IBOutlet weak var normalTextField: UITextField!
    @IBOutlet weak var pickerContainer: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var pickerButton: UIButton!
    @IBOutlet weak var pickerTextField: UITextField!

    
    var maximumDate : Date? {
        didSet{
           setMaximumDate()
        }
    }
    
    var minimumDate : Date? {
        didSet{
            setMinimumDate()
        }
    }

    
    var dropDownItemsArray : [String] = []
    var pickerType : PickerType = .picker{
        didSet{
            setTextField()
        }
    }
    var isPicker:Bool = true{
        didSet{
            pickerButton.isHidden = !isPicker
        }
    }
    
    @IBInspectable var placeholder:String = ""{
        didSet{
            if pickerType == .textField{
                normalTextField.placeholder = placeholder
            }
            else{
                pickerTextField.placeholder = placeholder
            }
        }
    }
    @IBInspectable var showDropdown:Bool = true{
        didSet{
            pickerButton.isHidden = !showDropdown
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewForXib()        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewForXib()
    }
    
    func setupViewForXib()
    {
        containerView = loadFromNib()
        containerView.frame = bounds
        containerView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(containerView)
    }
    func loadFromNib() ->UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "Picker", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    class func instanceFromNib() ->UIView {
        let nib = UINib(nibName: "Picker", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    override func awakeFromNib() {
        setTextField()
        
    }
    
    @IBAction func pickerTextFieldAction(_ sender: UITextField) {
    
    }
    @IBAction func pickerAction(_ sender: UIButton) {
        if pickerTextField.isFirstResponder{
//            pickerTextField.resignFirstResponder()
        }
        else{
            pickerTextField.becomeFirstResponder()
        }
    }
    
    
    func setTextField() {
        normalTextField.isHidden = true
        pickerContainer.isHidden = false
        
        if pickerType == .picker {
            setPicker()
        }
        else if pickerType == .datePicker {
            setDatePicker()
        }
        else if pickerType == .timePicker {
            setTimePicker()
        }
        else if pickerType == .textField{
            setNormalTextField()
        }
    }
    func setMaximumDate(){
        if let datePicker = pickerTextField.inputView as? UIDatePicker {
           datePicker.maximumDate =  maximumDate
        }
    }
    
    func setMinimumDate(){
        
        if let datePicker = pickerTextField.inputView as? UIDatePicker {
            datePicker.minimumDate =  minimumDate
        }
    }
    
    func setNormalTextField(){
        normalTextField.delegate = self
        normalTextField.isHidden = false
        pickerContainer.isHidden = true
        
    }
    func setPicker(){
        
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.tintColor = UIColor.white
        picker.backgroundColor = UIColor.white
        
        let toolBar = UIToolbar (frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 30))
        toolBar.barStyle = UIBarStyle.default   
        toolBar.tintColor = UIColor.black
        toolBar.barTintColor = UIColor.white
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(Picker.doneAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
     
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        pickerTextField.delegate = self
        pickerTextField.inputView = picker
        pickerTextField.inputAccessoryView = toolBar
    }
    
    func doneAction(){
        if pickerType == .picker{
            if selectedValue != ""{
                pickerTextField.text = selectedValue
                pickerTextField.tag = selectedTagValue
              
                delegate?.pickerSelected?(self,isFirst: true)
            }
        }
        pickerTextField.resignFirstResponder()
    }
    
    
    //MARK:- DatePicker
    func setDatePicker(){
        let datePickerView  = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        pickerTextField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(Picker.handleDatePicker(_:)), for: UIControlEvents.valueChanged)
        
        
    }
    
    
    //MARK:- TimePicker
    func setTimePicker(){
        let timePickerView  = UIDatePicker()
        timePickerView.datePickerMode = UIDatePickerMode.time
        timePickerView.locale = Locale(identifier: "en_US")
        pickerTextField.inputView = timePickerView
        timePickerView.addTarget(self, action: #selector(Picker.handleTimePicker(_:)), for: UIControlEvents.valueChanged)
    }
    
    func pickerInputItems(_ pickerArray :NSArray) {
        
        if pickerArray.count > 0{
            dropDownItemsArray = pickerArray as! [String]
            let picker = pickerTextField.inputView as! UIPickerView
            picker.reloadAllComponents()
            pickerTextField.text = dropDownItemsArray[0]

        }
    }
    
    func pickerInputIDitems(_ idArray : [Int])
    {
        if idArray.count > 0
        {
            inputIdArray = idArray
        }
    }

    //Mark:- Picker Delegates Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dropDownItemsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dropDownItemsArray[row] as? String
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if dropDownItemsArray.count > 0{
            if inputIdArray.count > 0
            {
                selectedTagValue = inputIdArray[row]
            }
            selectedValue = dropDownItemsArray[row] as! String
            selectedIndex = row
//            delegate?.selectedRow!(self)
        }
    }
    
    //MARK:- DatePicker
    func handleDatePicker(_ sender : UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.dateFormat = "MM-dd-yyyy"
        pickerTextField.text = dateFormatter.string(from: sender.date)
    }
    
    //MARK:- TimePicker
    func handleTimePicker(_ sender : UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        pickerTextField.text = timeFormatter.string(from: sender.date)
    }
    
    //MARK:- TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        if pickerType != .textField{
            if pickerType != PickerType.datePicker && pickerType != PickerType.timePicker && dropDownItemsArray.count == 0 && isPicker{
                    pickerTextField.resignFirstResponder()
            }
            
                if dropDownItemsArray.count != 0 {
                    if pickerType == .picker{
                        textField.text = dropDownItemsArray[0] as? String
                        
                        if inputIdArray.count > 0{
                            textField.tag = inputIdArray[0]
                            textField.text = dropDownItemsArray[0] as? String
                        }
                    }
                }
                else if let datePicker = textField.inputView as? UIDatePicker{
                    if pickerType == .datePicker{
                        handleDatePicker(datePicker)
                    }
                    else if pickerType == .timePicker{
                        handleTimePicker(datePicker)
                    }
                }else{
                    
//                    return
                }
        }
        delegate?.pickerEditingDidBegin?(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.pickerEditingDidEnd?(self)
    }
    
}
/*class DropDownTextField:UITextField {
    override internal func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {        
        switch action {
        case #selector(NSObject.paste(_:)),#selector(NSObject.select(_:)), #selector(NSObject.selectAll(_:)),#selector(NSObject.copy(_:)),#selector(NSObject.cut(_:)) : return false
        default :break
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }
} */
