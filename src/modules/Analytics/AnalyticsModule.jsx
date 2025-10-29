import React from 'react';
import StatCard from '../../components/StatCard';

function TrafficSource({ source, percentage }) {
  return (
    <div>
      <div className="flex justify-between text-sm mb-1">
        <span className="font-medium">{source}</span>
        <span className="text-gray-600">{percentage}%</span>
      </div>
      <div className="w-full bg-gray-200 rounded-full h-2">
        <div className="bg-green-500 h-2 rounded-full" style={{ width: `${percentage}%` }} />
      </div>
    </div>
  );
}

export default function AnalyticsModule() {
  return (
    <div className="space-y-6">
      <div className="bg-gradient-to-br from-green-500 to-teal-500 rounded-xl p-6 text-white">
        <h2 className="text-2xl font-bold mb-2">Analytics Hub</h2>
        <p className="opacity-90">Track performance across all properties</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <StatCard icon="👥" label="Total Visitors" value="12.4K" color="green" />
        <StatCard icon="💰" label="Donations" value="$8,920" color="teal" />
        <StatCard icon="📈" label="Conversion Rate" value="3.2%" color="blue" />
      </div>

      <div className="bg-white rounded-xl p-6 shadow-sm">
        <h3 className="font-bold text-lg mb-4">Traffic Sources</h3>
        <div className="space-y-3">
          <TrafficSource source="Organic Search" percentage={45} />
          <TrafficSource source="Social Media" percentage={30} />
          <TrafficSource source="Direct" percentage={25} />
        </div>
      </div>
    </div>
  );
}

