import 'package:angular/angular.dart';
import 'package:angular/animate/module.dart';
import 'package:angular/application_factory.dart';

import 'dart:async';

const Duration dt = const Duration(milliseconds:100);

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
  RichMan() {
    Timer timer = new Timer.periodic(dt, update);

  }

  update(Timer timer) {
    money+=1;
  }

  int money = 1;


}
