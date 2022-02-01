# fl_heatmap

A heatmap widget for Flutter apps.

![heatmap](https://user-images.githubusercontent.com/13302336/151945676-a5d81296-ef46-4067-9ee5-4c40b6d69e78.png)

## Usage

### 1 - Depend on it

Add it to your package's pubspec.yaml file

```yml
dependencies:
  fl_heatmap: ^0.0.1
```


### 2 - Install it

Install packages from the command line

```sh
flutter packages get
```

### 3 - Use it

```dart
class _ExampleState extends State<ExampleApp> {
  HeatmapItem? selectedItem;

  late HeatmapData heatmapData;

  @override
  void initState() {
    _initExampleData();
    super.initState();
  }

  void _initExampleData() {
    const rows = [
      '2022',
      '2021',
      '2020',
      '2019',
    ];
    const columns = [
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez',
    ];
    final r = Random();
    const String unit = 'kWh';
    heatmapData = HeatmapData(rows: rows, columns: columns, items: [
      for (int row = 0; row < rows.length; row++)
        for (int col = 0; col < columns.length; col++)
          HeatmapItem(
              value: r.nextDouble() * 6,
              unit: unit,
              xAxisLabel: columns[col],
              yAxisLabel: rows[row]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final title = selectedItem != null
        ? '${selectedItem!.value.toStringAsFixed(2)} ${selectedItem!.unit}'
        : '--- ${heatmapData.items.first.unit}';
    final subtitle = selectedItem != null
        ? '${selectedItem!.xAxisLabel} ${selectedItem!.yAxisLabel}'
        : '---';
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Heatmap plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(title, textScaleFactor: 1.4),
              Text(subtitle),
              const SizedBox(height: 8),
              Heatmap(
                  onItemSelectedListener: (HeatmapItem? selectedItem) {
                    debugPrint(
                        'Item ${selectedItem?.yAxisLabel}/${selectedItem?.xAxisLabel} with value ${selectedItem?.value} selected');
                    setState(() {
                      this.selectedItem = selectedItem;
                    });
                  },
                  heatmapData: heatmapData)
            ],
          ),
        ),
      ),
    );
  }
}
```

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

