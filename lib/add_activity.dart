import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:timetracker/requests.dart' as requests;
class AddActivity extends StatefulWidget {
  int id;
  AddActivity(this.id);

  @override
  _AddActivityState createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  late int id = widget.id;
  final _formKey = GlobalKey<FormState>();
  List<String> tagList = [];
  String dropdownValue = 'Project';
  String inputname = "";
  @override
  Widget build(BuildContext context) {
    // Nombre
    // Task/Project
    // Tags -> Chip/formulario con añadir
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir actividad'),
      ),

      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Activity: '),
                _buildDropDownButton(),
              ],
            ),
          _buildNameForm(),
          Divider(height: 50,),
          Expanded(
            child: TextFieldTags(
            tagsStyler: TagsStyler(),
            onTag: (tag) {
              tagList.add(tag);
            },
            validator: (tag) {
              if (tag.length > 20) {
                return "es un tag muy largo...";
              }
              return null;
            },
            onDelete: (tag){
              tagList.remove(tag);
            },
            textFieldStyler: TextFieldStyler(
              hintText: 'Quieres añadir tags?',
              
            ),
            tagsDistanceFromBorderEnd: 0.725,
          ),
          ),
          ElevatedButton(
            child: Text('Añadir'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                requests.addActivity(id, dropdownValue, inputname, tagList);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Añadiendo ' + dropdownValue + ' ' + this.inputname + '...')),
                );
                Navigator.of(context).pop();
                //HACER UN POP Y VOLVER ATRAS
              }
            }
          )
        ],
      ),
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

  Widget _buildNameForm() {
    return Container(
      margin: const EdgeInsets.symmetric(),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top:10),
            child: TextFormField(
              focusNode: FocusNode(),
              decoration: InputDecoration(
                
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                )
              ),
              validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Escribe el nombre de la actividad';
              }
              inputname = value;
              return null;
            }
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Name'),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTagForms() {
    return Container();
  }
}