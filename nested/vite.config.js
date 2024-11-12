import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/js/app.jsx'
            ],
            refresh: true,
        }),
        react(),
    ],
    server: {
        host: '0.0.0.0',
        port: 5173,
        strictPort: true,
        hmr: {
            host: 'localhost',
            protocol: 'ws'
        },
    },
    resolve: {
        alias: {
            '@': '/resources/js',
            'ziggy': '/vendor/tightenco/ziggy/dist/index.js',
            'ziggy-js': '/vendor/tightenco/ziggy/dist/index.js'
        },
    },
    base: '/laravelapp/',
    optimizeDeps: {
        include: ['@inertiajs/react', '@inertiajs/core']
    }
});
