import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<ProductData> product = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var response =
          await http.get(Uri.parse('http://localhost:8001/products'));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          product = jsonList.map((item) => ProductData.fromJson(item)).toList();
        });
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> createProduct(
      String name, String description, double price) async {
    try {
      var response = await http.post(
          Uri.parse("http://localhost:8001/products"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(
              {"name": name, "description": description, "price": price}));
      if (response.statusCode == 201) {
        fetchData();
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateProduct(
      int idUpdate, String name, String description, double price) async {
    try {
      var response = await http.put(
          Uri.parse("http://localhost:8001/products/$idUpdate"),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(
              {"name": name, "description": description, "price": price}));
      if (response.statusCode == 200) {
        fetchData();
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteProduct(int idDelete) async {
    try {
      var response = await http
          .delete(Uri.parse("http://localhost:8001/products/$idDelete"));
      if (response.statusCode == 200) {
        fetchData();
      } else {
        throw Exception("Failed to delete products");
      }
    } catch (e) {
      print(e);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product'),
        backgroundColor: const Color.fromARGB(255, 164, 164, 164),
      ),
      body: ListView.separated(
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemCount: product.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
                leading: Text(
                  '${product[index].id}',
                  style: TextStyle(fontSize: 15),
                ),
                title: Text('${product[index].name}'),
                subtitle: Text('${product[index].description}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${product[index].price}.0',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 30,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showEditProductDialog(product[index]);
                          },
                          child: Text(
                            "Edit",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 79, 109, 219),
                            padding: EdgeInsets.all(10),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text('Delete Product'),
                                content: const Text('Press Confirm to delete.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Confirm'),
                                    child: const Text('Confirm'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Cancel'),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            ).then((result) {
                              if (result == 'Confirm') {
                                deleteProduct(product[index].id);
                              }
                            });
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 219, 88, 79),
                            padding: EdgeInsets.all(10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateProductDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateProductDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String name = nameController.text;
                String description = descriptionController.text;
                double price = double.tryParse(priceController.text) ?? 0.0;

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Create Success!'),
                  backgroundColor: Colors.green,
                ));
                createProduct(name, description, price);

                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showEditProductDialog(ProductData productData) {
    final TextEditingController nameController =
        TextEditingController(text: productData.name);
    final TextEditingController descriptionController =
        TextEditingController(text: productData.description);
    final TextEditingController priceController =
        TextEditingController(text: productData.price.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newName = nameController.text;
                String newDescription = descriptionController.text;
                double newPrice =
                    double.tryParse(priceController.text) ?? productData.price;

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Update Success!'),
                  backgroundColor: Colors.blue,
                ));
                updateProduct(
                    productData.id, newName, newDescription, newPrice);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class ProductData {
  final int id;
  final String name;
  final String description;
  final double price;
  ProductData(this.id, this.name, this.description, this.price);

  ProductData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        price = (json['price'] as num).toDouble();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
    };
  }
}
