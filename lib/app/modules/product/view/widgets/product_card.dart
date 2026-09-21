import 'package:ecom_delivery_flutter/app/models/product/product_response_model.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
    this.isAddingToCart = false,
  });

  final ProductData product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;
  final bool isAddingToCart;

  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final String imageUrl = product.imageUrl();
    final bool hasImage = imageUrl.trim().isNotEmpty;
    final int stock = product.currentStock ?? 0;

    return Material(
      color: _cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(
                imageUrl: hasImage ? imageUrl : null,
                isOutOfStock: product.isOutOfStock,
                isPublished: product.isPublished,
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? 'Unnamed Product',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 11,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        _formatMoney(product.unitPrice ?? 0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Expanded(
                            child: _StockBadge(
                              stock: stock,
                            ),
                          ),
                          if (onAddToCart != null) ...[
                            const SizedBox(width: 4),
                            _AddToCartButton(
                              onTap: onAddToCart!,
                              isLoading: isAddingToCart,
                            ),
                          ],

                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatMoney(double value) {
    final bool hasDecimals = value % 1 != 0;
    final String fixed =
        hasDecimals ? value.toStringAsFixed(2) : value.toStringAsFixed(0);
    final List<String> parts = fixed.split('.');
    final String integerPart = parts[0];
    final String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    if (hasDecimals && parts.length > 1) {
      return '৳$formattedInteger.${parts[1]}';
    }
    return '৳$formattedInteger';
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.imageUrl,
    required this.isOutOfStock,
    required this.isPublished,
  });

  final String? imageUrl;
  final bool isOutOfStock;
  final bool isPublished;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Container(
              color: const Color(0xFF242528),
              child: imageUrl == null
                  ? const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Color(0xFF6B7280),
                        size: 26,
                      ),
                    )
                  : Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Color(0xFF6B7280),
                            size: 26,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        return const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),

        if (isOutOfStock)
          Positioned(
            left: 5,
            bottom: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Out of stock',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        Positioned(
          right: 5,
          top: 5,
          child: _StatusPill(
            color: isPublished
                ? const Color(0xFF34D399)
                : const Color(0xFFFBBF24),
            text: isPublished ? 'Live' : 'Draft',
          ),
        ),
      ],
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({
    required this.stock,
  });

  final int stock;

  @override
  Widget build(BuildContext context) {
    final isOut = stock <= 0;
    final color = isOut ? Colors.redAccent : const Color(0xFF34D399);

    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOut ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
            color: color,
            size: 11,
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              isOut ? 'Stock: 0' : 'Qty: $stock',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.color,
    required this.text,
  });

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.65), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({
    required this.onTap,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 22,
        width: 22,
        decoration: BoxDecoration(
          color: const Color(0xFF34D399),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 11,
                height: 11,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Colors.black,
                ),
              )
            : const Icon(
                Icons.add,
                color: Colors.black,
                size: 15,
              ),
      ),
    );
  }
}
