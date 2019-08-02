/**
 * rzmn
 * @flow
 */

import React, { Component } from 'react';
import {
  StyleSheet,
  Text,
  View,
  Image,
  Button,
  ActivityIndicator,
  NativeEventEmitter
} from 'react-native';


import SmartIDReader from 'smart-id-reader';


type Props = {};
export default class App extends Component<Props> {

  async loadEngine() {
    try {
      await SmartIDReader.initEngine();
      this.toggleCancel();
      SmartIDReader.setParams({
        'displayZonesQuadrangles': true,
        'displayDocumentQuadrangle': true,
        'documentMask': 'rus.passport.national'
      })
    } catch (e) {
      console.error(e);
    }
  }

  async startRecognition() {
    try {
      await SmartIDReader.startRecognition();      
      this.state.title = ''
      this.state.image = null

      this.forceUpdate()
    } catch (e) {
      console.error(e);
    }
  }

  async cancelRecognition() {
    try {
      await SmartIDReader.cancelRecognition();          
      this.state.title = 'Recognition cancelled by user';
      this.forceUpdate();
    } catch (e) {
      console.error(e)
    }
  }

  configureSubscriptions() {
    const smartIDReaderDelegate = new NativeEventEmitter(SmartIDReader);

    const subscription1 = smartIDReaderDelegate.addListener(
      'DidRecognize',
      (reminder) => {
            console.log(reminder)
            if (reminder.terminal) {
                try {
                  SmartIDReader.cancelRecognition();
                  this.state.title = JSON.stringify(reminder.stringFields, null, 2)
                  if (reminder.imageFields != undefined) {
                    this.state.image = reminder.imageFields['photo']
                  }
                  
                  this.forceUpdate();
                } catch (e) {
                  console.error(e)
                }
            }
        }
    );
    const sub2 = smartIDReaderDelegate.addListener(
      'DidCancel',
      (reminder) => {
        this.cancelRecognition()
      }
    );
  }

  constructor(props) {
    super(props);
    this.count = 0
    this.state = {
      showCancel: false,
      title: '',
      'image': null
    };
    this.loadEngine();
    this.configureSubscriptions()
  }

  toggleCancel() {
      this.state.showCancel = !this.state.showCancel;
      this.forceUpdate();
  }



  render() {
    if (this.state.showCancel) {
        return (
          <View style={styles.containerLoaded}>
          <Image key ={this.count++} style={styles.imageView} source={{uri: `data:image/jpg;base64,${this.state.image}`,cache: 'reload'}}/>
          <Text>
            {this.state.title}
          </Text>
            <Button style={styles.button}
              onPress={this.startRecognition.bind(this)}
              color='#48BBEC'
              title='Scan ID!'
            />
          </View>
        );
    } else {
        return (
        <View style={styles.containerLoading}>
        <ActivityIndicator size='large'/>
        <Text style={styles.description}>
          Initializing engine...
        </Text>
        </View>);
    }
  }
}

const styles = StyleSheet.create({
  description: {
    marginBottom: 20,
    fontSize: 18,
    textAlign: 'center',
    color: '#656565'
  },
  button: {
    flex: 0
  },
  containerLoading: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
  },
  containerLoaded: {
    flex: 0.9,
    flexDirection: 'column',
    justifyContent: 'flex-end',
    alignItems: 'center',
  },
  imageView: {
    width: 70, 
    height: 100
  }
});
