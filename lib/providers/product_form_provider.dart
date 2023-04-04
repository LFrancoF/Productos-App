import 'package:flutter/material.dart';
import 'package:productos_app/models/models.dart';

class ProductFormProvider extends ChangeNotifier{

  GlobalKey<FormState> formkey = GlobalKey();
  Product product;
  
  ProductFormProvider(this.product);

  updateAvailability(bool value){
    product.available = value;
    notifyListeners();
  }

  bool isValidForm(){

    return formkey.currentState?.validate() ?? false;
  }

}