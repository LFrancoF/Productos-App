import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:productos_app/models/models.dart';
import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier{

  final String _baseUrl = 'flutter-datos-4fa67-default-rtdb.firebaseio.com';
  final List<Product> products = [];
  bool isLoading = true;

  bool isSaving = false;

  late Product selectedProduct;

  File? newPictureFile;

  ProductsService(){
    loadProducts();
  }

  Future< List<Product> > loadProducts()async{

    isLoading = true;
    notifyListeners();

    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.get(url);

    final Map<String, dynamic> productsMap = jsonDecode(resp.body);
    
    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      products.add(tempProduct);
    });

    isLoading = false;
    notifyListeners();

    return products;
  }

  Future saveOrCreateProduct(Product product) async{
    isSaving = true;
    notifyListeners();

    if (product.id == null){  
      //crear producto
      await createProduct(product);
    }else{
      //actualizar producto
      await updateProduct(product);
    }


    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async{
    final url = Uri.https(_baseUrl, 'products/${product.id}.json');
    await http.put(url, body: product.toJson() );

    final index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;

    return product.id!;
  }

  Future<String> createProduct(Product product) async{
    final url = Uri.https(_baseUrl, 'products.json');
    final resp = await http.post(url, body: product.toJson() );
    final decodedData = json.decode(resp.body);
    
    product.id = decodedData['name'];

    products.add(product);

    return product.id!;
  }

  void updateSelectedProductImage(String path){

    selectedProduct.picture = path;
    newPictureFile = File.fromUri(Uri(path: path)); //se guarda el archivo en esta variable
    notifyListeners();

  }

  Future<String?> uploadImage() async{
    if (newPictureFile == null) return null;

    isSaving = true;

    //alternativa a Uri.https()
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dtpxjlijj/image/upload?upload_preset=fuidbbkb');
    
    //Para hacer la request a Cloudinary
    final imageUploadRequest = http.MultipartRequest('POST', url);

    //Para guardar el archivo
    final file = await http.MultipartFile.fromPath('file', newPictureFile!.path);

    //añadimos el archivo al request
    imageUploadRequest.files.add(file);

    //Realizamos la peticion
    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201){
      print('Algo salio mal');
      print(resp.body);
      return null;
    }

    newPictureFile = null;
    final decodedData = json.decode(resp.body);
    return decodedData['secure_url'];

  }

}