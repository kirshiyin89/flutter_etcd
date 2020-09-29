import 'package:flutter/material.dart';
import 'configdata.dart';
import 'etcdservice.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String _title = 'Admin UI Console';

  Future<List> getConfigData(String prefix) {
    print("get config data for $prefix");
    return fetchServerInfo(prefix);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: _title,
        home: DefaultTabController(
            length: createTabs().length,
            child: Builder(builder: (BuildContext context) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text(_title),
                  centerTitle: true,
                  bottom: TabBar(
                    tabs: createTabs(),
                  ),
                ),
                body: TabBarView(
                  children: generateTabColumns(),
                ),
              );
            })));
  }

  List<Widget> createTabs() {
    return [
      Tab(text: "Message Broker"),
      Tab(text: "Email Client"),
      Tab(text: "Cloud Storage"),
    ];
  }

  List<Widget> generateTabColumns() {
    return [
      DataTableWidget(listOfColumns: getConfigData("rabbitmq")),
      DataTableWidget(listOfColumns: getConfigData("smtp")),
      DataTableWidget(listOfColumns: getConfigData("minio")),
    ];
  }
}

class DataTableWidget extends StatefulWidget {
  DataTableWidget({Key key, this.listOfColumns}) : super(key: key);
  final Future<List<ConfigData>> listOfColumns;

  @override
  _DataTableWidgetState createState() =>
      _DataTableWidgetState(this.listOfColumns);
}

class _DataTableWidgetState extends State<DataTableWidget> {
  _DataTableWidgetState(this.listOfColumns);

  final Future<List<ConfigData>> listOfColumns;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConfigData>>(
        future: this.listOfColumns,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              return generateTable(context, snapshot.data);
          }
        });
  }

  Widget generateTable(BuildContext context, List<ConfigData> data) {
    return DataTable(
        columns: generateDataColumns(), rows: generateDataRows(context, data));
  }

  List<DataColumn> generateDataColumns() {
    return const <DataColumn>[
      DataColumn(
        label: Text(
          'Name',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
      DataColumn(
        label: Text(
          'Value',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    ];
  }

  List<DataRow> generateDataRows(BuildContext context, List<ConfigData> data) {
    return data.map((element) => getRow(element)).toList();
  }

  DataRow getRow(ConfigData element) {
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(element.name)),
        DataCell(
            TextFormField(
              initialValue: element.value,
              keyboardType: TextInputType.name,
              onFieldSubmitted: (val) {
                element.value = val;
                setConfigValue(element);
              },
            ),
            showEditIcon: true),
      ],
    );
  }

  setConfigValue(ConfigData config) {
    print(
        "update etcd key ${config.prefix}/${config.name} with value '${config.value}'");
    setEtcdValue(config);
  }
}
