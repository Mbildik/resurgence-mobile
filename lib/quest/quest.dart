import 'package:flutter/foundation.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/task/model.dart';

class QuestResponse {
  QuestResponse({
    @required this.id,
    @required this.quest,
    @required this.status,
    @required this.name,
    @required this.description,
    @required this.isUnlocked,
    @required this.canComplete,
    @required this.needs,
    @required this.percentage,
  });

  final int id;
  final Quest quest;
  final AbstractEnum status;
  final String name;
  final String description;
  final bool isUnlocked;
  final bool canComplete;
  final Needs needs;
  final double percentage;

  factory QuestResponse.fromJson(Map<String, dynamic> json) => QuestResponse(
        id: json["id"],
        quest: Quest.fromJson(json["quest"]),
        status: AbstractEnum.fromJson(json["status"]),
        name: json["name"],
        description: json["description"],
        isUnlocked: json["is_unlocked"],
        canComplete: json["can_complete"],
        needs: Needs.fromJson(json["needs"]),
        percentage: json["percentage"] ?? 0,
      );
}

class Quest {
  Quest({
    @required this.consumeItemCompleteRequirements,
    @required this.taskCompleteRequirements,
    @required this.questCompleteRequirements,
    @required this.experienceReward,
    @required this.itemRewards,
  });

  final List<ConsumeItemCompleteRequirement> consumeItemCompleteRequirements;
  final List<TaskCompleteRequirement> taskCompleteRequirements;
  final List<AbstractEnum> questCompleteRequirements;
  final ExperienceReward experienceReward;
  final List<ConsumeItemCompleteRequirement> itemRewards;

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
        consumeItemCompleteRequirements:
            List<ConsumeItemCompleteRequirement>.from(
                json["consume_item_complete_requirements"]
                    .map((x) => ConsumeItemCompleteRequirement.fromJson(x))),
        taskCompleteRequirements: List<TaskCompleteRequirement>.from(
            json["task_complete_requirements"]
                .map((x) => TaskCompleteRequirement.fromJson(x))),
        questCompleteRequirements: List<AbstractEnum>.from(
            json["quest_complete_requirements"]
                .map((x) => AbstractEnum.fromJson(x))),
        experienceReward: ExperienceReward.fromJson(json["experience_reward"]),
        itemRewards: List<ConsumeItemCompleteRequirement>.from(
            json["item_rewards"]
                .map((x) => ConsumeItemCompleteRequirement.fromJson(x))),
      );
}

class ConsumeItemCompleteRequirement {
  ConsumeItemCompleteRequirement({
    @required this.item,
    @required this.quantity,
  });

  final Item item;
  final int quantity;

  factory ConsumeItemCompleteRequirement.fromJson(Map<String, dynamic> json) =>
      ConsumeItemCompleteRequirement(
        item: Item.fromJson(json["item"]),
        quantity: json["quantity"],
      );
}

class TaskCompleteRequirement {
  TaskCompleteRequirement({
    @required this.task,
    @required this.times,
  });

  final AbstractEnum task;
  final int times;

  factory TaskCompleteRequirement.fromJson(Map<String, dynamic> json) =>
      TaskCompleteRequirement(
        task: AbstractEnum.fromJson(json["task"]),
        times: json["times"],
      );
}

class ExperienceReward {
  ExperienceReward({
    @required this.experience,
  });

  final int experience;

  factory ExperienceReward.fromJson(Map<String, dynamic> json) =>
      ExperienceReward(
        experience: json["experience"],
      );
}

class Needs {
  Needs({
    @required this.itemNeeds,
    @required this.taskNeeds,
    @required this.questNeeds,
  });

  final List<ItemNeed> itemNeeds;
  final List<TaskNeed> taskNeeds;
  final List<AbstractEnum> questNeeds;

  factory Needs.fromJson(Map<String, dynamic> json) => Needs(
        itemNeeds: List<ItemNeed>.from(
            json["item_needs"].map((x) => ItemNeed.fromJson(x))),
        taskNeeds: List<TaskNeed>.from(
            json["task_needs"].map((x) => TaskNeed.fromJson(x))),
        questNeeds: List<AbstractEnum>.from(
            json["quest_needs"].map((x) => AbstractEnum.fromJson(x))),
      );
}

class ItemNeed {
  ItemNeed({
    @required this.item,
    @required this.quantity,
  });

  final Item item;
  final int quantity;

  factory ItemNeed.fromJson(Map<String, dynamic> json) => ItemNeed(
        item: Item.fromJson(json["item"]),
        quantity: json["quantity"],
      );
}

class TaskNeed {
  TaskNeed({
    @required this.task,
    @required this.quantity,
  });

  final Task task;
  final int quantity;

  factory TaskNeed.fromJson(Map<String, dynamic> json) => TaskNeed(
        task: Task.fromJson(json["task"]),
        quantity: json["quantity"],
      );
}
