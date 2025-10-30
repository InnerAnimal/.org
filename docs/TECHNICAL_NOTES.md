# Technical Notes - Admin Portal

## Framework Configuration

### ⚠️ IMPORTANT: Vite vs Next.js Discrepancy

**Issue Identified**: 2025-10-30

**Current State**:
- **Codebase**: Using **Vite + React** (not Next.js)
- **Documentation**: References **Next.js 14**
- **Package.json**: Shows Vite dependencies
- **Build Tool**: Vite 5.4.0

**Evidence**:
```json
// From package.json
{
  "scripts": {
    "dev": "vite",          // ← Vite, not Next.js
    "build": "vite build"
  },
  "dependencies": {
    "react": "^18.3.0",
    "vite": "^5.4.0"        // ← Vite
  }
}
```

**Impact**:

1. **Environment Variables**:
   - Current: Uses `VITE_` prefix
   - Documented: Uses `NEXT_PUBLIC_` prefix
   - Solution: `.env` includes both variants for flexibility

2. **Build Process**:
   - Current: `npm run dev` runs Vite dev server on port 5173
   - Expected (if Next.js): Would run Next.js on port 3000

3. **Deployment**:
   - Current: Vite build outputs to `dist/`
   - Next.js: Would output to `.next/`

**Recommended Actions**:

### Option 1: Keep Vite (Simpler)
**Pros**:
- Already working
- Lighter weight
- Faster build times
- Good for admin dashboards

**Cons**:
- No SSR (Server-Side Rendering)
- No API routes without additional setup
- Less SEO-friendly (not critical for admin portal)

**To Keep Vite**:
1. Update all documentation to reflect Vite
2. Remove `NEXT_PUBLIC_` references
3. Keep using `VITE_` prefix for env vars
4. Document this decision

### Option 2: Migrate to Next.js 14 (Matches Docs)
**Pros**:
- Matches documentation
- Server-side rendering
- Built-in API routes
- Better for multi-app monorepo
- Unified with other apps (meauxbility.org, inneranimals.com)

**Cons**:
- Requires migration work
- More complex setup
- Larger bundle size

**To Migrate to Next.js**:
1. Install Next.js dependencies
2. Restructure to `app/` or `pages/` directory
3. Convert Vite config to `next.config.js`
4. Update all imports and routing
5. Migrate components to Next.js conventions

**Recommendation**: **Keep Vite** for now, migrate to Next.js later if needed for monorepo unification.

---

## Environment Variable Strategy

Given the framework uncertainty, `.env` includes both variants:

```bash
# Vite version (current)
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...

# Next.js version (future-proofing)
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
```

This ensures compatibility regardless of framework choice.

---

## Deployment Configuration

**Current**: https://iaudodidact.com/

**Platform**: Vercel

**Vercel Build Settings** (for Vite):
```
Framework Preset: Vite
Build Command: npm run build
Output Directory: dist
Install Command: npm install
```

**If migrating to Next.js**:
```
Framework Preset: Next.js
Build Command: npm run build
Output Directory: .next
Install Command: npm install
```

---

## API Routes Strategy

**Current Limitation**: Vite doesn't have built-in API routes

**Solutions**:

### Option 1: Use Supabase Edge Functions
- Deploy serverless functions to Supabase
- Access via Supabase client
- Good for admin portal use case

### Option 2: Add Express/Fastify Backend
- Create separate API server
- Deploy to Vercel as serverless functions
- More complex setup

### Option 3: Migrate to Next.js
- Get built-in API routes
- Simplifies architecture

**Current Approach**: Using Supabase directly (no API routes needed yet)

---

## Monorepo Considerations

**Current Structure**:
```
InnerAnimal/.org/
├── Admin Portal (Vite + React) ← You are here
```

**Planned Monorepo** (from documentation):
```
meauxbilityfoundation/.org/
├── apps/
│   ├── admin-portal/ (Vite or Next.js?)
│   ├── meauxbility-org/ (Next.js?)
│   └── inneranimals-shop/ (Next.js?)
├── packages/
│   ├── ui-components/
│   └── database-schemas/
└── tools/
```

