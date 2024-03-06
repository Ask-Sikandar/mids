import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'launch_model.dart';
import 'dart:math' as math;

class SpaceMissions extends StatefulWidget {
  const SpaceMissions({super.key});

  @override
  State<SpaceMissions> createState() => _SpaceMissionsState();
}


class DescriptionTextWidget extends StatefulWidget {
  final String text;

  DescriptionTextWidget({required this.text});

  @override
  _DescriptionTextWidgetState createState() => new _DescriptionTextWidgetState();
}

class _DescriptionTextWidgetState extends State<DescriptionTextWidget> {
  late String firstHalf;
  late String secondHalf;

  bool flag = true;

  @override
  void initState() {
    super.initState();

    if (widget.text.length > 50) {
      firstHalf = widget.text.substring(0, 50);
      secondHalf = widget.text.substring(50, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding:  EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: secondHalf.isEmpty
          ?  Text(firstHalf)
          :  Column(
        children: <Widget>[
           Text(flag ? (firstHalf + "...") : (firstHalf + secondHalf)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {

                  setState(() {
                    flag = !flag;
                  });
                },
                child: Text(
                  flag ? "show more" : "show less",
                  style: new TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpaceMissionsState extends State<SpaceMissions> {
  var expandedText = false;
  Future<List<Launch>> fetchData() async {
    Uri url = Uri.parse('https://api.spacexdata.com/v3/missions');
    List<Launch> myList;
    try {
      http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        var list = jsonDecode(response.body);
        myList = list.map<Launch>((e) => Launch.fromJson(e)).toList();
        return myList;
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception('Error occurred');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: fetchData(),
          builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error Retrieving Data'));
        } else {
          List<Launch> myList = snapshot.data!;
          return ListView(
            children: [
              for(Launch i in myList)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(i.missionName!,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),
                        ),
                        DescriptionTextWidget(text: i.description!),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 9.0,
                          children: [
                            for(var j in i.payloadIds!)
                              Chip(
                                label: Text(j),
                                backgroundColor: Color.fromARGB(
                                  math.Random().nextInt(255),
                                  math.Random().nextInt(255),
                                  math.Random().nextInt(255),
                                  math.Random().nextInt(255),
                                ),
                              )
                          ],
                  )
              ]),
            )
              ))],
          );
        }
      })
    );
  }
}
