import 'package:flutter/material.dart';
import 'package:untitled1/Data.blog.dart';
import 'package:untitled1/Detail_blog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Blogs extends StatefulWidget {
  @override
  _BlogsState createState() => _BlogsState();
}

class _BlogsState extends State<Blogs> {
  late Future<List<Results>> blogsList;

  @override
  void initState() {
    super.initState();
    blogsList = _fetchBlogs();
  }

  Future<List<Results>> _fetchBlogs() async {
    final response = await http.get(Uri.parse("https://api.spaceflightnewsapi.net/v4/blogs/?format=json"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['results'];
      return data.map((result) => Results.fromJson(result)).toList();
    } else {
      throw Exception('Failed to load blogs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blogs',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, // Remove app bar shadow
      ),
      body: FutureBuilder<List<Results>>(
        future: blogsList,
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
              child: Text('No blogs available.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final blog = snapshot.data![index];
                return Card(
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      blog.title ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Image.network(
                        blog.imageUrl ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailBlogs(blog: blog),
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
