import 'package:anarchist/types/anilist_data.dart';
import 'package:anarchist/util/constants.dart';
import 'package:anarchist/util/search_query.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart'; // For rendering charts

class MediaDetailsPage extends StatelessWidget with SearchQueryHandler {
  static const String route = '/details/:id';
  static const double _bannerHeight = 200;

  late final Future<DetailedMediaEntry> _mediaEntry;

  MediaDetailsPage({super.key, required int mediaId}) {
    _mediaEntry = fetchMediaDetails(mediaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _mediaEntry,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _errorScreen(snapshot.error);
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return _body(context, snapshot.data!);
        },
      ),
    );
  }

  Widget _body(BuildContext context, DetailedMediaEntry details) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.transparent],
              ).createShader(rect),
              child: details.bannerImage != null
                  ? Image.network(
                      details.bannerImage!,
                      height: _bannerHeight,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    )
                  : SizedBox(
                      height: _bannerHeight,
                      width: MediaQuery.sizeOf(context).width,
                      child: ColoredBox(color: details.coverImageColor),
                    ),
            ),
            _titleInformation(details),
            _graphs(context, details),
          ],
        ),
      ),
    );
  }

  Widget _titleInformation(DetailedMediaEntry details) {
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: paddingWidgetSpacer),
            child: Image.network(
              details.coverImageURLHD!,
            ),
          ),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.preferredName!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_outline),
                    ),
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('Add to List'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _graphs(BuildContext context, DetailedMediaEntry details) {
    return Padding(
      padding: const EdgeInsets.all(paddingWidgetSpacer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score Distribution Graph
          Text(
            "Score Distribution",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          _buildScoreDistributionGraph(details.scoreDistribution),

          // Status Distribution Graph
          SizedBox(height: 32),
          Text(
            "Status Distribution",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 16),
          _buildStatusDistributionGraph(details.statusDistribution),
        ],
      ),
    );
  }

  Widget _buildScoreDistributionGraph(List<ScoreDistribution> scoreData) {
    if (scoreData.isEmpty) {
      return Center(child: Text("No score data available"));
    }

    return SizedBox(
      height: 300, // Provide a fixed height for the graph
      child: BarChart(
        BarChartData(
          barGroups: scoreData
              .map((score) => BarChartGroupData(
                    x: score.score,
                    barRods: [
                      BarChartRodData(
                        toY: score.amount.toDouble(),
                        width: 16,
                        color: _getBarColor(score.score),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ))
              .toList(),
          titlesData: FlTitlesData(
            show: false, // Removes all axis labels
          ),
          gridData: FlGridData(show: false),
          // Removes grid lines
          borderData: FlBorderData(show: false),
          // Removes borders
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              // tooltipBgColor: Colors.black,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${group.x}: ${rod.toY.toInt()}',
                  TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),

            allowTouchBarBackDraw: true,
            // Ensures background is redrawn on touch
            handleBuiltInTouches:
                true, // Enables touch interactions for tooltips
          ),
        ),
      ),
    );
  }

  Color _getBarColor(int score) {
    if (score <= 20) {
      return Colors.red;
    } else if (score <= 40) {
      return Colors.orange;
    } else if (score <= 60) {
      return Colors.yellow;
    } else if (score <= 80) {
      return Colors.lightGreen;
    } else {
      return Colors.green;
    }
  }

  Widget _buildStatusDistributionGraph(List<StatusDistribution> statusData) {
    if (statusData.isEmpty) {
      return Center(child: Text("No status data available"));
    }

    // Group small segments into "Other" category
    final largeSegments = statusData.where((s) => s.amount >= 1000).toList();
    final smallSegmentsTotal = statusData
        .where((s) => s.amount < 1000)
        .fold(0, (sum, s) => sum + s.amount);

    if (smallSegmentsTotal > 0) {
      largeSegments
          .add(StatusDistribution(status: "OTHER", amount: smallSegmentsTotal));
    }

    return Column(
      children: [
        SizedBox(
          height: 300, // Fixed height for the chart
          child: PieChart(
            PieChartData(
              sections: largeSegments
                  .map((status) => PieChartSectionData(
                        title: '', // No labels inside the chart
                        value: status.amount.toDouble(),
                        radius: 50,
                        color: _getStatusColor(status.status),
                      ))
                  .toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40, // Makes it a donut chart
            ),
          ),
        ),
        SizedBox(height: 16), // Spacing between chart and legend
        _buildLegend(largeSegments), // Add legend below the chart
      ],
    );
  }

  Widget _buildLegend(List<StatusDistribution> statusData) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: statusData.map((status) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: _getStatusColor(status.status),
            ),
            SizedBox(width: 8),
            Text('${status.status}: ${status.amount}'),
          ],
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "CURRENT":
        return Colors.green;
      case "PLANNING":
        return Colors.blue;
      case "COMPLETED":
        return Colors.orange;
      case "DROPPED":
        return Colors.red;
      case "PAUSED":
        return Colors.purple;
      case "OTHER":
        return Colors.grey; // Color for "Other" category
      default:
        return Colors.grey;
    }
  }

  Widget _errorScreen(Object? error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(paddingScreenEdge),
            child: Icon(Icons.warning),
          ),
          Text(error.toString(), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
