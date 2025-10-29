import React, { useState, useEffect, useRef } from 'react';
import { Search, Code, Palette, BarChart3, Megaphone, FileText, Users, Settings, ChevronRight, Github } from 'lucide-react';

export default function CommandPalette({ isOpen, onClose, onNavigate }) {
  const [search, setSearch] = useState('');
  const inputRef = useRef(null);
  const [selectedIndex, setSelectedIndex] = useState(0);

  const commands = [
    { id: 'github', name: 'GitHub Dashboard', icon: Github, action: () => onNavigate('github') },
    { id: 'builder', name: 'Website Builder', icon: Code, action: () => onNavigate('builder') },
    { id: 'brand', name: 'Brand Lab', icon: Palette, action: () => onNavigate('brand') },
    { id: 'analytics', name: 'Analytics Hub', icon: BarChart3, action: () => onNavigate('analytics') },
    { id: 'campaigns', name: 'Campaign Manager', icon: Megaphone, action: () => onNavigate('campaigns') },
    { id: 'grants', name: 'Grant Hub', icon: FileText, action: () => onNavigate('grants') },
    { id: 'team', name: 'View Team', icon: Users, action: () => alert('Team view coming soon!') },
    { id: 'settings', name: 'Settings', icon: Settings, action: () => alert('Settings coming soon!') },
  ];

  const filtered = commands.filter(cmd => 
    cmd.name.toLowerCase().includes(search.toLowerCase())
  );

  useEffect(() => {
    if (isOpen && inputRef.current) {
      inputRef.current.focus();
    }
  }, [isOpen]);

  useEffect(() => {
    setSelectedIndex(0);
  }, [search]);

  const handleKeyDown = (e) => {
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      setSelectedIndex(i => (i + 1) % filtered.length);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      setSelectedIndex(i => (i - 1 + filtered.length) % filtered.length);
    } else if (e.key === 'Enter' && filtered[selectedIndex]) {
      e.preventDefault();
      filtered[selectedIndex].action();
      onClose();
      setSearch('');
    } else if (e.key === 'Escape') {
      onClose();
      setSearch('');
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-start justify-center pt-[20vh]"
         onClick={onClose}>
      <div className="w-full max-w-2xl mx-4 bg-white rounded-2xl shadow-2xl overflow-hidden"
           onClick={e => e.stopPropagation()}>
        {/* Search Input */}
        <div className="flex items-center gap-3 p-4 border-b border-gray-200">
          <Search className="w-5 h-5 text-gray-400" />
          <input
            ref={inputRef}
            type="text"
            placeholder="Search commands..."
            value={search}
            onChange={e => setSearch(e.target.value)}
            onKeyDown={handleKeyDown}
            className="flex-1 text-lg outline-none"
          />
          <kbd className="px-2 py-1 text-xs bg-gray-100 rounded">ESC</kbd>
        </div>

        {/* Results */}
        <div className="max-h-96 overflow-y-auto">
          {filtered.map((cmd, idx) => {
            const Icon = cmd.icon;
            return (
              <div
                key={cmd.id}
                className={`flex items-center gap-3 px-4 py-3 cursor-pointer transition-colors ${
                  idx === selectedIndex ? 'bg-blue-50' : 'hover:bg-gray-50'
                }`}
                onClick={() => {
                  cmd.action();
                  onClose();
                  setSearch('');
                }}
              >
                <Icon className="w-5 h-5 text-gray-600" />
                <span className="flex-1 font-medium">{cmd.name}</span>
                <ChevronRight className="w-4 h-4 text-gray-400" />
              </div>
            );
          })}
          {filtered.length === 0 && (
            <div className="px-4 py-8 text-center text-gray-500">
              No commands found
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="px-4 py-3 bg-gray-50 border-t border-gray-200 flex items-center justify-between text-xs text-gray-500">
          <div className="flex gap-4">
            <span><kbd className="px-1.5 py-0.5 bg-white rounded border">↑↓</kbd> Navigate</span>
            <span><kbd className="px-1.5 py-0.5 bg-white rounded border">⏎</kbd> Select</span>
          </div>
          <span>⌘K to open</span>
        </div>
      </div>
    </div>
  );
}

