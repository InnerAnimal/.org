import React from 'react';
import { FolderGit2 } from 'lucide-react';
import StatCard from '../../components/StatCard';

function ActivityItem({ repo, action, time }) {
  return (
    <div className="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
      <div>
        <div className="font-semibold text-sm">{repo}</div>
        <div className="text-gray-600 text-xs">{action}</div>
      </div>
      <div className="text-gray-400 text-xs">{time}</div>
    </div>
  );
}

export default function GitHubModule() {
  return (
    <div className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <StatCard icon={FolderGit2} label="Repositories" value="12" color="blue" />
        <StatCard icon="⭐" label="Total Stars" value="47" color="yellow" />
        <StatCard icon="🐛" label="Open Issues" value="8" color="red" />
      </div>
      
      <div className="bg-white rounded-xl p-6 shadow-sm">
        <h3 className="font-bold text-lg mb-4">Recent Activity</h3>
        <div className="space-y-3">
          <ActivityItem repo="meauxbility-platform" action="3 new commits" time="2h ago" />
          <ActivityItem repo="inneranimals-shop" action="Issue closed" time="5h ago" />
          <ActivityItem repo="accessibility-tools" action="Pull request merged" time="1d ago" />
        </div>
      </div>
    </div>
  );
}

