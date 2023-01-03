import UIKit

var html = NSAttributedString()

class PasteTextViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate{
    
    @IBOutlet weak var СharacterNumLabel: UILabel!
    @IBOutlet weak var PlaceholderTextView: UITextView!
    @IBOutlet weak var PasteButton: UIButton!
    @IBOutlet weak var TitleTextField: UITextField!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var BackView: UIView!
    
    weak var delegate:OkDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        СharacterNumLabel.text = "0 of 15 characters"
        СharacterNumLabel.textColor = .gray
        
        PlaceholderTextView.delegate = self
        PlaceholderTextView.layer.cornerRadius = 10
        PlaceholderTextView.layer.borderWidth = 0.5
        PlaceholderTextView.layer.borderColor = UIColor.systemGray4.cgColor
        
        TitleTextField.delegate = self
        TitleTextField.layer.cornerRadius = 5
        TitleTextField.layer.borderWidth = 0.5
        TitleTextField.layer.borderColor = UIColor.systemGray4.cgColor
        
        let tapBackView = UITapGestureRecognizer(target: self, action: #selector(self.Back))
        BackView.addGestureRecognizer(tapBackView)
        
        let tapSaveButton = UITapGestureRecognizer(target: self, action: #selector(self.Save))
        SaveButton.addGestureRecognizer(tapSaveButton)
        
        let tapPasteButton = UITapGestureRecognizer(target: self, action: #selector(self.Paste))
        PasteButton.addGestureRecognizer(tapPasteButton)
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tapView)
        
        TitleTextField.addTarget(self, action: #selector(PasteTextViewController.textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
        СharacterNumLabel.text = String(textField.text!.count) + " of 15 characters"
        
        if ((TitleTextField.text!.count <= 15)){
            СharacterNumLabel.textColor = .gray
            textField.layer.borderColor = UIColor.systemGray4.cgColor
        }else{
            textField.layer.borderColor = UIColor.red.cgColor
            СharacterNumLabel.textColor = .red
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if ((textView.textColor?.accessibilityName == "black") && (textView.text != "")){
            textView.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
    
    @objc
    private func Back(){
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc private func Save(){
        
        var NumOfErrors = 0
        
        if ((TitleTextField.textColor?.accessibilityName == "gray") || (TitleTextField.text == "") || (TitleTextField.text!.count > 15)){
            TitleTextField.layer.borderColor = UIColor.red.cgColor
            NumOfErrors += 1
        }
        
        if ((PlaceholderTextView.textColor?.accessibilityName == "gray") || (PlaceholderTextView.text == "")){
            PlaceholderTextView.layer.borderColor = UIColor.red.cgColor
            NumOfErrors += 1
        }
        
        if NumOfErrors == 0{
            
            let title = TitleTextField.text
            let text = PlaceholderTextView.text
            
            let dict = ["title": title!, "type": "text", "text" : text!] as [String : String]
            
            if data.contains(dict) {
                AlertCopy()
            }else{
                data.append(dict)
                UserDefaults.standard.set(data, forKey: "data")
                
                dismiss(animated: true, completion: nil)
                delegate?.Ok("Ok")
            }
            
        }
        
    }
    
    @objc private func Paste(){
        
        PlaceholderTextView.textColor = .label
        PlaceholderTextView.text = UIPasteboard.general.string
        
    }
    
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        TitleTextField.textColor = .label
        
        if TitleTextField.text == "Title"{
            TitleTextField.text = ""
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if TitleTextField.text == ""{
            TitleTextField.text = "Title"
            TitleTextField.textColor = .lightGray
        }
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        PlaceholderTextView.textColor = .label
        
        if PlaceholderTextView.text == "Placeholder Text..."{
            PlaceholderTextView.text = ""
        }
        
        return true
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == ""{
            PlaceholderTextView.text = "Placeholder Text..."
            PlaceholderTextView.textColor = .lightGray
        }
        
    }
    
    func AlertCopy(){
        
        let alertCopy = UIAlertController(title: "This text already exists in the list!", message: "Please add a new text or change the current text.", preferredStyle: UIAlertController.Style.alert)
        
        alertCopy.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alertCopy, animated: true, completion: nil)
        
    }
    
}
