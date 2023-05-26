// ignore_for_file: use_build_context_synchronously

import 'package:bobi_pay_out/main.dart';
import 'package:bobi_pay_out/manager/config_mgr.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/model/sql/tablesInit.dart';
import 'package:bobi_pay_out/utils/route/routers.dart';
import 'package:bobi_pay_out/utils/utility.dart';
import 'package:bobi_pay_out/view_model/config_model.dart';
import 'package:bobi_pay_out/view_model/root_scene_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:provider/provider.dart';

class WoDePage extends StatefulWidget {
  const WoDePage({Key? key}) : super(key: key);

  @override
  State<WoDePage> createState() => _WoDePageState();
}

class _WoDePageState extends State<WoDePage> {
  final TextEditingController _desController =
      TextEditingController(); // config_des
  final TextEditingController _valueController =
      TextEditingController(); // config_value
  final TextEditingController _keyController =
      TextEditingController(); // config_key

  @override
  void initState() {
    super.initState();
  }

  Widget getRow(
      {required TextEditingController controller,
      required String title,
      required String hintText,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      bool disable = false}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(title),
        Expanded(
          child: Container(
            height: 40.w,
            decoration: BoxDecoration(
              color: disable ? Colors.grey : const Color(0xffededed),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: TextField(
              readOnly: disable,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: TextStyle(fontSize: 12.w),
              keyboardAppearance: Brightness.light,
              controller: controller,
              maxLines: 1,
              decoration: InputDecoration(
                isDense: true,
                enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        width: 0,
                        color: Colors.transparent,
                        style: BorderStyle.none)), //输入框启用时，下划线的样式
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        width: 0,
                        color: Colors.transparent,
                        style: BorderStyle.none)),
                contentPadding: EdgeInsets.only(
                  top: 12.w,
                  left: 16.w,
                  right: 32.w,
                ),
                hintText: hintText,
              ),
            ),
          ),
        )
      ],
    );
  }

  // 表单添加数据
  Future<void> showInformationDialog(BuildContext context,
      {ConfData? confData}) async {
    bool isEdit = false;
    if (confData == null || confData.isEmpty) {
      _desController.clear();
      _valueController.clear();
      _keyController.clear();
    } else {
      isEdit = true;
      _desController.text = confData.config_desc!;
      _valueController.text = confData.config_value!;
      _keyController.text = confData.config_key!;
    }
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 100),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: EdgeInsets.all(10.w),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              height: MediaQuery.of(context).size.height / 3.0 + 30.h,
              child: Column(
                children: [
                  const Center(
                    child: Text('参数配置'),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  //key
                  getRow(
                      disable: isEdit,
                      controller: _keyController,
                      title: '键名:  ',
                      hintText: '请输入键名'),
                  SizedBox(height: 10.w),
                  // 参数描
                  getRow(
                      disable: isEdit,
                      controller: _desController,
                      title: '描述:  ',
                      hintText: '请输入参数描述'),
                  SizedBox(height: 10.w),
                  //数据
                  getRow(
                      controller: _valueController,
                      title: '内容:  ',
                      hintText: '请输入参数内容'),
                  SizedBox(height: 20.w),
                  Row(
                    // mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          child: const Text('取消'),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            Routes.popPage(context);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Expanded(
                        child: ElevatedButton(
                            child: Text(isEdit ? '修改' : '添加'),
                            onPressed: () async {
                              if (isEdit) {
                                await confMgr.edit(ConfData(
                                    id: confData!.id,
                                    config_desc: _desController.text,
                                    config_key: _keyController.text,
                                    config_value: _valueController.text));
                                Routes.popPage(context);
                              } else {
                                await confMgr.add(ConfData(
                                    config_desc: _desController.text,
                                    config_key: _keyController.text,
                                    config_value: _valueController.text));
                                Routes.popPage(context);
                              }
                            }),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 48,
        backgroundColor: mainColor,
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: Consumer<ConfigModel>(
              builder: (BuildContext context, value, Widget? child) {
                return ListView.builder(
                    itemCount: value.list.length,
                    itemBuilder: (BuildContext context, int index) {
                      return SwipeActionCell(
                          key: ValueKey(value.list[index]),
                          trailingActions: <SwipeAction>[
                            SwipeAction(
                              ///
                              /// This attr should be passed to first action
                              ///
                              nestedAction: SwipeNestedAction(title: "确认删除"),
                              title: "删除",
                              onTap: (CompletionHandler handler) async {
                                if (confMgr.listKey
                                    .contains(value.list[index].config_key!)) {
                                  showToastTip(
                                      '${value.list[index].config_key}不允许删除');
                                  await handler(false);
                                  return;
                                }
                                bool result =
                                    await confMgr.delete(value.list[index]);
                                if (result) {
                                  showToastTip('删除成功');
                                }
                                await handler(result);
                              },
                              color: Colors.red,
                            ),
                            SwipeAction(
                                title: "编辑",
                                onTap: (CompletionHandler handler) async {
                                  await showInformationDialog(context,
                                      confData: value.list[index]);
                                },
                                color: Colors.blue),
                          ],
                          child: InkWell(
                            onLongPress: () {
                              if (confMgr.secretListKey
                                  .contains(value.list[index].config_key)) {
                                return;
                              }
                              copyStr(
                                  value.list[index].config_value.toString());
                              showToastTip(
                                  "复制成功:${value.list[index].config_value}");
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Card(
                                child: ListTile(
                                  // leading: const Icon(Icons.all_inclusive),
                                  title: Padding(
                                    padding: EdgeInsets.only(bottom: 10.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text('${value.list[index].config_desc}',
                                            style: TextStyle(
                                                fontSize: 14.w)), //configDesc
                                        Text(
                                          '${value.list[index].config_key}', //configKey
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  subtitle: Text(
                                      value.list[index].secretValue.toString(),
                                      style: TextStyle(fontSize: 12.w)),
                                ),
                              ),
                            ),
                          ));
                    });
              },
            ),
          ),
          Container(
              decoration: BoxDecoration(
                  border:
                      Border(top: BorderSide(width: 1.w, color: Colors.grey))),
              height: 100.w,
              width: MediaQuery.of(context).size.width - 20.w,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            await showCustomDialog(context,
                                content: '您确定要重置所有配置吗？(会清理本地库)',
                                ok: '重置', onResult: (result) async {
                              if (!result) return;

                              await sqlTables.dropAllTable();
                              await mainInit();
                              await mainUpdateConf();
                              showToastTip('重置所有配置完成');
                            });
                          },
                          child: const Text("重置所有配置")),
                      SizedBox(
                        width: 10.w,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                          onPressed: () async {
                            await showCustomDialog2(context,
                                title: '请输入json内容',
                                content: '导入配置',
                                ok: '导入', onResult: (result, {str}) async {
                              if (!result) return;
                              final a = await confMgr.importConf(str!);
                              if (a) {
                                showToastTip('导入配置完成');
                              } else {
                                showToastTip('导入配置失败,请检查json内容');
                              }
                            });
                          },
                          child: const Text("导入配置")),
                      SizedBox(
                        width: 10.w,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            await showCustomDialog(context,
                                content: '导出配置',
                                ok: '导出', onResult: (result) async {
                              if (!result) return;
                              final a = await confMgr.outportConf();
                              if (a) {
                                showToastTip('导出配置完成');
                              } else {
                                showToastTip('导出配置失败');
                              }
                            });
                          },
                          child: const Text("导出配置")),
                    ],
                  )
                ],
              )),
        ],
      )),
      floatingActionButton:
          Provider.of<RootSceneModel>(context).currentPage == RootScenePage.Wode
              ? FloatingActionButton(
                  onPressed: () async {
                    await showInformationDialog(context);
                  },
                  backgroundColor: mainColor,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24.0,
                  ),
                )
              : null,
    );
  }
}
