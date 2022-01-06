import 'package:flutter/material.dart';

class AddActivity extends StatefulWidget {
  int id;
  AddActivity(this.id);

  @override
  _AddActivityState createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  late int id;
  String dropdownValue = 'Project';

  @override
  Widget build(BuildContext context) {
    // Nombre
    // Task/Project
    // Tags -> Chip/formulario con añadir
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir actividad'),
      ),

      body: _buildDropDownButton(),
    );
  }

  Widget _buildDropDownButton() {
    return DropdownButton<String>(
      value: dropdownValue,
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
                  dropdownValue = newValue!;
                });
      },
      items: <String>[
        'Project', 'Task'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}