import { router } from '@inertiajs/react';
import './bootstrap';

// Configure o Inertia para usar o path base correto
router.on('before', (event) => {
    const baseUrl = '/laravelapp';
    const url = event.detail.visit.url;

    // Verifica se url existe e tem a propriedade raw
    if (url && typeof url === 'string' && !url.startsWith(baseUrl)) {
        event.detail.visit.url = `${baseUrl}${url}`;
    } else if (url && url.raw && !url.raw.startsWith(baseUrl)) {
        url.raw = `${baseUrl}${url.raw}`;
    }
});
