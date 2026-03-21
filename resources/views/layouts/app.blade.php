<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'Laravel') }}</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

        <!-- Scripts -->
        @vite(['resources/css/app.css', 'resources/js/app.js'])
    </head>
    <body class="font-sans antialiased bg-gray-100">
        <div class="flex h-screen overflow-hidden">
            <!-- Sidebar -->
            @include('layouts.sidebar')

            <!-- Main Content -->
            <div class="flex-1 flex flex-col min-w-0 overflow-hidden ml-64">
                <!-- Top Header -->
                <header class="bg-white shadow-md p-4 text-xl font-bold flex items-center z-10">
                    <button id="toggleSidebar" class="mr-4 p-2 rounded-md bg-gray-200 hover:bg-gray-300">
                        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
                        </svg>
                    </button>
                    <div class="font-mono">
                        Welcome, {{ Auth::user()->full_name ?? Auth::user()->name }}
                    </div>
                </header>

                <!-- Page Content -->
                <main class="flex-1 overflow-y-auto p-4">
                    {{ $slot }}
                </main>
            </div>
        </div>

        <script>
            document.getElementById('toggleSidebar').addEventListener('click', function() {
                const sidebar = document.getElementById('sidebar');
                const mainContent = sidebar.nextElementSibling;
                if (sidebar.classList.contains('w-64')) {
                    sidebar.classList.remove('w-64');
                    sidebar.classList.add('w-0');
                    mainContent.classList.remove('ml-64');
                    mainContent.classList.add('ml-0');
                } else {
                    sidebar.classList.remove('w-0');
                    sidebar.classList.add('w-64');
                    mainContent.classList.remove('ml-0');
                    mainContent.classList.add('ml-64');
                }
            });
        </script>
    </body>
</html>
