import React from 'react';

export default function StatCard({ icon, label, value, color }) {
  const Icon = typeof icon === 'string' ? null : icon;
  const colors = {
    blue: 'from-blue-500 to-blue-600',
    green: 'from-green-500 to-green-600',
    teal: 'from-teal-500 to-teal-600',
    yellow: 'from-yellow-500 to-yellow-600',
    red: 'from-red-500 to-red-600',
    indigo: 'from-indigo-500 to-indigo-600'
  };

  return (
    <div className={`bg-gradient-to-br ${colors[color]} rounded-xl p-6 text-white shadow-lg`}>
      <div className="text-3xl mb-2">{Icon ? <Icon className="w-8 h-8" /> : icon}</div>
      <div className="text-3xl font-bold mb-1">{value}</div>
      <div className="text-sm opacity-90">{label}</div>
    </div>
  );
}

