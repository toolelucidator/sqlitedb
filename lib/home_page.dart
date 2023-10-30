import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqlitedb/convert_utility.dart';
import 'package:sqlitedb/dbManager.dart';
import 'package:sqlitedb/student.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Student>>? Studentss;
  TextEditingController controlNumController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController apepaController = TextEditingController();
  TextEditingController apemaController = TextEditingController();
  TextEditingController telController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String? name = '';
  String? apema = '';
  String? tel = '';
  String? email = '';
  String? photoName = '';
  String? apepa = '';

  //Update control
  int? currentUserId;
  final formKey = GlobalKey<FormState>();
  late var dbHelper;
  late bool isUpdating;

  //Metodos de usuario
  refreshList() {
    setState(() {
      Studentss = dbHelper.getStudents();
    });
  }

  pickImageFromGallery() {
    ImagePicker imagePicker = ImagePicker();
    imagePicker
        .pickImage(source: ImageSource.gallery, maxHeight: 480, maxWidth: 640)
        .then((value) async {
      Uint8List? imageBytes = await value!.readAsBytes();
      setState(() {
        photoName = Utility.base64String(imageBytes!);
      });
    });
  }

  clearFields() {
    controlNumController.text = '';
    nameController.text = '';
    apepaController.text = '';
    apemaController.text = '';
    telController.text = '';
    emailController.text = '';
  }

  @override
  void initState() {
    super.initState();
    dbHelper = DBManager();
    refreshList();
    isUpdating = false;
  }

  Widget userForm() {
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: [
            const SizedBox(height: 10),
//            TextFormField(
//              controller: controlNumController,
//              keyboardType: TextInputType.number,
//              decoration: const InputDecoration(
//                labelText: 'Control Number',
//              ),
//              validator: (val) => val!.isEmpty ? 'Enter Control Number' : null,
//              onSaved: (val) => controlNumController.text = val!,
//            ),
            TextFormField(
              controller: nameController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
              validator: (val) => val!.isEmpty ? 'Enter Name' : null,
              onSaved: (val) => name = val!,
            ),
            TextFormField(
              controller: apepaController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Apellido Paterno',
              ),
              validator: (val) => val!.isEmpty ? 'Ape Paterno' : null,
              onSaved: (val) => apepa = val!,
            ),
            TextFormField(
              controller: apemaController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Apellido Materno',
              ),
              validator: (val) => val!.isEmpty ? 'Ape Materno' : null,
              onSaved: (val) => apema = val!,
            ),
            TextFormField(
              controller: telController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
              ),
              validator: (val) => val!.isEmpty ? 'Tel' : null,
              onSaved: (val) => tel = val!,
            ),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
              ),
              validator: (val) => val!.isEmpty ? 'Enter E-mail' : null,
              onSaved: (val) => email = val!,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  onPressed: validate,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.red)),
                  child: Text(isUpdating ? "Actualizar" : "Insertar"),
                ),
                MaterialButton(
                  onPressed: () {
                    pickImageFromGallery();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.tealAccent)),
                  child: const Text("Seleccionar imagen"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView userDataTable(List<Student>? Studentss) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Photo')),
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Paterno')),
          DataColumn(label: Text('Materno')),
          DataColumn(label: Text('E-mail')),
          DataColumn(label: Text('Tel')),
          DataColumn(label: Text('Delete')),
        ],
        rows: Studentss!
            .map((student) => DataRow(cells: [
          DataCell(Container(
            width: 80,
            height: 120,
            child: Utility.ImageFromBase64String(student.photoName!),
          )),
          DataCell(Text(student.name!), onTap: () {
            setState(() {
              isUpdating = true;
              currentUserId = student.controlNum;
            });
            nameController.text = student.name!;
            apepaController.text = student.apepa!;
            apemaController.text = student.apema!;
            emailController.text = student.email!;
            telController.text = student.tel!;
          }),
          DataCell(Text(student.apepa!)),
          DataCell(Text(student.apema!)),
          DataCell(Text(student.email!)),
          DataCell(Text(student.tel!)),
          DataCell(IconButton(
            onPressed: () {
              dbHelper.delete(student.controlNum);
              refreshList();
            },
            icon: const Icon(Icons.delete),
          ))
        ]))
            .toList(),
      ),
    );
  }

  Widget list() {
    return Expanded(
        child: SingleChildScrollView(
          child: FutureBuilder(
              future: Studentss,
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data);
                  return userDataTable(snapshot.data);
                }
                if (!snapshot.hasData) {
                  print("Data Not Found");
                }
                return const CircularProgressIndicator();
              }),
        ));
  }

  validate() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (isUpdating) {
        Student student = Student(
            controlNum: currentUserId,
            name: name,
            apepa: apepa,
            apema: apema,
            email: email,
            tel: tel,
            photoName: photoName);
        dbHelper.update(student);
        isUpdating = false;
      } else {
        Student student = Student(
            controlNum: null,
            name: name,
            apepa: apepa,
            apema: apema,
            email: email,
            tel: tel,
            photoName: photoName);
        dbHelper.save(student);
      }
      clearFields();
      refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('SQLite DB'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: [userForm(), list()],
      ),
    );
  }
}
