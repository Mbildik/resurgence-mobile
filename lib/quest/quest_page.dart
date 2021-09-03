import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/item/ui.dart';
import 'package:resurgence/quest/carousel.dart';
import 'package:resurgence/quest/quest.dart';
import 'package:resurgence/quest/service.dart';
import 'package:resurgence/task/model.dart';
import 'package:resurgence/ui/bottom_sheet.dart';
import 'package:resurgence/ui/error_handler.dart';
import 'package:resurgence/ui/shared.dart';

class QuestPage extends StatefulWidget {
  const QuestPage({Key key}) : super(key: key);

  @override
  _QuestPageState createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  QuestService _service;
  Future<List<QuestResponse>> _quests;

  @override
  void initState() {
    super.initState();
    this._service = context.read<QuestService>();
    this._quests = this._service.all();
  }

  Future<List<QuestResponse>> _refresh() {
    var quests = _service.all();
    setState(() {
      this._quests = quests;
    });
    return quests;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Görevler"),
      ),
      body: LoadingFutureBuilder<List<QuestResponse>>(
        future: this._quests,
        onError: this._refresh,
        builder: (context, snapshot) {
          var quests = snapshot.data;

          return RefreshIndicator(
            onRefresh: this._refresh,
            child: ListView.separated(
              separatorBuilder: (_, __) => SizedBox(height: 16.0),
              itemCount: quests.length,
              itemBuilder: (context, index) {
                var quest = quests[index];

                return QuestCard(
                  questResponse: quest,
                  onPerform: () => context
                      .read<QuestService>()
                      .perform(quest.id)
                      .catchError((e) => ErrorHandler.showError(context, e))
                      .whenComplete(() {
                    this._refresh();
                    Navigator.maybePop(context)
                        .then((_) => showQuestCompleteDialog(context, quest));
                  }),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void showQuestCompleteDialog(context, QuestResponse questResponse) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Görevi başarı ile tamamladın.'),
          contentPadding: const EdgeInsets.all(8.0),
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200.0,
              child: CarouselWidget(
                onChildChanged: (f) {},
                children: questResponse.quest.itemRewards.map((e) {
                  return AspectRatio(
                    aspectRatio: 1.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Tooltip(
                          message: e.item.value,
                          child: Image.network(e.item.image),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Text(
                            'x${e.quantity}',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        )
                      ],
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () => Navigator.maybePop(context),
                child: Text('Topla'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class QuestCard extends StatelessWidget {
  const QuestCard({
    Key key,
    @required this.questResponse,
    @required this.onPerform,
  }) : super(key: key);

  final QuestResponse questResponse;
  final VoidCallback onPerform;

  @override
  Widget build(BuildContext context) {
    var title = Text(
      questResponse.name,
      style: Theme.of(context).textTheme.headline6,
    );
    var description = Text(
      questResponse.description,
      style: Theme.of(context).textTheme.subtitle2,
    );
    var bottom = Row(
      children: [
        Icon(
          Icons.keyboard_arrow_up,
          color: Colors.lightGreenAccent,
        ),
        Text(
          NumberFormat.compact()
                  .format(questResponse.quest.experienceReward.experience) +
              " EXP",
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.lightGreenAccent),
        ),
        Spacer(),
        Text(
          "Ayrıntılar için tıkla",
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );

    final bottomBorderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(8.0),
      bottomRight: Radius.circular(8.0),
    );

    return Card(
      child: InkWell(
        borderRadius: bottomBorderRadius,
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return _DetailWidget(
                questResponse: questResponse,
                onPerform: this.onPerform,
              );
            },
          );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  description,
                  const SizedBox(height: 16.0),
                  bottom,
                ],
              ),
            ),
            Container(
              height: 20.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: bottomBorderRadius,
              ),
              child: QuestPercentage(percentage: questResponse.percentage),
            )
          ],
        ),
      ),
    );
  }
}

class _DetailWidget extends StatelessWidget {
  const _DetailWidget({
    Key key,
    @required this.questResponse,
    @required this.onPerform,
  }) : super(key: key);

  final QuestResponse questResponse;
  final VoidCallback onPerform;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BottomSheetPin(),
        const SizedBox(height: 16.0),
        Text(
          questResponse.name,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // const Divider(color: Colors.grey),
                  if (questResponse
                      .quest.consumeItemCompleteRequirements.isNotEmpty)
                    QuestCompleteSubject(
                      title: 'Harcanması gereken malzemeler',
                      itemCount: questResponse
                          .quest.consumeItemCompleteRequirements.length,
                      itemBuilder: (context, index) {
                        var e = questResponse
                            .quest.consumeItemCompleteRequirements[index];
                        var item = e.item;
                        var mustHave = e.quantity;
                        var gathered = mustHave -
                            (questResponse.needs.itemNeeds
                                    .singleWhere(
                                        (need) => need.item.key == e.item.key,
                                        orElse: () => null)
                                    ?.quantity ??
                                0);
                        const imageSize = 42.0;

                        return OneClickTooltip(
                          message: item.value,
                          child: QuestCompleteAchievementWidget(
                            image: ItemImage(
                              item: item,
                              height: imageSize,
                              width: imageSize,
                            ),
                            mustHave: mustHave,
                            gathered: gathered,
                          ),
                        );
                      },
                    ),
                  SizedBox(height: 4.0),
                  if (questResponse.quest.taskCompleteRequirements.isNotEmpty)
                    QuestCompleteSubject(
                      title: 'İşlenmesi gereken suçlar',
                      itemCount:
                          questResponse.quest.taskCompleteRequirements.length,
                      itemBuilder: (context, index) {
                        var e =
                            questResponse.quest.taskCompleteRequirements[index];
                        var mustHave = e.times;
                        var gathered = mustHave -
                            (questResponse.needs.taskNeeds
                                    .singleWhere(
                                        (need) => need.task.key == e.task.key,
                                        orElse: () => null)
                                    ?.quantity ??
                                0);
                        const imageSize = 56.0;

                        return OneClickTooltip(
                          message: e.task.value,
                          child: QuestCompleteAchievementWidget(
                            image: Image.network(
                              Task.imageOf(e.task.key),
                              width: imageSize,
                              height: imageSize,
                            ),
                            mustHave: mustHave,
                            gathered: gathered,
                          ),
                        );
                      },
                    ),
                  SizedBox(height: 4.0),
                  if (questResponse.quest.questCompleteRequirements.isNotEmpty)
                    QuestCompleteSubject(
                      height: 80.0,
                      scrollDirection: Axis.vertical,
                      title: 'Tamamlanması gereken görevler',
                      itemCount:
                          questResponse.quest.questCompleteRequirements.length,
                      itemBuilder: (context, index) {
                        var e =
                            questResponse.quest.questCompleteRequirements[0];

                        bool done = questResponse.needs.questNeeds.singleWhere(
                                (qn) => qn.key == e.key,
                                orElse: () => null) ==
                            null;

                        var icon = done
                            ? Icon(Icons.done, color: Colors.green)
                            : Icon(Icons.timelapse, color: Colors.yellow);

                        return Row(
                          children: [
                            Icon(Icons.arrow_right),
                            Text(e.value),
                            SizedBox(width: 8.0),
                            icon,
                          ],
                        );
                      },
                    ),
                  SizedBox(height: 4.0),
                  if (questResponse.quest.itemRewards.isNotEmpty)
                    QuestCompleteSubject(
                      title: 'Ödüller',
                      itemCount: questResponse.quest.itemRewards.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= questResponse.quest.itemRewards.length) {
                          return Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 56.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Text(
                                      "EXP",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6
                                          .copyWith(
                                              color: Colors.lightGreenAccent),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    NumberFormat.compact().format(questResponse
                                        .quest.experienceReward.experience),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        var e = questResponse.quest.itemRewards[index];
                        var item = e.item;
                        var quantity = e.quantity;
                        const imageSize = 42.0;

                        return OneClickTooltip(
                          message: item.value,
                          child: Column(
                            children: [
                              ItemImage(
                                item: item,
                                height: imageSize,
                                width: imageSize,
                              ),
                              SizedBox(height: 4.0),
                              Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    quantity.toString(),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: questResponse.canComplete ? this.onPerform : null,
            child: Text("Bitir"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
            ),
          ),
        ),
      ],
    );
  }
}

class QuestPercentage extends StatelessWidget {
  const QuestPercentage({
    Key key,
    @required this.percentage,
  }) : super(key: key);

  final double percentage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          children: [
            Container(
              width: constraints.maxWidth * percentage,
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight:
                      percentage >= .99 ? Radius.circular(8.0) : Radius.zero,
                ),
              ),
              // child: Center(child: Text("%$percentage")),
            ),
          ],
        );
      },
    );
  }
}

