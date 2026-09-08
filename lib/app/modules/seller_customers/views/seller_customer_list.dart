
import 'package:ecom_delivery_flutter/app/models/seller_customer_list_model.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_customers/controllers/seller_customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerCustomerListItem extends GetView<SellerCustomerController> {
  const SellerCustomerListItem({
    super.key,
    this.item,
  });

  final SellerPreferredCustomer? item;

  @override
  Widget build(BuildContext context) {
    final customer = item!.customer;

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          customer.name.isNotEmpty
              ? customer.name[0].toUpperCase()
              : '?',
        ),
      ),
      title: Text(
        customer.name.isNotEmpty
            ? customer.name
            : 'Unnamed customer',
      ),
      subtitle: Text(
        [
          if (customer.phone != null && customer.phone!.isNotEmpty)
            customer.phone!,
          if (customer.email.isNotEmpty) customer.email,
        ].join(' · '),
      ),
      trailing: Chip(
        label: Text(item!.status),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}