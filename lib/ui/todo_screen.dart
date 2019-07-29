import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/base_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';

class TodoScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return TodoScreenState();
  }
}

class TodoScreenState extends BaseWidgetState<TodoScreen> {
  /// 获取TODO列表数据
  Future<Null> getTodoList() async {
    ApiService().getTodoList((BaseModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
      } else {}
    }, (DioError error) {
      print(error.response);
      showError();
    });
  }

  @override
  AppBar attachAppBar() {
    return new AppBar(
      title: Text(""),
    );
  }

  @override
  Widget attachContentWidget(BuildContext context) {
    return Text("");
  }

  @override
  void onClickErrorWidget() {}
}