class QuestCompleteAchievementWidget extends StatelessWidget {
  const QuestCompleteAchievementWidget({
    Key key,
    this.image,
    this.gathered,
    this.mustHave,
  }) : super(key: key);

  final Widget image;
  final int gathered;
  final int mustHave;

  @override
  Widget build(BuildContext context) {
    var completed = gathered >= mustHave;
    const coverSize = 56.0;

    var content = Column(
      children: [
        image,
        SizedBox(height: 4.0),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$gathered/$mustHave',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: completed ? Colors.green : Colors.white),
            ),
          ),
        )
      ],
    );

    if (!completed) {
      return content;
    }

    var icon = Icon(Icons.done, size: coverSize, color: Colors.green);
    var cover = Container(
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(.3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      width: coverSize,
      height: coverSize,
      padding: EdgeInsets.zero,
    );

    return Stack(
      alignment: Alignment.topCenter,
      children: [content, icon, cover],
    );
  }
}

class QuestCompleteSubject extends StatelessWidget {
  const QuestCompleteSubject({
    Key key,
    @required this.title,
    @required this.itemCount,
    @required this.itemBuilder,
    this.scrollDirection = Axis.horizontal,
    this.height = 106.0,
  }) : super(key: key);

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Axis scrollDirection;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyText1),
            SizedBox(height: 8.0),
            Container(
              height: (height),
              child: ListView.separated(
                scrollDirection: scrollDirection,
                separatorBuilder: (_, __) => SizedBox(width: 4.0),
                itemCount: itemCount,
                itemBuilder: itemBuilder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
