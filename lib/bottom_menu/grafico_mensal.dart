import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastos/utils/utils.dart';

class GraficoMensal extends StatelessWidget {
  final List<GastosCategoria> seriesList;
  final bool animate;

  GraficoMensal({this.seriesList, this.animate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 550,
      height: 450,
      child: charts.PieChart(_createData(),
          animate: animate,
          // Configure the width of the pie slices to 60px. The remaining space in
          // the chart will be left as a hole in the center.
          defaultRenderer: new charts.ArcRendererConfig(
              arcWidth: 80,
                  arcRendererDecorators: [
                    charts.ArcLabelDecorator(
                      labelPosition: charts.ArcLabelPosition.auto
                    )
                  ]
          ),
        behaviors: [
        new charts.DatumLegend(
        // Positions for "start" and "end" will be left and right respectively
        // for widgets with a build context that has directionality ltr.
        // For rtl, "start" and "end" will be right and left respectively.
        // Since this example has directionality of ltr, the legend is
        // positioned on the right side of the chart.
        position: charts.BehaviorPosition.bottom,
        // By default, if the position of the chart is on the left or right of
        // the chart, [horizontalFirst] is set to false. This means that the
        // legend entries will grow as new rows first instead of a new column.
        horizontalFirst: false,
        // This defines the padding around each legend entry.
        cellPadding: new EdgeInsets.only(right: 2.0, bottom: 0.0),
        // Set [showMeasures] to true to display measures in series legend.
        showMeasures: true,
        // Configure the measure value to be shown by default in the legend.
        legendDefaultMeasure: charts.LegendDefaultMeasure.firstValue,
        // Optionally provide a measure formatter to format the measure value.
        // If none is specified the value is formatted as a decimal.
        measureFormatter: (num value) {
          return value == null ? '-' : ' - ${Utils.intToCurrency(value)}';
        },
      ),
      ], ),
    );
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<GastosCategoria, String>> _createData() {

    return [
      new charts.Series<GastosCategoria, String>(
        id: 'Gastos',
        displayName: 'Text',
        domainFn: (GastosCategoria gastos, _) => gastos.descricaoCategoria,
        measureFn: (GastosCategoria gastos, _) => gastos.valor,
        labelAccessorFn: (GastosCategoria row, _) => '${row.descricaoCategoria}',
        data: seriesList,
      )
    ];
  }
}

/// Sample linear data type.
class GastosCategoria {
  final String descricaoCategoria;
  final int valor;

  GastosCategoria({this.descricaoCategoria, this.valor});
}