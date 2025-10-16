import 'dart:async';
//import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/ChatUsersScreen.dart';
import 'package:grainapp/abautapp.dart';
import 'package:grainapp/authentificatin.dart';
import 'package:grainapp/developer.dart';
import 'package:grainapp/districtscreen.dart';
import 'package:grainapp/mypost.dart';
import 'package:grainapp/posts.dart';
import 'package:grainapp/profile.dart';
import 'package:grainapp/signupFirebase.dart';
import 'package:grainapp/viewpost.dart';
class RegionScreen extends StatefulWidget {
  const RegionScreen({super.key});

  @override
  State<RegionScreen> createState() => _RegionScreenState();
}

class _RegionScreenState extends State<RegionScreen> {
String? uid; 
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _pagecontrol = PageController(initialPage: 0);
  final _imagecontroler = PageController(initialPage: 0);
  int imageindex = 0;
  int currentpage = 0;
  int l_data=0;
  int count = 0;
  late String pid;
  late String poid;
  String regionSearchQuery = '';
  String selectedproduct="zote";
  String productSearchQuery = '';
 final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
 String activePage = 'Programmer';
  @override
  void initState() {
    super.initState();
    imageshift();
    loadproduct();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          uid = user.uid;
        });
    }
    });
  }
  Stream<QuerySnapshot> getUserss() {
  if(selectedproduct=="zote"){
     return FirebaseFirestore.instance
      .collection('userpost')
      //.where('region', isEqualTo: widget.region)
      //.where('distrname', isEqualTo: widget.district) // Add the second condition
      .snapshots();
  }else{
     return FirebaseFirestore.instance
      .collection('userpost')
      //.where('region', isEqualTo: widget.region)
      //.where('distrname', isEqualTo: widget.district)
      .where('pname', isEqualTo: selectedproduct) // Add the second condition
      .snapshots();
  }
 
}

  void imageshift() {
    int prev = -1;
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (prev <= imageindex) {
        if (imageindex < 7) {
          _imagecontroler.nextPage(
              duration: Duration(seconds: 3), curve: Curves.ease);
          prev++;
        } else {
          prev++;
        }
      } else {
        if (imageindex != 0) {
          _imagecontroler.previousPage(
              duration: Duration(seconds: 3), curve: Curves.ease);
        } else {
          prev = -1;
        }
      }
    });
  }
  List  products = ["zote"];
  @override
  Widget build(BuildContext context) {
  List regions =  [
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
 var filteredProducts = products
        .where((product) =>
        product.toLowerCase().contains(productSearchQuery.toLowerCase()))
        .toList();
    var filteredRegions = regions
        .where((regions) =>
        regions.toLowerCase().contains(regionSearchQuery.toLowerCase()))
        .toList();
        imageindex = 0;

    return WillPopScope(
      onWillPop: ()async {
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        appBar: AppBar(
           iconTheme: IconThemeData(color:Colors.white),
        
        backgroundColor:Colors.blueGrey.shade900,
       
           // Matches the design
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            setState(() {
                  activePage = 'Programmer';
                });
            _scaffoldKey.currentState?.openDrawer(); // Open the drawer using the global key
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'BISSNESS ON YOUR HAND',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
          '***',
          style: TextStyle(
            color: Colors.white.withBlue(200),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
          ],
        ),
        centerTitle: true,
      ),
       drawer: Drawer(
        backgroundColor: Colors.blueGrey.shade800,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey.shade900, Colors.black],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
             ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text(
                'home',
                style: TextStyle(color: Colors.white),
              ),
              selected: activePage == 'Programmer',
              selectedTileColor: Colors.black54,
              selectedColor: Colors.purple,
              onTap: () {
                setState(() {
                  activePage = 'Programmer';
                });
               // _scaffoldKey.currentState?.closeDrawer();
                 Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>RegionScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  ),
);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'Profile',
                style: TextStyle(color: Colors.white),
              ),
              selected: activePage == 'Profile',
              selectedTileColor: Colors.black54,
              selectedColor: Colors.purple,
              onTap: () {
                setState(() {
                  activePage = 'Profile';
                });
                //_scaffoldKey.currentState?.closeDrawer();
                  Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>Profile(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  ),
);
              
              },
            ),
            ListTile(
              leading: const Icon(Icons.post_add, color: Colors.white),
              title: const Text(
                'Post Order',
                style: TextStyle(color: Colors.white),
              ),
              selected: activePage == 'Post Order',
              selectedTileColor: Colors.black54,
              selectedColor: Colors.purple,
              onTap: () {
                setState(() {
                  activePage = 'Post Order';
                });
               // _scaffoldKey.currentState?.closeDrawer();
                 Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>MyPost(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  ),
);
             
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.white),
              title: const Text(
                'My Order',
                style: TextStyle(color: Colors.white),
              ),
              selected: activePage == 'My Order',
              selectedTileColor: Colors.black54,
              selectedColor: Colors.purple,
              onTap: () {
                setState(() {
                  activePage = 'My Order';
                });
               // _scaffoldKey.currentState?.closeDrawer();
                 Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>ProductCard(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  ),
);
              
              },
            ),
       ListTile(
      leading: uid == null
          ? const Icon(Icons.chat, color: Colors.white)
          : StreamBuilder<int>(
              stream: getUnreadChatsCount(uid!),
              builder: (context, snapshot) {
                count = snapshot.data ?? 0;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.chat, color: Colors.white),
                    if (count > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
      title: const Text('Chats', style: TextStyle(color: Colors.white)),
      onTap: () {
        if (uid == null) return; // Prevent navigation if uid not ready
        setState(() {
          activePage = 'Chats';
        });
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ChatUsersScreen(currentUserId: uid!),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween = Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
    ),

            ListTile(
              leading: const Icon(Icons.read_more, color: Colors.white),
              title: const Text(
                'About App',
                style: TextStyle(color: Colors.white),
              ),
              selected: activePage == 'About App',
              selectedTileColor: Colors.black54,
              selectedColor: Colors.purple,
              onTap: () {
                setState(() {
                  activePage = 'About App';
                });
               // _scaffoldKey.currentState?.closeDrawer();
                 Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>AboutAppPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  ),
);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_pin_rounded, color: Colors.white),
              title: const Text(
                'About us',
                style: TextStyle(color: Colors.white),
              ),
              selected: activePage == 'developer',
              selectedTileColor: Colors.black54,
              selectedColor: Colors.purple,
              onTap: () {
                setState(() {
                  activePage = 'developer';
                });
               // _scaffoldKey.currentState?.closeDrawer();
  Navigator.push(
  context,
  PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>DeveloperProfilePage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  ),
);

               // Navigator.push(
                //  context,
                 // MaterialPageRoute(builder: (context) =>DeveloperProfilePage()),
               // );
              },
            ),
           
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton(
                onPressed: () {
                  _scaffoldKey.currentState?.closeDrawer();
                  signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Center(
                  child: Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    
    
      body: PageView(
         physics: NeverScrollableScrollPhysics(),
          controller: _pagecontrol,
          children: [
            Column(
              children: [
                Container(margin:EdgeInsets.only(top: 3),
                  height: MediaQuery.sizeOf(context).height * 0.3,
                  child: PageView(
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      controller: _imagecontroler,
                      onPageChanged: (value) {
                        imageindex = value;
                      },
                      children: [
                        Container(
        padding: EdgeInsets.symmetric(horizontal: 20), // Reduce padding for better alignment
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/image1.webp'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.3), // Adds a dark overlay to make text stand out
          BlendMode.darken,
        ),
      ),
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(50),
        bottomLeft: Radius.circular(50),
      ),
      color: Colors.white,
        ),
        height: MediaQuery.sizeOf(context).height * 0.3,
        child: Center(
      child: Container(
        padding: EdgeInsets.all(15), // Padding to space text inside the container
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Semi-transparent background for readability
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'Nafaka nzuri kwa ajili ya lishe bora ya mama na mtoto! Ulipo tupo!!',
          style: const TextStyle(
            color: Colors.white, // White color for better contrast on image
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2, // Adds spacing between letters for readability
            height: 1.5, // Line height for better spacing between lines
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Color.fromARGB(150, 0, 0, 0), // Adds a shadow for depth
              ),
            ],
          ),
          textAlign: TextAlign.center, // Centers the text
        ),
      ),
        ),
      ),
      
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20), // Reduce padding for better alignment
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/image2.jpeg'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.3), // Adds a dark overlay to make text stand out
          BlendMode.darken,
        ),
      ),
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(50),
        bottomLeft: Radius.circular(50),
      ),
      color: Colors.white,
        ),
        height: MediaQuery.sizeOf(context).height * 0.3,
        child: Center(
      child: Container(
        padding: EdgeInsets.all(15), // Padding to space text inside the container
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Semi-transparent background for readability
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'Nafaka nzuri kwa ajili ya lishe bora ya mama na mtoto! Ulipo tupo!!',
          style: const TextStyle(
            color: Colors.white, // White color for better contrast on image
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2, // Adds spacing between letters for readability
            height: 1.5, // Line height for better spacing between lines
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Color.fromARGB(150, 0, 0, 0), // Adds a shadow for depth
              ),
            ],
          ),
          textAlign: TextAlign.center, // Centers the text
        ),
      ),
        ),
      ),
       
      
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20), // Reduce padding for better alignment
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/image3.jpeg'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.3), // Adds a dark overlay to make text stand out
          BlendMode.darken,
        ),
      ),
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(50),
        bottomLeft: Radius.circular(50),
      ),
      color: Colors.white,
        ),
        height: MediaQuery.sizeOf(context).height * 0.3,
        child: Center(
      child: Container(
        padding: EdgeInsets.all(15), // Padding to space text inside the container
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Semi-transparent background for readability
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'Nafaka nzuri kwa ajili ya lishe bora ya mama na mtoto! Ulipo tupo!!',
          style: const TextStyle(
            color: Colors.white, // White color for better contrast on image
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2, // Adds spacing between letters for readability
            height: 1.5, // Line height for better spacing between lines
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Color.fromARGB(150, 0, 0, 0), // Adds a shadow for depth
              ),
            ],
          ),
          textAlign: TextAlign.center, // Centers the text
        ),
      ),
        ),
      ),                    
                      
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20), // Reduce padding for better alignment
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/image4.jpeg'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.3), // Adds a dark overlay to make text stand out
          BlendMode.darken,
        ),
      ),
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(50),
        bottomLeft: Radius.circular(50),
      ),
      color: Colors.white,
        ),
        height: MediaQuery.sizeOf(context).height * 0.3,
        child: Center(
      child: Container(
        padding: EdgeInsets.all(15), // Padding to space text inside the container
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Semi-transparent background for readability
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'Nafaka nzuri kwa ajili ya lishe bora ya mama na mtoto! Ulipo tupo!!',
          style: const TextStyle(
            color: Colors.white, // White color for better contrast on image
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2, // Adds spacing between letters for readability
            height: 1.5, // Line height for better spacing between lines
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Color.fromARGB(150, 0, 0, 0), // Adds a shadow for depth
              ),
            ],
          ),
          textAlign: TextAlign.center, // Centers the text
        ),
      ),
        ),
      ),                  
      
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20), // Reduce padding for better alignment
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/image5.jpeg'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.3), // Adds a dark overlay to make text stand out
          BlendMode.darken,
        ),
      ),
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(50),
        bottomLeft: Radius.circular(50),
      ),
      color: Colors.white,
        ),
        height: MediaQuery.sizeOf(context).height * 0.3,
        child: Center(
      child: Container(
        padding: EdgeInsets.all(15), // Padding to space text inside the container
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Semi-transparent background for readability
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'Nafaka nzuri kwa ajili ya lishe bora ya mama na mtoto! Ulipo tupo!!',
          style: const TextStyle(
            color: Colors.white, // White color for better contrast on image
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2, // Adds spacing between letters for readability
            height: 1.5, // Line height for better spacing between lines
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Color.fromARGB(150, 0, 0, 0), // Adds a shadow for depth
              ),
            ],
          ),
          textAlign: TextAlign.center, // Centers the text
        ),
      ),
        ),
      ), 
      
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20), // Reduce padding for better alignment
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/image6.jpeg'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.3), // Adds a dark overlay to make text stand out
          BlendMode.darken,
        ),
      ),
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(50),
        bottomLeft: Radius.circular(50),
      ),
      color: Colors.white,
        ),
        height: MediaQuery.sizeOf(context).height * 0.3,
        child: Center(
      child: Container(
        padding: EdgeInsets.all(15), // Padding to space text inside the container
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Semi-transparent background for readability
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'Nafaka nzuri kwa ajili ya lishe bora ya mama na mtoto! Ulipo tupo!!',
          style: const TextStyle(
            color: Colors.white, // White color for better contrast on image
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2, // Adds spacing between letters for readability
            height: 1.5, // Line height for better spacing between lines
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Color.fromARGB(150, 0, 0, 0), // Adds a shadow for depth
              ),
            ],
          ),
          textAlign: TextAlign.center, // Centers the text
        ),
      ),
        ),
      ),
      
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20), // Reduce padding for better alignment
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/image7.jpeg'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.3), // Adds a dark overlay to make text stand out
          BlendMode.darken,
        ),
      ),
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(50),
        bottomLeft: Radius.circular(50),
      ),
      color: Colors.white,
        ),
        height: MediaQuery.sizeOf(context).height * 0.3,
        child: Center(
      child: Container(
        padding: EdgeInsets.all(15), // Padding to space text inside the container
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Semi-transparent background for readability
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          'Nafaka nzuri kwa ajili ya lishe bora ya mama na mtoto! Ulipo tupo!!',
          style: const TextStyle(
            color: Colors.white, // White color for better contrast on image
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2, // Adds spacing between letters for readability
            height: 1.5, // Line height for better spacing between lines
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Color.fromARGB(150, 0, 0, 0), // Adds a shadow for depth
              ),
            ],
          ),
          textAlign: TextAlign.center, // Centers the text
        ),
      ),
        ),
      ),
      
      ]),
                ),
                Container(
                  height: 50,
                  color: Color.fromARGB(255, 14, 13, 13),
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width * 0.1,
                      vertical: 3),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '       Tafuta mkoa...',
                      hintStyle: TextStyle(color: Colors.blueGrey),
                      prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    style: TextStyle(color: Colors.blueGrey),
                    onChanged: (value) {
                      setState(() {
                        regionSearchQuery = value;
                      });
                      
                    },
                  ),
                ),
                Expanded(
                  child:Container(
        padding: EdgeInsets.all(10),
        child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of items per row
        crossAxisSpacing: 10, // Horizontal space between grid items
        mainAxisSpacing: 10, // Vertical space between grid items
        childAspectRatio: 3 / 2, // Aspect ratio for grid items
      ),
      itemCount: filteredRegions.length,
      itemBuilder: (context, index) {
         return StreamBuilder<int>(
                  stream: FirebaseFirestore.instance
                      .collection('userpost')
                      .where('region', isEqualTo: filteredRegions[index])
                      .snapshots()
                      .map((snapshot) => snapshot.docs.length),
                  builder: (context, sdatalSnapshot) {
                  final datal = sdatalSnapshot.data ?? 0;
                       return GestureDetector(
          onTap: () {
            int regionid=regions.indexOf(filteredRegions[index]);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DistrictScreen(region: filteredRegions[index],regionid:regionid),
              ),
            );
          },
          child: Card(
            elevation: 5, // Adds shadow for a lifted effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child:Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      gradient: LinearGradient(
        colors: [Colors.blueGrey.shade700, Colors.blueGrey.shade400],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
        ),
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          filteredRegions[index],
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart, // Order icon
              color: Colors.white70,
              size: 18,
            ),
            SizedBox(width: 5),
            Text(
              "Jumla ya order:", // You can dynamically replace '70' with a variable
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        SizedBox(width: 5),
        Text(
              "$datal  leo!", // You can dynamically replace '70' with a variable
              style: TextStyle(
                color:  Colors.white.withBlue(200),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
      ],
        ),
      ),
          ),
        );}
                    );


   
      },
        ),
      ),
                ),
              ],
            ),
            Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(7),),
            child:  Column(
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
    stream: getUserss(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }
      return ListView(
        children: snapshot.data!.docs.map((doc) {
          Timestamp timestamp = doc['created_at']; // Firestore value
          DateTime dateTime = timestamp.toDate();
         
         l_data = snapshot.data!.docs.length;
         
         print(l_data);
          return Column(
            children: [
              Container(
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
                  itemCount: 1,
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
                        backgroundImage: AssetImage('images/avator.png'),
                        backgroundColor: Colors.blueAccent.withOpacity(0.3),
                      ),
                      title:   Column(
                        children: [
                           Text(
                            doc['username'],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height:4 ,),
                          Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                          Icon(Icons.phone,
                                        color: Colors.grey[400], size: 16),
                                        SizedBox(width: 4,),
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
                                             Text(
                                             // doc['distrname'],
                                             doc['region'],
                                              style: TextStyle(
                          color: Colors.white.withBlue(200),
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
                                    Icon(Icons.production_quantity_limits_rounded,
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
                                Icon(Icons.timelapse,
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
                                Icon(Icons.line_weight,
                                    color: Colors.grey[400], size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "quantity: " + doc['quantyty']+"(kg)",
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
                                   "district: " + doc['distrname'],
                                  
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
                                Icon(Icons.streetview,
                                    color: Colors.grey[400], size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "street: " + doc['mtaa'],
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
                         pid=doc.id;
                         poid=doc['usertable'];
   
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewPost(pid:pid,userId_:uid!,postuid:poid)),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 10,),
             ],
          );
        }).toList(),
        
      );
    },
  ),
),
  Container(color: Color.fromARGB(179, 13, 13, 13),height: MediaQuery.sizeOf(context).height * 0.01 ,alignment: Alignment.bottomCenter,)
        ],
  ),),
  SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
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
           SizedBox( height:20),
                    Container(height: MediaQuery.of(context).size.height*0.58,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7),gradient: LinearGradient(colors: [
                        Colors.black,Colors.blueGrey.shade900,Colors.black
                      ]),),padding: EdgeInsets.all(20),
                     child: ListView.builder(
  itemCount: regions.length,
  itemBuilder: (context, index) {
    return StreamBuilder<int>(
      stream: FirebaseFirestore.instance
          .collection('userpost')
          .snapshots()
          .map((snapshot) => snapshot.docs.length),
      builder: (context, totalSnapshot) {
        if (totalSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Loading state for total data
        }

        if (totalSnapshot.hasError) {
          return Text('Error: ${totalSnapshot.error}'); // Error state
        }

        final totaldatal = totalSnapshot.data ?? 0;

        return StreamBuilder<int>(
          stream: FirebaseFirestore.instance
              .collection('userpost')
              .where('pname', isEqualTo: selectedproduct)
              .snapshots()
              .map((snapshot) => snapshot.docs.length),
          builder: (context, stotalSnapshot) {
            if (stotalSnapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Loading state for stotaldatal
            }

            if (stotalSnapshot.hasError) {
              return Text('Error: ${stotalSnapshot.error}'); // Error state
            }

            final stotaldatal = stotalSnapshot.data ?? 0;

            return StreamBuilder<int>(
              stream: FirebaseFirestore.instance
                  .collection('userpost')
                  .where('region', isEqualTo: regions[index])
                  .snapshots()
                  .map((snapshot) => snapshot.docs.length),
              builder: (context, dataSnapshot) {
                if (dataSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Loading state for datal
                }

                if (dataSnapshot.hasError) {
                  return Text('Error: ${dataSnapshot.error}'); // Error state
                }

                final datal = dataSnapshot.data ?? 0;

                return StreamBuilder<int>(
                  stream: FirebaseFirestore.instance
                      .collection('userpost')
                      .where('region', isEqualTo: regions[index])
                      .where('pname', isEqualTo: selectedproduct)
                      .snapshots()
                      .map((snapshot) => snapshot.docs.length),
                  builder: (context, sdatalSnapshot) {
                    if (sdatalSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Loading state for sdatal
                    }

                    if (sdatalSnapshot.hasError) {
                      return Text('Error: ${sdatalSnapshot.error}'); // Error state
                    }

                    final sdatal = sdatalSnapshot.data ?? 0;

                    double percentT;
                    double heightT;

                    if (selectedproduct == "zote") {
                      percentT = (datal / (totaldatal == 0 ? 1 : totaldatal)) * 100;
                      heightT = (MediaQuery.of(context).size.width - 56) * (percentT / 100);
                    } else {
                      percentT = (sdatal / (stotaldatal == 0 ? 1 : stotaldatal)) * 100;
                      heightT = (MediaQuery.of(context).size.width - 56) * (percentT / 100);
                    }
print(percentT);
print(stotaldatal);
                    return buildFileSizeChart(
                      regions[index],
                      Colors.white.withBlue(200),
                     
                      heightT,
                       percentT,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  },
),

                        
                    ),
                    Container(height: MediaQuery.of(context).size.height*0.05,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(7),gradient: LinearGradient(colors: [
                        Colors.black,Colors.black12,
                      ],begin:Alignment.topLeft),),
                    child: Center(child: Text("Created by Eng: Mkori", style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white.withBlue(200)),)),),
                  ],
                ),
              ),
            )
    ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 57, 73, 82),
          currentIndex: currentpage,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white24,
          onTap: (ind) {
            setState(() {
              currentpage = ind;
            });
            _pagecontrol.jumpToPage(ind);
            if (currentpage == 0) {
              imageshift();
            }
          },
          items: [
            BottomNavigationBarItem(
                backgroundColor: Colors.black,
                icon: Icon(Icons.landscape_outlined,),
                label: "maalum"),
            BottomNavigationBarItem(
                icon: Icon(Icons.line_style_rounded,), label: "zote"),
            BottomNavigationBarItem(icon: Icon(Icons.leaderboard_outlined,), label: "takwimu")
          ],
        ),
      ),
    );
  }
    Column buildFileSizeChart(String name, Color color, double size, double percente) {
      print(percente);
    return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),),
                     Text("$percente%", style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white.withBlue(200)),),
                  ],
                ),
                   SizedBox(height: 5,),
                Container(height: 8, width: size,decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),color: color,
                ),),
                SizedBox(height: 20,),
              ],);

              
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
  
  //   String uidfind() {
  //   User? currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser != null) {
  //     return currentUser.uid;
  //   }
  //   return '';
  // }
  
// Get count of chats where current user has unread messages
Stream<int> getUnreadChatsCount(String currentUserId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .where('participants', arrayContains: currentUserId)
      .where('unreadCounts.$currentUserId', isGreaterThan: 0)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}
}