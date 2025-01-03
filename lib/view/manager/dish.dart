import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'package:project_android_final/config/config_url.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class DishPage extends StatefulWidget {
  const DishPage({super.key});

  @override
  State<DishPage> createState() => _DishPageState();
}

class _DishPageState extends State<DishPage> {
  final List<Map<String, dynamic>> dishes = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? selectedImage;
  String? selectedImageUrl;

  List<Map<String, dynamic>> categories = [];
  int? selectedCategoryId;

  int currentPage = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    fetchDishes();
    fetchCategories();
  }

  Future<void> fetchDishes({int page = 1}) async {
    try {
      final response = await http.get(Uri.parse('${Config_URL.baseUrl}DishApi?page=$page&pageSize=$pageSize'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['\$values'] != null && jsonResponse['\$values'] is List) {
          final data = jsonResponse['\$values'] as List<dynamic>;
          setState(() {
            if (page == 1) dishes.clear();
            dishes.addAll(data.map((item) {
              return {
                "id": item['idDish'] ?? -1,
                "name": item['dishName'] ?? '',
                "description": item['description'] ?? '',
                "amount": item['amount'] ?? 0.0,
                "imageUrl": item['pictureUrlArray'] ?? '',
                "active": item['active'] ?? false,
              };
            }).toList());
          });
        } else {
          print("Error: `\$values` is null or not a list");
        }
      } else {
        print("Failed to fetch dishes: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching dishes: $e");
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

  Future<void> addDish(String name, String description, double amount, int categoryId) async {
    try {
      final response = await http.post(
        Uri.parse('${Config_URL.baseUrl}DishApi'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "dishName": name,
          "description": description,
          "amount": amount,
          "active": true,
          "idCategory": categoryId,
        }),
      );

      if (response.statusCode == 201) {
        final newDish = json.decode(response.body);
        print("Món ăn đã được thêm thành công: ${newDish['idDish']}");

        setState(() {
          dishes.add({
            "id": newDish['idDish'],
            "name": newDish['dishName'],
            "description": newDish['description'],
            "amount": newDish['amount'],
            "imageUrl": selectedImageUrl,
            "idCategory": newDish['idCategory'],
          });
        });

        if (selectedImageUrl != null && selectedImageUrl!.startsWith('blob:')) {
          final cloudinaryUrl = await uploadBlobToCloudinary(selectedImageUrl!);
          if (cloudinaryUrl != null) {
            await updateDishImage(newDish['idDish'], name, description, amount, categoryId, cloudinaryUrl);
          }
        }
      } else {
        print("Thêm món ăn thất bại: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      print("Lỗi khi thêm món ăn: $e");
    }
  }

  Future<void> updateDishImage(int dishId, String name, String description, double amount, int categoryId, String imageUrl) async {
    try {
      final response = await http.put(
        Uri.parse('${Config_URL.baseUrl}DishApi/$dishId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "idDish": dishId,
          "dishName": name,
          "description": description,
          "amount": amount,
          "idCategory": categoryId,
          "pictureUrlArray": imageUrl,
          "active": true,
        }),
      );

      if (response.statusCode == 204) {
        print("Cập nhật ảnh món ăn thành công!");
        setState(() {
          final index = dishes.indexWhere((dish) => dish['id'] == dishId);
          if (index != -1) {
            dishes[index]['imageUrl'] = imageUrl;
          }
        });
      } else {
        print("Cập nhật ảnh món ăn thất bại: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      print("Lỗi khi cập nhật ảnh món ăn: $e");
    }
  }

  Future<void> deleteDish(int index) async {
    final id = dishes[index]['id'];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc chắn muốn xóa món ăn này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(Uri.parse('${Config_URL.baseUrl}DishApi/$id'));
        if (response.statusCode == 204) {
          setState(() {
            dishes.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Xóa món ăn thành công!")));
        } else {
          print("Failed to delete dish: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Xóa món ăn thất bại!")));
        }
      } catch (e) {
        print("Error deleting dish: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi khi xóa món ăn!")));
      }
    }
  }

  Future<String?> uploadBlobToCloudinary(String blobUrl) async {
    try {
      final response = await http.get(Uri.parse(blobUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final dio = Dio();
        final formData = FormData.fromMap({
          "file": MultipartFile.fromBytes(
            bytes,
            filename: "uploaded_image.png",
          ),
        });

        final uploadResponse = await dio.post(
          '${Config_URL.baseUrl}Image/upload',
          data: formData,
        );

        if (uploadResponse.statusCode == 200) {
          final jsonResponse = uploadResponse.data;
          return jsonResponse['url'];
        } else {
          print("Upload ảnh thất bại: ${uploadResponse.statusCode}");
        }
      } else {
        print("Không thể tải blob: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi khi tải blob lên Cloudinary: $e");
    }
    return null;
  }

  void pickFileForWeb() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        final localUrl = await saveImageLocally(file);
        if (localUrl != null) {
          setState(() {
            selectedImageUrl = localUrl;
          });
          print("Ảnh đã lưu cục bộ: $localUrl");
        }
      }
    });
  }

  Future<String?> saveImageLocally(html.File file) async {
    try {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      await reader.onLoadEnd.first;

      final buffer = reader.result as Uint8List;
      final blob = html.Blob([buffer]);

      final objectUrl = html.Url.createObjectUrlFromBlob(blob);
      return objectUrl;
    } catch (e) {
      print("Lỗi khi lưu ảnh cục bộ: $e");
      return null;
    }
  }

  void showAddPopup() {
    nameController.clear();
    descriptionController.clear();
    amountController.clear();
    selectedImageUrl = null;
    selectedCategoryId = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thêm Món Mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Tên Món"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Chi Tiết"),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Giá"),
            ),
            DropdownButton<int>(
              isExpanded: true,
              value: selectedCategoryId,
              hint: const Text("Chọn Loại"),
              items: categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category['id'],
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: pickFileForWeb,
              child: const Text("Chọn Ảnh"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  amountController.text.isNotEmpty &&
                  selectedCategoryId != null) {
                await addDish(
                  nameController.text,
                  descriptionController.text,
                  double.parse(amountController.text),
                  selectedCategoryId!,
                );
              } else {
                print("Vui lòng nhập đầy đủ thông tin và chọn loại");
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

  Widget buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: currentPage > 1 ? () => fetchDishes(page: --currentPage) : null,
          child: const Text("Trang Trước"),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => fetchDishes(page: ++currentPage),
          child: const Text("Trang Sau"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản Lý Món Ăn"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: dishes.length,
              separatorBuilder: (context, index) => Divider(
                indent: 25,
                endIndent: 25,
                color: Colors.grey.withOpacity(0.5),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final dish = dishes[index];
                return ListTile(
                  leading: dish['imageUrl'] != null
                      ? (dish['imageUrl'].startsWith('blob:')
                      ? Image.network(dish['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                      : Image.network(dish['imageUrl'], width: 50, height: 50, fit: BoxFit.cover))
                      : const Icon(Icons.image, size: 50),
                  title: Text(
                    dish['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    dish['description'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Logic for editing
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteDish(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          buildPaginationControls(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddPopup,
        child: const Icon(Icons.add),
      ),
    );
  }
}
