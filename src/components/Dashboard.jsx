import React, { useState, useEffect } from 'react';
import { Settings, Command } from 'lucide-react';
import CommandPalette from './CommandPalette';
import { plugins } from '../lib/plugins';

export default function Dashboard() {
  const [activeModule, setActiveModule] = useState('github');
  const [commandOpen, setCommandOpen] = useState(false);

  useEffect(() => {
    const handleKeyDown = (e) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        setCommandOpen(true);
      } else if (e.key === 'Escape') {
        setCommandOpen(false);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  const activePlugin = plugins[activeModule];
  const ActiveComponent = activePlugin?.component;

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Top Navigation */}
      <nav className="bg-white border-b border-gray-200 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <h1 className="text-xl font-bold">Meauxbility</h1>
            <span className="px-2 py-1 bg-gradient-to-r from-purple-600 to-pink-600 text-white text-xs font-bold rounded">
              ADMIN
            </span>
          </div>
          
          <button
            onClick={() => setCommandOpen(true)}
            className="flex items-center gap-2 px-4 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors"
          >
            <Command className="w-4 h-4" />
            <span className="text-sm font-medium">Quick Actions</span>
            <kbd className="px-1.5 py-0.5 bg-white rounded text-xs border">⌘K</kbd>
          </button>
        </div>
      </nav>

      {/* Main Layout */}
      <div className="flex max-w-7xl mx-auto">
        {/* Sidebar */}
        <aside className="w-64 bg-white border-r border-gray-200 min-h-[calc(100vh-57px)] p-4">
          <div className="space-y-1">
            {Object.values(plugins).map(plugin => {
              const Icon = plugin.icon;
              const isActive = activeModule === plugin.id;
              
              return (
                <button
                  key={plugin.id}
                  onClick={() => setActiveModule(plugin.id)}
                  className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition-all ${
                    isActive 
                      ? `bg-gradient-to-r ${plugin.color} text-white shadow-lg` 
                      : 'text-gray-700 hover:bg-gray-100'
                  }`}
                >
                  <Icon className="w-5 h-5" />
                  <span>{plugin.name}</span>
                </button>
              );
            })}
          </div>

          <div className="mt-8 pt-8 border-t border-gray-200">
            <button className="w-full flex items-center gap-3 px-4 py-3 text-gray-700 hover:bg-gray-100 rounded-xl font-medium">
              <Settings className="w-5 h-5" />
              <span>Settings</span>
            </button>
          </div>
        </aside>

        {/* Main Content */}
        <main className="flex-1 p-6">
          {ActiveComponent && <ActiveComponent />}
        </main>
      </div>

      {/* Command Palette */}
      <CommandPalette 
        isOpen={commandOpen} 
        onClose={() => setCommandOpen(false)}
        onNavigate={(moduleId) => setActiveModule(moduleId)}
      />
    </div>
  );
}

