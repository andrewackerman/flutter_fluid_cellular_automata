import 'dart:ui';
import 'dart:math' as Math;

import 'package:water_cellular_automata/components/cell.dart';
import 'package:water_cellular_automata/components/grid.dart';

class LiquidSimulator {
  double minValue = 0.005;
  double maxValue = 1.0;

  double maxCompression = 0.25;

  double minFlow = 0.005;
  double maxFlow = 4;

  double flowSpeed = 1;

  List<double> diffs;
  double getDiff(int x, int y) => diffs[y * Grid.gridWidth + x];
  void setDiff(int x, int y, double value) => diffs[y * Grid.gridWidth + x] = value;

  void initialize(List<Cell> cells) {
    diffs = List.filled(Grid.gridWidth * Grid.gridHeight, 0, growable: false);
  }

  double calculateVerticalFlowValue(double remainingLiquid, Cell destination)
	{
		double sum = remainingLiquid + destination.liquid;
		double value = 0;

		if (sum <= maxValue) {
			value = maxValue;
		} else if (sum < 2 * maxValue + maxCompression) {
			value = (maxValue * maxValue + sum * maxCompression) / (maxValue + maxCompression);
		} else {
			value = (sum + maxCompression) / 2;
		}

		return value;
	}

  void simulate(List<Cell> cells) {
    Cell getCell(int x, int y) => cells[y * Grid.gridWidth + x];
    
    double flow = 0;

    diffs = List.filled(Grid.gridWidth * Grid.gridHeight, 0, growable: false);

    for (int x = 0; x < Grid.gridWidth; x++) {
      for (int y = 0; y < Grid.gridHeight; y++) {
        Cell cell = getCell(x, y);
        cell.resetFlowDirections();

        if (cell.type == CellType.solid) {
          cell.liquid = 0;
          continue;
        }
        if (cell.liquid == 0) {
          continue;
        }
        if (cell.settled) {
          continue;
        }
        if (cell.liquid < minValue) {
          cell.liquid = 0;
          continue;
        }

        final startValue = cell.liquid;
        double remainingValue = cell.liquid;
        flow = 0;

        // Flow to bottom cell
        if (cell.bottom != null && cell.bottom.type == CellType.blank) {
          // Determine rate of flow
          flow = calculateVerticalFlowValue(cell.liquid, cell.bottom) - cell.bottom.liquid;
          if (cell.bottom.liquid > 0 && flow > minFlow) {
            flow *= flowSpeed;
          }

          // Constrain flow
          flow = Math.max(flow, 0);
          if (flow > Math.min(maxFlow, remainingValue)) {
            flow = Math.min(maxFlow, remainingValue);
          }

          // Update temp values
          if (flow != 0) {
            remainingValue -= flow;
            setDiff(x, y, getDiff(x, y) - flow);
            setDiff(x, y+1, getDiff(x, y+1) + flow);
            cell.flowDirections[FlowDirection.bottom] = true;
            cell.bottom.settled = false;
          }
        }

        if (remainingValue < minValue) {
          setDiff(x, y, getDiff(x, y) - remainingValue);
          continue;
        }

        // Flow to left cell
        if (cell.left != null && cell.left.type == CellType.blank) {
          // Determine rate of flow
          flow = (remainingValue - cell.left.liquid) / 4;
          if (flow > minFlow) {
            flow *= flowSpeed;
          }

          // Constrain flow
          flow = Math.max(flow, 0);
          if (flow > Math.min(maxFlow, remainingValue)) {
            flow = Math.min(maxFlow, remainingValue);
          }

          // Update temp values
          if (flow != 0) {
            remainingValue -= flow;
            setDiff(x, y, getDiff(x, y) - flow);
            setDiff(x-1, y, getDiff(x-1, y) + flow);
            cell.flowDirections[FlowDirection.left] = true;
            cell.left.settled = false;
          }
        }

        if (remainingValue < minValue) {
          setDiff(x, y, getDiff(x, y) - remainingValue);
          continue;
        }

        // Flow to right cell
        if (cell.right != null && cell.right.type == CellType.blank) {
          // Determine rate of flow
          flow = (remainingValue - cell.right.liquid) / 4;
          if (flow > minFlow) {
            flow *= flowSpeed;
          }

          // Constrain flow
          flow = Math.max(flow, 0);
          if (flow > Math.min(maxFlow, remainingValue)) {
            flow = Math.min(maxFlow, remainingValue);
          }

          // Update temp values
          if (flow != 0) {
            remainingValue -= flow;
            setDiff(x, y, getDiff(x, y) - flow);
            setDiff(x+1, y, getDiff(x+1, y) + flow);
            cell.flowDirections[FlowDirection.right] = true;
            cell.right.settled = false;
          }
        }

        if (remainingValue < minValue) {
          setDiff(x, y, getDiff(x, y) - remainingValue);
          continue;
        }

        // Flow to top cell
        if (cell.top != null && cell.top.type == CellType.blank) {
          // Determine rate of flow
          flow = remainingValue - calculateVerticalFlowValue(remainingValue, cell.top);
          if (flow > minFlow) {
            flow *= flowSpeed;
          }

          // Constrain flow
          flow = Math.max(flow, 0);
          if (flow > Math.min(maxFlow, remainingValue)) {
            flow = Math.min(maxFlow, remainingValue);
          }

          // Update temp values
          if (flow != 0) {
            remainingValue -= flow;
            setDiff(x, y, getDiff(x, y) - flow);
            setDiff(x, y-1, getDiff(x, y-1) + flow);
            cell.flowDirections[FlowDirection.top] = true;
            cell.top.settled = false;
          }
        }

        if (remainingValue < minValue) {
          setDiff(x, y, getDiff(x, y) - remainingValue);
          continue;
        }

        // Check if cell is settled
        if (startValue == remainingValue) {
          cell.settleCount++;
          if (cell.settleCount >= 10) {
            cell.resetFlowDirections();
            cell.settled = true;
          }
        } else {
          cell.unsettleNeighbors();
        }
      }
    }

    // Update cell values
    for (int x = 0; x < Grid.gridWidth; x++) {
      for (int y = 0; y < Grid.gridHeight; y++) {
        Cell cell = getCell(x, y);
        cell.liquid += getDiff(x, y);
        if (cell.liquid < minValue) {
          cell.liquid = 0;
          cell.settled = false;
        }
      }
    }
  }

}