import 'package:flutter/material.dart';
import 'package:grainapp/spesificproduct.dart';

class DistrictScreen extends StatefulWidget {
  final String region;
  final int regionid;
 

  const DistrictScreen({super.key, required this.region,required this.regionid});

  @override
  _DistrictScreenState createState() => _DistrictScreenState();
}

class _DistrictScreenState extends State<DistrictScreen> {
  String districtSearchQuery = '';

  @override
  Widget build(BuildContext context) {
    
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

 
    List districts=district[widget.regionid];
    var filteredDistricts =districts
        .where((districts) =>
           districts.toLowerCase().contains(districtSearchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
         iconTheme: IconThemeData(color:Colors.white),
        backgroundColor:Colors.blueGrey.shade900.withAlpha(130),
        title: Center(
          child: Text(
            'Districts in ${widget.region.toLowerCase()}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Upper container for decoration (you can customize it further)
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)), color: Colors.white,
            image:DecorationImage(image: AssetImage('images/image3.jpeg'),
            fit: BoxFit.cover)
            ),
            height: MediaQuery.of(context).size.height * 0.3,
           
          ),
          // Search bar container
          Container(
            height: 50,
            color: Colors.black,
             // Black background
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width * 0.1, vertical: 3),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tafuta wilaya...',
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
                  districtSearchQuery = value;
                });
              },
            ),
          ),
          // List of districts
          Expanded(
            child: ListView.builder(
              itemCount: filteredDistricts.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.blueGrey.shade900,Colors.blueGrey]),
                    borderRadius:BorderRadius.circular(20),
                  ),
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    color: Colors.transparent, // White background for the card
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.white, width: 2),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10.0),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.black, // Dark blue background for the icon
                        child: Icon(
                          Icons.location_city,
                          color: Colors.white, // White icon inside the circle
                          size: 30,
                        ),
                      ),
                      title: Text(
                        filteredDistricts[index],
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white, // Dark blue for trailing icon
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductScreen(
                                district: filteredDistricts[index],region: widget.region),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }, 
            ),
          ),
   Container(//color: Color.fromARGB(179, 147, 147, 147),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(30),color: Colors.blueGrey.shade100,),
   height: MediaQuery.sizeOf(context).height * 0.01 ,alignment: Alignment.bottomCenter,)
   
        ],
      ),
      
    );
  }
}


