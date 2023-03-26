import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class ContactsModel {
  Color contactColor;
  Contact contactInfo;

  ContactsModel({
    required Key key,
    required this.contactColor,
    required this.contactInfo,
  });
}
