<div id="sidebar" class="bg-slate-900 text-white flex flex-col w-64 transition-all duration-300 ease-in-out overflow-hidden h-screen fixed left-0 top-0 z-50 border-r border-slate-800">
    <div class="p-6 text-center border-b border-slate-800 bg-slate-900">
        <div class="text-xl font-black tracking-tight text-white uppercase italic">
            <span class="text-red-500">WBP</span> <span class="text-blue-500">Reception</span>
        </div>
        <div class="text-[10px] text-slate-400 font-mono mt-1 font-bold">WEST BENGAL POLICE</div>
    </div>
    
    <nav class="flex-1 p-4 overflow-y-auto custom-scrollbar">
        <ul class="space-y-1.5 font-sans text-sm font-medium" x-data="{ openMenu: '{{ request()->routeIs('complaints.*') || request()->routeIs('statistics.*') ? 'reports' : (request()->routeIs('police-stations.*') || request()->routeIs('categories.*') || request()->routeIs('sub-categories.*') ? 'jurisdiction' : '') }}' }">
            <li class="px-2 py-1 text-[10px] font-bold text-slate-500 uppercase tracking-widest">Main</li>
            <li>
                <a href="{{ route('dashboard') }}" class="flex items-center px-3 py-2.5 rounded-lg transition-all duration-200 group {{ request()->routeIs('dashboard') ? 'bg-blue-600 text-white shadow-lg shadow-blue-600/20' : 'text-slate-400 hover:bg-slate-800 hover:text-white' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 {{ request()->routeIs('dashboard') ? 'text-white' : 'text-slate-500 group-hover:text-blue-400' }}" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2 2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                    </svg>
                    Dashboard
                </a>
            </li>

            @if(auth()->user()->hasRole(['super', 'admin', 'superior']))
            <li class="pt-4 px-2 py-1 text-[10px] font-bold text-slate-500 uppercase tracking-widest">Analytics</li>
            <li class="relative">
                <button @click="openMenu = openMenu === 'reports' ? '' : 'reports'" class="w-full flex items-center justify-between px-3 py-2.5 rounded-lg transition-all duration-200 group {{ request()->routeIs('complaints.*') || request()->routeIs('statistics.*') ? 'text-white bg-slate-800/50' : 'text-slate-400 hover:bg-slate-800 hover:text-white' }}">
                    <div class="flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 text-slate-500 group-hover:text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                        <span>Reports Center</span>
                    </div>
                    <svg class="w-4 h-4 transition-transform duration-200" :class="openMenu === 'reports' ? 'rotate-180' : ''" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M19 9l-7 7-7-7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </button>
                <ul x-show="openMenu === 'reports'" x-cloak class="mt-1 ml-4 border-l border-slate-800 space-y-1">
                    <li>
                        <a href="{{ route('complaints.index') }}" class="flex items-center px-4 py-2 rounded-lg transition-all {{ request()->routeIs('complaints.*') ? 'text-blue-400 font-bold' : 'text-slate-500 hover:text-white' }}">
                            <span class="w-1.5 h-1.5 rounded-full mr-3 {{ request()->routeIs('complaints.*') ? 'bg-blue-400' : 'bg-slate-700' }}"></span>
                            All Complaints
                        </a>
                    </li>
                    <li>
                        <a href="{{ route('statistics.index') }}" class="flex items-center px-4 py-2 rounded-lg transition-all {{ request()->routeIs('statistics.*') ? 'text-blue-400 font-bold' : 'text-slate-500 hover:text-white' }}">
                            <span class="w-1.5 h-1.5 rounded-full mr-3 {{ request()->routeIs('statistics.*') ? 'bg-blue-400' : 'bg-slate-700' }}"></span>
                            Data Statistics
                        </a>
                    </li>
                </ul>
            </li>
            @endif

            @if(auth()->user()->hasRole(['super', 'admin']))
            <li class="pt-4 px-2 py-1 text-[10px] font-bold text-slate-500 uppercase tracking-widest">Administration</li>
            <li>
                <a href="{{ route('users.index') }}" class="flex items-center px-3 py-2.5 rounded-lg transition-all duration-200 group {{ request()->routeIs('users.*') ? 'bg-blue-600 text-white shadow-lg shadow-blue-600/20' : 'text-slate-400 hover:bg-slate-800 hover:text-white' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 {{ request()->routeIs('users.*') ? 'text-white' : 'text-slate-500 group-hover:text-blue-400' }}" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z" />
                    </svg>
                    User Management
                </a>
            </li>
            <li class="relative">
                <button @click="openMenu = openMenu === 'jurisdiction' ? '' : 'jurisdiction'" class="w-full flex items-center justify-between px-3 py-2.5 rounded-lg transition-all duration-200 group {{ request()->routeIs('police-stations.*') || request()->routeIs('categories.*') || request()->routeIs('sub-categories.*') ? 'text-white bg-slate-800/50' : 'text-slate-400 hover:bg-slate-800 hover:text-white' }}">
                    <div class="flex items-center">
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 text-slate-500 group-hover:text-blue-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                        </svg>
                        <span>Jurisdiction</span>
                    </div>
                    <svg class="w-4 h-4 transition-transform duration-200" :class="openMenu === 'jurisdiction' ? 'rotate-180' : ''" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path d="M19 9l-7 7-7-7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </button>
                <ul x-show="openMenu === 'jurisdiction'" x-cloak class="mt-1 ml-4 border-l border-slate-800 space-y-1">
                    <li>
                        <a href="{{ route('police-stations.index') }}" class="flex items-center px-4 py-2 rounded-lg transition-all {{ request()->routeIs('police-stations.*') ? 'text-blue-400 font-bold' : 'text-slate-500 hover:text-white' }}">
                            <span class="w-1.5 h-1.5 rounded-full mr-3 {{ request()->routeIs('police-stations.*') ? 'bg-blue-400' : 'bg-slate-700' }}"></span>
                            Police Stations
                        </a>
                    </li>
                    <li>
                        <a href="{{ route('categories.index') }}" class="flex items-center px-4 py-2 rounded-lg transition-all {{ request()->routeIs('categories.*') ? 'text-blue-400 font-bold' : 'text-slate-500 hover:text-white' }}">
                            <span class="w-1.5 h-1.5 rounded-full mr-3 {{ request()->routeIs('categories.*') ? 'bg-blue-400' : 'bg-slate-700' }}"></span>
                            Complaint Categories
                        </a>
                    </li>
                    <li>
                        <a href="{{ route('sub-categories.index') }}" class="flex items-center px-4 py-2 rounded-lg transition-all {{ request()->routeIs('sub-categories.*') ? 'text-blue-400 font-bold' : 'text-slate-500 hover:text-white' }}">
                            <span class="w-1.5 h-1.5 rounded-full mr-3 {{ request()->routeIs('sub-categories.*') ? 'bg-blue-400' : 'bg-slate-700' }}"></span>
                            Sub-Categories
                        </a>
                    </li>
                </ul>
            </li>
            @endif

            <li class="pt-4 px-2 py-1 text-[10px] font-bold text-slate-500 uppercase tracking-widest">Personal</li>
            <li>
                <a href="{{ route('profile.edit') }}" class="flex items-center px-3 py-2.5 rounded-lg transition-all duration-200 group {{ request()->routeIs('profile.edit') ? 'bg-blue-600 text-white shadow-lg shadow-blue-600/20' : 'text-slate-400 hover:bg-slate-800 hover:text-white' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-3 {{ request()->routeIs('profile.edit') ? 'text-white' : 'text-slate-500 group-hover:text-blue-400' }}" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                    </svg>
                    My Profile
                </a>
            </li>
        </ul>
    </nav>
    <div class="p-4 border-t border-slate-800">
        <form method="POST" action="{{ route('logout') }}">
            @csrf
            <button type="submit" class="w-full flex items-center justify-center px-4 py-2.5 bg-red-600/10 text-red-500 rounded-lg hover:bg-red-600 hover:text-white font-bold transition-all duration-200 group">
                <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2 text-red-500 group-hover:text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
                Logout
            </button>
        </form>
    </div>
</div>
