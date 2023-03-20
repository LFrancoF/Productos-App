import 'package:flutter/material.dart';

class LoginFormProvider extends ChangeNotifier {
  
  GlobalKey<FormState> formkey = GlobalKey();

  String email = '';
  String password = '';

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value){
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm(){
    print(formkey.currentState?.validate() ?? false);
    print('$email - $password');
    return formkey.currentState?.validate() ?? false;
  }

}