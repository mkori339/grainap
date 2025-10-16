import 'package:flutter/material.dart';
import 'package:grainapp/authentificatin.dart';

class DialogBuilder {
  final BuildContext context;

  DialogBuilder(this.context);

  /// Show a dialog with the result message.
  Future<void> showResultDialog(String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button to dismiss the dialog
    builder: (BuildContext context) {
      return Dialog(
        alignment: Alignment.bottomCenter,
        backgroundColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ), // Optional to give rounded corners to the dialog
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(5),
          constraints: const BoxConstraints(
            maxWidth:200, // Set maximum width for the dialog
            maxHeight: 100, // Set maximum height for the dialog
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Center(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white, // Red text for the message
                          fontSize: 14, // Smaller font size for the message
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); 
                if(message=='please go to your email to verify'){
              Navigator.push(context, MaterialPageRoute(builder:(context)=>LoginScreen()));
                }// Close the dialog
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}


  /// Show a loading dialog while waiting for an operation to complete
  void showLoadingDialog({String? message}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: <Widget>[
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message ?? 'Loading...')),
            ],
          ),
        );
      },
    );
  }

  /// Hide the loading dialog when the operation completes
  void hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop(); // Close the loading dialog
  }
}
