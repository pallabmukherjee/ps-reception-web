<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="h-full">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'WBP Reception') }}</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700,800,900&display=swap" rel="stylesheet" />

        <!-- Scripts -->
        @vite(['resources/css/app.css', 'resources/js/app.js'])
    </head>
    <body class="font-sans antialiased h-full text-slate-900 overflow-hidden">
        <div class="min-h-screen flex flex-col justify-center items-center p-6 bg-slate-900 relative">
            <!-- Background Orbs -->
            <div class="absolute top-0 left-0 -m-20 w-64 h-64 bg-blue-600 rounded-full blur-[100px] opacity-20"></div>
            <div class="absolute bottom-0 right-0 -m-20 w-64 h-64 bg-red-600 rounded-full blur-[100px] opacity-10"></div>

            <div class="relative z-10 w-full flex flex-col items-center">
                <div class="mb-8">
                    <a href="/">
                        <x-application-logo class="text-white scale-125" />
                    </a>
                </div>

                <div class="w-full sm:max-w-md bg-white rounded-[32px] shadow-2xl overflow-hidden border border-slate-200">
                    <div class="p-8 sm:p-10">
                        {{ $slot }}
                    </div>
                </div>
                
                <div class="mt-8 text-center">
                    <p class="text-[10px] font-black text-slate-500 uppercase tracking-[0.4em] italic">Official Personnel Security Layer</p>
                </div>
            </div>
        </div>
    </body>
</html>
