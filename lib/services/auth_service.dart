import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService extends ChangeNotifier{
  
  final String _baseUrl = 'identitytoolkit.googleapis.com';
  final String _firebaseToken = 'AIzaSyAtP2nh3b_an8NSe3ZILr60Kt4L450sC-Q';

  //para guardar el tokenID del usuario
  final storage = const FlutterSecureStorage();

  //Si retornamos algo, es un error, sino, usuario creado con exito
  Future<String?> createUsers(String email, String password) async{
    final Map<String, dynamic> authData = {
      'email' : email,
      'password' : password,
      'returnSecureToken' : true
    };

    final url = Uri.https(_baseUrl, '/v1/accounts:signUp', {
      'key' : _firebaseToken
    });

    final resp = await http.post(url, body: json.encode(authData));

    final Map<String, dynamic> decodedResp = json.decode(resp.body);

    if (decodedResp.containsKey('idToken')){
      await storage.write(key: 'idToken', value: decodedResp['idToken']);
      return null;
    }else{
      return decodedResp['error']['message'];
    }

  }

  //return null = todo bien,,,, return algo = error
  Future<String?> login(String email, String password) async{
    final Map<String, dynamic> authData = {
      'email' : email,
      'password' : password,
      'returnSecureToken' : true
    };

    final url = Uri.https(_baseUrl, '/v1/accounts:signInWithPassword', {
      'key' : _firebaseToken
    });

    final resp = await http.post(url, body: json.encode(authData));

    final Map<String, dynamic> decodedResp = json.decode(resp.body);

    if (decodedResp.containsKey('idToken')){
      await storage.write(key: 'idToken', value: decodedResp['idToken']);
      return null;
    }else{
      return decodedResp['error']['message'];
    }

  }

  Future<String> readToken() async{
    return await storage.read(key: 'idToken') ?? '';
  }

  Future logout() async{
    await storage.delete(key: 'idToken');
    return;
  }
  
}