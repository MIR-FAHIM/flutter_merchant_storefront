import 'dart:ui';
import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/app/modules/global_widgets/block_button_widget.dart';
import 'package:ecom_delivery_flutter/app/modules/global_widgets/text_field_widget.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/login_controller.dart';


class LoginView extends GetView<LoginController> {

  final userdata = GetStorage();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    userdata.write('mobile_number', controller.mobileNumber.value);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
        resizeToAvoidBottomInset: true,
        body: Obx(() {
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10,),

                GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SizedBox(
                    width: _size.width,
                    height: _size.height,
                    child: Stack(
                      children: [


                        Positioned(
                          top: 180,
                          left: 0,
                          right: 0,
                          child: Container(
                            // height: _size.width,
                            width: _size.width,
                            margin: EdgeInsets.all(_size.width * .04),
                            decoration: Ui.getBoxDecoration(color: AppColors.backgroundColor,),
                            child: Form(
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              key: controller.loginFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(
                                    height: _size.width * .04,
                                  ),
                                  const Center(
                                    child: Text(
                                      'Login to ${CompanyData.appname}',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: _size.width * .04,
                                  ),
                                  TextFieldWidget(
                                    labelText: "Email or mobile".tr,
                                    hintText: "Email/Mobile".tr,
                                    keyboardType: TextInputType.text,
                                    readOnly: false,

                                    // onTapped: () {
                                    //   FocusScope.of(context).requestFocus(FocusNode());
                                    // },
                                    initialValue: controller.mobileNumber.value,
                                    onChanged: (input) => controller.mobileNumber.value = input,
                                    // onSaved: (input) =>
                                    // controller.currentUser.value.email = input,
                                    // validator: (input) => !input!.contains('@') ? "Should be a valid email".tr : null,
                                    // iconData: CupertinoIcons.device_phone_portrait,
                                    imageData: 'assets/icons/number_pad.png',
                                  ),
                                  TextFieldWidget(
                                    labelText: "Password:".tr,
                                    hintText: "***".tr,
                                    keyboardType: TextInputType.text,
                                    obscureText: controller.hidePassword.value,
                                    onChanged: (input) {
                                      controller.password.value = input;
                                    },



                                    
                                    limit: 15,
                                    counterText: "",
                                    validator: (input) => input!.length < 4 ? "Should be more than 15 characters".tr : null,

                                    // obscureText:
                                    // Get.put(AuthController()).hidePassword.value,
                                    // iconData: Icons.lock_outline,
                                    iconData: CupertinoIcons.lock,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        controller.hidePassword.value = !controller.hidePassword.value;
                                      },
                                      color: const Color(0xFF652981),
                                      icon: Icon(
                                        !controller.hidePassword.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: !controller.hidePassword.value ? const Color(0xFF652981) : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  // TextField(
                                  //   decoration: InputDecoration(
                                  //     hintText: "Email",
                                  //     counterText: "",
                                  //   ),
                                  //   maxLength: 6,
                                  // ),
                                  // Row(
                                  //   mainAxisAlignment: MainAxisAlignment.end,
                                  //   children: [
                                  //     InkWell(
                                  //       onTap: () {
                                  //
                                  //
                                  //
                                  //       },
                                  //       child: Container(
                                  //         child: Text(
                                  //           "Forget Pin?".tr,
                                  //           style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                  //         ),
                                  //       ),
                                  //     )
                                  //   ],
                                  // ).paddingSymmetric(horizontal: 20),
                                  SizedBox(
                                    height: _size.width * .04,
                                  ),
                                  BlockButtonWidget(
                                    onPressed: () {
                                     // FirebaseService().logCustomEvent();
                                      controller.login();
                                    },
                                    color: Colors.green,
                                    text: Text(
                                      "Login".tr,
                                      style: Get.textTheme.bodyMedium!.merge(const TextStyle(color: Colors.white)),
                                    ),
                                  ).paddingSymmetric(vertical: _size.width * .04, horizontal: 20),

                                  SizedBox(
                                    height: _size.width * .08,
                                  ),
                                  const Center(
                                    child: Text(
                                      'Version ${CompanyData.appVersion}',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }));
  }
}
