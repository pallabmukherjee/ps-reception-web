<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="h-full bg-slate-50">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'WBP Reception') }}</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700,800&display=swap" rel="stylesheet" />

        <!-- Scripts -->
        @vite(['resources/css/app.css', 'resources/js/app.js'])
        
        <style>
            [x-cloak] { display: none !important; }
            .custom-scrollbar::-webkit-scrollbar { width: 4px; }
            .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
            .custom-scrollbar::-webkit-scrollbar-thumb { background: #334155; border-radius: 10px; }
        </style>
    </head>
    <body class="font-sans antialiased text-slate-900 h-full overflow-hidden">
        <div class="flex h-full">
            <!-- Sidebar -->
            @include('layouts.sidebar')

            <!-- Main Content -->
            <div class="flex-1 flex flex-col min-w-0 overflow-hidden ml-64 transition-all duration-300 ease-in-out" id="main-content">
                <!-- Top Header -->
                <header class="bg-white border-b border-slate-200 h-16 flex items-center justify-between px-6 shrink-0 z-10 shadow-sm">
                    <div class="flex items-center">
                        <button id="toggleSidebar" class="p-2 rounded-lg text-slate-500 hover:bg-slate-100 hover:text-slate-600 transition-colors">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
                            </svg>
                        </button>
                        <h2 class="ml-4 text-lg font-bold text-slate-800 tracking-tight hidden md:block">
                            @yield('header_title', 'Krishnanagar Police District')
                        </h2>
                    </div>
                    
                    <div class="flex items-center space-x-4">
                        <div class="flex flex-col items-end mr-2">
                            <span class="text-sm font-bold text-slate-900">{{ Auth::user()->name }}</span>
                            <span class="text-[10px] font-bold text-blue-600 uppercase tracking-wider">{{ Auth::user()->getRoleNames()->first() ?? 'User' }}</span>
                        </div>
                        <div class="h-10 w-10 rounded-full bg-slate-100 border border-slate-200 flex items-center justify-center text-slate-600 font-bold">
                            {{ substr(Auth::user()->name, 0, 1) }}
                        </div>
                    </div>
                </header>

                <!-- Page Content -->
                <main class="flex-1 overflow-y-auto p-6 bg-slate-50 custom-scrollbar">
                    {{ $slot }}
                </main>
            </div>
        </div>

        <script>
            document.getElementById('toggleSidebar').addEventListener('click', function() {
                const sidebar = document.getElementById('sidebar');
                const mainContent = document.getElementById('main-content');
                if (sidebar.classList.contains('w-64')) {
                    sidebar.classList.replace('w-64', 'w-0');
                    mainContent.classList.replace('ml-64', 'ml-0');
                } else {
                    sidebar.classList.replace('w-0', 'w-64');
                    mainContent.classList.replace('ml-0', 'ml-64');
                }
            });
        </script>
    </body>
</html>
