# Modern Frontend Frameworks

Guide to modern React meta-frameworks and build tools.

## Next.js (React Framework)

### App Router (Next.js 13+)

```typescript
// app/layout.tsx - Root layout
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}

// app/page.tsx - Home page
export default function Home() {
  return <h1>Welcome</h1>;
}

// app/dashboard/page.tsx - Dashboard page
export default function Dashboard() {
  return <div>Dashboard</div>;
}
```

### Server Components

```typescript
// Server Component (default)
async function UserProfile({ userId }: { userId: string }) {
  const user = await fetchUser(userId); // Runs on server

  return <div>{user.name}</div>;
}

// Client Component (when needed)
'use client';

function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(count + 1)}>{count}</button>;
}
```

### Data Fetching

```typescript
// Server-side fetch
async function Page() {
  const data = await fetch('https://api.example.com/data', {
    next: { revalidate: 60 }, // ISR with 60s revalidation
  }).then(res => res.json());

  return <div>{data.title}</div>;
}

// Static generation
export async function generateStaticParams() {
  const posts = await fetchAllPosts();
  return posts.map(post => ({ id: post.id }));
}
```

## Remix

```typescript
// routes/posts.$postId.tsx
import { json, type LoaderFunctionArgs } from '@remix-run/node';
import { useLoaderData } from '@remix-run/react';

export async function loader({ params }: LoaderFunctionArgs) {
  const post = await getPost(params.postId);
  return json({ post });
}

export default function Post() {
  const { post } = useLoaderData<typeof loader>();
  return <article>{post.title}</article>;
}
```

## Vite (Build Tool)

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
  },
  build: {
    sourcemap: true,
  },
});
```

## When to Use What

- **Next.js**: Full-stack React apps, SEO-critical sites
- **Remix**: Form-heavy apps, progressive enhancement
- **Vite**: SPA, fast development experience
- **Create React App**: Simple projects (consider Vite instead)

## Migration Considerations

- Next.js pages → App Router: Gradual migration possible
- CRA → Vite: Straightforward, much faster builds
- Remix: Best for new projects or full rewrites
