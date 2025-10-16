import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/viewpost.dart';
class ProductScreen extends StatefulWidget {
  final String district;
  final String region;

  const ProductScreen({super.key, required this.district,required this.region});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late String uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
   @override
  void initState() {
    loadproduct();
    super.initState();
    uid = uidfind();

  }
  String selectedproduct="zote";
  late String pid;
Stream<QuerySnapshot> getUsers() {
  if(selectedproduct=="zote"){
     return FirebaseFirestore.instance
      .collection('userpost')
      .where('region', isEqualTo: widget.region)
      .where('distrname', isEqualTo: widget.district) // Add the second condition
      .snapshots();
  }else{
     return FirebaseFirestore.instance
      .collection('userpost')
      .where('region', isEqualTo: widget.region)
      .where('distrname', isEqualTo: widget.district)
      .where('pname', isEqualTo: selectedproduct) // Add the second condition
      .snapshots();
  }
 
}

  int l_data=0;
  String productSearchQuery = '';
  List  products = ["zote"];
  @override
  Widget build(BuildContext context) {  
    var filteredProducts = products
        .where((product) =>
            product.toLowerCase().contains(productSearchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Color.fromARGB(179, 13, 13, 13),
      appBar: AppBar(
         iconTheme: IconThemeData(color:Colors.white),
        title: Center(
          child: Text(
            'Products in ${widget.district.toLowerCase()}',
            style:TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.blueGrey.shade900.withAlpha(130), // Dark background for the app bar
      ),
      body: Column(
        children: [
          // Search bar for products  
         Container(
            height: 50,
            color: Colors.black, // Black background
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.1, vertical: 3),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tafuta bidhaa...',
                hintStyle: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              style: TextStyle(color: Colors.blueGrey),
              onChanged: (value) {
                setState(() {
                  productSearchQuery = value;
                });
              },
            ),
          ),
          // Horizontal scrollable list of products
          Container(height: MediaQuery.of(context).size.height*0.12,color: Color.fromARGB(255, 18, 18, 18),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        child: Chip(
                          backgroundColor: Colors.blueGrey.shade900, // Dark blue background for the chip
                          label: Text(
                            filteredProducts[index],
                            style:TextStyle(
                              color: Colors.white, // White text for contrast
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          elevation: 4, // Elevation to add a shadow effect
                          shadowColor: Colors.black54,
                        ),
                        onTap: () {
                           setState(() {
                      selectedproduct=products[index];});
                        },
                      ),
                       Radio(activeColor:Colors.white,   value: products[index], groupValue: selectedproduct, onChanged:(value){  
                                           }), 
                    ],
                       ),
                  );  
              },
            ),
          ),
        Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: getUsers(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }
      return ListView(
        children: snapshot.data!.docs.map((doc) {
          Timestamp timestamp = doc['created_at']; // Firestore value
          DateTime dateTime = timestamp.toDate();
           pid=doc.id;
         l_data = snapshot.data!.docs.length;
          return Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade900,
                  Colors.grey.shade900.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true, // Add this to constrain the ListView
              physics: NeverScrollableScrollPhysics(), // Prevent scroll conflict
              itemCount: l_data,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[700],
                thickness: 0.5,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('images/image1.webp'),
                    backgroundColor: Colors.blueAccent.withOpacity(0.3),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                        Text(
                            doc['username'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                      Row(
                        children: [
                          Icon(Icons.phone,
                                    color: Colors.grey[400], size: 16),
                                SizedBox(width: 4),
                          Text(
                            doc['phone'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        selectedproduct == "zote"
                            ? Row(
                              children: [
                                Icon(Icons.interests,
                                    color: Colors.grey[400], size: 16),
                                SizedBox(width: 4),
                                Text(
                                    "product: " + doc['pname'],
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            )
                            : SizedBox(),
                        Row(
                          children: [
                            Icon(Icons.email,
                                color: Colors.grey[400], size: 16),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dateTime.toString(),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone,
                                color: Colors.grey[400], size: 16),
                            SizedBox(width: 4),
                            Text(
                              "Phone: " + doc['quantyty'],
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.grey[400], size: 16),
                            SizedBox(width: 4),
                            Text(
                              "Mtaa: " + doc['mtaa'],
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewPost(pid:pid,userId_:uid,postuid:4)),
                    );
                  },
                );
              },
            ),
          );
        }).toList(),
      );
    },
  ),
),

Container(color: Color.fromARGB(179, 13, 13, 13),height: MediaQuery.sizeOf(context).height * 0.01 ,alignment: Alignment.bottomCenter,)
        ],
        
      ),
      
    );
  }
   String uidfind() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    }
    return '';
  }
  
  void loadproduct() {
    Stream<QuerySnapshot> getUsers() {
return FirebaseFirestore.instance.collection('product').snapshots();
}
  getUsers().listen((QuerySnapshot snapshot) {
    //int length = snapshot.docs.length;
    Map<String, dynamic>? data;
    int attributesLength=0;
    // Optionally, print each document data
    for (var doc in snapshot.docs) {
     data = doc.data() as Map<String, dynamic>;
    attributesLength = data.values.length;
    //attributesLength = data.keys.length;
      //print('Document ID: ${doc.id}');
      //print('Data: ${doc.data()}');
    }
    for(int i=1;i <= attributesLength;i++){
      products.add(data?['$i']);
    }
    setState(() {   
    });
  });
  }
}
