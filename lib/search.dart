import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class Food implements Comparable<Food> {
  String name = "";
  String brand = "";
  int calories = 0;

  Food(this.name, this.brand, this.calories);

  @override
  int compareTo(Food other) => name.compareTo(other.name);
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(title: const Text('Search Page'), actions: [
          IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
              icon: const Icon(Icons.search))
        ]));
  }
}

class CustomSearchDelegate extends SearchDelegate {
  List<Food> suggestions = [];
  var body = {};
  getFood(searchedFood) async {
    print(searchedFood);
    suggestions = [];
    var url1 = Uri.parse(
        'https://api.nal.usda.gov/fdc/v1/foods/search?query=apple&api_key=4xuCPTczsw6SIyIYMbnwiXp5VLhOv3iYHqPt0Frv&query=$searchedFood&pageSize=100&dataType=Branded');
    print("hello");
    var response = await http.get(url1);
    print("goodbye");
    print(response);
    print("body");

    body = jsonDecode(response.body);
    print(body.length);
    print(body);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = "";
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    getFood(query);
    var num = 0;
    return ListView.builder(
      itemCount: body["foods"].length,
      itemBuilder: (context, index) {
        print(index);
        print(body);
        var result = body["foods"][index];
        print(body["foods"].length);
        num = index;
        return Card(
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SecondRoute(body1: body["foods"][index])),
              );
            },
            title: Text(result["lowercaseDescription"]),
            subtitle: Text(result["brandOwner"]),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var length = 0;
    getFood(query);
    print(body["foods"]);
    if (!query.isEmpty && body["foods"] != null) {
      length = body["foods"].length;
    } else {
      length = 0;
    }
    return ListView.builder(
      itemCount: length,
      itemBuilder: (context, index) {
        print(index);
        print(body);
        var result = body["foods"][index];
        return Card(
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SecondRoute(body1: body["foods"][index])),
              );
            },
            title: Text(result["lowercaseDescription"]),
            subtitle: Text(result["brandOwner"]),
          ),
        );
      },
    );
  }
}

class SecondRoute extends StatelessWidget {
  SecondRoute({Key? key, required this.body1}) : super(key: key);
  final body1;
  final List<String> list = <String>['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Water'];
  String dropdownValue = "Breakfast";

  RegisterUser(food,servings,meal) async {
    final storage = new FlutterSecureStorage();
    String? value = await storage.read(key: "token");

    var header = {"Content-Type": "Application/JSON"};
    print("food");
    print(food);

    var body = {
      'food': food,
      'servings': int.parse(servings),
      'meal': meal,
    };

    print("I love tokens");
    print(value);
    print("USER DATA: ${body}");
    final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/addfood?value=$value'),
        headers: header,
        body: jsonEncode(body));

    var data = jsonDecode(response.body);

    print("Data");
    print(data);

  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final myController = TextEditingController();
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Adding to Journal'),
          ),
          body: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'NAME',
                    style: TextStyle(
                      color: Colors.grey,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    body1["lowercaseDescription"],
                    style: TextStyle(
                      color: Colors.amberAccent[200],
                      fontWeight: FontWeight.bold,
                      fontSize: 28.0,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Calories',
                    style: TextStyle(
                      color: Colors.grey,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    body1["foodNutrients"][4]["value"].toString(),
                    style: TextStyle(
                      color: Colors.amberAccent[200],
                      fontWeight: FontWeight.bold,
                      fontSize: 28.0,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 7.0),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 10.0),
                            Text(
                              'Carbs',
                              style: TextStyle(
                                color: Colors.grey,
                                letterSpacing: 2.0,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              body1["foodNutrients"][3]["value"].toString(),
                              style: TextStyle(
                                color: Colors.amberAccent[200],
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                letterSpacing: 2.0,
                              ),
                            )
                          ],
                        ),
                        SizedBox(width: 35),
                        Column(
                          children: [
                            SizedBox(height: 10.0),
                            Text(
                              '   Protein',
                              style: TextStyle(
                                color: Colors.grey,
                                letterSpacing: 2.0,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              body1["foodNutrients"][1]["value"].toString(),
                              style: TextStyle(
                                color: Colors.amberAccent[200],
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 35),
                        Column(
                          children: [
                            SizedBox(height: 10.0),
                            Text(
                              '   Fat',
                              style: TextStyle(
                                color: Colors.grey,
                                letterSpacing: 2.0,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              body1["foodNutrients"][2]["value"].toString(),
                              style: TextStyle(
                                color: Colors.amberAccent[200],
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(
                        controller: myController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Enter number of servings consumed',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a number';
                          }
                          return null;
                        },
                      ),
                    ]),
                  ),
                  Row(
                    children: [
                      Text("Choose your meal:   ",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16.0,
                          )),
                      DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(color: Colors.green),
                        underline: Container(
                          height: 3,
                          color: Colors.green,
                        ),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            dropdownValue = value!;
                          });
                        },
                        items: list.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print("Form Data");
                        print(body1);
                        print(myController.text);
                        print(dropdownValue);
                        Navigator.pop(context);
                        RegisterUser(body1,myController.text,dropdownValue);
                        setState(() {});
                      }
                    },
                    child: Text("Submit"),
                  ),
                ]),
          )));
      },
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

const List<String> list = <String>['Breakfast', 'Lunch', 'Dinner', 'Snack'];

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.green),
      underline: Container(
        height: 3,
        color: Colors.green,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}