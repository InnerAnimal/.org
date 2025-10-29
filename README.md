# MAP=MeauxbilityAdminPortal

> Next-generation operations dashboard for Meauxbility & Inner Animals

A powerful, modular admin platform for managing websites, campaigns, grants, brand assets, and team collaboration across both organizations.

## 🎯 Features

- **🔌 Modular Plugin System** - Extensible architecture for unlimited functionality

- **⌘ Command Palette** - Lightning-fast navigation with keyboard shortcuts

- **🐙 GitHub Integration** - Real-time repo tracking and issue management

- **🎨 Brand Lab** - Centralized asset management and design tools

- **📊 Analytics Hub** - Cross-platform performance tracking

- **📣 Campaign Manager** - Email, social, and fundraiser coordination

- **📝 Grant Hub** - Application pipeline and document management

- **🏗️ Website Builder** - Component library and deployment tools

- **👥 Real-time Collaboration** - Live updates and team activity feeds

## 🚀 Tech Stack

### Frontend

- **React** - UI framework

- **Tailwind CSS** - Styling

- **Lucide Icons** - Icon system

- **Vite** - Build tool

### Backend

- **Supabase** - Database, Auth, Storage, Real-time

- **PostgreSQL** - Relational database

- **Row Level Security** - Fine-grained access control

### Integrations

- **GitHub API** - Repository and issue tracking

- **Google Analytics** - Traffic and conversion tracking

- **Stripe API** - Payment and donation processing

- **Anthropic Claude API** - AI-powered assistance

## 📁 Project Structure

```
meauxbility-admin-portal/
├── src/
│   ├── components/           # Reusable UI components
│   │   ├── CommandPalette.jsx
│   │   ├── StatCard.jsx
│   │   ├── ActionCard.jsx
│   │   └── Dashboard.jsx
│   ├── modules/              # Feature modules (plugins)
│   │   ├── GitHub/
│   │   ├── WebsiteBuilder/
│   │   ├── BrandLab/
│   │   ├── Analytics/
│   │   ├── Campaigns/
│   │   └── Grants/
│   ├── lib/                  # Utilities and configs
│   │   ├── supabase.js
│   │   ├── github.js
│   │   ├── utils.js
│   │   └── plugins.js
│   ├── hooks/                # Custom React hooks
│   │   ├── useAuth.js
│   │   ├── useRealtime.js
│   │   └── useAnalytics.js
│   ├── App.jsx               # Main app component
│   ├── main.jsx              # Entry point
│   └── index.css             # Global styles
├── public/
├── supabase/
│   └── migrations/           # Database migrations (future)
├── env.example               # Environment variables template
├── package.json
├── vite.config.js
├── tailwind.config.js
└── README.md
```

## 🛠️ Setup

### Prerequisites

- Node.js 18+
- npm or yarn
- Supabase account
- GitHub Personal Access Token (optional, for private repos)

### Installation

1. **Clone the repository**

```bash
git clone git@github.com:meauxbility/meauxbility-admin-portal.git
cd meauxbility-admin-portal
```

2. **Install dependencies**

```bash
npm install
```

3. **Set up environment variables**

Copy the environment template and add your credentials:

```bash
cp env.example .env
```

Edit `.env` with your credentials:

```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_GITHUB_TOKEN=your_github_token (optional)
VITE_GA_MEASUREMENT_ID=your_ga_id
```

4. **Set up Supabase database**

- Create a new Supabase project
- Run the schema from `supabase-schema.sql` (if available) or set up your own tables
- Configure authentication providers

5. **Start development server**

```bash
npm run dev
```

Visit `http://localhost:5173` 🚀

## 🔑 Authentication

The portal supports role-based access:

- **Admin** (Sam) - Full access to all features
- **CTO** (Connor) - Technical tools and GitHub management
- **CMO** (Fred) - Marketing, campaigns, and analytics
- **Member** - Limited access based on project collaboration

## 📦 Key Dependencies

```json
{
  "react": "^18.3.0",
  "lucide-react": "^0.460.0",
  "@supabase/supabase-js": "^2.45.0",
  "tailwindcss": "^3.4.0"
}
```

## 🎨 Design System

The portal uses a consistent design language:

- **Colors**: Gradient-based system with semantic color roles
- **Typography**: SF Pro Display / System fonts
- **Spacing**: 4px base unit
- **Radius**: 12px-24px rounded corners
- **Shadows**: Layered elevation system

## 🔌 Adding New Modules

1. Create module directory in `src/modules/YourModule/`
2. Export module component
3. Register in `src/lib/plugins.js`:

```javascript
{
  id: 'yourmodule',
  name: 'Your Module',
  icon: YourIcon,
  color: 'from-blue-500 to-blue-700',
  component: YourModule
}
```

## 🚢 Deployment

### Vercel (Recommended)

```bash
npm run build
vercel --prod
```

### Netlify

```bash
npm run build
netlify deploy --prod --dir=dist
```

### Environment Variables

Make sure to set all environment variables in your deployment platform.

## 📊 Database Schema

See `supabase-schema.sql` for the initial schema including:

- User profiles and authentication
- Sessions and messages (AI conversations)
- API key management

Additional tables for projects, campaigns, grants, and analytics will be added as modules are expanded.

## 🤝 Contributing

This is a private repository for the Meauxbility team. If you're a team member:

1. Create a feature branch (`git checkout -b feature/amazing-feature`)
2. Commit your changes (`git commit -m 'Add amazing feature'`)
3. Push to the branch (`git push origin feature/amazing-feature`)
4. Open a Pull Request

## 🔐 Security

- All sensitive data is stored securely in Supabase
- Row Level Security (RLS) enforces access control
- API keys are never committed to the repository
- All external API calls use environment variables

## 📝 License

Private - © 2024 Meauxbility 501(c)(3) & Inner Animals

## 👥 Team

- **Sam** - CEO/Founder (Admin)
- **Connor McNeely** - CTO
- **Fred Williams** - CMO

## 🆘 Support

For issues or questions:

- Create an issue in this repository
- Contact: info@meauxbility.org
- Slack: #admin-portal

---

Built with 💜 for accessibility and impact

