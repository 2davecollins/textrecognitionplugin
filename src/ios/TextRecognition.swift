@objc(ModusEchoSwift) class ModusEchoSwift : CDVPlugin {
  func echo(command: CDVInvokedUrlCommand) {
    var pluginResult = CDVPluginResult(
      status: CDVCommandStatus_ERROR
    )

    let msg = command.arguments[0] as? String ?? ""

    if msg.characters.count > 0 {
      /* UIAlertController is iOS 8 or newer only. */
      let toastController: UIAlertController = 
        UIAlertController(
          title: "", 
          message: msg, 
          preferredStyle: .Alert
        )

      self.viewController?.presentViewController(
        toastController, 
        animated: true, 
        completion: nil
      )

      let duration = Double(NSEC_PER_SEC) * 3.0
      
      dispatch_after(
        dispatch_time(
          DISPATCH_TIME_NOW, 
          Int64(duration)
        ), 
        dispatch_get_main_queue(), 
        { 
          toastController.dismissViewControllerAnimated(
            true, 
            completion: nil
          )
        }
      )

      pluginResult = CDVPluginResult(
        status: CDVCommandStatus_OK,
        messageAsString: msg
      )
    }

    self.commandDelegate!.sendPluginResult(
      pluginResult, 
      callbackId: command.callbackId
    )
  }
}

func processResult(from text: VisionText?, error: Error?) {
    removeDetectionAnnotations()
    guard error == nil, let text = text else {
      let errorString = error?.localizedDescription ?? Constants.detectionNoResultsMessage
      print("Text recognizer failed with error: \(errorString)")
      return
    }

    let transform = self.transformMatrix()

    // Blocks.
    for block in text.blocks {
      drawFrame(block.frame, in: .purple, transform: transform)

      // Lines.
      for line in block.lines {
        drawFrame(line.frame, in: .orange, transform: transform)

        // Elements.
        for element in line.elements {
          drawFrame(element.frame, in: .green, transform: transform)

          let transformedRect = element.frame.applying(transform)
          let label = UILabel(frame: transformedRect)
          label.text = element.text
          label.adjustsFontSizeToFitWidth = true
          self.annotationOverlayView.addSubview(label)
        }
      }
    }
  }