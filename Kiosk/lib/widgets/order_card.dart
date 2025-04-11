import 'package:flutter/material.dart';

class OrderCard extends StatefulWidget {
  final String name;
  final int price;
  final int count;
  final VoidCallback plusCount;
  final VoidCallback minusCount;
  final VoidCallback onZeroCount;

  const OrderCard({
    required this.name,
    required this.price,
    required this.count,
    required this.plusCount,
    required this.minusCount,
    required this.onZeroCount,
    required ValueKey key,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String Function(Match) mathFunc = (Match match) => '${match[1]},';

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.name),
                  GestureDetector(
                    child: Icon(Icons.cancel),
                    onTap: () {
                      widget.onZeroCount();
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        child: Icon(Icons.remove),
                        onTap: () {
                          if (widget.count - 1 <= 0) {
                            widget.onZeroCount();
                          } else {
                            widget.minusCount();
                          }
                        },
                      ),
                      Text("${widget.count}"),
                      GestureDetector(
                        child: Icon(Icons.add),
                        onTap: () {
                          widget.plusCount();
                        },
                      ),
                    ],
                  ),
                  Text(
                    "${(widget.price * widget.count).toString().replaceAllMapped(reg, mathFunc)} 원",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
