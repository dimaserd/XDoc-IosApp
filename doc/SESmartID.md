## Smart ID Reader SDK Integration Guide for iOS

### 1. Configuring Xcode project

1. Add `SESmartID` folder containing source files to your project, select **Create groups** in the menu
2. Add `SESmartIDCore/lib` folder containing static library to your project, select **Create groups** in the menu
3. Add `SESmartIDCore/data-zip` folder to your project, select **Create folder references** in the menu
4. Add `SESmartIDCore/include` folder to the **Header Search Paths** in project settings
5. If you use Swift, add `SESmartID/SmartSmartID-Bridging-Header.h` to the **Objective-C Bridging Header** in project settings

## 2. Sample code tutorial

1. Make your ViewController (```sampleViewController``` in sample project) conform to ```<smartIDViewControllerDelegate>```.

2. Create and configure ```SmartIDViewController``` instance, set enabled document types before presenting (`SmartIDViewControllerCPP` for ObjC++ support and `SmartIDViewControllerWrap` for ObjC/Swift support)

### Swift
```swift
let smartIDController = smartIDViewController();
smartIDController.SmartIDDelegate = self
// if needed, set a timeout in seconds
smartIDController.sessionTimeout = 5.0

// set roi offsets (in points) for each device orientation, if needed
smartIDController.setRoiWithOffsetX(20, andY: 40, orientation: .portrait)
smartIDController.setRoiWithOffsetX(60, andY: 10, orientation: .landscapeLeft)
smartIDController.setRoiWithOffsetX(10, andY: 60, orientation: .landscapeRight)

// configure optional visualization properties (they are false by default)
smartIDController.shouldDisplayDocumentZones = true
smartIDController.shouldDisplayDocumentQuadrangles = true
smartIDController.shouldDisplayRoi = true

// important!
// setting enabled document types for this view controller
// according to available document types for your delivery
// you can specify a concrete document type or a wildcard expression (for convenience)
// to enable or disable multiple types
// by default no document types are enabled
// if exception is thrown please read the exception message
// see smartIDViewController.sessionSettings().getSupportedDocumentTypes()


smartIDController.removeEnabledDocumentTypesMask(documentTypeMask: "*")
smartIDController.addEnabledDocumentTypesMask(documentTypeMask: "rus.passport.national")
//smartIDViewController.addEnabledDocumentTypesMask(documentTypeMask: "mrz.*")
//smartIDViewController.addEnabledDocumentTypesMask(documentTypeMask: "card.*")
//smartIDViewController.addEnabledDocumentTypesMask(documentTypeMask: "rus.drvlic.*")

// presenting OCR view controller
present(smartIDController, animated: true, completion: { self.smartIDController.startRecognition() })
```
### Objective-C++
```objective-c
// important!
// setting enabled document types for this view controller
// according to available document types for your delivery
// these types will be passed to se::smartid::SessionSettings
// with which se::smartid::RecognitionEngine::SpawnSession(...) is called
// internally when Smart ID view controller is presented
// you can specify a concrete document type or a wildcard expression (for convenience)
// to enable or disable multiple types
// by default no document types are enabled
// if exception is thrown please read the exception message
// see self.smartidViewController.supportedDocumentTypes,
// se::smartid::SessionSettings and Smart IDReader documentation for further information
[self.smartIdViewController removeEnabledDocumentTypesMask:"*"];

//  [self.smartIdViewController addEnabledDocumentTypesMask:"*"];
//  [self.smartIdViewController addEnabledDocumentTypesMask:"mrz.*"];
//  [self.smartIdViewController addEnabledDocumentTypesMask:"card.*"];
[self.smartIdViewController addEnabledDocumentTypesMask:"rus.passport.*"];
//  [self.smartIdViewController addEnabledDocumentTypesMask:"rus.snils.*"];
//  [self.smartIdViewController addEnabledDocumentTypesMask:"rus.sts.*"];
//  [self.smartIdViewController addEnabledDocumentTypesMask:"rus.drvlic.*"];

// if needed, set a timeout in seconds
self.smartIdViewController.sessionTimeout = 5.0f;

// presenting OCR view controller
[self presentViewController:self.smartIdViewController
                            animated:YES
                            completion:^{ [self.smartIdViewController startRecognition]; }];

// if you want to deinitialize view controller to save the memory, do this:
// self.smartIdViewController = nil;
```
3. Implement  ```smartIdViewControllerDidRecognizeResult:``` method which will be called when ```smartIDViewController``` has successfully scanned a document and ```smartIdViewControllerDidCancel``` method which will be called when recognition has been cancelled by user

### Swift
```swift
// SampleViewController.swift

func smartIDViewControllerDidRecognizeResult(result: SmartIDRecognitionResult) {
    // use recognition result, see sample code for details
    // ...
}

func smartIDViewControllerDidCancel() {
    dismiss(animated: true, completion: {
        print("sample: smartIDViewController cancelled by user")
    })
}
```
### Objective-C++
```objective-c
- (void)smartIDViewControllerDidRecognize:(const se::smartid::RecognitionResult &)result {
    // use recognition result, see sample code for details
    // ...
}
- (void)smartIDviewControllerDidCancel {
    [self dismissViewControllerAnimated:YES completion:nil];

    NSLog(@"Recognition cancelled by user");
}
```
4. Present ```smartIDViewController``` modally when needed