**Question for Team**:
- Should all apps use the same framework?
- If yes, which one: Vite or Next.js?
- Or is mixed framework OK?

**Recommendation**:
- **Admin Portal**: Keep Vite (internal tool, SSR not needed)
- **Public Sites**: Use Next.js (meauxbility.org, inneranimals.com)
- **Shared Components**: Framework-agnostic React components

---

## Security Considerations

### API Key Exposure

**Vite Behavior**:
- Variables prefixed with `VITE_` are exposed to client
- They are bundled into the JavaScript
- Visible in browser DevTools

**Safe to Expose** (with `VITE_` prefix):
- ✅ Supabase Anon Key (designed for client-side)
- ✅ Google Analytics Measurement ID
- ✅ Stripe Publishable Key
- ✅ Public API endpoints

**NEVER Expose** (keep without `VITE_` prefix):
- ❌ Supabase Service Role Key
- ❌ Stripe Secret Key
- ❌ OpenAI API Key (unless rate-limited)
- ❌ Anthropic API Key
- ❌ GitHub Tokens
- ❌ JWT/Encryption Secrets

**Current `.env` follows this correctly**.

---

## Performance Considerations

### Vite Advantages
- ⚡ Lightning-fast HMR (Hot Module Replacement)
- 🚀 Quick startup time
- 📦 Efficient code splitting
- 🔧 Simple configuration

### Next.js Advantages
- 🎨 Built-in image optimization
- 📱 Automatic code splitting by route
- 🔍 Better SEO
- 🌐 SSR/SSG capabilities

**For Admin Portal**: Vite advantages are more valuable (internal tool, speed matters)

---

## Testing the Current Setup

### Verify Vite is Working

```bash
# Install dependencies
npm install

# Start dev server
npm run dev

# Should open http://localhost:5173
```

### Verify Supabase Connection

```javascript
// In src/lib/supabase.js
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)

// Test connection
const { data, error } = await supabase.from('profiles').select('*')
console.log('Supabase test:', { data, error })
```

### Build for Production

```bash
# Build
npm run build

# Preview production build
npm run preview

# Should open http://localhost:4173
```

---

## Migration Path (If Needed)

### Phase 1: Prepare
1. Document current Vite setup
2. Create Next.js branch
3. Install Next.js dependencies
4. Set up basic Next.js structure

### Phase 2: Migrate Components
1. Move components to Next.js structure
2. Update imports (Vite's `import.meta.env` → Next.js `process.env`)
3. Test each module
4. Fix routing

### Phase 3: Deploy
1. Update Vercel settings
2. Test deployment
3. Update DNS (if needed)
4. Monitor for issues

### Phase 4: Cleanup
1. Remove Vite dependencies
2. Update documentation
3. Archive old code

**Estimated Effort**: 2-3 weeks for full migration

---

## Decision Log

| Date | Decision | Reason | Status |
|------|----------|--------|--------|
| 2025-10-30 | Keep Vite for now | Working, faster for admin portal | ✅ Implemented |
| TBD | Evaluate Next.js migration | If monorepo needs consistency | ⏸️ Pending |

---

## Questions for Team

1. **Framework Choice**:
   - Keep Vite for admin portal?
   - Or migrate to Next.js for consistency?

2. **Monorepo Structure**:
   - All apps in one repo?
   - Or separate repos per app?

3. **Other Apps**:
   - Is meauxbility.org actually Next.js?
   - Is inneranimals.com actually Next.js?
   - Or are those also different frameworks?

4. **Priority**:
   - Focus on getting current app working?
   - Or prioritize framework migration?

---

## Resources

- [Vite Documentation](https://vitejs.dev/)
- [Next.js Documentation](https://nextjs.org/docs)
- [Vite → Next.js Migration Guide](https://nextjs.org/docs/migrating/from-vite)
- [Supabase with Vite](https://supabase.com/docs/guides/getting-started/quickstarts/vite)
- [Supabase with Next.js](https://supabase.com/docs/guides/getting-started/quickstarts/nextjs)

---

**Last Updated**: 2025-10-30
**Author**: Claude (AI Assistant)
**Status**: Documentation in progress
