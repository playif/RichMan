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
  int totalEarn = 0;
  int totalAction = 0;
  int totalHurry = 0;
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
  When hurry;

  num singleIncome() {
    return income();
  }

  num totalIncome() {
    return singleIncome() * count;
  }


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
  int maxLevel = 10;
  Func cost;
  If canBuy;
  If show;
  When buy;
}

class Work {
  String name;
  List<String> desc = [];

  Func income;

  If show;

  When work;

  int totalEarn = 0;
  int totalAction = 0;
}


main() {
  applicationFactory()
  .addModule(new AnimationModule())
  .addModule(new Module()
    ..bind(RichMan))
  .run();
}

//TODO tag system

@Controller(
    selector: '[rich-man]',
    publishAs: 'ctrl')
class RichMan {
  Set<String> unlocks = new Set();

  RichMan() {
    Work pick = setupWork("撿破爛", [], 0,
    income:() {
      return 10 + totalCount * 2;
    });

    Work biss = setupWork("做生意", [], 8000,
    income:() {
      return 30 + (0.4 * totalWork).floor();
    });

    Work bigBiss = setupWork("做貿易", [], 200000,
    income:() {
      return (100 + 0.05 * pow(totalWork * totalCount, 0.85)).floor();
    });

    Work hugeBiss = setupWork("國際貿易", [], 5000000,
    income:() {
      return (400 + 0.03 * pow(totalWork * totalCount * totalUpgrade, 0.8)).floor();
    });

    Work unviseBiss = setupWork("宇宙貿易", [], 12000000,
    income:() {
      return (800 + 0.001 * pow(totalWork * totalCount * totalUpgrade, 0.8) * pow(totalEarn, 0.2)).floor();
    });

    Work dimBiss = setupWork("次元貿易", [], 312000000,
    income:() {
      return (1600 + 0.0001 * pow(totalWork * totalCount * totalUpgrade, 0.8) * pow(totalEarn, 0.2) * pow(totalAction, 0.3)).floor();
    });


    Attribute dog = new Attribute();
    var claw = setupUpgrade(dog, "利爪", ["收入增加10"], 100000, 2);
    var nose = setupUpgrade(dog, "嗅覺", ["收入增加30%"], 1000000, 2);

    Attribute human = new Attribute();
    var power = setupUpgrade(human, "體能鍛鍊", ["收入增加30"], 200000, 2);
    var group = setupUpgrade(human, "乞丐幫", ["費用/2"], 2000000, 2);
    var home = setupUpgrade(human, "家庭計畫", ["每個女姓員工減少的等待效果加30%"], 6000000, 5, maxLevel:5);


    Attribute trainer = new Attribute();
    var superTrain = setupUpgrade(trainer, "超效訓練", ["訓練練狗的效果增加20%"], 500000, 2);
    var selfTrain = setupUpgrade(trainer, "自我修練", ["每個訓練師增加自身5收入", "你的訓練師收入增加5%"], 2200000, 4);
    var humanTrain = setupUpgrade(trainer, "人體實驗", ["每個訓練師增加流浪漢10收入", "你的流浪漢收入增加10%"], 7000000, 2);
    var girlTrain = setupUpgrade(trainer, "女孩教育", ["每個訓練師增加女孩100收入", "你的女孩收入增加20%"], 90000000, 3);


    Attribute girl = new Attribute();
    var please = setupUpgrade(girl, "禮儀訓練", ["你每次工作都會增加小女孩0.1的收入"], 1100000, 2);
    var lovely = setupUpgrade(girl, "人見人愛", ["你每個成員都會增加小女孩1的收入"], 15000000, 2);
    var expert = setupUpgrade(girl, "專業訓練", ["你每個升級都會增加小女孩10的收入"], 180000000, 3);


    Attribute smallVandor = new Attribute();
    Attribute smallBiss = new Attribute();
    Attribute midBiss = new Attribute();
    Attribute LargeBiss = new Attribute();


    setupAttr(dog, 100, 1.1, 10)
      ..name = "野狗"
      ..desc = ["他會用敏銳的鼻子幫你找點錢回來"]
      ..income = () {
      return (1 + claw.level * 10 + 0.5 * trainer.count * pow(1.2, superTrain.level)) * pow(1.3, nose.level) ;
    };

    setupAttr(human, 1000, 1.12, 11)
      ..name = "流浪漢"
      ..desc = ["顧些流浪漢幫你找些錢回來", "你的女性員工會減少等待"]
      ..income = () {
      return (10 + humanTrain.level * trainer.count + power.level * 30) * pow(1.1, humanTrain.level);
    }
      ..delay = () {
      var girls = girl.count;
      return 11 * (50) / (50 + girls * pow(1.3, home.level));
    };
    human.cost = () {
      return (1000 * pow(1.15, human.count) / pow(2, group.level)).floor();
    };


    setupAttr(trainer, 5000, 1.14, 12)
      ..name = "訓練師"
      ..desc = ["賺點小錢", "增加野狗的收入"]
      ..income = () {
      return (100 + 5 * selfTrain.level * trainer.count) * pow(1.05, selfTrain.level);
    };

    setupAttr(girl, 15000, 1.18, 20)
      ..name = "女孩"
      ..desc = ["賣點口香糖賺錢吧"]
      ..income = () {
      return (500
      + 100 * trainer.count * girlTrain.level
      + 0.1 * totalWork * please.level
      + totalCount * lovely.level
      + 10 * totalUpgrade * expert.level) * pow(1.2, humanTrain.level);
    };

    setupAttr(smallVandor, 55000, 1.25, 40)
      ..name = "小攤販"
      ..desc = ["獲得不少收入", "越多員工收入越多"]
      ..income = () {
      return 8000 + pow(girl.count, 1.5) + pow(human.count, 1.5);
    };

    setupAttr(smallBiss, 850000, 1.31, 80)
      ..name = "小店鋪"
      ..desc = ["獲得更多收入", "每個小攤販都會增加店鋪收入"]
      ..income = () {
      return 120000 + pow(smallVandor.count * 100, 1.5);
    };

    setupAttr(midBiss, 7200000, 1.38, 160)
      ..name = "中型店鋪"
      ..desc = ["比小店舖獲得更多收入", "每個小攤販和小店舖都會增加收入"]
      ..income = () {
      return 920000 + pow(smallBiss.count * 300, 1.5) + pow(smallVandor.count * 200, 1.5);
    };

    setupAttr(LargeBiss, 52200000, 1.47, 320)
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

    attr.hurry = () {
      attr.cd += 1;
      attr.totalHurry += 1;
      totalHurry += 1;
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
    } else {
      up.canBuy = canBuy;
    }

    if (show == null) {
      up.show = () {
        return totalEarn >= up.cost() && up.maxLevel > up.level;
      };
    } else {
      up.show = show;
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

  Work setupWork(String name, List<String> desc, int baseShow, {income, show, work}) {
    Work w = new Work();
    w.name = name;
    w.desc = desc;

    if (income == null) {
      w.income = () {

      };
    } else {
      w.income = income;
    }

    if (show == null) {
      w.show = () {
        return totalEarn >= baseShow;
      };
    } else {
      w.show = show;
    }

    if (work == null) {
      w.work = () {
        money += w.income();
        totalEarn += w.income();
        w.totalEarn += w.income();
        totalWork += 1;
        w.totalAction += 1;
      };
    } else {
      w.work = work;
    }

    works.add(w);
    return w;
  }

  List<Attribute> attributes = [];

  List<Work> works = [];

  _update(Timer timer) {
    for (var attr in attributes) {
      if (!attr.has())continue;
      attr.cd += delay;
      if (attr.cd >= attr.delay()) {
        attr.cd = 0;
        var income = (attr.income() * attr.count);
        money += income;
        attr.totalEarn += income;
        attr.totalAction += attr.count;
        totalEarn += income;
        totalAction += attr.count;
        attr.action();
      }
    }
    //money += income;
  }

//  int income = 0;

  int money = 0;
  int totalEarn = 0;
  int totalCount = 0;
  int totalAction = 0;
  int totalUpgrade = 0;
  int totalWork = 0;
  int totalHurry = 0;

//  bool canBuyDog = false;

//  void work() {
//    money += workIncome + totalCount;
//    totalEarn += workIncome;
//  }

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
