import 'package:flutter/material.dart';
import 'package:project_android_final/view/manager/category.dart';
import 'package:project_android_final/view/manager/dish.dart';
import 'package:project_android_final/view/manager/payment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoreView extends StatefulWidget {
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  String role = ''; // Biến lưu role của người dùng

  List<Map<String, dynamic>> moreArr = [
    {
      "index": "1",
      "name": "Payment Details",
      "image": "assets/img/more_payment.png",
      "base": 0
    },
    {
      "index": "2",
      "name": "My Orders",
      "image": "assets/img/more_my_order.png",
      "base": 0
    },
    {
      "index": "3",
      "name": "Notifications",
      "image": "assets/img/more_notification.png",
      "base": 15
    },
    {
      "index": "4",
      "name": "Inbox",
      "image": "assets/img/more_inbox.png",
      "base": 0
    },
    {
      "index": "5",
      "name": "About Us",
      "image": "assets/img/more_info.png",
      "base": 0
    },
    {
      "index": "6",
      "name": "Logout",
      "image": "assets/img/more_info.png",
      "base": 0
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedRole = prefs.getString('userRole');
    setState(() {
      role = savedRole ?? '';
      if (role == "Admin") {
        moreArr.addAll([
          {
            "index": "7",
            "name": "Category",
            "image": "assets/img/more_info.png",
            "base": 0
          },
          {
            "index": "8",
            "name": "Dish",
            "image": "assets/img/more_info.png",
            "base": 0
          },
          {
            "index": "9",
            "name": "Payment",
            "image": "assets/img/more_info.png",
            "base": 0
          },
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "More",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Image.asset(
                        "assets/img/shopping_cart.png",
                        width: 25,
                        height: 25,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: moreArr.length,
                itemBuilder: (context, index) {
                  var mObj = moreArr[index];
                  return InkWell(
                    onTap: () {
                      switch (mObj["index"].toString()) {
                        case "7": // Category
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoryPage(),
                            ),
                          );
                          break;
                        case "8": // Dish
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DishPage(),
                            ),
                          );
                          break;

                      case "9": // Dish
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (context) => const CustomerOrderPage(),
                          ),
                          );
                          break;
                          default:

                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 20),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            margin: const EdgeInsets.only(right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  alignment: Alignment.center,
                                  child: Image.asset(
                                    mObj["image"].toString(),
                                    width: 25,
                                    height: 25,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    mObj["name"].toString(),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
