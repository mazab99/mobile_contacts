import 'dart:math';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_contacts/src/contacts_model.dart';
import 'package:mobile_contacts/src/core/contact_list.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Contacts",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Contacts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ContactsModel> contacts = [];
  List<ContactsModel> contactsFiltered = [];

  final contactsColorMap = <String, Color>{};

  TextEditingController searchController = TextEditingController();
  bool contactsLoaded = false;

  @override
  void initState() {
    super.initState();
    getPermissions();
  }

  getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      getAllContacts();
      searchController.addListener(() {
        filterContacts();
      });
    }
  }

  String flattenPhoneNumber(String phoneStr) {
    return phoneStr.replaceAllMapped(
      RegExp(r'^(\+)|\D'),
          (Match m) {
        return m[0] == "+" ? "+" : "";
      },
    );
  }

  Future<void> getAllContacts() async {
    List colors = [
      Colors.green,
      Colors.indigo,
      Colors.yellow,
      Colors.orange,
    ];

    int colorIndex = 0;
    // ưaay random
    final random = Random();

    List<Contact> _contactTemps =
    (await ContactsService.getContacts()).toList();
    List<ContactsModel> _contacts = _contactTemps.map((e) {
      final indexKey = _contactTemps.indexOf(e);
      return ContactsModel(
        key: ValueKey(indexKey.toString()),
        contactColor: colors.elementAt(random.nextInt(4)),
        contactInfo: e,
      );
    }).toList();

    for (var i = 0; i < _contacts.length; i++) {
      final appContact = _contacts.elementAt(i);
      Color baseColor = colors[colorIndex];

      contactsColorMap.putIfAbsent(
          appContact.contactInfo.displayName.toString(), () => baseColor);

      contactsColorMap[appContact.contactInfo.displayName] == baseColor;

      _contacts[i].contactColor = baseColor;

      colorIndex++;

      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
    }

    setState(
          () {
        contacts = _contacts;
        contactsLoaded = true;
      },
    );
  }

  filterContacts() {
    List<ContactsModel> _contacts = [];

    _contacts.addAll(contacts);
    String searchTerm = searchController.text.toLowerCase();

    if (searchController.text.isNotEmpty) {
      contactsFiltered = contacts.where((element) {
        final checkPhone = element.contactInfo.phones
            ?.where(
                (element) => element.value?.contains(searchTerm) ?? false)
            .isNotEmpty ??
            false;
        return (element.contactInfo.displayName
            ?.toLowerCase()
            .contains(searchTerm.toLowerCase()) ??
            false) ||
            checkPhone;
      }).toList();
    } else {}
    setState(() {});
    return;
  }

  bool get isSearching => searchController.text.isNotEmpty;

  bool get listItemsExist =>
      ((isSearching == true && contactsFiltered.isNotEmpty) ||
          (isSearching != true && contacts.isNotEmpty));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            Contact contact = await ContactsService.openContactForm();
            if (contact != null) {
              getAllContacts();
            }
          } on FormOperationException catch (e) {
            switch (e.errorCode) {
              case FormOperationErrorCode.FORM_OPERATION_CANCELED:
              case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
              case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
                print(e.toString());
            }
          }
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.red,
                ),
              ),
            ),
            contactsLoaded == true
                ? listItemsExist == true
                ? ContactsList(
              reloadContacts: () async {
                await getAllContacts();

                filterContacts();
              },
              contacts: (isSearching) ? contactsFiltered : contacts,
            )
                : Container(
                padding: const EdgeInsets.only(top: 250),
                child: Text(
                  isSearching
                      ? 'NO SEARCH RESULTS TO SHOW'
                      : 'NO CONTACTS EXIST',
                  style:
                  const TextStyle(color: Colors.grey, fontSize: 20),
                ))
                : Container(
              // still loading contacts
              padding: const EdgeInsets.only(top: 250),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
