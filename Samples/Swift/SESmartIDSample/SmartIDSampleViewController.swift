import UIKit

class SampleViewController: UIViewController {
    
    let startButton : UIButton = {
        let button = UIButton(type: .roundedRect)
        button.backgroundColor = .white
        button.autoresizingMask = .flexibleWidth
        button.setTitle("Press to Scan ID!", for: .normal)
        return button
    }()
    
    let resultTextView : UITextView = {
        let view = UITextView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight];
        view.isEditable = false
        view.font = UIFont(name: "Menlo-Regular", size: 12)
        return view
    }()
    
    let resultImageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        return view
    }()
    
    let smartIDController : SmartIDViewControllerSwift = {
        let smartIDController = SmartIDViewControllerSwift()
        
        smartIDController.captureButtonDelegate = smartIDController
      
        // if needed, set a timeout in seconds
        smartIDController.sessionTimeout = 5.0
      
        // configure optional visualization properties (they are NO by default)
        smartIDController.displayZonesQuadrangles = true
        smartIDController.displayDocumentQuadrangle = true
        smartIDController.displayProcessingFeedback = true
      
        // uncomment this to customize Region of Interest (RoI)
        // smartIDController.shouldDisplayRoi = true
        // smartIDController.setRoiWithOffsetX(20, andY: 40, orientation: .portrait)
        // smartIDController.setRoiWithOffsetX(60, andY: 10, orientation: .landscapeLeft)
        // smartIDController.setRoiWithOffsetX(10, andY: 60, orientation: .landscapeRight)
      
        return smartIDController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        smartIDController.smartIDDelegate = self
        startButton.addTarget(self, action: #selector(showSmartIdViewController), for: .touchUpInside)
        view.addSubview(startButton)
        view.addSubview(resultTextView)
        resultTextView.addSubview(resultImageView)
    }
    
    override func viewDidLayoutSubviews() {
        startButton.frame = CGRect(x: 0, y: 20, width: view.bounds.size.width, height: 50)
        let imageWidth = 120.0
        let imageHeight = imageWidth * 3.0 / 2.0
        
        resultTextView.frame = CGRect(x: 0,
                                      y: startButton.frame.maxY + 15,
                                      width: view.bounds.size.width,
                                      height: view.bounds.size.height - startButton.frame.maxY - 15)
        
        let imageFrame = CGRect(x: Double(resultTextView.bounds.size.width) - imageWidth - 10.0,
                                y: 10.0,
                                width: imageWidth,
                                height: imageHeight)
        resultImageView.frame = imageFrame
        
        var exclusionRect = imageFrame
        exclusionRect.size.width = resultTextView.bounds.size.width
        
        let exclusionPath = UIBezierPath(rect: exclusionRect)
        resultTextView.textContainer.exclusionPaths = [exclusionPath]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func showSmartIdViewController() {
        
        // important!
        // setting enabled document types for this view controller
        // according to available document types for your delivery
        // you can specify a concrete document type or a wildcard expression (for convenience)
        // to enable or disable multiple types
        // by default no document types are enabled
        // if exception is thrown please read the exception message
        // see smartIDViewController.sessionSettings().getSupportedDocumentTypes()
        
        
        smartIDController.removeEnabledDocTypesMask("*")
        // smartIDController.addEnabledDocTypesMask("rus.passport.national")
        smartIDController.addEnabledDocTypesMask("*")
        // smartIDController.addEnabledDocTypesMask("card.*")
        // smartIDController.addEnabledDocTypesMask("rus.drvlic.*")
        
        self.present(smartIDController, animated: true, completion: {
            print("sample: smartIDViewController presented")
        })
    }
}

extension SampleViewController : SmartIDViewControllerDelegate {
    func smartIDViewControllerDidRecognize(_ result: SmartIDRecognitionResult) {
        guard result.isTerminal() else {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "resultController") as! ResultViewController
        let navCon = UINavigationController(rootViewController: controller)
        var resultText = "";
        for (key, value) in result.getStringFields() {
            resultText += key
            resultText += ": "
            resultText += value.getValue()
            resultText += (value.isAccepted() ? " [+]" : " [-]")
            resultText += "\n"
        }
        self.resultTextView.text = resultText
        if result.hasImageField(withName: "photo") {
            self.resultImageView.image = result.getImageField(withName: "photo").value.uiImage
        } else {
            self.resultImageView.image = nil;
        }
        dismiss(animated: true, completion: nil)
        present(navCon, animated: true) {
            controller.configure(with: result)
        }
    }
    
    func smartIDviewControllerDidCancel() {
        self.resultTextView.text = "Recognition cancelled by user"
        self.resultImageView.image = nil;
        dismiss(animated: true, completion: nil)
    }
}
