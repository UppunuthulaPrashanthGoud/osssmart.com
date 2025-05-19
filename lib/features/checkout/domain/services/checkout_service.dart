import 'package:flutter_sixvalley_ecommerce/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_sixvalley_ecommerce/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';

class CheckoutService implements CheckoutServiceInterface {
  final CheckoutRepositoryInterface checkoutRepositoryInterface;
  final DioClient? dioClient;

  CheckoutService({required this.checkoutRepositoryInterface, required this.dioClient});

  @override
  Future<ApiResponse> cashOnDeliveryPlaceOrder(String? addressID, String? couponCode, String? couponDiscountAmount, String? billingAddressId, String? orderNote) async {
    return await checkoutRepositoryInterface.cashOnDeliveryPlaceOrder(addressID, couponCode, couponDiscountAmount, billingAddressId, orderNote);
  }

  @override
  Future<ApiResponse> digitalPaymentPlaceOrder(String? orderNote, String? customerId, String? addressId, String? billingAddressId, String? couponCode, String? couponDiscount, String? paymentMethod, {String? receiptId}) async {
    try {
      final response = await dioClient!.post(
        AppConstants.digitalPayment,
        data: {
          'order_note': orderNote,
          'customer_id': customerId,
          'address_id': addressId,
          'billing_address_id': billingAddressId,
          'coupon_code': couponCode,
          'coupon_discount': couponDiscount,
          'payment_method': paymentMethod,
          'receipt_id': receiptId,
        },
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  @override
  Future<ApiResponse> offlinePaymentList() async {
   return await checkoutRepositoryInterface.offlinePaymentList();
  }

  @override
  Future<ApiResponse> offlinePaymentPlaceOrder(String? addressID, String? couponCode, String? couponDiscountAmount, String? billingAddressId, String? orderNote, List<String?> typeKey, List<String> typeValue, int? id, String name, String? paymentNote) async {
    return await checkoutRepositoryInterface.offlinePaymentPlaceOrder(addressID, couponCode, couponDiscountAmount, billingAddressId, orderNote, typeKey, typeValue, id, name, paymentNote);
  }

  @override
  Future<ApiResponse> walletPaymentPlaceOrder(String? addressID, String? couponCode, String? couponDiscountAmount, String? billingAddressId, String? orderNote) async {
    return await checkoutRepositoryInterface.walletPaymentPlaceOrder(addressID, couponCode, couponDiscountAmount, billingAddressId, orderNote);
  }

  @override
  Future<ApiResponse> verifyRazorpayPayment({required String paymentId, required String orderId, required String signature}) async {
    try {
      final response = await dioClient!.post(
        '${AppConstants.digitalPayment}/verify',
        data: {
          'payment_id': paymentId,
          'order_id': orderId,
          'signature': signature,
          'payment_method': 'razor_pay'
        },
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }
}