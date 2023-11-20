import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:untitled1/Detail_report.dart';
import 'Data_reports.dart';


class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  late Future<List<Results>> reportsList;

  @override
  void initState() {
    super.initState();
    reportsList = _fetchNews();
  }

  Future<List<Results>> _fetchNews() async {
    final response = await http.get(Uri.parse("https://api.spaceflightnewsapi.net/v4/reports/?format=json"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      return data.map((result) => Results.fromJson(result)).toList();
    } else {
      throw Exception('Failed to load Reports');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Results>>(
        future: reportsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No reports available.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final reports = snapshot.data![index];
                return Card(
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      reports.title ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(reports.imageUrl ?? ''),
                        ),
                      ),
                    ),
                    onTap: () {
                      // Navigasi ke halaman detail news
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailReports(reports: reports),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
