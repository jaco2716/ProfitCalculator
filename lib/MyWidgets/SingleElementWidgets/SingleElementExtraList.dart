import 'package:flutter/material.dart';

class SingleElementExtraList extends StatelessWidget {
  final String currencyString;
  final List<Map<String, dynamic>> elementList;
  final String title;
  SingleElementExtraList(this.currencyString, this.elementList, this.title);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title,
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 22,
                  color: Colors.pink[200],
                )),
          ),
          Divider(
            thickness: 1,
          ),
          elementList.length == 0
              ? Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text('No ${title.toLowerCase()} added.'),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(0),
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 1,
                      thickness: 2,
                    );
                  },
                  itemCount: elementList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SingleElementExtraListTile(
                        elementList[index]['title'],
                        elementList[index]['subtitle'],
                        '${elementList[index]['trailing'].toStringAsFixed(2)} ,- $currencyString');
                  },
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                ),
        ],
      ),
    );
  }
}

class SingleElementExtraListTile extends StatelessWidget {
  final String _title;
  final String _subtitle;
  final String _trailing;
  SingleElementExtraListTile(this._title, this._subtitle, this._trailing);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(_title),
      subtitle: Text(' - $_subtitle '),
      trailing: Text(_trailing),
    );
  }
}
