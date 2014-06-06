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
  List<Upgrade> upgrades = [];
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
    return income();
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

class Upgrade {
  String name;
  List<String> desc;
  int level = 0;
  int maxLevel = 3;
  Func cost;
  If canBuy;
  If show;
  When buy;


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
    Attribute midBiss = new Attribute();
    Attribute LargeBiss = new Attribute();

    var claw = setupUpgrade(dog, "利爪", ["野狗收入增加10"], 100000, 2);
    var nose = setupUpgrade(dog, "嗅覺", ["野狗收入*2"], 1000000, 2);
    setupAttr(dog, 100, 1.1, 10)
      ..name = "野狗"
      ..desc = ["他會用敏銳的鼻子幫你找點錢回來"]
      ..income = () {
      return (1 + claw.level * 10 + 0.5 * trainer.count) * pow(2, nose.level);
    };


    setupAttr(human, 1000, 1.15, 11)
      ..name = "流浪漢"
      ..desc = ["顧些流浪漢幫你找些錢回來", "你的女性員工會增加流浪漢的士氣"]
      ..income = () {
      return 10;
    }
      ..delay = () {
      var girls = girl.count;
      return 11 * (50) / (50 + girls);
    };


    setupAttr(trainer, 5000, 1.2, 12)
      ..name = "訓狗師"
      ..desc = ["賺點小錢", "增加野狗的收入"]
      ..income = () {
      return 100;
    };

    setupAttr(girl, 15000, 1.25, 20)
      ..name = "女孩"
      ..desc = ["賣點口香糖賺錢吧"]
      ..income = () {
      return 500;
    };

    setupAttr(smallVandor, 55000, 1.3, 40)
      ..name = "小攤販"
      ..desc = ["獲得不少收入", "越多員工收入越多"]
      ..income = () {
      return 8000 + pow(girl.count, 1.5) + pow(human.count, 1.5);
    };

    setupAttr(smallBiss, 850000, 1.4, 80)
      ..name = "小店鋪"
      ..desc = ["獲得更多收入", "每個小攤販都會增加店鋪收入"]
      ..income = () {
      return 120000 + pow(smallVandor.count * 100, 1.5);
    };

    setupAttr(midBiss, 7200000, 1.5, 160)
      ..name = "中型店鋪"
      ..desc = ["比小店舖獲得更多收入", "每個小攤販和小店舖都會增加收入"]
      ..income = () {
      return 920000 + pow(smallBiss.count * 300, 1.5) + pow(smallVandor.count * 200, 1.5);
    };

    setupAttr(LargeBiss, 52200000, 1.6, 320)
      ..name = "大型店鋪"
      ..desc = ["比中型店舖獲得更多收入", "所有店舖都會增加收入"]
      ..income = () {
      return 8820000 + pow(midBiss.count * 2500, 1.5) + pow(smallBiss.count * 1500, 1.5) + pow(smallVandor.count * 1000, 1.5);
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
      return money >= attr.cost();
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
        totalCount += 1;
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

  Upgrade setupUpgrade(Attribute attr, String name, List<String> desc, int costBase, int costExp, { canBuy, show, buy, maxLevel}) {

    Upgrade up = new Upgrade();
    attr.upgrades.add(up);

    up.name = name;
    up.desc = desc;

    if (maxLevel != null) {
      up.maxLevel = maxLevel;
    }

    up.cost = () {
      return costBase * pow(up.level + 1, costExp);
    };

    if (canBuy == null) {
      up.canBuy = () {
        return money >= up.cost() && up.maxLevel > up.level;
      };
    }

    if (show == null) {
      up.show = () {
        return totalEarn >= up.cost() && up.maxLevel > up.level;
      };
    }

    if (buy == null) {
      up.buy = () {
        if (up.canBuy()) {
          money -= up.cost();
          up.level += 1;
          totalUpgrade += 1;
        }
      };
    }

    return up;
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
        totalAction += 1;
        attr.action();
      }
    }
    //money += income;
  }

//  int income = 0;

  int workIncome = 10;
  int money = 0;
  int totalEarn = 0;
  int totalCount = 0;
  int totalAction = 0;
  int totalUpgrade = 0;

//  bool canBuyDog = false;

  void work() {
    money += workIncome + totalCount;
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
