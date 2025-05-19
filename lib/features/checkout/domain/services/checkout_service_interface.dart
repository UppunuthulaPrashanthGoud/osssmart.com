import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';

abstract class CheckoutServiceInterface{

  Future<ApiResponse> cashOnDeliveryPlaceOrder(String? addressID, String? couponCode,String? couponDiscountAmount, String? billingAddressId, String? orderNote);

  Future<ApiResponse> offlinePaymentPlaceOrder(String? addressID, String? couponCode, String? couponDiscountAmount, String? billingAddressId, String? orderNote, List <String?> typeKey, List<String> typeValue, int? id, String name, String? paymentNote);

  Future<ApiResponse> walletPaymentPlaceOrder(String? addressID, String? couponCode,String? couponDiscountAmount, String? billingAddressId, String? orderNote);

  Future<ApiResponse> digitalPaymentPlaceOrder(String? orderNote, String? customerId, String? addressId, String? billingAddressId, String? couponCode, String? couponDiscount, String? paymentMethod, {String? receiptId});

  Future<ApiResponse> offlinePaymentList();

  Future<ApiResponse> verifyRazorpayPayment({required String paymentId, required String orderId, required String signature});
}