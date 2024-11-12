<?php

namespace App\Providers;

use Illuminate\Support\Facades\URL;
use Illuminate\Support\Facades\Vite;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Route;

class AppServiceProvider extends ServiceProvider
{
    /**
     * The path to your application's "home" route.
     */
    public const HOME = '/laravelapp/dashboard';

    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        if (app()->environment('production')) {
            URL::forceScheme('https');
        }
        URL::forceRootUrl(config('app.url'));

        Vite::prefetch(concurrency: 3);

        // Configuração das rotas web
        Route::pattern('id', '[0-9]+');

        Route::middleware('web')
            ->group(base_path('routes/web.php'));

//        Route::middleware('api')
//            ->prefix('api')
//            ->group(base_path('routes/api.php'));

        // Força todas as URLs geradas a incluir o path base
        URL::formatPathUsing(function ($path) {
            if (!str_starts_with($path, '/laravelapp') && !str_starts_with($path, 'http')) {
                return '/laravelapp' . ($path === '/' ? '' : $path);
            }
            return $path;
        });
    }
}
