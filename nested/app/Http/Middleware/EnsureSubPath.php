<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureSubPath
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $subPath = config('app.path', '/laravelapp');
        $currentUri = $request->getRequestUri();

        // Remove múltiplas barras
        $currentUri = preg_replace('#/+#', '/', $currentUri);

        // Se não começar com o subpath, adiciona
        if (!str_starts_with($currentUri, $subPath)) {
            // Remove a barra inicial se existir
            $currentUri = ltrim($currentUri, '/');
            // Adiciona o subpath
            $request->server->set('REQUEST_URI', $subPath . '/' . $currentUri);
        }

        return $next($request);
    }
}
