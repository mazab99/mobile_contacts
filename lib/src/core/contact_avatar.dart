import 'package:flutter/material.dart';
import '../contacts_model.dart';
import 'app_colors.dart';

class ContactAvatar extends StatelessWidget {
  const ContactAvatar(this.contact, this.size, {super.key});
  final ContactsModel contact;
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle, gradient: getColorGradient(contact.contactColor)),
        child: (contact.contactInfo.avatar != null && contact.contactInfo.avatar!.isNotEmpty)
            ? CircleAvatar(
                backgroundImage: MemoryImage(contact.contactInfo.avatar!),
              )
            : CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Text(contact.contactInfo.initials(),
                    style: const TextStyle(color: Colors.white))));
  }
}
