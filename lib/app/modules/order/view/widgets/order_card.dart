import 'package:ecom_delivery_flutter/app/models/order/order_list_model.dart';
import 'package:flutter/material.dart';


class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final ShopOrderItem item;
  final VoidCallback onTap;

  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);

  @override
  Widget build(BuildContext context) {
    final order = item.order;

    return Material(
      color: _cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order?.orderNumber ?? 'Order #${item.orderId ?? '-'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  _StatusChip(status: item.status ?? order?.status ?? 'N/A'),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.productName ?? 'Unnamed Product',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE5E7EB),
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfo(
                      title: 'Qty',
                      value: '${item.qty ?? 0}',
                    ),
                  ),
                  Expanded(
                    child: _MiniInfo(
                      title: 'Unit',
                      value: _money(item.unitPrice ?? 0),
                    ),
                  ),
                  Expanded(
                    child: _MiniInfo(
                      title: 'Line Total',
                      value: _money(item.lineTotal ?? 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: _borderColor),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      order?.customerName ?? order?.user?.name ?? 'No customer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _money(order?.total ?? item.lineTotal ?? 0),
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _money(double value) {
    return '৳${value.toStringAsFixed(2)}';
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 7),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF242528),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF34363A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final text = status.toLowerCase();

    Color color;

    if (text == 'completed' || text == 'paid') {
      color = const Color(0xFF34D399);
    } else if (text == 'pending' || text == 'unpaid') {
      color = const Color(0xFFFBBF24);
    } else {
      color = const Color(0xFF60A5FA);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}