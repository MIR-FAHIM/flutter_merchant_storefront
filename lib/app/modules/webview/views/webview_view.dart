import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../controllers/webview_controller.dart';

class WebviewView extends GetView<WebviewController> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.handleBack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            title: Obx(
              () => Text(
                controller.title.value,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
          body: Stack(
            children: [
              InAppWebView(
                key: GlobalKey(),
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    transparentBackground: true,
                  ),
                ),
                initialUrlRequest: URLRequest(
                  url: WebUri(controller.paymentUrl.value),
                ),
                onWebViewCreated: (InAppWebViewController webController) {
                  controller.setWebViewController(webController);
                },
                onProgressChanged: (InAppWebViewController webController, int progress) {
                  controller.progress.value = progress / 100;
                },
                onUpdateVisitedHistory: (
                  InAppWebViewController webController,
                  WebUri? uri,
                  bool? androidIsReload,
                ) {
                  controller.handleVisitedUrl(uri?.toString());
                },
              ),
              Obx(
                () => controller.progress.value < 1
                    ? LinearProgressIndicator(value: controller.progress.value)
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

