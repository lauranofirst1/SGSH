import 'package:app/models/business.dart';
import 'package:app/pages/storedetail.dart';
import 'package:app/widgets/store_card.dart';
import 'package:flutter/material.dart';

class StoreDetailBottomSheet extends StatelessWidget {
  final String name;
  final String address;
  final business_data? store;

  const StoreDetailBottomSheet({
    Key? key,
    required this.name,
    required this.address,
    this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StoreCard(
          store:
              store ??
              business_data(
                id: -1,
                name: name,
                address: address,
                image: '',
                time: '정보 없음',
                lat: '',
                lng: '',
                number: '',
                description: '',
                url: '',
              ),
          onTap: () {
            Navigator.pop(context);
            if (store != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoreDetailPage(store: store!),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
