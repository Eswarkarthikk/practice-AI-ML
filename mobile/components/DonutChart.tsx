/**
 * DonutChart - Simplified donut chart component
 */

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import Svg, { Circle, Path } from 'react-native-svg';
import { COLORS } from '@/lib/theme';

interface DonutChartProps {
  data: Array<[string, number]>;
  size?: number;
  centerText?: string;
  strokeWidth?: number;
}

export const SimplifiedDonutChart: React.FC<DonutChartProps> = ({
  data,
  size = 180,
  centerText = '0',
  strokeWidth = 20,
}) => {
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const centerX = size / 2;
  const centerY = size / 2;

  // Chart colors
  const chartColors = [
    COLORS.purpleMain,
    '#4ECDC4',
    COLORS.successGreen,
    COLORS.dangerRed,
    '#F5A623',
    '#FF8BB1',
    '#95A5A6',
  ];

  const total = data.reduce((sum, [_, value]) => sum + value, 0);

  let currentAngle = -90; // Start from top

  const arcs = data.map(([label, value], index) => {
    const percentage = total > 0 ? (value / total) * 100 : 0;
    const angle = (percentage / 100) * 360;
    const startAngle = (currentAngle * Math.PI) / 180;
    const endAngle = ((currentAngle + angle) * Math.PI) / 180;

    const x1 = centerX + radius * Math.cos(startAngle);
    const y1 = centerY + radius * Math.sin(startAngle);
    const x2 = centerX + radius * Math.cos(endAngle);
    const y2 = centerY + radius * Math.sin(endAngle);

    const largeArc = angle > 180 ? 1 : 0;

    const pathData = `M ${centerX} ${centerY} L ${x1} ${y1} A ${radius} ${radius} 0 ${largeArc} 1 ${x2} ${y2} Z`;

    currentAngle += angle;

    return (
      <Path
        key={index}
        d={pathData}
        fill={chartColors[index % chartColors.length]}
      />
    );
  });

  return (
    <View style={styles.container}>
      <View style={{ width: size, height: size }}>
        <Svg width={size} height={size}>
          {arcs}
          {/* Center circle to create donut effect */}
          <Circle
            cx={centerX}
            cy={centerY}
            r={radius - strokeWidth}
            fill={COLORS.cardBg}
          />
        </Svg>
        {/* Center text */}
        <View style={styles.centerText}>
          <Text style={styles.centerValue}>{centerText}</Text>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
  },
  centerText: {
    position: 'absolute',
    width: '100%',
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  centerValue: {
    fontSize: 20,
    fontWeight: '600',
    color: COLORS.textPrimary,
  },
});
