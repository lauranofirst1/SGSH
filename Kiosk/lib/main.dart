import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/menu.dart';
import 'widgets/menu_card.dart';
import 'widgets/order_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print("failed");
  }

  await Supabase.initialize(
    url: dotenv.env["PROJECT_URL"] ?? "",
    anonKey: dotenv.env["PROJECT_API_KEY"] ?? "",
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'asd'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final supabase = Supabase.instance.client;

  List<menu_data> menuList = [];
  List<Map<String, dynamic>> orderList = [];
  List<Map<String, dynamic>> orderedList = [];

  double totalAmount = 0;

  void fetchStores() async {
    try {
      var response = await supabase
          .from("menu_data")
          .select()
          .order("id", ascending: true);

      setState(() {
        menuList =
            response.map<menu_data>((data) => menu_data.fromMap(data)).toList();
      });
      print(menuList);
    } catch (e) {
      print("$e");
    }
  }

  void addOrder(String name, int price, int count) {
    if (orderList.any((order) => order['name'] == name)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('이미 추가하셨습니다.')));
    } else {
      setState(() {
        orderList.add({'name': name, 'price': price, 'count': count});
      });
    }
  }

  void calculateTotalAmount() {
    setState(() {
      totalAmount = orderList.fold(0, (sum, item) {
        return sum + (item['price'] * item['count']);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchStores();
    calculateTotalAmount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.75,
            child:
                menuList.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                      color: Colors.white,
                      // color: Colors.red,
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12.0),
                        itemCount: menuList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, // 한 줄에 보여줄 아이템 수
                              crossAxisSpacing: 5.0, // 아이템 간의 가로 간격
                              mainAxisSpacing: 12.0, // 아이템 간의 세로 간격
                              childAspectRatio: 0.68, // 아이템의 가로, 세로 비율
                            ),
                        itemBuilder: (context, index) {
                          return MenuCard(
                            menu: menuList[index],
                            onTap: () async {
                              addOrder(
                                menuList[index].name,
                                menuList[index].price,
                                1,
                              );
                              calculateTotalAmount();
                              print(orderList);
                            },
                          );
                        },
                      ),
                    ),
          ),
          Container(
            color: const Color.fromARGB(255, 255, 246, 246),
            // color: Colors.blue,
            width: MediaQuery.of(context).size.width * 0.25,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  orderList.isEmpty
                      ? SizedBox(
                        height: MediaQuery.of(context).size.height - 170,
                        child: Center(
                          child: Text(
                            '주문이 없습니다.',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      : Expanded(
                        child: ListView.builder(
                          itemCount: orderList.length,
                          itemBuilder: (context, index) {
                            return OrderCard(
                              key: ValueKey(
                                orderList[index]['name'],
                              ), // 각 항목에 고유한 키 사용
                              name: orderList[index]['name'],
                              price: orderList[index]['price'],
                              count: orderList[index]['count'],
                              plusCount: () {
                                setState(() {
                                  orderList[index]['count']++;
                                });
                                calculateTotalAmount();
                              },
                              minusCount: () {
                                setState(() {
                                  orderList[index]['count']--;
                                });
                                calculateTotalAmount();
                              },
                              onZeroCount: () {
                                setState(() {
                                  orderList.removeAt(index);
                                });
                                calculateTotalAmount();
                              },
                            );
                          },
                        ),
                      ),

                  Container(
                    height: 50,
                    color: Colors.tealAccent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Table No. 8",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          GestureDetector(
                            onTap: () {
                              print(orderedList);
                            },
                            child: Text(
                              "주문 내역",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final time = DateTime.now().toString().substring(0, 19);
                      var tmpName = "";
                      var tmpPrice = "";
                      var tmpCount = "";
                      if (totalAmount != 0) {
                        for (var order in orderList) {
                          tmpName += "${order['name']},";
                          tmpPrice += "${order['price']},";
                          tmpCount += "${order['count']},";
                          orderedList.add(order);
                        }
                        await supabase.from('order_data').insert({
                          'b_id': 1,
                          'table_no': 8,
                          'name': tmpName,
                          'price': tmpPrice,
                          'count': tmpCount,
                          'time': time,
                          'status': 'order', // order, check, cancel
                        });
                        setState(() {
                          orderList = [];
                          totalAmount = 0;
                        });
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('주문 완료되었습니다.')));
                      } else {
                        print(orderList.map((order) => print(order)));
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('주문이 없습니다.')));
                      }
                    },
                    child: Container(
                      color: Colors.amberAccent,
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 100,
                      child: Center(
                        child: Text(
                          "${totalAmount.toString().substring(0, totalAmount.toString().length - 2)}\n주문하기",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
