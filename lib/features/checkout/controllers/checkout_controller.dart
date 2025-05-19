import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/screens/digital_payment_order_place_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/cart/controllers/cart_controller.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_sixvalley_ecommerce/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/animated_custom_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/order_place_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_toast_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';

class CheckoutController with ChangeNotifier {
  final CheckoutServiceInterface checkoutServiceInterface;
  CheckoutController({required this.checkoutServiceInterface});

  int? _addressIndex;
  int? _billingAddressIndex;
  int? get billingAddressIndex => _billingAddressIndex;
  int? _shippingIndex;
  bool _isLoading = false;
  int _paymentMethodIndex = -1;
  bool _onlyDigital = true;
  bool get onlyDigital => _onlyDigital;
  int? get addressIndex => _addressIndex;
  int? get shippingIndex => _shippingIndex;
  bool get isLoading => _isLoading;
  int get paymentMethodIndex => _paymentMethodIndex;

  String? _addressId;
  String? _billingAddressId;
  String? _couponCode;
  String? _couponDiscount;
  String? _customerId;

  String? get addressId => _addressId;
  String? get billingAddressId => _billingAddressId;
  String? get couponCode => _couponCode;
  String? get couponDiscount => _couponDiscount;

  void setAddressId(String? id) {
    _addressId = id;
    notifyListeners();
  }

  void setBillingAddressId(String? id) {
    _billingAddressId = id;
    notifyListeners();
  }

  void setCouponDetails(String? code, String? discount) {
    _couponCode = code;
    _couponDiscount = discount;
    notifyListeners();
  }

  String selectedPaymentName = '';
  void setSelectedPayment(String payment){
    selectedPaymentName = payment;
    notifyListeners();
  }

  final TextEditingController orderNoteController = TextEditingController();
  List<String> inputValueList = [];

