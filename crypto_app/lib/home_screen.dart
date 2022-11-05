import 'dart:convert';
import 'package:crypto_app/app_theme.dart';
import 'package:crypto_app/coin_data_model.dart';
import 'package:crypto_app/coin_graph.dart';
import 'package:crypto_app/update_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String url =
      'Paste your Api key';
  String name = "", email = "", age = "" ;
  bool isDark = AppTheme.isDarkEnabled;
  bool isFirstTimeDataAccess = true;
  List<CoinDataModel> coinDataList = [];
  late Future<List<CoinDataModel>> coinDataFuture;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUserDetail();
    coinDataFuture = getCoinsData();
  }

  void getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? "";
      email = prefs.getString('email') ?? "";
      age = prefs.getString('age') ?? "";
    });
}

Future<List<CoinDataModel>> getCoinsData() async {
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    if(response.statusCode == 200 || response.statusCode==201) {
      List coinsDat = json.decode(response.body);
      List<CoinDataModel> data = coinsDat.map((e) => CoinDataModel.fromJson(e)).toList();
      return data;
    } else {
      return <CoinDataModel>[];
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor: isDark ? const Color(0xFF1D1D35) : Colors.white,
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1D1D35) : Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFFE9901),
              ),
              currentAccountPicture: Image.asset(
                'assets/G.png',
                height: 300,
                width: 300,
              ),
                accountName: Text(
                    name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                accountEmail: Text(
                   '$email\nAge : $age',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                )
            ),
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfile()));
              },
              leading: Icon(
                  FontAwesomeIcons.user,
                color: isDark ? Colors.white : Colors.grey.shade800,
              ),
              title: Text(
                'Update Profile',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black
                ),
              ),
            ),
            ListTile(
              onTap: () async {

                SharedPreferences prefs = await SharedPreferences.getInstance();

               setState(() {
                 isDark = !isDark;
               });
               AppTheme.isDarkEnabled = isDark;
                await prefs.setBool('isDark', isDark);
              },
              leading: Icon(
                  isDark ? FontAwesomeIcons.lightbulb : FontAwesomeIcons.moon,
                color: isDark ? Colors.white : Colors.grey.shade800,
              ),
              title: Text(
                  isDark ? 'Light Mode' : 'Dark Mode',
                style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black
                ),
              ),
            ),
            ListTile(
              onTap: () {
                SystemNavigator.pop();
              },
              leading: const Icon(
                FontAwesomeIcons.powerOff,
                color: Colors.red
              ),
              title: Text(
                'Exit',
                style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black
                ),
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFE9901),
        leading: IconButton(
          onPressed: () {
            _globalKey.currentState!.openDrawer();
          },
          icon: const Icon(
              FontAwesomeIcons.barsStaggered,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Gem Coin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder(
        future: coinDataFuture,
          builder: (context,
              AsyncSnapshot<List<CoinDataModel>> snapshot) {
        if(snapshot.hasData) {
          if(isFirstTimeDataAccess) {
            coinDataList = snapshot.data!;
            isFirstTimeDataAccess = false;
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                child: TextField(
                  onChanged: (query) {
                    List<CoinDataModel> searchResult = snapshot.data!.where((element) {
                      String coinName = element.name;
                      bool isItemSearched = coinName.contains(query);
                      return isItemSearched;
                    }).toList();
                    setState(() {
                      coinDataList = searchResult;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for a Coin',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey.shade700 : null,
                    ),
                    prefixIcon: Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      color: isDark ? Colors.black : Colors.grey.shade800,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        style: BorderStyle.solid,
                        color: Color(0xFFFE9901),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    fillColor: Colors.grey.shade300,
                    filled: true,
                  ),
                ),
              ),
              Expanded(
                child: coinDataList.isEmpty ? Center(
                  child: Text(
                    'No Coin found',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: isDark ? Colors.white : Colors.grey.shade700
                    ),
                  ),
                ) : ListView.builder(
                    itemCount: coinDataList.length,
                    itemBuilder: (context, index) {
                      return coinsData(coinDataList[index]);
                    }),
              ),
            ],
          );
        } else {
          return const Center(
            child: SpinKitCubeGrid(
            color: Colors.deepOrange,
          ),
          );
        }
      }),
    );
  }

  Widget coinsData(CoinDataModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CoinGraph(
              coinDataModel: model,)));
        },
        leading: SizedBox(
          height: 50,
            width: 50,
            child: Image.network(model.image)),
        title: Text(
            '${model.name}\n${model.symbol}',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: RichText(
          textAlign: TextAlign.end,
          text: TextSpan(
            text: 'PKR.${model.currentPrice}\n',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
            children: [
              TextSpan(
                text: '${model.priceChangePercentage24h}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}