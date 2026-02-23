import 'dart:async';
import 'dart:io';
import 'package:v_one_mshwar_app_customer/common/widget/custom_app_bar.dart';
import 'package:v_one_mshwar_app_customer/core/constant/constant.dart';
import 'package:v_one_mshwar_app_customer/core/constant/show_toast_dialog.dart';
import 'package:v_one_mshwar_app_customer/features/ride/chat/controller/conversation_controller.dart';
import 'package:v_one_mshwar_app_customer/features/ride/chat/view/FullScreenImageViewer.dart';
import 'package:v_one_mshwar_app_customer/features/ride/chat/view/FullScreenVideoViewer.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';
import 'package:v_one_mshwar_app_customer/core/utils/dark_theme_provider.dart';
import 'package:v_one_mshwar_app_customer/common/widget/firebase_pagination/src/firestore_pagination.dart';
import 'package:v_one_mshwar_app_customer/common/widget/firebase_pagination/src/models/view_type.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ConversationScreen extends StatelessWidget {
  ConversationScreen({super.key});

  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDarkMode = themeChange.getThem();

    return GetX<ConversationController>(
      init: ConversationController(),
      initState: (controller) {
        if (_controller.hasClients) {
          Timer(
            const Duration(milliseconds: 500),
            () => _controller.jumpTo(_controller.position.maxScrollExtent),
          );
        }
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: isDarkMode
              ? AppThemeData.surface50Dark
              : AppThemeData.surface50,
          appBar: CustomAppBar(
            title: controller.receiverName.value,
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: FirestorePagination(
                  controller: _controller,
                  physics: const BouncingScrollPhysics(),
                  onEmpty: Center(
                    child: Text(
                      "No message found".tr,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppThemeData.grey900Dark
                            : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  itemBuilder: (context, documentSnapshots, index) {
                    final data = documentSnapshots[index].data() as Map?;
                    return chatItemView(
                      data!['senderId'] == controller.senderId.value,
                      data,
                      controller,
                    );
                  },
                  // orderBy is compulsory to enable pagination
                  query: Constant.conversation
                      .doc(
                        "${controller.senderId.value < controller.receiverId.value ? controller.senderId.value : controller.receiverId.value}-${controller.orderId}-${controller.senderId.value < controller.receiverId.value ? controller.receiverId.value : controller.senderId.value}",
                      )
                      .collection("thread")
                      .orderBy('created', descending: false),
                  //Change types accordingly
                  viewType: ViewType.list,
                  // to fetch real-time data
                  isLive: true,
                ),
              ),
              buildMessageInput(controller, context),
            ],
          ),
        );
      },
    );
  }

  Widget chatItemView(
    bool isMe,
    Map<dynamic, dynamic> data,
    ConversationController controller,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: isMe
          ? Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  data['type'] == "text"
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            color: AppThemeData.primary200,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Text(
                            data['message'],
                            style: TextStyle(
                              color:
                                  data['senderId'] == controller.senderId.value
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        )
                      : data['type'] == "image"
                      ? ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 50,
                            maxWidth: 200,
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Get.to(
                                      FullScreenImageViewer(
                                        imageUrl: data['url']['url'],
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: data['url']['url'],
                                    child: CachedNetworkImage(
                                      imageUrl: data['url']['url'],
                                      placeholder: (context, url) =>
                                          Constant.loader(context),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                            "assets/icons/appLogo.png",
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : FloatingActionButton(
                          mini: true,
                          heroTag: data['id'],
                          backgroundColor: AppThemeData.primary200,
                          onPressed: () {
                            Get.to(
                              FullScreenVideoViewer(
                                heroTag: data['id'],
                                videoUrl: data['url']['url'],
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child:
                          (controller.senderPhoto.value.isNotEmpty &&
                              controller.senderPhoto.value != 'null')
                          ? CachedNetworkImage(
                              imageUrl: controller.senderPhoto.value,
                              height: 35,
                              width: 35,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                "assets/icons/appLogo.png",
                                height: 35,
                                width: 35,
                              ),
                            )
                          : Image.asset(
                              "assets/icons/appLogo.png",
                              height: 35,
                              width: 35,
                            ),
                    ),
                  ),
                ],
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child:
                        (controller.receiverPhoto.value.isNotEmpty &&
                            controller.receiverPhoto.value != 'null')
                        ? CachedNetworkImage(
                            imageUrl: controller.receiverPhoto.value,
                            height: 35,
                            width: 35,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              "assets/icons/appLogo.png",
                              height: 35,
                              width: 35,
                            ),
                          )
                        : Image.asset(
                            "assets/icons/appLogo.png",
                            height: 35,
                            width: 35,
                          ),
                  ),
                ),
                data['type'] == "text"
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          color: AppThemeData.grey200,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Text(
                          data['message'],
                          style: TextStyle(
                            color: data['senderId'] == controller.senderId.value
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      )
                    : data['type'] == "image"
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 50,
                          maxWidth: 200,
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.to(
                                    FullScreenImageViewer(
                                      imageUrl: data['url']['url'],
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: data['url']['url'],
                                  child: CachedNetworkImage(
                                    imageUrl: data['url']['url'],
                                    placeholder: (context, url) =>
                                        Constant.loader(context),
                                    errorWidget: (context, url, error) =>
                                        Image.asset("assets/icons/appLogo.png"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : FloatingActionButton(
                        mini: true,
                        heroTag: data['id'],
                        backgroundColor: AppThemeData.primary200,
                        onPressed: () {
                          Get.to(
                            FullScreenVideoViewer(
                              heroTag: data['id'],
                              videoUrl: data['url']['url'],
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
              ],
            ),
    );
  }

  static final _messageController = TextEditingController();

  Widget buildMessageInput(
    ConversationController controller,
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppThemeData.grey200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  onPressed: () async {
                    _onCameraClick(context, controller);
                  },
                  icon: const Icon(Icons.camera_alt),
                  color: AppThemeData.primary200,
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextField(
                    textInputAction: TextInputAction.send,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    controller: _messageController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppThemeData.grey200,
                      contentPadding: const EdgeInsets.only(top: 3, left: 10),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppThemeData.grey300,
                          width: 0.0,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppThemeData.grey300,
                          width: 0.0,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      hintText: 'Start typing ...'.tr,
                    ),
                    onSubmitted: (value) {
                      controller.sendMessage(
                        _messageController.text.trim(),
                        Url(mime: '', url: ''),
                        "",
                        "text",
                      );
                      Timer(
                        const Duration(milliseconds: 500),
                        () => _controller.jumpTo(
                          _controller.position.maxScrollExtent,
                        ),
                      );
                      _messageController.clear();
                    },
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: AppThemeData.grey200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  onPressed: () async {
                    if (_messageController.text.trim().isNotEmpty) {
                      controller.sendMessage(
                        _messageController.text.trim(),
                        Url(mime: '', url: ''),
                        "",
                        "text",
                      );
                      Timer(
                        const Duration(milliseconds: 500),
                        () => _controller.jumpTo(
                          _controller.position.maxScrollExtent,
                        ),
                      );
                      _messageController.clear();
                    } else {
                      ShowToastDialog.showToast("Please enter a message".tr);
                    }
                  },
                  icon: const Icon(Icons.send_rounded),
                  color: AppThemeData.primary200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCameraClick(BuildContext context, ConversationController controller) {
    final action = CupertinoActionSheet(
      message: Text(
        'Send media'.tr,
        style: const TextStyle(fontSize: 15.0, fontFamily: 'Cairo'),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Get.back();
            XFile? image = await ImagePicker().pickImage(
              source: ImageSource.gallery,
            );
            if (image != null) {
              Url url = await Constant.uploadChatImageToFireStorage(
                File(image.path),
              );
              controller.sendMessage("Sent an image".tr, url, "", 'image');
            }
          },
          child: Text('Choose image from gallery'.tr),
        ),
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Get.back();
            XFile? galleryVideo = await ImagePicker().pickVideo(
              source: ImageSource.gallery,
            );
            if (galleryVideo != null) {
              ChatVideoContainer videoContainer =
                  await Constant.uploadChatVideoToFireStorage(
                    File(galleryVideo.path),
                  );
              controller.sendMessage(
                "Sent an video".tr,
                videoContainer.videoUrl,
                videoContainer.thumbnailUrl,
                'video',
              );
            }
          },
          child: Text('Choose video from gallery'.tr),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Get.back();
            XFile? image = await ImagePicker().pickImage(
              source: ImageSource.camera,
            );
            if (image != null) {
              Url url = await Constant.uploadChatImageToFireStorage(
                File(image.path),
              );
              controller.sendMessage('Sent an image'.tr, url, '', 'image');
            }
          },
          child: Text('Take a picture'.tr),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Get.back();
            XFile? recordedVideo = await ImagePicker().pickVideo(
              source: ImageSource.camera,
            );
            if (recordedVideo != null) {
              ChatVideoContainer videoContainer =
                  await Constant.uploadChatVideoToFireStorage(
                    File(recordedVideo.path),
                  );
              controller.sendMessage(
                'Sent an video'.tr,
                videoContainer.videoUrl,
                videoContainer.thumbnailUrl,
                'video',
              );
            }
          },
          child: Text('Record video'.tr),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('cancel'.tr),
        onPressed: () {
          Get.back();
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}

class ChatVideoContainer {
  Url videoUrl;

  String thumbnailUrl;

  ChatVideoContainer({required this.videoUrl, required this.thumbnailUrl});
}