  Future<void> placeOrder({required Function callback, String? addressID,
        String? couponCode, String? couponAmount,
        String? billingAddressId, String? orderNote, String? transactionId,
        String? paymentNote, int? id, String? name,bool isfOffline = false, bool wallet = false}) async {
    for(TextEditingController textEditingController in inputFieldControllerList) {
      inputValueList.add(textEditingController.text.trim());

    }
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse;
    isfOffline?
    apiResponse = await checkoutServiceInterface.offlinePaymentPlaceOrder(addressID, couponCode,couponAmount, billingAddressId, orderNote, keyList, inputValueList, offlineMethodSelectedId, offlineMethodSelectedName, paymentNote):
    wallet?
    apiResponse = await checkoutServiceInterface.walletPaymentPlaceOrder(addressID, couponCode,couponAmount, billingAddressId, orderNote):
    apiResponse = await checkoutServiceInterface.cashOnDeliveryPlaceOrder(addressID, couponCode,couponAmount, billingAddressId, orderNote);

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _isLoading = false;
      _addressIndex = null;
      _billingAddressIndex = null;

      String message = apiResponse.response!.data.toString();
      callback(true, message, '');
    } else {
      _isLoading = false;
     ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void setAddressIndex(int index) {
    _addressIndex = index;
    notifyListeners();
  }
  void setBillingAddressIndex(int index) {
    _billingAddressIndex = index;
    notifyListeners();
  }

  void resetPaymentMethod(){
    _paymentMethodIndex = -1;
    codChecked = false;
    walletChecked = false;
    offlineChecked = false;

  }

  void shippingAddressNull(){
    _addressIndex = null;
    notifyListeners();
  }

  void billingAddressNull(){
    _billingAddressIndex = null;
    notifyListeners();
  }

  void setSelectedShippingAddress(int index) {
    _shippingIndex = index;
    notifyListeners();
  }
  void setSelectedBillingAddress(int index) {
    _billingAddressIndex = index;
    notifyListeners();
  }

  bool offlineChecked = false;
  bool codChecked = false;
  bool walletChecked = false;

  void setOfflineChecked(String type){
    if(type == 'offline'){
      offlineChecked = !offlineChecked;
      codChecked = false;
      walletChecked = false;
      _paymentMethodIndex = -1;
      setOfflinePaymentMethodSelectedIndex(0);
    }else if(type == 'cod'){
      codChecked = !codChecked;
      offlineChecked = false;
      walletChecked = false;
      _paymentMethodIndex = -1;
    }else if(type == 'wallet'){
      walletChecked = !walletChecked;
      offlineChecked = false;
      codChecked = false;
      _paymentMethodIndex = -1;
    }

    notifyListeners();
  }

  String selectedDigitalPaymentMethodName = '';

  void setDigitalPaymentMethodName(int index, String name) {
    _paymentMethodIndex = index;
    selectedDigitalPaymentMethodName = name;
    codChecked = false;
    walletChecked = false;
    offlineChecked = false;
    notifyListeners();
  }

  void digitalOnly(bool value, {bool isUpdate = false}){
    _onlyDigital = value;
    if(isUpdate){
      notifyListeners();
    }

  }

  OfflinePaymentModel? offlinePaymentModel;
  Future<ApiResponse> getOfflinePaymentList() async {
    ApiResponse apiResponse = await checkoutServiceInterface.offlinePaymentList();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      offlineMethodSelectedIndex = 0;
      offlinePaymentModel = OfflinePaymentModel.fromJson(apiResponse.response?.data);
    }
    else {
      ApiChecker.checkApi( apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  List<TextEditingController> inputFieldControllerList = [];
  List <String?> keyList = [];
  int offlineMethodSelectedIndex = -1;
  int offlineMethodSelectedId = 0;
  String offlineMethodSelectedName = '';

  void setOfflinePaymentMethodSelectedIndex(int index, {bool notify = true}){
    keyList = [];
    inputFieldControllerList = [];
    offlineMethodSelectedIndex = index;
    if(offlinePaymentModel != null && offlinePaymentModel!.offlineMethods!= null && offlinePaymentModel!.offlineMethods!.isNotEmpty){
      offlineMethodSelectedId = offlinePaymentModel!.offlineMethods![offlineMethodSelectedIndex].id!;
      offlineMethodSelectedName = offlinePaymentModel!.offlineMethods![offlineMethodSelectedIndex].methodName!;
    }

    if(offlinePaymentModel!.offlineMethods != null && offlinePaymentModel!.offlineMethods!.isNotEmpty && offlinePaymentModel!.offlineMethods![index].methodInformations!.isNotEmpty){
      for(int i= 0; i< offlinePaymentModel!.offlineMethods![index].methodInformations!.length; i++){
        inputFieldControllerList.add(TextEditingController());
        keyList.add(offlinePaymentModel!.offlineMethods![index].methodInformations![i].customerInput);
      }
    }
    if(notify){
      notifyListeners();
    }

  }

  Future<ApiResponse> digitalPaymentPlaceOrder({String? orderNote, String? customerId,
    String? addressId, String? billingAddressId,
    String? couponCode,
    String? couponDiscount,
    String? paymentMethod}) async {
    _isLoading = true;
    notifyListeners();

    try {
      ApiResponse apiResponse = await checkoutServiceInterface.digitalPaymentPlaceOrder(
        orderNote, 
        customerId, 
        addressId, 
        billingAddressId, 
        couponCode, 
        couponDiscount, 
        'razor_pay', // Force payment method to be razor_pay
        receiptId: 'order_${DateTime.now().millisecondsSinceEpoch}'.substring(0, 19)
      );

      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _isLoading = false;
        
        // Handle the response data
        dynamic responseData = apiResponse.response?.data;
        String? redirectLink;

        // If response is a string, it's the redirect link
        if (responseData is String) {
          redirectLink = responseData;
        } 
        // If response is a map, get the redirect_link
        else if (responseData is Map) {
          redirectLink = responseData['redirect_link']?.toString();
        }

        if (redirectLink != null && redirectLink.isNotEmpty) {
          if (Get.context != null && Get.context!.mounted) {
          Navigator.pushReplacement(
            Get.context!, 
            MaterialPageRoute(
              builder: (_) => DigitalPaymentScreen(
                  url: redirectLink,
                onPaymentComplete: (bool success) async {
                  if (success) {
                    await Provider.of<CartController>(Get.context!, listen: false).clearCart();
                    await Provider.of<CartController>(Get.context!, listen: false).getCartData(Get.context!);
                  }
                }
              )
            )
          );
          }
        } else {
          if (Get.context != null && Get.context!.mounted) {
          showCustomSnackBar('${getTranslated('payment_method_not_properly_configured', Get.context!)}', Get.context!);
          }
        }
      } else {
        _isLoading = false;
        if (Get.context != null && Get.context!.mounted) {
        showCustomSnackBar('${getTranslated('payment_method_not_properly_configured', Get.context!)}', Get.context!);
        }
      }
      notifyListeners();
      return apiResponse;
    } catch (e) {
      _isLoading = false;
      if (Get.context != null && Get.context!.mounted) {
      showCustomSnackBar('${getTranslated('payment_failed', Get.context!)}', Get.context!);
      }
      notifyListeners();
      return ApiResponse.withError(e.toString());
    }
  }

  bool sameAsBilling = false;
  void setSameAsBilling(){
    sameAsBilling = !sameAsBilling;
    notifyListeners();
  }

  late Razorpay _razorpay;
  bool _isRazorpayInitialized = false;

  void initRazorpay() {
    if (!_isRazorpayInitialized) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      _isRazorpayInitialized = true;
    }
  }

  Future<void> initiateRazorpayPayment({
    required String orderNote,
    required String customerId,
    required String addressId,
    required String billingAddressId,
    required String couponCode,
    required String couponDiscount,
    required String paymentMethod,
    required double amount,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Store the values
      _addressId = addressId;
      _billingAddressId = billingAddressId;
      _couponCode = couponCode;
      _couponDiscount = couponDiscount;
      _customerId = customerId;

      // Initialize Razorpay
      initRazorpay();

      // Create Razorpay options directly
      var options = {
        'key': AppConstants.razorpayKey,
        'amount': (amount * 100).toInt(), // Amount in smallest currency unit
        'name': 'Your App Name',
        'description': 'Order Payment',
        'prefill': {
          'contact': '',
          'email': ''
        },
        'external': {
          'wallets': ['paytm', 'phonepe', 'gpay', 'bhim']
        }
      };

      // Open Razorpay payment sheet
      _razorpay.open(options);
    } catch (e) {
      if (Get.context != null && Get.context!.mounted) {
        showCustomSnackBar('${getTranslated('payment_failed', Get.context!)}: ${e.toString()}', Get.context!);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      print('[RZP] PaymentSuccessResponse: paymentId=${response.paymentId}, orderId=${response.orderId}, signature=${response.signature}');
      if (response.paymentId == null) {
        print('[RZP] ERROR: paymentId is null');
        throw Exception('Invalid payment response');
      }

      _isLoading = true;
      notifyListeners();

      // Use placeOrder with payment details
      await placeOrder(
        callback: (success, message, orderId) {
          if (success) {
            print('[RZP] Order placed successfully. Clearing cart.');
            if (Get.context != null && Get.context!.mounted) {
              Navigator.of(Get.context!).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const DashBoardScreen()),
                (route) => false
              );
              showAnimatedDialog(Get.context!, OrderPlaceDialogWidget(
                icon: Icons.done,
                title: getTranslated('order_placed', Get.context!),
                description: getTranslated('your_order_placed', Get.context!),
              ), dismissible: false, willFlip: true);
            }
          } else {
            print('[RZP] ERROR: Order creation failed: $message');
            if (Get.context != null && Get.context!.mounted) {
              Navigator.of(Get.context!).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const DashBoardScreen()),
                (route) => false
              );
              showAnimatedDialog(Get.context!, OrderPlaceDialogWidget(
                icon: Icons.clear,
                title: getTranslated('payment_failed', Get.context!),
                description: 'Payment successful but order creation failed: $message',
                isFailed: true,
              ), dismissible: false, willFlip: true);
            }
          }
        },
        addressID: _addressId,
        couponCode: _couponCode,
        couponAmount: _couponDiscount,
        billingAddressId: _billingAddressId,
        orderNote: orderNoteController.text,
        transactionId: response.paymentId,
        paymentNote: 'Payment completed via Razorpay',
        name: 'razor_pay'
      );

    } catch (e) {
      print('[RZP] EXCEPTION: $e');
      _isLoading = false;
      notifyListeners();
      if (Get.context != null && Get.context!.mounted) {
        Navigator.of(Get.context!).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashBoardScreen()),
          (route) => false
        );
        showAnimatedDialog(Get.context!, OrderPlaceDialogWidget(
          icon: Icons.clear,
          title: getTranslated('payment_failed', Get.context!),
          description: 'Payment successful but order creation failed: ${e.toString()}',
          isFailed: true,
        ), dismissible: false, willFlip: true);
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _isLoading = false;
    notifyListeners();
    
    if (Get.context != null && Get.context!.mounted) {
      Navigator.of(Get.context!).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashBoardScreen()),
        (route) => false
      );
      showAnimatedDialog(Get.context!, OrderPlaceDialogWidget(
        icon: Icons.clear,
        title: getTranslated('payment_failed', Get.context!),
        description: response.message ?? getTranslated('your_payment_failed', Get.context!),
        isFailed: true,
      ), dismissible: false, willFlip: true);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet selection
  }

  @override
  void dispose() {
    if (_isRazorpayInitialized) {
      _razorpay.clear();
    }
    super.dispose();
  }
}
