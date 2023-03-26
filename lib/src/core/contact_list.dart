import 'package:flutter/material.dart';
import 'package:mobile_contacts/src/contacts_model.dart';
import 'package:mobile_contacts/src/core/contact_avatar.dart';

import '../presentation/contact_detail_screen.dart';

class ContactsList extends StatelessWidget {
  final List<ContactsModel> contacts;
  Function() reloadContacts;

  ContactsList({Key? key, required this.contacts, required this.reloadContacts})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          ContactsModel contact = contacts[index];

          return ListTile(
              onTap: (() {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ContactDetails(
                    contact,
                    onContactUpdate: (ContactsModel _contact) {
                      reloadContacts();
                    },
                    onContactDelete: (ContactsModel _contact) {
                      reloadContacts();
                      Navigator.of(context).pop();
                    },
                  ),
                ));
              }),
              title: Text(contact.contactInfo.displayName.toString()),
              subtitle: Text("${contact.contactInfo.phones?.elementAt(0).value}"),
              leading: ContactAvatar(contact, 36));
        },
      ),
    );
  }
}
