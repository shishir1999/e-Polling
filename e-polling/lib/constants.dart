import 'package:flutter/material.dart';

const appVersion = 1.0;
const isInDevelopment = true;

const Color primaryBGColor = Color(0xffE6EAFF);

const Color primaryColor = Color(0xff008080);
final _inputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.circular(
    10,
  ),
  borderSide: BorderSide(
    color: Colors.grey,
  ),
);

InputDecoration kInputDecoration = InputDecoration(
  enabledBorder: _inputBorder,
  focusedBorder: _inputBorder,
  errorBorder: _inputBorder,
  border: _inputBorder,
);

//Primary Colors
double radius = 150;
Color black = const Color(0xFF1A1A1A);
Color white = const Color(0xFFFFFFFF);

//Secondary Color
Color orange = const Color(0xFFFBC22B);
Color grey1 = const Color(0xFF8E8E93);
Color grey2 = const Color(0xFFAEAEB2);
Color grey3 = const Color(0xFFC7C7CC);
Color grey4 = const Color(0xFFD1D1D6);
Color grey5 = const Color(0xFFE5E5EA);
Color grey6 = const Color(0xFFF2F2F7);

//Font Style
//Font family - manrope

const largeTitle01 = TextStyle(fontSize: 34, fontWeight: FontWeight.bold);
const largeTitle02 = TextStyle(fontSize: 41, fontWeight: FontWeight.bold);

const title101 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
const title102 = TextStyle(fontSize: 34, fontWeight: FontWeight.bold);

const title201 = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
const title202 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);

const title301 = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
const title302 = TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

const headline01 = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
const headline02 = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

const body01 = TextStyle(fontSize: 14);
const body02 = TextStyle(fontSize: 16);

const subhead01 = TextStyle(fontSize: 16);
const subhead02 = TextStyle(fontSize: 17);

const footnote01 = TextStyle(fontSize: 12);
const footnote02 = TextStyle(fontSize: 14);
const footnote001 = TextStyle(fontSize: 10);

//space

double xxs = 4;
double xs = 8;
double s = 12;
double m = 16;
double l = 24.0;
double xl = 32;
double xxl = 48;
double xxxL = 60;
