/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/widgets.dart';
import 'package:tiki_style/tiki_style.dart';

class ScreenViewWidgetState extends StatelessWidget {
  static const String _title = "Your data";

  final Image image;
  final String summary;
  final String description;
  final Color color;

  ScreenViewWidgetState(
      {Key? key,
      required this.image,
      required this.summary,
      required this.description,
      this.color = ColorProvider.blue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _title,
          style: TextStyle(
              fontFamily: TextProvider.familyKoara,
              fontWeight: FontWeight.bold,
              fontSize: SizeProvider.instance.text(22),
              color: ColorProvider.tikiBlue),
        ),
        Container(
            margin: EdgeInsets.only(top: SizeProvider.instance.height(1)),
            child: Image(
              image: image.image,
              height: SizeProvider.instance.height(17),
              fit: BoxFit.fitHeight,
            )),
        Container(
            margin: EdgeInsets.only(top: SizeProvider.instance.height(1)),
            child: Text(
              summary,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: TextProvider.familyKoara,
                  fontWeight: FontWeight.bold,
                  fontSize: SizeProvider.instance.text(16),
                  color: color),
            )),
        Container(
            margin: EdgeInsets.only(top: SizeProvider.instance.height(0.75)),
            child: Text(description,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: TextProvider.familyNunitoSans,
                    fontWeight: FontWeight.w600,
                    color: ColorProvider.tikiBlue,
                    fontSize: SizeProvider.instance.text(11)))),
      ],
    );
  }
}
