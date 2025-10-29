import React from 'react';
import { Megaphone } from 'lucide-react';
import ActionCard from '../../components/ActionCard';

function CampaignItem({ name, status, reach }) {
  const statusColors = {
    'Active': 'bg-green-100 text-green-700',
    'Scheduled': 'bg-blue-100 text-blue-700',
    'Draft': 'bg-gray-100 text-gray-700'
  };

  return (
    <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
      <div>
        <div className="font-medium text-sm">{name}</div>
        <div className="text-gray-600 text-xs">Reach: {reach}</div>
      </div>
      <span className={`px-2 py-1 rounded-full text-xs font-semibold ${statusColors[status]}`}>
        {status}
      </span>
    </div>
  );
}

export default function CampaignsModule() {
  return (
    <div className="space-y-6">
      <div className="bg-gradient-to-br from-orange-500 to-red-500 rounded-xl p-6 text-white">
        <h2 className="text-2xl font-bold mb-2">Campaign Manager</h2>
        <p className="opacity-90">Plan, execute, and track marketing campaigns</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <ActionCard 
          title="Email Campaign" 
          description="Send to 1,200 subscribers"
          icon={Megaphone}
          action="Create →"
        />
        <ActionCard 
          title="Social Scheduler" 
          description="Plan posts across platforms"
          icon={Megaphone}
          action="Schedule →"
        />
      </div>

      <div className="bg-white rounded-xl p-6 shadow-sm">
        <h3 className="font-bold text-lg mb-4">Active Campaigns</h3>
        <div className="space-y-3">
          <CampaignItem name="Fall Fundraiser" status="Active" reach="2.3K" />
          <CampaignItem name="Newsletter Q4" status="Scheduled" reach="1.2K" />
          <CampaignItem name="Holiday Drive" status="Draft" reach="—" />
        </div>
      </div>
    </div>
  );
}

