import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/posts.dart';
import 'package:grainapp/signupFirebase.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyPost extends StatefulWidget {
  const MyPost({super.key});

  @override
  State<MyPost> createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  @override
  void initState() {
    loadproduct();
    super.initState();
  }

  String? selectedProduct;
  String? selectedRegion;
  String? selectedDistrict;
  late String productname;
  late String districtname;
  late String regionname;
  List<String> products = [];
  List<String> districtopt = [];
  List district = [
    ["ARUMERU", "ARUSHA", "ARUSHA JIJI", "KARATU", "LONGIDO", "MONDULI", "NGORONGORO"],
    ["ILALA", "KIGAMBONI", "KINONDONI", "TEMEKE", "UBUNGO"],
    ["BAHI", "CHAMWINO", "CHAMWINO DC", "CHEMBA", "DODOMA", "KONDOA", "KONGWA", "MPWAPWA"],
    ["BUKOMBE", "CHATO", "GEITA", "MBOGWE", "NYANG'WALE"],
    ["IRINGA", "KILOLO", "MUFINDI", "MAFINGA"],
    ["BIHARAMULO", "BUKOBA", "KARAGWE", "KYERWA", "MISSENYI", "MULEBA", "NGARA"],
    ["MLELE", "MPANDA", "TANGANYIKA"],
    ["BUHIGWE", "KAKONKO", "KASULU", "KIBONDO", "KIGOMA", "UVINZA"],
    ["HAI", "MOSHI", "MWANGA", "ROMBO", "SAME", "SIHA"],
    ["KILWA", "LINDI", "LIWALE", "NACHINGWEA", "RUANGWA"],
    ["BABATI", "HANANG", "KITETO", "MBULU", "SIMANJIRO"],
    ["BUNDA", "BUTIAMA", "MUSOMA", "RORYA", "SERENGETI", "TARIME"],
    ["CHUNYA", "KYELA", "MBARALI", "MBEYA", "RUNGWE", "TUKUYU"],
    ["GAIRO", "KILOMBERO", "KILOSA", "MALINYI", "MOROGORO", "MVOMERO", "ULANGA"],
    ["MASASI", "MTWARA", "NANYUMBU", "NEWALA", "TANDAHIMBA"],
    ["ILEMELA", "KWIMBA", "MAGU", "MISUNGWI", "NYAMAGANA", "SENGEREMA", "UKEREWE"],
    ["LUDEWA", "MAKETE", "NJOMBE", "WANG'ING'OMBE"],
    ["BAGAMOYO", "KIBAHA", "KIBITI", "KISARAWE", "MAFIA", "MKURANGA", "RUFIJI"],
    ["KALAMBO", "NKASI", "SUMBAWANGA"],
    ["MBINGA", "NAMTUMBO", "NYASA", "SONGEA", "TUNDURU"],
    ["KAHAMA", "KISHAPU", "SHINYANGA"],
    ["BARIADI", "BUSEGA", "ITILIMA", "MASWA", "MEATU"],
    ["IKUNGI", "IRAMBA", "MANYONI", "MKALAMA", "SINGIDA"],
    ["ILEJE", "MBOZI", "MOMBA", "SONGWE"],
    ["IGUNGA", "KALIUA", "NZEGA", "SIKONGE", "TABORA", "URAMBO", "UYUI"],
    ["HANDENI", "KILINDI", "KOROGWE", "LUSHOTO", "MKINGA", "MUHEZA", "PANGANI", "TANGA"],
    ["PEMBA KASKAZINI", "PEMBA KUSINI", "UNGUJA MJINI MAGHRIB", "UNGUJA KASKAZINI", "UNGUJA KUSINI"]
  ];
  List regions = [
    "ARUSHA",
    "DAR ES SALAAM",
    "DODOMA",
    "GEITA",
    "IRINGA",
    "KAGERA",
    "KATAVI",
    "KIGOMA",
    "KILIMANJARO",
    "LINDI",
    "MANYARA",
    "MARA",
    "MBEYA",
    "MOROGORO",
    "MTWARA",
    "MWANZA",
    "NJOMBE",
    "PWANI",
    "RUKWA",
    "RUVUMA",
    "SHINYANGA",
    "SIMIYU",
    "SINGIDA",
    "SONGWE",
    "TABORA",
    "TANGA",
    "ZANZIBAR"
  ];

  TextEditingController quantityController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController explainController = TextEditingController();
  TextEditingController mtaaController = TextEditingController();

  File? _profileImage;
  var filename;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
        filename = pickedFile.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey.shade800.withOpacity(0.9),
        title: const Text(
          'Product Form',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blueGrey.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedProduct,
                  items: products
                      .map((product) => DropdownMenuItem(
                            value: product,
                            child: Text(
                              product,
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedProduct = value;
                    productname = selectedProduct!;
                  }),
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.production_quantity_limits, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey.shade400),
                    ),
                  ),
                  dropdownColor: Colors.blueGrey.shade800,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Quantity (kg)',
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.format_list_numbered, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 1),
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white),
                      gradient: LinearGradient(
                        colors: [Colors.blueGrey.shade900, Colors.black],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_profileImage != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Image.file(
                      _profileImage!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                TextField(
                  controller: explainController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: 'Explanation',
                    labelStyle: const TextStyle(color: Colors.white),
                    prefixIcon: const Icon(Icons.copy, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                DropdownButtonFormField<String>(
                  value: selectedRegion,
                  items: regions.map((region) {
                    return DropdownMenuItem<String>(
                      value: region,
                      child: Text(
                        region,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() {
                    selectedRegion = null;
                    selectedDistrict = null;
                    selectedRegion = value;
                    districtopt = district[regions.indexOf(value)];
                    regionname = selectedRegion!;
                  }),
                  decoration: InputDecoration(
                    labelText: 'Region',
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.location_on, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey.shade400),
                    ),
                  ),
                  dropdownColor: Colors.blueGrey.shade600,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDistrict,
                  items: districtopt
                      .map((district) => DropdownMenuItem(
                            value: district,
                            child: Text(
                              district,
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedDistrict = value;
                    districtname = selectedDistrict!;
                  }),
                  decoration: InputDecoration(
                    labelText: 'District',
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.map, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey.shade400),
                    ),
                  ),
                  dropdownColor: Colors.blueGrey.shade800,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.phone, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: mtaaController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mtaa',
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.home, color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blueGrey.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      String mtaa = mtaaController.text;
                      String quantyty = quantityController.text;
                      String phone = phoneController.text;
                      String explain = explainController.text;
                      int post = await userPost(mtaa, quantyty, phone, explain, productname, regionname, districtname, _profileImage?.path ?? "path");
                      if (post == 0) {
                        setState(() {
                          phoneController.clear();
                          mtaaController.clear();
                          quantityController.clear();
                          explainController.clear();
                          selectedProduct = null;
                          selectedRegion = null;
                          selectedDistrict = null;
                          _profileImage = null;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductCard(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    ),
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text('Submit', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void loadproduct() {
    Stream<QuerySnapshot> getUsers() {
      return FirebaseFirestore.instance.collection('product').snapshots();
    }

    getUsers().listen((QuerySnapshot snapshot) {
      Map<String, dynamic>? data;
      int attributesLength = 0;
      for (var doc in snapshot.docs) {
        data = doc.data() as Map<String, dynamic>;
        attributesLength = data.values.length;
      }
      for (int i = 1; i <= attributesLength; i++) {
        products.add(data?['$i']);
      }
      setState(() {});
    });
  }
}

