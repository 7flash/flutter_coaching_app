import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import './colors.dart';

class ContributionForm extends StatefulWidget {
  final Function onSubmit;

  const ContributionForm(this.onSubmit);

  @override
  _ContributionFormState createState() => _ContributionFormState();
}

class _ContributionFormState extends State<ContributionForm> {
  int _chosenCategory = 1;
  String _chosenTitle = 'Make 10 hour meditation';
  DateTime _chosenTimeout = DateTime.now();

  final List<Map<String, Object>> _categories = [
    {
      'reward': 5,
      'name': '5 coins',
      'dotColor': CustomColors.YellowIcon,
      'boxColor': CustomColors.YellowIcon,
      'shadowColor': CustomColors.YellowShadow,
    },
    {
      'reward': 10,
      'name': '10 coins',
      'dotColor': CustomColors.GreenIcon,
      'boxColor': CustomColors.GreenIcon,
      'shadowColor': CustomColors.GreenShadow,
    },
    {
      'reward': 25,
      'name': '25 coins',
      'dotColor': CustomColors.PurpleIcon,
      'boxColor': CustomColors.PurpleIcon,
      'shadowColor': CustomColors.PurpleShadow,
    },
    {
      'reward': 50,
      'name': '50 coins',
      'dotColor': CustomColors.BlueIcon,
      'boxColor': CustomColors.BlueIcon,
      'shadowColor': CustomColors.BlueShadow,
    }
  ];

  void _changeChosenCategory(int i) {
    setState(() {
      _chosenCategory = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 80,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: <Widget>[
          Positioned(
            top: MediaQuery.of(context).size.height / 25,
            left: 0,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(175, 30),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 340,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      child: Image.asset('assets/fab-delete.png'),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            CustomColors.TrashRed,
                            Colors.redAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(50.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: CustomColors.PurpleShadow,
                            blurRadius: 10.0,
                            spreadRadius: 5.0,
                            offset: Offset(0.0, 0.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        'Create challenge',
                        style: TextStyle(
                            fontSize: 13, fontFamily: "worksans", fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: TextFormField(
                          onChanged: (value) {
                            _chosenTitle = value;
                          },
                          initialValue: _chosenTitle,
                          autofocus: false,
                          style: TextStyle(
                              fontSize: 22, fontStyle: FontStyle.normal),
                          decoration: InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: 60,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 1.0,
                              color: CustomColors.GreyBorder,
                            ),
                            bottom: BorderSide(
                              width: 1.0,
                              color: CustomColors.GreyBorder,
                            ),
                          ),
                        ),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: _categories.length,
                          itemBuilder: (ctx, i) {
                            final category = _categories[i];
                            final categoryWidget = _chosenCategory == i
                                ? ActiveCategory(category: category)
                                : InactiveCategory(category: category);
                            return InkWell(
                              onTap: () {
                                _changeChosenCategory(i);
                              },
                              child: Center(child: categoryWidget),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: Text(
                          'Choose timeout',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 12, fontFamily: "worksans",),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: DateTimeField(
                          autofocus: false,
                          style: TextStyle(
                            fontSize: 14,
                          ),
                          // decoration: InputDecoration(border: InputBorder.none),
                          format: DateFormat('yyyy-MM-dd – kk:mm'),
                          initialValue: _chosenTimeout,
                          onShowPicker: (context, currentValue) async {
                            final date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2100));
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    currentValue ?? DateTime.now()),
                              );
                              setState(() {
                                _chosenTimeout = DateTimeField.combine(date, time); 
                              });
                              return _chosenTimeout;
                            } else {
                              return currentValue;
                              // return currentValue;
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      RaisedButton(
                        onPressed: () {
                          widget.onSubmit(_chosenTitle,
                              _categories[_chosenCategory]['reward'],
                              DateFormat('yyyy-MM-dd – kk:mm').format(_chosenTimeout),
                              );
                          Navigator.of(context).pop();
                        },
                        textColor: Colors.white,
                        padding: const EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 60,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                CustomColors.GreenLight,
                                CustomColors.GreenDark,
                              ],
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: CustomColors.GreenShadow,
                                blurRadius: 2.0,
                                spreadRadius: 1.0,
                                offset: Offset(0.0, 0.0),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          child: Center(
                            child: const Text(
                              'Create challenge',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500, fontFamily: "worksans", ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InactiveCategory extends StatelessWidget {
  const InactiveCategory({
    Key key,
    @required this.category,
  }) : super(key: key);

  final Map<String, Object> category;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 10.0,
          width: 10.0,
          margin: EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: category['dotColor'],
            shape: BoxShape.circle,
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 10),
          child: Text(category['name'], style: TextStyle(fontFamily: "worksans", ),),
        ),
      ],
    );
  }
}

class ActiveCategory extends StatelessWidget {
  const ActiveCategory({
    Key key,
    @required this.category,
  }) : super(key: key);

  final Map<String, Object> category;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: Text(
        category['name'],
        style: TextStyle(color: Colors.white, fontFamily: "worksans", ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
          color: category['boxColor'],
          boxShadow: [
            BoxShadow(
              color: category['shadowColor'],
              blurRadius: 5.0,
              spreadRadius: 3.0,
              offset: Offset(0.0, 0.0),
            ),
          ]),
    );
  }
}