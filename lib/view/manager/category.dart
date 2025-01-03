import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:project_android_final/config/config_url.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final List<Map<String, dynamic>> categories = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> addCategory(String name, String description) async {
    try {
      final response = await http.post(
        Uri.parse('${Config_URL.baseUrl}CategoryApi'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"categoryName": name, "description": description, "active": true}),
      );
      if (response.statusCode == 201) {
        final newCategory = json.decode(response.body);
        setState(() {
          categories.add({
            "id": newCategory['idCategory'],
            "name": newCategory['categoryName'],
            "description": newCategory['description'],
            "active": newCategory['active'],
          });
        });
      } else {
        print("Failed to add category: ${response.statusCode}");
      }
    } catch (e) {
      print("Error adding category: $e");
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('${Config_URL.baseUrl}CategoryApi'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['\$values'] != null && jsonResponse['\$values'] is List) {
          final data = jsonResponse['\$values'] as List<dynamic>;
          setState(() {
            categories.clear();
            categories.addAll(data.map((item) {
              return {
                "id": item['idCategory'] ?? -1,
                "name": item['categoryName'] ?? '',
                "description": item['description'] ?? '',
                "active": item['active'] ?? false,
              };
            }).toList());
          });
        } else {
          print("Error: `\$values` is null or not a list");
        }
      } else {
        print("Failed to fetch categories: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> updateCategory(int id, String name, String description) async {
    try {
      final response = await http.put(
        Uri.parse('${Config_URL.baseUrl}CategoryApi/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"categoryName": name, "description": description, "active": true}),
      );
      if (response.statusCode == 204) {
        setState(() {
          final index = categories.indexWhere((category) => category['id'] == id);
          if (index != -1) {
            categories[index] = {
              "id": id,
              "name": name,
              "description": description,
              "active": true,
            };
          }
        });
      } else {
        print("Failed to update category: ${response.statusCode}");
      }
    } catch (e) {
      print("Error updating category: $e");
    }
  }

  Future<void> deleteCategory(int index) async {
    try {
      final id = categories[index]['id'];
      if (id == null || id == -1) {
        print("Invalid ID for category at index $index");
        return;
      }

      final response = await http.delete(Uri.parse('${Config_URL.baseUrl}CategoryApi/$id'));
      if (response.statusCode == 204) {
        setState(() {
          categories.removeAt(index);
        });
      } else {
        print("Failed to delete category: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting category: $e");
    }
  }

  void showAddPopup() {
    nameController.clear();
    descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm Loại Mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Tên Loại"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Chi Tiết"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                addCategory(nameController.text, descriptionController.text);
              } else {
                print("Vui lòng nhập đầy đủ thông tin!");
              }
              Navigator.pop(context);
            },
            child: const Text("Thêm"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Hủy"),
          ),
        ],
      ),
    );
  }

  void showEditPopup(int id, String currentName, String currentDescription) {
    nameController.text = currentName;
    descriptionController.text = currentDescription;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sửa Loại"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Tên Loại"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Chi Tiết"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                updateCategory(id, nameController.text, descriptionController.text);
              } else {
                print("Vui lòng nhập đầy đủ thông tin!");
              }
              Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Hủy"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Quản Lý Loại"),
      ),
      body: ListView.separated(
        itemCount: categories.length,
        separatorBuilder: (context, index) => Divider(
          indent: 25,
          endIndent: 25,
          color: Colors.grey.withOpacity(0.5),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            tileColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            title: Text(
              category['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(category['description']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => showEditPopup(
                    category['id'],
                    category['name'],
                    category['description'],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteCategory(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddPopup,
        child: const Icon(Icons.add),
      ),
    );
  }
}
