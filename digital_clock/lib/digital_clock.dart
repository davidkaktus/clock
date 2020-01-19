// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flare_flutter/flare_actor.dart';

/// A basic digital clock.
///
/// Nobody can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  String previousTimeString;
  String currentTimeString;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      final hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
      final minute = DateFormat('mm').format(_dateTime);
      currentTimeString = "$hour$minute";
      // Update once per minute.
      _timer = Timer(
        Duration(minutes: 1) - Duration(seconds: _dateTime.second) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).size.width / 3.5;
    final digitWidth = (MediaQuery.of(context).size.width / 6).floorToDouble();
    final digitHeight = (MediaQuery.of(context).size.height / 3).floorToDouble();

    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _createDigits(
          digitWidth: digitWidth,
          digitHeight: digitHeight,
          fontSize: fontSize,
          animationNames: _animationNamesFrom(currentTimeString),
        ),
      ),
    );
  }

  Iterable<String> _animationNamesFrom(String currentTimeString) {
    if (previousTimeString == null) {
      previousTimeString = currentTimeString;
    }

    final animationNames = [
      "${previousTimeString[0]}_to_${currentTimeString[0]}",
      "${previousTimeString[1]}_to_${currentTimeString[1]}",
      "${previousTimeString[2]}_to_${currentTimeString[2]}",
      "${previousTimeString[3]}_to_${currentTimeString[3]}",
    ];
    previousTimeString = currentTimeString;
    return animationNames;
  }

  List<Widget> _createDigits({List<String> animationNames, double digitWidth, double digitHeight, double fontSize}) {
    return <Widget>[
      _animatedDigit(digitWidth: digitWidth, animationName: animationNames[0]),
      _animatedDigit(digitWidth: digitWidth, animationName: animationNames[1]),
      _colon(digitWidth: digitWidth),
      _animatedDigit(digitWidth: digitWidth, animationName: animationNames[2]),
      _animatedDigit(digitWidth: digitWidth, animationName: animationNames[3]),
    ];
  }

  Widget _colon({double digitWidth}) {
    assert(digitWidth != null);
    return Container(
      width: digitWidth,
      child: AspectRatio(
        aspectRatio: 7 / 20,
        child: FlareActor(
          "assets/flare/colon.flr",
          isPaused: false,
          animation: "fade_in",
        ),
      ),
    );
  }

  Widget _animatedDigit({double digitWidth, String animationName}) {
    assert(digitWidth != null);
    assert(animationName != null);
    return Container(
      width: digitWidth,
      child: AspectRatio(
        aspectRatio: 7 / 20,
        child: FlareActor(
          "assets/flare/digits.flr",
          isPaused: false,
          animation: animationName,
        ),
      ),
    );
  }
}
