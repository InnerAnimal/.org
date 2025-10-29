import React from 'react';
import { Palette } from 'lucide-react';
import ActionCard from '../../components/ActionCard';

function BrandAsset({ type, count }) {
  return (
    <div className="bg-white rounded-xl p-4 shadow-sm text-center">
      <div className="text-2xl font-bold text-purple-600 mb-1">{count}</div>
      <div className="text-sm text-gray-600">{type}</div>
    </div>
  );
}

export default function BrandLabModule() {
  return (
    <div className="space-y-6">
      <div className="bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl p-6 text-white">
        <h2 className="text-2xl font-bold mb-2">Brand Lab</h2>
        <p className="opacity-90">Design assets and brand management</p>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <BrandAsset type="Logos" count="24" />
        <BrandAsset type="Colors" count="8" />
        <BrandAsset type="Fonts" count="12" />
        <BrandAsset type="Images" count="156" />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <ActionCard 
          title="Social Post Generator" 
          description="Create branded social graphics"
          icon={Palette}
          action="Generate →"
        />
        <ActionCard 
          title="Email Templates" 
          description="Branded email designs"
          icon={Palette}
          action="Browse →"
        />
      </div>
    </div>
  );
}

