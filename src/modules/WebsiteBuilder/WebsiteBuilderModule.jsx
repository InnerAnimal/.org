import React from 'react';
import { Code } from 'lucide-react';
import ActionCard from '../../components/ActionCard';

function ProjectItem({ name, status }) {
  const statusColors = {
    'In Progress': 'bg-yellow-100 text-yellow-700',
    'Deployed': 'bg-green-100 text-green-700',
    'In Review': 'bg-blue-100 text-blue-700'
  };

  return (
    <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
      <span className="font-medium text-sm">{name}</span>
      <span className={`px-2 py-1 rounded-full text-xs font-semibold ${statusColors[status]}`}>
        {status}
      </span>
    </div>
  );
}

export default function WebsiteBuilderModule() {
  return (
    <div className="space-y-6">
      <div className="bg-gradient-to-br from-blue-500 to-blue-700 rounded-xl p-6 text-white">
        <h2 className="text-2xl font-bold mb-2">Website Builder</h2>
        <p className="opacity-90">Build and deploy sites with your component library</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <ActionCard 
          title="Component Library" 
          description="Browse glassmorphic UI elements"
          icon={Code}
          action="Browse →"
        />
        <ActionCard 
          title="New Project" 
          description="Start from template or blank canvas"
          icon={Code}
          action="Create →"
        />
      </div>

      <div className="bg-white rounded-xl p-6 shadow-sm">
        <h3 className="font-bold text-lg mb-4">Recent Projects</h3>
        <div className="space-y-2">
          <ProjectItem name="Southern Pets Redesign" status="In Progress" />
          <ProjectItem name="MSHIPPI Landing Page" status="Deployed" />
          <ProjectItem name="SwampBlood Guide Site" status="In Review" />
        </div>
      </div>
    </div>
  );
}

