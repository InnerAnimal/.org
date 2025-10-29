import { Code, Palette, BarChart3, Megaphone, FileText, Github } from 'lucide-react';
import GitHubModule from '../modules/GitHub/GitHubModule';
import WebsiteBuilderModule from '../modules/WebsiteBuilder/WebsiteBuilderModule';
import BrandLabModule from '../modules/BrandLab/BrandLabModule';
import AnalyticsModule from '../modules/Analytics/AnalyticsModule';
import CampaignsModule from '../modules/Campaigns/CampaignsModule';
import GrantsModule from '../modules/Grants/GrantsModule';

export const plugins = {
  github: {
    id: 'github',
    name: 'GitHub',
    icon: Github,
    color: 'from-gray-700 to-gray-900',
    component: GitHubModule
  },
  builder: {
    id: 'builder',
    name: 'Website Builder',
    icon: Code,
    color: 'from-blue-500 to-blue-700',
    component: WebsiteBuilderModule
  },
  brand: {
    id: 'brand',
    name: 'Brand Lab',
    icon: Palette,
    color: 'from-purple-500 to-pink-500',
    component: BrandLabModule
  },
  analytics: {
    id: 'analytics',
    name: 'Analytics',
    icon: BarChart3,
    color: 'from-green-500 to-teal-500',
    component: AnalyticsModule
  },
  campaigns: {
    id: 'campaigns',
    name: 'Campaigns',
    icon: Megaphone,
    color: 'from-orange-500 to-red-500',
    component: CampaignsModule
  },
  grants: {
    id: 'grants',
    name: 'Grant Hub',
    icon: FileText,
    color: 'from-indigo-500 to-purple-600',
    component: GrantsModule
  }
};

