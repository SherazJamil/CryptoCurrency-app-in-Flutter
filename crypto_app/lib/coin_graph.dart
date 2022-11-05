import 'dart:convert';
import 'package:crypto_app/app_theme.dart';
import 'package:crypto_app/coin_data_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class CoinGraph extends StatefulWidget {

  final CoinDataModel coinDataModel;

  const CoinGraph({Key? key, required this.coinDataModel}) : super(key: key);

  @override
  State<CoinGraph> createState() => _CoinGraphState();
}

class _CoinGraphState extends State<CoinGraph> {

  bool isLoading  = true, isFirstTime = true, isDark = AppTheme.isDarkEnabled;
  List<FlSpot> flSpotList = [];
  double minX = 0.0, minY = 0.0, maxX = 0.0, maxY = 0.0;

  @override
  void initState(){
    super.initState();
    getChartDetail('1');
  }

  void getChartDetail(String days) async {

    if(isFirstTime) {
      isFirstTime = false;
    } else {
      setState(() {
        isLoading = true;
      });
    }

    String apiUrl =
        'Paste your Api key';
    Uri uri = Uri.parse(apiUrl);
    final response = await http.get(uri);
    if(response.statusCode == 200 ||response.statusCode == 201) {
      Map<String, dynamic> result = json.decode(response.body);

      List rawList = result['prices'];
      List<List> chartData = rawList.map((e) => e as List).toList();
      List<PriceAndTime> priceAndTimeList = chartData.map((e) =>
          PriceAndTime(time: e[0] as int, price: e[1] as double)).toList();

      flSpotList = [];

      for(var element in priceAndTimeList) {
        flSpotList.add(FlSpot(element.time.toDouble(), element.price),);
      }
      minX = priceAndTimeList.first.time.toDouble();
      maxX = priceAndTimeList.last.time.toDouble();

      priceAndTimeList.sort((a, b) => a.price.compareTo(b.price));

      minY = priceAndTimeList.first.price;
      maxY = priceAndTimeList.last.price;

    setState(() {
      isLoading = false;
    });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1D1D35) : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
          color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFE9901),
        title: Text(
          widget.coinDataModel.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
      body: isLoading == false ? SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                    text: TextSpan(
                      text: '${widget.coinDataModel.name} Price\n',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 18,
                      ),
                      children: [
                        TextSpan(
                          text: 'PKR.${widget.coinDataModel.currentPrice}',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: '${widget.coinDataModel.priceChangePercentage24h}%\n',
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        TextSpan(
                          text: 'PKR.$maxY',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ],
                )),
              ),
            ),
            const SizedBox(
              height: 200,
            ),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: LineChart(
                  LineChartData(
                    minX: minX,
                    minY: minY,
                    maxX: maxX,
                    maxY: maxY,
                    borderData: FlBorderData(
                      show: false,
                    ),
                    titlesData: FlTitlesData(
                      show: false,
                    ),
                    gridData: FlGridData(
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          strokeWidth: 0,
                        );
                      },
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          strokeWidth: 0,
                        );
                      }
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: flSpotList,
                        dotData: FlDotData(
                          show: false,
                        ),
                      ),
                    ]
                  )
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFFFE9901), // Background color
                      ),
                      onPressed: () {
                        getChartDetail('1');
                      },
                      child: const Text(
                        '1 Day',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFFFE9901), // Background color
                      ),
                      onPressed: () {
                        getChartDetail('15');
                      },
                      child: const Text(
                        '15 Day',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color(0xFFFE9901), // Background color
                      ),
                      onPressed: () {
                        getChartDetail('30');
                      },
                      child: const Text(
                        '30 Days',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      )
          : const Center(
        child: SpinKitCubeGrid(
        color: Colors.deepOrange,
      ),
      ),
    );
  }
}


class PriceAndTime {
  late int time;
  late double price;
  PriceAndTime({required this.time, required this.price});
}