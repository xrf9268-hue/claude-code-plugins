# Build Optimization

Guide to optimizing build configuration for production-ready React applications.

## Webpack Configuration

```javascript
// webpack.config.js
const TerserPlugin = require('terser-webpack-plugin');
const CompressionPlugin = require('compression-webpack-plugin');

module.exports = {
  mode: 'production',
  optimization: {
    minimize: true,
    minimizer: [new TerserPlugin()],
    splitChunks: {
      chunks: 'all',
      cacheGroups: {
        vendor: {
          test: /[\\/]node_modules[\\/]/,
          name: 'vendors',
          priority: 10,
        },
      },
    },
  },
  plugins: [
    new CompressionPlugin({
      algorithm: 'gzip',
      test: /\.(js|css|html|svg)$/,
    }),
  ],
};
```

## Vite Configuration

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ui: ['@mui/material'],
        },
      },
    },
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
      },
    },
  },
});
```

## Tree Shaking

```typescript
// ✅ Good: Import only what you need
import { debounce } from 'lodash-es';

// ❌ Avoid: Import entire library
import _ from 'lodash';
```

## Code Splitting

```typescript
// Route-based splitting
const Home = lazy(() => import('./pages/Home'));
const Dashboard = lazy(() => import('./pages/Dashboard'));

// Component-based splitting
const HeavyChart = lazy(() => import('./components/HeavyChart'));
```

## Bundle Analysis

```bash
# Webpack
npm install --save-dev webpack-bundle-analyzer

# Vite
npm install --save-dev rollup-plugin-visualizer
```

## Production Checklist

- ✅ Enable minification
- ✅ Configure code splitting
- ✅ Enable tree shaking
- ✅ Compress assets (gzip/brotli)
- ✅ Optimize images
- ✅ Remove console.log statements
- ✅ Set NODE_ENV=production
- ✅ Analyze bundle size
- ✅ Enable source maps (for debugging)
- ✅ Configure caching headers
