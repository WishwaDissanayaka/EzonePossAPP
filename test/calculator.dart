import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart'; // For expression evaluation

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _input = '';
  String _result = '';
  final List<String> _history = [];

  void _onPressed(String text) {
    setState(() {
      if (text == 'C') {
        _input = '';
        _result = '';
      } else if (text == '=') {
        try {
          _result = _evaluate(_input);
          _history.add('$_input = $_result');
        } catch (e) {
          _result = 'Error';
        }
      } else if (text == '⌫') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else {
        _input += text;
      }
    });
  }

  String _evaluate(String expression) {
    try {
      Parser parser = Parser();
      Expression exp = parser.parse(expression);
      ContextModel contextModel = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, contextModel);
      return eval.toString();
    } catch (e) {
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 25, 196, 33),
                Color.fromARGB(255, 58, 80, 226),
                Color.fromARGB(255, 7, 182, 236),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              'CALCULATOR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Display history
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _history
                      .map((calculation) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              calculation,
                              style: const TextStyle(
                                  fontSize: 18, color: Color.fromARGB(255, 0, 0, 0)),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),


            // Display input and result
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _input.isEmpty ? '0' : _input,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),


            // Buttons matching the image layout
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(20),
              ),
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...['7', '8', '9', 'C'],   // Clear button in the top-right corner
                  ...['4', '5', '6', '/'],   // Division button
                  ...['1', '2', '3', '*'],   // Multiplication button
                  ...['⌫', '0', '=', '+'],   // Backspace, Equal, and Addition
                ].map((text) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: text == '='
                          ? const Color.fromARGB(255, 255, 255, 255)
                          : const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _onPressed(text),
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
