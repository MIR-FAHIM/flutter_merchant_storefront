import 'package:ecom_delivery_flutter/app/modules/seller_tips/models/seller_tip.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

class SellerTipsData {
  const SellerTipsData._();

  static const List<SellerTip> tips = [
    SellerTip(
      id: 'packages',
      icon: Icons.workspace_premium_outlined,
      title: 'কিভাবে প্যাকেজ কিনবেন',
      summary:
          'প্যাকেজ active না থাকলে অনেক store feature সীমিত থাকতে পারে। তাই আগে আপনার store এর জন্য package কিনুন।',
      estimatedTime: '২ মিনিট',
      actionLabel: 'প্যাকেজ দেখুন',
      actionRoute: Routes.SELLER_PACKAGES,
      steps: [
        SellerTipStep(
          title: 'Seller Dashboard খুলুন',
          description: 'Login করার পর seller dashboard এ যান।',
        ),
        SellerTipStep(
          title: 'Packages পেজে যান',
          description: 'Menu থেকে Packages অথবা Subscription Package নির্বাচন করুন।',
        ),
        SellerTipStep(
          title: 'প্যাকেজ তুলনা করুন',
          description:
              'Price, product limit, staff limit এবং commission দেখে আপনার store এর জন্য ঠিক প্যাকেজ বেছে নিন।',
        ),
        SellerTipStep(
          title: 'Buy/Subscribe চাপুন',
          description: 'প্যাকেজ নির্বাচন করে Subscribe বা Buy Package চাপুন।',
        ),
        SellerTipStep(
          title: 'Payment সম্পন্ন করুন',
          description: 'Payment gateway এ গেলে payment শেষ করুন।',
        ),
        SellerTipStep(
          title: 'Dashboard এ ফিরে status দেখুন',
          description: 'Payment সফল হলে package status active হয়েছে কি না দেখুন।',
        ),
      ],
    ),
    SellerTip(
      id: 'categories',
      icon: Icons.category_outlined,
      title: 'কিভাবে store category চালু করবেন',
      summary:
          'Seller product add করার সময় শুধু active category দেখা যাবে। তাই আগে store category activate করুন।',
      estimatedTime: '৩ মিনিট',
      actionLabel: 'ক্যাটাগরি চালু করুন',
      actionRoute: Routes.MARKETPLACE_CATEGORIES,
      steps: [
        SellerTipStep(
          title: 'Categories পেজ খুলুন',
          description: 'Seller menu থেকে Categories এ যান।',
        ),
        SellerTipStep(
          title: 'Store নির্বাচন করুন',
          description: 'আপনার একাধিক store থাকলে সঠিক store নির্বাচন করুন।',
        ),
        SellerTipStep(
          title: 'Marketplace category দেখুন',
          description:
              'Global marketplace category tree থেকে প্রয়োজনীয় parent ও child category দেখুন।',
        ),
        SellerTipStep(
          title: 'প্রয়োজনীয় category tick দিন',
          description:
              'যে category আপনার store এ দরকার, সেগুলো checkbox দিয়ে active করুন।',
        ),
        SellerTipStep(
          title: 'Save Categories চাপুন',
          description:
              'Save করার পর এই category গুলো আপনার store এর product form এবং storefront এ ব্যবহার হবে।',
        ),
        SellerTipStep(
          title: 'Product add page এ যাচাই করুন',
          description:
              'Product add করার সময় category dropdown এ active category দেখা যাচ্ছে কি না চেক করুন।',
        ),
      ],
    ),
    SellerTip(
      id: 'products',
      icon: Icons.inventory_2_outlined,
      title: 'কিভাবে product add করবেন',
      summary:
          'Product ঠিকভাবে add করলে customer store page থেকে সহজে order করতে পারবে।',
      estimatedTime: '৪ মিনিট',
      actionLabel: 'Product Add করুন',
      actionRoute: Routes.PRODUCT_ADD,
      steps: [
        SellerTipStep(
          title: 'Products পেজ খুলুন',
          description: 'Seller menu থেকে Products এ যান।',
        ),
        SellerTipStep(
          title: 'Add Product চাপুন',
          description: 'নতুন product যোগ করার জন্য Add Product button চাপুন।',
        ),
        SellerTipStep(
          title: 'Basic information দিন',
          description: 'Product name, category, price, stock এবং unit পূরণ করুন।',
        ),
        SellerTipStep(
          title: 'Product image দিন',
          description:
              'কমপক্ষে একটি clear image upload করুন। প্রথম image primary রাখুন।',
        ),
        SellerTipStep(
          title: 'Description লিখুন',
          description:
              'Short description এবং details দিন যাতে customer product বুঝতে পারে।',
        ),
        SellerTipStep(
          title: 'Publish চালু রাখুন',
          description: 'Published toggle active রাখুন।',
        ),
        SellerTipStep(
          title: 'Save করুন',
          description:
              'Save করার পর product list এবং public storefront এ product দেখা যাচ্ছে কি না চেক করুন।',
        ),
      ],
    ),
    SellerTip(
      id: 'store-qr',
      icon: Icons.qr_code_2_rounded,
      title: 'কিভাবে store link ও QR share করবেন',
      summary: 'QR scan করলে customer সরাসরি আপনার store খুলতে পারবে।',
      estimatedTime: '২ মিনিট',
      actionLabel: 'Store QR খুলুন',
      actionRoute: Routes.SELLER_STORE_QR,
      steps: [
        SellerTipStep(
          title: 'Store QR পেজ খুলুন',
          description: 'Seller menu থেকে Store QR খুলুন।',
        ),
        SellerTipStep(
          title: 'Store নির্বাচন করুন',
          description: 'একাধিক store থাকলে সঠিক store নির্বাচন করুন।',
        ),
        SellerTipStep(
          title: 'QR download করুন',
          description: 'Download QR Frame চাপুন।',
        ),
        SellerTipStep(
          title: 'QR print/share করুন',
          description:
              'Counter, delivery bag, poster, Facebook post অথবা visiting card এ QR ব্যবহার করুন।',
        ),
        SellerTipStep(
          title: 'Link copy করুন',
          description: 'Store URL copy করে customer কে message করতে পারেন।',
        ),
        SellerTipStep(
          title: 'Scan করে test করুন',
          description: 'MyZoo app দিয়ে QR scan করে store load হচ্ছে কি না চেক করুন।',
        ),
      ],
    ),
    SellerTip(
      id: 'orders',
      icon: Icons.receipt_long_outlined,
      title: 'কিভাবে order handle করবেন',
      summary: 'Order দ্রুত confirm এবং update করলে customer trust বাড়ে।',
      estimatedTime: '৩ মিনিট',
      actionLabel: 'Orders দেখুন',
      actionRoute: Routes.ORDER_SHOP_LIST,
      steps: [
        SellerTipStep(
          title: 'Orders পেজ খুলুন',
          description: 'Seller menu থেকে Orders এ যান।',
        ),
        SellerTipStep(
          title: 'Pending order দেখুন',
          description: 'নতুন order গুলো pending status এ থাকবে।',
        ),
        SellerTipStep(
          title: 'Product ও stock মিলান',
          description: 'Order product, quantity এবং stock চেক করুন।',
        ),
        SellerTipStep(
          title: 'Customer details দেখুন',
          description:
              'Customer phone, address, delivery/pickup option এবং payment status দেখুন।',
        ),
        SellerTipStep(
          title: 'Status update করুন',
          description:
              'Order confirmed, processing, delivered অথবা cancelled status update করুন।',
        ),
        SellerTipStep(
          title: 'Customer কে প্রয়োজন হলে call করুন',
          description: 'Address বা product issue থাকলে customer কে call করুন।',
        ),
      ],
    ),
    SellerTip(
      id: 'delivery-man',
      icon: Icons.delivery_dining_rounded,
      title: 'কিভাবে delivery man add করবেন',
      summary:
          'নিজস্ব delivery team থাকলে delivery man add করে delivery management সহজ করুন।',
      estimatedTime: '৩ মিনিট',
      actionLabel: 'Delivery Man যোগ করুন',
      actionRoute: Routes.DELIVERY_MAN_LIST,
      steps: [
        SellerTipStep(
          title: 'Delivery Man পেজ খুলুন',
          description: 'Seller/Admin menu থেকে Delivery Man পেজে যান।',
        ),
        SellerTipStep(
          title: 'Add Delivery Man চাপুন',
          description: 'নতুন delivery staff যোগ করার জন্য Add button চাপুন।',
        ),
        SellerTipStep(
          title: 'Basic information দিন',
          description: 'Name, phone, address এবং login information দিন।',
        ),
        SellerTipStep(
          title: 'Save করুন',
          description: 'Save করার পর delivery man list এ দেখা যাচ্ছে কি না চেক করুন।',
        ),
        SellerTipStep(
          title: 'Order assign করুন',
          description: 'Order ready হলে delivery man assign করুন।',
        ),
        SellerTipStep(
          title: 'Delivery status follow করুন',
          description: 'Delivery complete হলে order status update করুন।',
        ),
      ],
    ),
    SellerTip(
      id: 'daily-checklist',
      icon: Icons.fact_check_outlined,
      title: 'প্রতিদিন কী কী চেক করবেন',
      summary:
          'নিয়মিত store check করলে order miss হবে না এবং customer satisfaction বাড়বে।',
      estimatedTime: '২ মিনিট',
      actionLabel: 'Dashboard খুলুন',
      actionRoute: Routes.ROOT,
      steps: [
        SellerTipStep(
          title: 'নতুন order আছে কি না দেখুন',
          description: 'Dashboard এবং Orders পেজে নতুন order নিয়মিত চেক করুন।',
        ),
        SellerTipStep(
          title: 'Pending order update করুন',
          description: 'Pending order থাকলে confirm, process বা cancel status দিন।',
        ),
        SellerTipStep(
          title: 'Stock কমে গেলে update করুন',
          description: 'Product stock কমে গেলে Product edit করে stock ঠিক করুন।',
        ),
        SellerTipStep(
          title: 'Price ও category দেখুন',
          description: 'Product price ঠিক আছে কি না এবং category active আছে কি না দেখুন।',
        ),
        SellerTipStep(
          title: 'Package status check করুন',
          description: 'Subscription active আছে কি না Packages পেজে যাচাই করুন।',
        ),
        SellerTipStep(
          title: 'Customer follow up করুন',
          description: 'Customer message/call follow up করুন এবং QR/link মাঝে মাঝে test করুন।',
        ),
      ],
    ),
  ];

  static SellerTip byId(String? id) {
    return tips.firstWhere(
      (tip) => tip.id == id,
      orElse: () => tips.first,
    );
  }
}
