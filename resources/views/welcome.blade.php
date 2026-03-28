<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}" class="h-full bg-slate-50">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>WBP Reception Management</title>
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700,800,900&display=swap" rel="stylesheet" />
    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>
<body class="font-sans antialiased h-full text-slate-900">
    <div class="relative min-h-screen flex flex-col justify-center items-center overflow-hidden bg-slate-900">
        <!-- Background Orbs -->
        <div class="absolute top-0 right-0 -m-40 w-96 h-96 bg-blue-600 rounded-full blur-[120px] opacity-20"></div>
        <div class="absolute bottom-0 left-0 -m-40 w-96 h-96 bg-red-600 rounded-full blur-[120px] opacity-10"></div>

        <div class="relative z-10 w-full max-w-4xl px-6 py-12 text-center">
            <div class="mb-12 inline-flex items-center gap-3 px-4 py-2 bg-white/5 border border-white/10 rounded-full backdrop-blur-md">
                <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
                <span class="text-[10px] font-black text-slate-400 uppercase tracking-[0.3em]">Official Personnel Access Only</span>
            </div>

            <h1 class="text-5xl md:text-7xl font-black text-white tracking-tighter uppercase italic leading-tight mb-6">
                West Bengal <span class="text-blue-500">Police</span>
            </h1>
            <p class="text-xl md:text-2xl text-slate-400 font-medium tracking-widest uppercase mb-12 opacity-80">
                Reception Management System
            </p>

            <div class="flex flex-col sm:flex-row items-center justify-center gap-6">
                @if (Route::has('login'))
                    @auth
                        <a href="{{ url('/dashboard') }}" class="w-full sm:w-auto px-12 py-4 bg-blue-600 text-white font-black rounded-2xl hover:bg-blue-700 transition-all shadow-2xl shadow-blue-600/30 uppercase tracking-widest text-sm">
                            Go to Dashboard
                        </a>
                    @else
                        <a href="{{ route('login') }}" class="w-full sm:w-auto px-12 py-4 bg-white text-slate-900 font-black rounded-2xl hover:bg-slate-100 transition-all shadow-2xl uppercase tracking-widest text-sm">
                            Access Portal
                        </a>

                        @if (Route::has('register'))
                            <a href="{{ route('register') }}" class="w-full sm:w-auto px-12 py-4 bg-white/5 text-white border border-white/20 font-black rounded-2xl hover:bg-white/10 transition-all backdrop-blur-sm uppercase tracking-widest text-sm">
                                Register
                            </a>
                        @endif
                    @endauth
                @endif
            </div>

            <div class="mt-24 grid grid-cols-1 md:grid-cols-3 gap-8 opacity-50">
                <div class="p-6">
                    <div class="text-white font-black mb-2 uppercase tracking-tighter">Real-time Logging</div>
                    <p class="text-xs text-slate-500">Instantly log all incoming visitor complaints and reports.</p>
                </div>
                <div class="p-6 border-x border-white/5">
                    <div class="text-white font-black mb-2 uppercase tracking-tighter">Instant Dispatch</div>
                    <p class="text-xs text-slate-500">Immediate mobile alerts for high-priority emergency cases.</p>
                </div>
                <div class="p-6">
                    <div class="text-white font-black mb-2 uppercase tracking-tighter">Detailed Analytics</div>
                    <p class="text-xs text-slate-500">Comprehensive jurisdictional data distribution and metrics.</p>
                </div>
            </div>
        </div>

        <div class="absolute bottom-12 text-center w-full">
            <p class="text-[10px] font-bold text-slate-600 uppercase tracking-[0.5em] italic">
                Secure National Network Integration
            </p>
        </div>
    </div>
</body>
</html>
