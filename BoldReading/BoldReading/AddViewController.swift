import UIKit
import Vision
import UniformTypeIdentifiers

var CurrentFolder: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

class AddViewController: UIViewController{
    
    @IBOutlet weak var PasteTextButton: UIButton!
    @IBOutlet weak var ImportPDFButton: UIButton!
    @IBOutlet weak var ImportTXTButton: UIButton!
    @IBOutlet weak var ImportHTMLButton: UIButton!
    @IBOutlet weak var ScanTextButton: UIButton!
    
    var item:String = ""
    weak var delegate:OkDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapImportPDFButton = UITapGestureRecognizer(target: self, action: #selector(self.ImportPDF))
        ImportPDFButton.addGestureRecognizer(tapImportPDFButton)
        
        let tapImportTXTButton = UITapGestureRecognizer(target: self, action: #selector(self.ImportTXT))
        ImportTXTButton.addGestureRecognizer(tapImportTXTButton)
        
        let tapImportHTMLButton = UITapGestureRecognizer(target: self, action: #selector(self.ImportHTML))
        ImportHTMLButton.addGestureRecognizer(tapImportHTMLButton)
        
        let tapScanTextButton = UITapGestureRecognizer(target: self, action: #selector(self.ScanText))
        ScanTextButton.addGestureRecognizer(tapScanTextButton)
        
    }
    
    @IBAction func CloseButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let yIndent = UIScreen.main.bounds.height - 450.0
        self.view.frame = CGRect(x: 0, y: yIndent, width: self.view.bounds.width, height: 450)
        self.view.layer.cornerRadius = 10
        self.view.layer.masksToBounds = true
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PasteTextVC"{
            if let navVC = segue.destination as? UINavigationController, let newVC = navVC.topViewController as? PasteTextViewController{
                newVC.delegate = self
            }
        }
    }
    
    @objc private func ImportPDF(){
        
        let types = UTType.types(tag: "pdf", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
        let documentPickerPDF = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        documentPickerPDF.allowsMultipleSelection = false
        documentPickerPDF.delegate = self
        self.present(documentPickerPDF, animated: true, completion: nil)
        
    }
    
    @objc private func ImportTXT(){
        
        let types = UTType.types(tag: "txt", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
        let documentPickerTXT = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        documentPickerTXT.allowsMultipleSelection = false
        documentPickerTXT.delegate = self
        self.present(documentPickerTXT, animated: true, completion: nil)
        
    }
    
    @objc private func ImportHTML(){
        
        let types = UTType.types(tag: "html", tagClass: UTTagClass.filenameExtension, conformingTo: nil)
        let documentPickerHTML = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        documentPickerHTML.allowsMultipleSelection = false
        documentPickerHTML.delegate = self
        self.present(documentPickerHTML, animated: true, completion: nil)
        
    }
    
    @objc private func ScanText(){
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true,completion: nil)
        
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            return
        }
        
        let recognizedStrings = observations.compactMap { observation in
            // Return the string of the top VNRecognizedText instance.
            return observation.topCandidates(1).first?.string
        }
        
        guard recognizedStrings != [] else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        var text = ""
        for String in recognizedStrings{
            text += String + " "
        }
        
        item = text
        
        let timeImages = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.YY, HH:mm"
        let formattedDate = formatter.string(from: timeImages as Date)
        formatter.timeZone = TimeZone(secondsFromGMT: 3)
        
        let title = "photo - " + "\(formattedDate)"
        let dict = ["title": title, "type": "image", "text" : item] as [String : String]
        
        if data.contains(dict) {
            dismiss(animated: true, completion: nil)
            AlertCopy()
        }else{
            data.append(dict)
            UserDefaults.standard.set(data, forKey: "data")
            
            dismiss(animated: true, completion: nil)
            dismiss(animated: true, completion: nil)
            
            delegate?.Ok("Ok")
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        guard let cgImage = image.cgImage else { return }
        
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        
        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
            
        } catch {
            print("Unable to perform the requests: \(error).")
            
        }
    }
    
    func AlertCopy(){
        
        let alertCopy = UIAlertController(title: "This text already exists in the list!", message: "Please add a new text or change the current text.", preferredStyle: UIAlertController.Style.alert)
        
        alertCopy.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alertCopy, animated: true, completion: nil)
        
    }
}

extension AddViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let myURL = urls.first else { return }
        print("import result: \(myURL)")
        
        let newFileName = myURL.lastPathComponent
        print("newFileName: \(newFileName)")
        
        let myURL2 = CurrentFolder.appendingPathComponent(newFileName)
        print("myURL2: \(myURL2)")
        
        let status = secureCopyItem(at: myURL, to: myURL2)
        print("Is copied from holder: \(status)")
        
        item = "\(myURL2)"
        
        let type = (newFileName as NSString).pathExtension
        
        var title = newFileName
        for _ in 0..<(type.count+1){
            title.removeLast()
        }
        
        let dict = ["title": title, "type": type, "text" : item] as [String : String]
        
        if data.contains(dict) {
            AlertCopy()
        }else{
            data.append(dict)
            UserDefaults.standard.set(data, forKey: "data")
            
            dismiss(animated: true, completion: nil)
            
            delegate?.Ok("Ok")
            
        }
        
    }
    
    public func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
        
        do {
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch (let error) {
            print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
            return false
        }
        return true
    }
    
}

extension AddViewController: OkDelegate{
    func Ok(_ Ok: String) {
        dismiss(animated: true, completion: nil)
        delegate?.Ok("Ok")
    }
}
