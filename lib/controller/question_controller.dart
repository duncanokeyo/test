import 'dart:collection';

import 'package:bridgemetherapist/controller/QuestionnaireController.dart';
import 'package:bridgemetherapist/model/Questionnaire.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:get_storage/get_storage.dart';



// We use get package for our state management
class QuestionController extends GetxController
    with SingleGetTickerProviderMixin {
  QuestionnaireController _questionnaireController =
      Get.find<QuestionnaireController>();
  // Lets animated our progress bar
  final box = Get.find<GetStorage>();

  late AnimationController _animationController;
  late Animation _animation;
  late BuildContext context;
  // so that we can access our animation outside
  Animation get animation => this._animation;

  late PageController _pageController;
  PageController get pageController => this._pageController;

  bool _isAnswered = false;
  bool get isAnswered => this._isAnswered;

  int getQuestionsLength() {
    return _questionnaireController.results.length;
  }

  List<Questionnaire> getQuestions() {
    return _questionnaireController.results.toList();
  }

  late int _correctAns;
  int get correctAns => this._correctAns;

  late int _selectedAns;
  int get selectedAns => this._selectedAns;

  // for more about obs please check documentation
  RxInt _questionNumber = 1.obs;
  RxInt get questionNumber => this._questionNumber;

  int _numOfCorrectAns = 0;
  int get numOfCorrectAns => this._numOfCorrectAns;

  // called immediately after the widget is allocated memory
  @override
  void onInit() {
    // Our animation duration is 60 s
    // so our plan is to fill the progress bar within 60s
    _animationController =
        AnimationController(duration: Duration(seconds: 60), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        // update like setState
        update();
      });

    // start our animation
    // Once 60s is completed go to the next qn
    _animationController.forward().whenComplete(nextQuestion);
    _pageController = PageController();
    super.onInit();
  }

  // // called just before the Controller is deleted from memory
  @override
  void onClose() {
    super.onClose();
    _animationController.dispose();
    _pageController.dispose();
  }

  Map<Questionnaire, int> selectedOptions = HashMap();

  void checkAns(Questionnaire question, int selectedIndex) {
    // because once user press any option then it will run
    selectedOptions[question] = selectedIndex;

    _isAnswered = true;
    _correctAns = 1; //question.answer;
    _selectedAns = selectedIndex;

    if (_correctAns == _selectedAns) _numOfCorrectAns++;

    // It will stop the counter
    _animationController.stop();
    update();

    // Once user select an ans after 3s it will go to the next qn
    Future.delayed(Duration(seconds: 3), () {
      nextQuestion();
    });
  }

  void nextQuestion() {
    if (_questionNumber.value != _questionnaireController.results.length) {
      _isAnswered = false;
      _pageController.nextPage(
          duration: Duration(milliseconds: 250), curve: Curves.ease);

      // Reset the counter
      _animationController.reset();

      // Then start it again
      // Once timer is finish go to the next qn
      _animationController.forward().whenComplete(nextQuestion);
    } else {
      _questionnaireController.save(selectedOptions);
    
      //Get.to(ScoreScreen());
    }
  }

  void updateTheQnNum(int index) {
    _questionNumber.value = index + 1;
  }

  void setContext(BuildContext context) {
    this.context = context;
  }
}
