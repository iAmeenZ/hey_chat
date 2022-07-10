import 'package:flutter/material.dart';


const kSendButtonTextStyle = TextStyle(
  color: Colors.redAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);


const kMessageTextFieldDecoration =  InputDecoration.collapsed(
  hintText: 'Type Something...',
  hintStyle: TextStyle(color: Colors.black),
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.redAccent, width: 2.0),
  ),
);

