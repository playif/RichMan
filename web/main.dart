import 'package:angular/angular.dart';
import 'package:angular/animate/module.dart';
import 'package:angular/application_factory.dart';

import 'dart:async';
import 'dart:math';

const Duration dt = const Duration(milliseconds:100);
const int delay = 1;

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
  Set canBuys = new Set();

  RichMan() {


    var dog = new Attribute();
    setupAttr(dog, 10, 1.1, 10)
      ..name = "野狗"
      ..desc = "每隻野狗可以幫你找點錢回來。"
      ..income = () {
      return 1;
    };


    var human = new Attribute();
    setupAttr(human, 100, 1.15, 11)
      ..name = "流浪漢"
      ..desc = "每位流浪漢可以幫你找些錢回來。"
      ..income = () {
      return 10;
    };


    Timer timer = new Timer.periodic(dt, _update);

  }


  bool canBuyForever(Attribute attr, [int lastMoney]) {
    if (lastMoney == null) {
      lastMoney = attr.cost();
    }
    if (canBuys.contains(attr) || money >= lastMoney) {
      canBuys.add(attr);
      return true;
    }
  }

  Attribute setupAttr(Attribute attr, int baseCost, num exp, int delay) {
    attr
      ..delay = () {
      return delay;
    }
      ..cost = () {
      return (baseCost * pow(exp, attr.count)).floor();
    }
      ..canBuy = () {
      return canBuyForever(attr);
    };
    attributes.add(attr);
    return attr;
  }

  List<Attribute> attributes = [];

  _update(Timer timer) {
    for (var attr in attributes) {
      attr.cd += delay;
      if (attr.cd >= attr.delay()) {
        attr.cd = 0;
        var income = attr.income() * attr.count;
        money += income;
        attr.totalEarn += income;
      }
    }
    //money += income;
  }

  int income = 0;

  int workIncome = 1;
  int money = 110;

  bool canBuyDog = false;

  void work() {
    money += workIncome;
    if (money > 10) {
      canBuyDog = true;
    }
  }

  int dogCount = 0;
  int dogIncome = 0;
  int dogDelay = 0;

  void buyDog() {

  }

  void buy(Attribute attr) {
    if (money >= attr.cost()) {
      money -= attr.cost();
      attr.count += 1;
    }
  }

  bool canBuy(Attribute attr) {
    if (money >= attr.cost()) {
      return true;
    }
    return false;
  }

}

typedef int Func();

typedef bool If();

class Attribute {
  String name;
  String desc;
  int count = 0;
  int cd = 0;
  Func cost;
  Func income;
  Func delay;
  If canBuy;

  num singleIncome() {
    return (10 * income() / delay()).floor();
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