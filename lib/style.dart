import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const LargeTextSize = 36.0;
const MediumTextSize = 20.0;
const BodyTextSize = 16.0;

const String FontNameDefault = 'Montserrat' ;

const AppBarTextStyle = TextStyle(
  fontFamily: 'sans-serif',
  fontWeight: FontWeight.bold,
  wordSpacing: 0,
  letterSpacing: 0.1,
  fontSize: 16,
  color: Colors.white ,
);

const TitleTextStyle = TextStyle(
  fontWeight: FontWeight.w900,
  fontSize: LargeTextSize,
  color: Color(0xFFFEFCEE) ,
);

const Body1TextStyle = TextStyle(
  fontFamily: FontNameDefault,
  fontWeight: FontWeight.bold,
  fontSize: 14,
  color: Color(0x0FFBB8888) ,
);
const Body2TextStyle = TextStyle(
  fontFamily: FontNameDefault,
  fontWeight: FontWeight.w300,
  fontSize: BodyTextSize,
  color: Color(0xFFF46655) ,
);
const SubtitleStyle = TextStyle(
  fontFamily: FontNameDefault,
  fontWeight: FontWeight.w600,
  fontSize: 11.0,
  color: Color(0x0FF224466) ,
);
const SubheadStyle = TextStyle(
  fontFamily: FontNameDefault,
  fontSize: 15,
  height: 1.1,
  color: Color(0xFF000000),
);
const CaptionStyle = TextStyle(
  fontFamily: FontNameDefault,
  fontWeight: FontWeight.w300,
  fontSize: 9.0,
  color: Color(0xFF553355) ,
);
const OverLineStyle = TextStyle(
  fontFamily: 'serif',
  letterSpacing: 0.0,
  wordSpacing: 0.0,
  fontWeight: FontWeight.w600,
  fontSize: 11.0,
  color: Color(0xffffddcd) ,
);