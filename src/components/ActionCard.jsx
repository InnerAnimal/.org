import React from 'react';

export default function ActionCard({ title, description, icon: Icon, action }) {
  return (
    <div className="bg-white rounded-xl p-6 shadow-sm hover:shadow-md transition-shadow cursor-pointer">
      <Icon className="w-8 h-8 text-blue-500 mb-3" />
      <h3 className="font-bold text-lg mb-2">{title}</h3>
      <p className="text-gray-600 text-sm mb-4">{description}</p>
      <div className="text-blue-500 font-semibold text-sm">{action}</div>
    </div>
  );
}

