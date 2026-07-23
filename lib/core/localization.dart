import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';

class Localization {
  final String locale;
  Localization(this.locale);

  static const _en = {
    'my_profile': 'My Profile',
    'total_orders': 'Total Orders',
    'wishlist': 'Wishlist',
    'account_settings': 'Account Settings',
    'edit_profile': 'Edit Profile',
    'saved_addresses': 'Saved Addresses',
    'change_password': 'Change Password',
    'my_activity': 'My Activity',
    'order_history': 'Order History',
    'wishlist_items': 'Wishlist Items',
    'notifications': 'Notifications',
    'preferences': 'Preferences',
    'dark_mode': 'Dark Mode',
    'language': 'Language',
    'sign_out': 'Sign Out',
    'edit_profile_title': 'Edit Profile',
    'full_name': 'Full Name',
    'phone_number': 'Phone Number',
    'cancel': 'Cancel',
    'save_changes': 'Save Changes',
    'select_language': 'Select Language',
    'urdu': 'Urdu (اردو)',
    'english': 'English',
    'upload_picture': 'Upload Picture',
    'no_notifications': 'No notifications yet',
    'deliver_to': 'Deliver to',
    'search_hint': 'Search for food, grocery...',
    'what_buy': 'What would you like to buy?',
    'featured_stores': 'Featured Stores',
    'view_all': 'View All',
    'popular_near': 'Popular Near You',
    'grocery': 'Grocery',
    'food': 'Food',
    'pharmacy': 'Pharmacy',
    'fashion': 'Fashion',
    'item_total': 'Item Total',
    'delivery_fee': 'Delivery Fee',
    'taxes': 'Taxes',
    'grand_total': 'Grand Total',
    'checkout': 'Proceed to Checkout',
    'my_cart': 'My Cart',
    'clear': 'Clear',
    'empty_cart': 'Your cart is empty',
    'start_shopping': 'Start Shopping',
    'confirm_order': 'Confirm Order',
    'delivery_location': 'Delivery Location',
    'payment_method': 'Payment Method',
    'order_items': 'Order Items',
    'cash_on_delivery': 'Cash on Delivery',
    'online_transfer': 'Online Transfer',
    'pay_confirm': 'Pay & Confirm Order',
    'order_summary': 'Order Summary',
    'item_subtotal': 'Order Subtotal',
    'total_to_pay': 'Total to Pay',
    'select_address': 'Select Address',
    'add_address_hint': 'Please add a delivery address to continue',
  };

  static const _ur = {
    'my_profile': 'میری پروفائل',
    'total_orders': 'کل آرڈرز',
    'wishlist': 'خواہش کی فہرست',
    'account_settings': 'اکاؤنٹ کی ترتیبات',
    'edit_profile': 'پروفائل تبدیل کریں',
    'saved_addresses': 'محفوظ کردہ پتے',
    'change_password': 'پاس ورڈ تبدیل کریں',
    'my_activity': 'میری سرگرمی',
    'order_history': 'آرڈر کی تاریخ',
    'wishlist_items': 'خواہش کی فہرست کی اشیاء',
    'notifications': 'اطلاعات',
    'preferences': 'ترجیحات',
    'dark_mode': 'ڈارک موڈ',
    'language': 'زبان',
    'sign_out': 'سائن آؤٹ',
    'edit_profile_title': 'پروفائل میں ترمیم کریں',
    'full_name': 'پورا نام',
    'phone_number': 'فون نمبر',
    'cancel': 'منسوخ کریں',
    'save_changes': 'تبدیلیاں محفوظ کریں',
    'select_language': 'زبان منتخب کریں',
    'urdu': 'اردو',
    'english': 'انگریزی',
    'upload_picture': 'تصویر اپ لوڈ کریں',
    'no_notifications': 'ابھی تک کوئی اطلاع نہیں ہے',
    'deliver_to': 'ڈیلیور کریں',
    'search_hint': 'کھانے، گروسری تلاش کریں...',
    'what_buy': 'آپ کیا خریدنا چاہیں گے؟',
    'featured_stores': 'نمایاں اسٹورز',
    'view_all': 'سب دیکھیں',
    'popular_near': 'آپ کے قریب مقبول',
    'grocery': 'گروسری',
    'food': 'کھانا',
    'pharmacy': 'فارماسی',
    'fashion': 'فیشن',
    'item_total': 'آئٹم ٹوٹل',
    'delivery_fee': 'ڈیلیوری فیس',
    'taxes': 'ٹیکس',
    'grand_total': 'کل رقم',
    'checkout': 'چیک آؤٹ کریں',
    'my_cart': 'میری کارٹ',
    'clear': 'صاف کریں',
    'empty_cart': 'آپ کی ٹوکری خالی ہے',
    'start_shopping': 'خریداری شروع کریں',
    'confirm_order': 'آرڈر کی تصدیق کریں',
    'delivery_location': 'ڈیلیوری کا مقام',
    'payment_method': 'ادائیگی کا طریقہ',
    'order_items': 'آرڈر کی اشیاء',
    'cash_on_delivery': 'کیش آن ڈیلیوری',
    'online_transfer': 'آن لائن ٹرانسفر',
    'pay_confirm': 'ادائیگی اور آرڈر کی تصدیق کریں',
    'order_summary': 'آرڈر کا خلاصہ',
    'item_subtotal': 'سب ٹوٹل',
    'total_to_pay': 'کل قابل ادائیگی',
    'select_address': 'پتہ منتخب کریں',
    'add_address_hint': 'جاری رکھنے کے لیے براہ کرم ڈیلیوری کا پتہ شامل کریں',
  };

  String translate(String key) {
    if (locale == 'ur') {
      return _ur[key] ?? key;
    }
    return _en[key] ?? key;
  }
}

final localizationProvider = Provider<Localization>((ref) {
  final settings = ref.watch(settingsProvider);
  return Localization(settings.locale.languageCode);
});

extension Trans on String {
  String tr(WidgetRef ref) {
    return ref.watch(localizationProvider).translate(this);
  }
}
