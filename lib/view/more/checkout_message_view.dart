import 'package:flutter/material.dart';
import 'package:project_android_final/common_widget/round_button.dart';
import 'package:project_android_final/view/home/home_view.dart';
import 'package:project_android_final/view/more/checkout_view.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../common/color_extension.dart';
import 'dart:math';

class CheckoutMessageView extends StatefulWidget {
  const CheckoutMessageView({super.key});

  @override
  State<CheckoutMessageView> createState() => _CheckoutMessageViewState();
}

class _CheckoutMessageViewState extends State<CheckoutMessageView> {
  String _orderCode = "";

  // Hàm tạo mã hóa đơn ngẫu nhiên
  String _generateRandomOrderCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
  @override
  void initState() {
    super.initState();
    _orderCode = _generateRandomOrderCode();
  }
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      width: media.width,
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: TColor.primaryText,
                  size: 25,
                ),
              )
            ],
          ),
          // Thay hình ảnh bằng QR Code
          if (_orderCode.isNotEmpty)
            QrImageView(
              data: _orderCode,
              version: QrVersions.auto,
              size: media.width * 0.55,
            )
          else
            Text(
              "Nhấn Random để tạo mã hóa đơn",
              textAlign: TextAlign.center,
              style: TextStyle(color: TColor.primaryText, fontSize: 16),
            ),
          const SizedBox(height: 25),
          Text(
            "Order Thành công",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: _orderCode.isNotEmpty ? "Mã hóa đơn của bạn: " : "Nhấn Random để tạo mã hóa đơn",
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              children: _orderCode.isNotEmpty
                  ? [
                TextSpan(
                  text: _orderCode,
                  style: TextStyle(
                    color: Colors.red, // Mã hóa đơn hiển thị màu đỏ
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ]
                  : [],
            ),
          ),

          const SizedBox(height: 25),
          Text(
            "Cảm ơn bạn đã order",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            "Bạn vui lòng sử dụng mã trên để nhận đồ ăn",
            textAlign: TextAlign.center,
            style: TextStyle(color: TColor.primaryText, fontSize: 14),
          ),
          const SizedBox(height: 35),
          // Nút Random Mã Hóa Đơn
          TextButton(
            onPressed: () {
              setState(() {
                _orderCode = _generateRandomOrderCode();
              });
            },
            child: Text(
              "Random Mã Hóa Đơn",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          RoundButton(
            title: "Theo dõi đơn hàng",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutView()),
              );
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeView()),
              );
            },
            child: Text(
              "Trang chủ",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
