import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/common/user.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/base_model.dart';
import 'package:flutter_wanandroid/data/model/collection_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/widgets/progress_view.dart';

/// 收藏页面
class CollectScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return new CollectScreenState();
  }
}

class CollectScreenState extends BaseWidgetState<CollectScreen> {
  List<CollectionBean> _collectList = new List();

  /// listview 控制器
  ScrollController _scrollController = new ScrollController();

  /// 是否显示悬浮按钮
  bool _isShowFAB = false;

  /// 页码，从0开始
  int _page = 0;

  @override
  void initState() {
    super.initState();

    showLoading();
    getCollectionList();

    _scrollController.addListener(() {
      /// 滑动到底部，加载更多
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getMoreCollectionList();
      }
      if (_scrollController.offset < 200 && _isShowFAB) {
        setState(() {
          _isShowFAB = false;
        });
      } else if (_scrollController.offset >= 200 && !_isShowFAB) {
        setState(() {
          _isShowFAB = true;
        });
      }
    });
  }

  /// 获取收藏文章列表
  Future<Null> getCollectionList() async {
    _page = 0;
    ApiService().getCollectionList((CollectionModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          showContent();
          setState(() {
            _collectList.clear();
            _collectList.addAll(model.data.datas);
          });
        } else {
          showEmpty();
        }
      } else {
        Navigator.pop(context);
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      print(error.response);
      setState(() {
        showError();
      });
    }, _page);
  }

  /// 获取更多文章列表
  Future<Null> getMoreCollectionList() async {
    _page++;
    ApiService().getCollectionList((CollectionModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          showContent();
          setState(() {
            _collectList.addAll(model.data.datas);
          });
        } else {
          T.show(msg: "没有更多数据了");
        }
      } else {
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      print(error.response);
      setState(() {
        showError();
      });
    }, _page);
  }

  @override
  AppBar attachAppBar() {
    return AppBar(
      title: Text("收藏"),
    );
  }

  @override
  Widget attachContentWidget(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        displacement: 15,
        onRefresh: getCollectionList,
        child: ListView.builder(
            itemBuilder: itemView,
            physics: new AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            // 包含轮播和加载更多
            itemCount: _collectList.length + 1),
      ),
      floatingActionButton: !_isShowFAB
          ? null
          : FloatingActionButton(
              heroTag: "collect",
              child: Icon(Icons.arrow_upward, color: Colors.white),
              onPressed: () {
                /// 回到顶部时要执行的动画
                _scrollController.animateTo(0,
                    duration: Duration(milliseconds: 2000), curve: Curves.ease);
              },
            ),
    );
  }

  Widget itemView(BuildContext context, int index) {
    if (index < _collectList.length) {
      CollectionBean item = _collectList[index];
      return InkWell(
        onTap: () {
          RouteUtil.toWebView(context, item.title, item.link);
        },
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Offstage(
                  offstage: item.envelopePic == '',
                  child: Container(
                    width: 100,
                    height: 80,
                    padding: EdgeInsets.fromLTRB(16, 10, 8, 10),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: item.envelopePic,
                      placeholder: (context, url) => new ProgressView(),
                      errorWidget: (context, url, error) =>
                          new Icon(Icons.error),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Row(
                          children: <Widget>[
                            Text(
                              item.author,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Expanded(
                              child: Text(
                                item.niceDate,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 2,
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.left,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                item.chapterName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            InkWell(
                              child: Container(
                                child: Image(
                                  // color: Colors.black12,
                                  image:
                                      AssetImage('assets/images/ic_like.png'),
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              onTap: () {
                                cancelCollect(index, item);
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Divider(height: 1),
          ],
        ),
      );
    }
    return null;
  }

  /// 取消收藏
  void cancelCollect(index, item) {
    List<String> cookies = User.singleton.cookie;
    if (cookies == null || cookies.length == 0) {
      T.show(msg: '请先登录~');
    } else {
      ApiService().cancelCollection((BaseModel model) {
        if (model.errorCode == Constants.STATUS_SUCCESS) {
          T.show(msg: '已取消收藏~');
          setState(() {
            _collectList.removeAt(index);
          });
        } else {
          T.show(msg: '取消收藏失败~');
        }
      }, (DioError error) {
        print(error.response);
      }, item.id);
    }
  }

  @override
  void onClickErrorWidget() {
    showLoading();
    getCollectionList();
  }
}
