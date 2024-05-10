import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async{
  runApp(MaterialApp(
    home: Home(),
    ));
      WidgetsFlutterBinding.ensureInitialized();
    await _insertInitialProduct();  
 
}

Future<void> _insertInitialProduct() async{
  var database = await _initializeDatabase();
  var Tv = Product(id: 1, nome: "Tc smart sansung", preco: 2000);
  var Celular = Product(id: 2, nome: "Iphone 12", preco: 3500);
  await _insertProduct(database, Tv);
  await _insertProduct(database, Celular);
}

Future<Database> _initializeDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), 'Product_a.db'),
    onCreate: (db, version) {
      db.execute(
        'CREATE TABLE producta(id INTEGER PRIMARY KEY, nome TEXT, preco REAL)',
      );
    },
    version: 1,
  );

}
Future<void> _insertProduct(Database database, Product product) async{
  await database.insert('producta', product.toMap(),
  conflictAlgorithm: ConflictAlgorithm.replace);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Product>> _Products;
  @override
  void initState(){
    super.initState();
    _Products = _fetchProducts();
  }
  Future<List<Product>> _fetchProducts()async{
    var database = await _initializeDatabase();
    final List<Map<String, dynamic>> maps = await database.query('producta');

    return List.generate(maps.length, (i){
      return Product(
        id: maps[i]['id'],
        nome: maps[i]['nome'],
        preco: maps[i]['preco'],
        );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("APP BD"),
      ),
      body: FutureBuilder<List<Product>>(
        future: _Products,
        builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
        }else if(snapshot.hasError){
          return Center(child: Text('Error: ${snapshot.error}'));
        }else {
          final products =snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index){
              final product = products[index];
              return ListTile(
                title: Text(product.nome),
                subtitle: Text('preco:${product.preco}'),
               ); 
              },          

            );  
               
          }
        },
      ),
    );
    
  }
}
class Product{
  final int id;
  String nome;
  final double preco;
  Product({
    required this.id,
    required this.nome,
    required this.preco
  });

  Map<String, dynamic> toMap(){
    return {'id':id, 'nome':nome, 'preco':preco};
  }
}