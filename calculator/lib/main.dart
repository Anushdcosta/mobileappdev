import 'package:chat_app/notsusatall.dart';
import 'package:chat_app/secretapp.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:expressions/expressions.dart';
import 'package:flutter/services.dart'; // Import this for handling key events

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = "";
  String _lastResult = "";
  String _ansvalue = "";
  String _previousExpression = "";

  FocusNode _focusNode = FocusNode();
  Map<String, bool> _buttonPressed = {}; // Track the pressed state of buttons

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  void _append(String text) {
    setState(() {
      _expression = _expression.replaceAll("x!", "");
      if (_expression == "Error") {
        _expression = text;
      } else if (_lastResult.isNotEmpty && _isNumeric(text)) {
        _expression = text;
      } else {
        if (_lastResult.isNotEmpty && !_isNumeric(text)) {
          _expression = "Ans$text";
        } else {
          if (text == 'x!') {
            _expression += 'factorial(';
          }
          if (text == "√") {
            _expression += "sqrt(";
          } else if (text == 'Inv') {
            _expression += '1/';
          } else if (['Sin', 'Cos', 'Tan', 'Log', 'Ln'].contains(text)) {
            _expression += '${text.toLowerCase()}(';
          } else {
            _expression += text;
          }
        }
      }

      _lastResult = "";
    });
  }

  bool _isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  void _calculate() {
    if (_expression.contains("😎")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Hey()),
      );
      return;
    }
    _expression = _expression.replaceAll('π', pi.toString());
    _expression = _expression.replaceAll('e', e.toString());
    _expression = _expression.replaceAll('Ans', _ansvalue);
    if (_expression == "1111") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => secretapp()),
      );
      return;
    }
    if (_expression == _ansvalue) {
      _expression = _previousExpression;
    }
    try {
      final result = _evaluateExpression(_expression);
      setState(() {
        _previousExpression = _expression;
        _expression = result.toString();
        _lastResult = result.toString();
        _ansvalue = _lastResult;
      });
    } catch (e) {
      setState(() {
        _expression = "Error";
        _lastResult = "";
      });
    }
  }

  void _clear() {
    setState(() {
      _expression = "";
      _lastResult = "";
      _previousExpression = "";
    });
  }

  void _backspace() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      } else {
        _showWarningDialog(context,
            "There is nothing to delete. Please type something first.");
      }
    });
  }

  void _showWarningDialog(BuildContext context, String warning) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(warning),
        );
      },
    );
  }

  double _evaluateExpression(String expression) {
    expression = expression.replaceAllMapped(
      RegExp(r'(\d+)\^(\d+)'),
      (match) {
        final base = match.group(1);
        final exponent = match.group(2);
        return 'pow($base, $exponent)';
      },
    );

    final factorialPattern = RegExp(r'factorial\((\d+)\)');
    expression = expression.replaceAllMapped(factorialPattern, (match) {
      final num = int.parse(match.group(1)!);
      return _factorial(num).toString();
    });

    const evaluator = ExpressionEvaluator();
    final context = {
      'sin': (num x) => sin(x * pi / 180),
      'cos': (num x) => cos(x * pi / 180),
      'tan': (num x) => tan(x * pi / 180),
      'log': (num x) => log(x),
      'ln': (num x) => log(x),
      'sqrt': (num x) => sqrt(x),
      'pow': (num x, num y) => pow(x, y),
    };

    try {
      final parsedExpression = Expression.parse(expression);
      return evaluator.eval(parsedExpression, context);
    } catch (e) {
      throw Exception('Invalid expression');
    }
  }

  int _factorial(int n) {
    if (n <= 1) return 1;
    return n * _factorial(n - 1);
  }

  void _handleKeyPress(String key) {
    setState(() {
      _buttonPressed[key] = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _buttonPressed[key] = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          String key = event.logicalKey.keyLabel;
          if (key.isNotEmpty &&
              key.length == 1 &&
              RegExp(r'\d').hasMatch(key)) {
            _append(key);
            _handleKeyPress(key); // Handle key press
            return KeyEventResult.handled;
          } else if (key == '+' ||
              key == '-' ||
              key == '*' ||
              key == '/' ||
              key == '^') {
            _append(key);
            _handleKeyPress(key); // Handle key press
            return KeyEventResult.handled;
          } else if (key.toLowerCase() == "c") {
            _clear();
            _handleKeyPress(key); // Handle key press
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
            _backspace();
            _handleKeyPress('bksp'); // Handle key press for backspace
            return KeyEventResult.handled;
          } else if (key.toLowerCase() == "s") {
            _append("sin(");
            _handleKeyPress('Sin'); // Handle key press for sin
          } else if (key.toLowerCase() == "t") {
            _append("tan(");
            _handleKeyPress('Tan'); // Handle key press for tan
          } else if (event.logicalKey == LogicalKeyboardKey.enter) {
            _calculate();
            _handleKeyPress('='); // Handle key press for enter
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _previousExpression,
                    style: const TextStyle(fontSize: 24.0, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _expression,
                    style: const TextStyle(
                        fontSize: 48.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _buildButton('('),
                        _buildButton(')'),
                        _buildButton('x!'),
                        _buildButton('%'),
                        _buildButton('😎'),
                        _buildButton('bksp', isSpecial: true),
                        _buildButton('C', isSpecial: true),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('Inv'),
                        _buildButton('Sin'),
                        _buildButton('Ln'),
                        _buildButton('7', isnum: true),
                        _buildButton('8', isnum: true),
                        _buildButton('9', isnum: true),
                        _buildButton('/', subtext: "÷"),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('π'),
                        _buildButton('Cos'),
                        _buildButton('Log'),
                        _buildButton('4', isnum: true),
                        _buildButton('5', isnum: true),
                        _buildButton('6', isnum: true),
                        _buildButton('*', subtext: "x"),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('e'),
                        _buildButton('Tan'),
                        _buildButton('√'),
                        _buildButton('1', isnum: true),
                        _buildButton('2', isnum: true),
                        _buildButton('3', isnum: true),
                        _buildButton('-'),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('Ans'),
                        _buildButton('^', subtext: "xʸ"),
                        _buildButton(''),
                        _buildButton('0', isnum: true),
                        _buildButton('.'),
                        _buildButton('+'),
                        _buildButton('=', isSpecial: true),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text,
      {bool isSpecial = false, bool isnum = false, String subtext = ""}) {
    bool isKeyPressed = _buttonPressed[text] ?? false;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _buttonPressed[text] = true; // Set pressed state
          });
        },
        onTapUp: (_) {
          setState(() {
            _buttonPressed[text] = false; // Reset pressed state
          });
        },
        onTapCancel: () {
          setState(() {
            _buttonPressed[text] =
                false; // Reset pressed state if tap is canceled
          });
        },
        onTap: () {
          if (text == 'bksp') {
            _backspace();
          } else if (text == 'C') {
            _clear();
          } else if (text == '=') {
            _calculate();
          } else {
            _append(text);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.all(4.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isKeyPressed
                ? (isSpecial
                    ? Colors.red.shade700 // Darker red for special buttons
                    : isnum
                        ? Colors.grey.shade600 // Darker grey for numbers
                        : Colors.grey.shade800) // Darker grey for operators
                : (isSpecial
                    ? Colors.red // Regular red for special buttons
                    : isnum
                        ? Colors.grey.shade400 // Regular grey for numbers
                        : Colors.grey.shade700), // Regular grey for operators
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Center(
            child: Text(
              (subtext == "") ? text : subtext,
              style: const TextStyle(
                fontSize: 37.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
