<div id="sidebar" class="bg-gray-800 text-white flex flex-col w-64 transition-all duration-300 ease-in-out overflow-hidden h-screen fixed left-0 top-0 z-50">
    <div class="p-4 text-2xl font-bold border-b border-gray-700">KPD Reception</div>
    <nav class="flex-1 p-4 overflow-y-auto">
        <ul class="space-y-2 font-mono text-sm">
            <li>
                <a href="{{ route('dashboard') }}" class="flex items-center p-2 rounded transition-all duration-200 ease-in-out hover:bg-gray-700 hover:bg-opacity-50 {{ request()->routeIs('dashboard') ? 'bg-gray-700 bg-opacity-70 shadow-inner' : '' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2 2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
                    </svg>
                    Home
                </a>
            </li>

            @hasrole('super')
            <li>
                <a href="{{ route('users.index') }}" class="flex items-center p-2 rounded transition-all duration-200 ease-in-out hover:bg-gray-700 hover:bg-opacity-50 {{ request()->routeIs('users.*') ? 'bg-gray-700 bg-opacity-70 shadow-inner' : '' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H2v-2a4 4 0 014-4h12.356" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 12v-1a4 4 0 014-4h2a4 4 0 014 4v1" />
                    </svg>
                    Users
                </a>
            </li>
            <li>
                <a href="{{ route('police-stations.index') }}" class="flex items-center p-2 rounded transition-all duration-200 ease-in-out hover:bg-gray-700 hover:bg-opacity-50 {{ request()->routeIs('police-stations.*') ? 'bg-gray-700 bg-opacity-70 shadow-inner' : '' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    Police Stations
                </a>
            </li>
            <li>
                <a href="{{ route('categories.index') }}" class="flex items-center p-2 rounded transition-all duration-200 ease-in-out hover:bg-gray-700 hover:bg-opacity-50 {{ request()->routeIs('categories.*') ? 'bg-gray-700 bg-opacity-70 shadow-inner' : '' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    Alert Types
                </a>
            </li>
            <li>
                <a href="{{ route('sub-categories.index') }}" class="flex items-center p-2 rounded transition-all duration-200 ease-in-out hover:bg-gray-700 hover:bg-opacity-50 {{ request()->routeIs('sub-categories.*') ? 'bg-gray-700 bg-opacity-70 shadow-inner' : '' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    Complain Categories
                </a>
            </li>
            <li>
                <a href="{{ route('complaints.index') }}" class="flex items-center p-2 rounded transition-all duration-200 ease-in-out hover:bg-gray-700 hover:bg-opacity-50 {{ request()->routeIs('complaints.*') ? 'bg-gray-700 bg-opacity-70 shadow-inner' : '' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
                    </svg>
                    Complains
                </a>
            </li>
            <li>
                <a href="{{ route('statistics.index') }}" class="flex items-center p-2 rounded transition-all duration-200 ease-in-out hover:bg-gray-700 hover:bg-opacity-50 {{ request()->routeIs('statistics.*') ? 'bg-gray-700 bg-opacity-70 shadow-inner' : '' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z" />
                    </svg>
                    Statistics
                </a>
            </li>
            @endhasrole

            <li>
                <a href="{{ route('profile.edit') }}" class="flex items-center p-2 rounded transition-all duration-200 ease-in-out hover:bg-gray-700 hover:bg-opacity-50 {{ request()->routeIs('profile.edit') ? 'bg-gray-700 bg-opacity-70 shadow-inner' : '' }}">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    Profile Management
                </a>
            </li>
        </ul>
    </nav>
    <div class="p-4 border-t border-gray-700 text-sm font-mono">
        <form method="POST" action="{{ route('logout') }}">
            @csrf
            <button type="submit" class="w-full p-2 bg-red-600 rounded hover:bg-red-700 text-white font-bold transition-all duration-200">
                Logout
            </button>
        </form>
    </div>
</div>
