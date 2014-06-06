import 'package:angular/angular.dart';
import 'package:angular/animate/module.dart';
import 'package:angular/application_factory.dart';

import 'dart:async';
import 'dart:math';

const Duration dt = const Duration(milliseconds:100);
const int delay = 1;


typedef int Func();

typedef bool If();

typedef void When();

class Attribute {
  String name;
  List<String> desc;
  int count = 0;
  int cd = 0;
  Func cost;
  Func income;
  Func delay;
  If canBuy;
  If unlock;
  If show;
  When action;
  When buy;
  When firstBuy;
  When everyBuy;

  num singleIncome() {
    return ( income()).floor();
  }

  num totalIncome() {
    return singleIncome() * count;
  }

  int totalEarn = 0;

  String get ratio {
    num rate = 100 * cd / delay();
    return "$rate%";
  }

  bool has() {
    return count >= 1;
  }


}

main() {
  applicationFactory()
  .addModule(new AnimationModule())
  .addModule(new Module()
    ..bind(RichMan))
  .run();
}

@Controller(
    selector: '[rich-man]',
    publishAs: 'ctrl')
class RichMan {
  Set<String> unlocks = new Set();

  RichMan() {


    Attribute dog = new Attribute();
    Attribute human = new Attribute();
    Attribute trainer = new Attribute();
    Attribute girl = new Attribute();
    Attribute smallVandor = new Attribute();
    Attribute smallBiss = new Attribute();

    setupAttr(dog, 10, 1.1, 10)
      ..name = "野狗"
      ..desc = ["找點錢回來。"]
      ..income = () {
      return 1 + 0.5 * trainer.count;
    };


    setupAttr(human, 100, 1.15, 11)
      ..name = "流浪漢"
      ..desc = ["找些錢回來。"]
      ..income = () {
      return 10;
    }
      ..delay = () {
      var girls = girl.count;
      return 11 * (50) / (50 + girls);
    };


    setupAttr(trainer, 500, 1.2, 12)
      ..name = "訓狗師"
      ..desc = ["增加野狗的收入。"]
      ..income = () {
      return 100;
    };

    setupAttr(girl, 1500, 1.25, 20)
      ..name = "女孩"
      ..desc = ["減少流浪漢的等待時間。"]
      ..income = () {
      return 500;
    };

    setupAttr(smallVandor, 5500, 1.3, 40)
      ..name = "小攤販"
      ..desc = ["獲得不少收入。"]
      ..income = () {
      return 8000 + pow(girl.count, 1.5);
    };

    setupAttr(smallBiss, 85000, 1.4, 80)
      ..name = "小店鋪"
      ..desc = ["獲得更多收入。"]
      ..income = () {
      return 120000 + smallBiss.count * pow(smallVandor.count, 1.5);
    };


    Timer timer = new Timer.periodic(dt, _update);

  }


  bool canBuyForever(Attribute attr, [int lastMoney]) {
    if (lastMoney == null) {
      lastMoney = attr.cost();
    }
    if (unlocks.contains(attr) || money >= lastMoney) {
      unlocks.add(attr.name);
      return true;
    }
  }

  Attribute setupAttr(Attribute attr, int baseCost, num exp, int delay) {
    attr.delay = () {
      return delay;
    };

    attr.cost = () {
      return (baseCost * pow(exp, attr.count)).floor();
    };

    attr.canBuy = () {
      //return canBuyForever(attr);
      if (money >= attr.cost()) {
        return true;
      }
      return false;
    };

    attr.show = () {
      return totalEarn >= attr.cost();
    };

    attr.unlock = () {
      return unlocks.contains(attr.name);
    };

    attr.action = () {
    };

    attr.firstBuy = () {

    };

    attr.everyBuy = () {

    };

    attr.buy = () {
      if (money >= attr.cost()) {
        money -= attr.cost();
        attr.count += 1;
        attr.everyBuy();
        if (!unlocks.contains(attr.name)) {
          unlocks.add(attr.name);
          attr.firstBuy();
          return true;
        }
      }
    };

    attributes.add(attr);
    return attr;
  }

  List<Attribute> attributes = [];

  _update(Timer timer) {
    for (var attr in attributes) {
      if (!attr.has())continue;
      attr.cd += delay;
      if (attr.cd >= attr.delay()) {
        attr.cd = 0;
        var income = (attr.income() * attr.count);
        money += income;
        attr.totalEarn += income;
        totalEarn += income;
        attr.action();
      }
    }
    //money += income;
  }

//  int income = 0;

  int workIncome = 1;
  int money = 0;
  int totalEarn = 0;

//  bool canBuyDog = false;

  void work() {
    money += workIncome;
    totalEarn += workIncome;
  }

//  int dogCount = 0;
//  int dogIncome = 0;
//  int dogDelay = 0;
//
//  void buyDog() {
//
//  }

//  void buy(Attribute attr) {
//    if (money >= attr.cost()) {
//      money -= attr.cost();
//      attr.count += 1;
//    }
//  }
//
//  bool canBuy(Attribute attr) {
//    if (money >= attr.cost()) {
//      return true;
//    }
//    return false;
//  }

}
