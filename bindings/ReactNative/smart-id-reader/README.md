Пусть `<MODULE_PATH>` - пусть к реактовому модулю smart-id-reader

Пусть `<iOS_SDK_PATH>` - путь к иосовому сдк se-smart-id

Как это нормально написать?

# Smart ID Reader React Native SDK integration guide

## 1. Configuring project


1. Move to your project root
2. Run `npm install` if your project doesnt have **node_modules** folder.
3. Run `npm install smart-id-reader@<MODULE_PATH> --save` where `<MODULE_PATH>` is a path to **smart-id-reader** directory
4. run `react-native upgrade` `react-native link`

### iOS

1. In **yourapp.xcodeproj**, in **Libraries** group, open **RCTSmartIDReader.xcodeproj**
2. Add `<iOS_SDK_PATH>/SESmartIDCore/lib` folder to the **Library Search Paths** in project build settings
3. Add `<iOS_SDK_PATH>/SESmartIDCore/include` folder to the **Header Search Paths** in project build settings
4. Add `<iOS_SDK_PATH>/SESmartIDCore/data-zip` folder to your project, use **Create Folder References** option
5. Set `enable bitcode = false`  in root project build settings 

### Android
Add ```<activity android:name="com.smartengines.jsmodule.SmartIDActivityJS"/>``` in your root **AndroidManifest**.



## 2. Sample Code tutorial

1. Import **smart-id-reader** module

``` javascript
import SmartIDReader from 'smart-id-reader'
```
2.  Load recognition engine
``` javascript
  async loadEngine() {
    try {
      await SmartIDReader.initEngine();
    } catch (e) {
      console.error(e);
    }
  }
```
3. Set session params
``` javascript
 SmartIDReader.setParams({
    'sessionTimeout': 6.0,
    'displayZonesQuadrangles': true,
    'displayDocumentQuadrangle': true,
    'documentMask': 'rus.passport.national'
  })
```
4. Push recognition controller/activity from current controller/activity
``` javascript
  async startRecognition() {
    try {
      await SmartIDReader.startRecognition();
    } catch (e) {
      console.error(e);
    }
  }
  ```
  5. Hide recognition controller/activity
  ``` javascript
  SmartIDReader.cancelRecognition((error, list) => {
      // your code here
    })
```
  
  ### Callbacks
  1. Create event emitter
  ``` javascript
  const smartIDReaderListener = new NativeEventEmitter(SmartIDReader);
  ```
  2. Listen if user cancelled recognition
 ``` javascript
 const userDidCancel = smartIDReaderListener.addListener(
  'DidCancel',
  (reminder) => {
      // your code here
  }
);
 ```
 3. Handle recognition on each processed frame
  ``` javascript
const sessionDidRecognize = smartIDReaderListener.addListener(
  'DidRecognize',
  (reminder) => {
      // your code here
    }
);
  ```
  
  
  
