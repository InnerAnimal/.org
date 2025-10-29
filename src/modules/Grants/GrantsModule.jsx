import React from 'react';
import StatCard from '../../components/StatCard';

function GrantItem({ funder, amount, status, deadline }) {
  const statusColors = {
    'Submitted': 'bg-blue-100 text-blue-700',
    'Draft': 'bg-gray-100 text-gray-700',
    'Research': 'bg-purple-100 text-purple-700'
  };

  return (
    <div className="p-4 bg-gray-50 rounded-lg">
      <div className="flex justify-between items-start mb-2">
        <div className="font-semibold">{funder}</div>
        <span className={`px-2 py-1 rounded-full text-xs font-semibold ${statusColors[status]}`}>
          {status}
        </span>
      </div>
      <div className="flex justify-between text-sm text-gray-600">
        <span className="font-bold text-green-600">{amount}</span>
        <span>Due: {deadline}</span>
      </div>
    </div>
  );
}

export default function GrantsModule() {
  return (
    <div className="space-y-6">
      <div className="bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl p-6 text-white">
        <h2 className="text-2xl font-bold mb-2">Grant Hub</h2>
        <p className="opacity-90">Manage grant applications and reporting</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <StatCard icon="📝" label="Applications" value="8" color="indigo" />
        <StatCard icon="✅" label="Awarded" value="$15K" color="green" />
        <StatCard icon="⏳" label="Pending" value="3" color="yellow" />
      </div>

      <div className="bg-white rounded-xl p-6 shadow-sm">
        <h3 className="font-bold text-lg mb-4">Pipeline</h3>
        <div className="space-y-3">
          <GrantItem funder="Community Foundation" amount="$5,000" status="Submitted" deadline="Nov 15" />
          <GrantItem funder="Louisiana Endowment" amount="$10,000" status="Draft" deadline="Dec 1" />
          <GrantItem funder="Healthcare Initiative" amount="$7,500" status="Research" deadline="Jan 15" />
        </div>
      </div>
    </div>
  );
}

