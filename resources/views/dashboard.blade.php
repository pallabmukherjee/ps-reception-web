<x-app-layout>
    <div class="max-w-7xl mx-auto space-y-6">
        <!-- Hero Section -->
        <div class="relative overflow-hidden bg-slate-900 rounded-3xl p-8 md:p-10 shadow-2xl">
            <div class="absolute top-0 right-0 -m-20 w-80 h-80 bg-blue-600 rounded-full blur-3xl opacity-20"></div>
            <div class="absolute bottom-0 left-0 -m-20 w-80 h-80 bg-red-600 rounded-full blur-3xl opacity-10"></div>
            
            <div class="relative z-10 flex flex-col md:flex-row items-center justify-between gap-6">
                <div class="text-center md:text-left">
                    <h1 class="text-4xl md:text-5xl font-black text-white tracking-tighter uppercase italic mb-1">
                        West Bengal <span class="text-blue-500">Police</span>
                    </h1>
                    <p class="text-slate-400 font-medium text-lg uppercase tracking-widest font-mono">Reception Management System</p>
                    
                    <div class="mt-6 flex flex-wrap justify-center md:justify-start gap-3">
                        @if(auth()->user()->hasRole('superior'))
                        <div class="px-4 py-2 bg-blue-600/20 border border-blue-500/30 rounded-full text-blue-400 text-xs font-black tracking-widest uppercase">
                            Assigned: {{ auth()->user()->policeStation->name ?? 'N/A' }}
                        </div>
                        @endif
                        <div class="px-4 py-2 bg-slate-800 border border-slate-700 rounded-full text-slate-400 text-xs font-black tracking-widest uppercase">
                            Role: {{ auth()->user()->getRoleNames()->first() ?? 'User' }}
                        </div>
                    </div>
                </div>
                
                <div class="flex flex-col sm:flex-row gap-4">
                    <div class="bg-white/5 backdrop-blur-sm border border-white/10 p-5 rounded-2xl text-center min-w-[160px]">
                        <div class="text-[10px] font-black text-blue-400 uppercase tracking-widest mb-1">Total Records</div>
                        <div class="text-4xl font-black text-white">{{ $totalEntries }}</div>
                    </div>
                    <div class="bg-white/5 backdrop-blur-sm border border-white/10 p-5 rounded-2xl text-center min-w-[160px]">
                        <div class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Total Pending</div>
                        <div class="text-4xl font-black text-white">{{ $totalPending }}</div>
                    </div>
                    <div class="bg-rose-500/10 backdrop-blur-sm border border-rose-500/20 p-5 rounded-2xl text-center min-w-[160px]">
                        <div class="text-[10px] font-black text-rose-400 uppercase tracking-widest mb-1">Critical Overdue</div>
                        <div class="text-4xl font-black text-rose-500">{{ $totalOverdueSensitive }}</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Section Title -->
        <div class="flex items-center gap-4 px-2">
            <div class="h-px flex-1 bg-slate-200"></div>
            <h2 class="text-[10px] font-black text-slate-400 uppercase tracking-[0.3em]">Station-wise Distribution</h2>
            <div class="h-px flex-1 bg-slate-200"></div>
        </div>

        <!-- Stats Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            @php
                $colors = [
                    ['bg' => 'bg-blue-50', 'border' => 'border-blue-100', 'text' => 'text-blue-600', 'icon_bg' => 'bg-blue-100/50'],
                    ['bg' => 'bg-emerald-50', 'border' => 'border-emerald-100', 'text' => 'text-emerald-600', 'icon_bg' => 'bg-emerald-100/50'],
                    ['bg' => 'bg-amber-50', 'border' => 'border-amber-100', 'text' => 'text-amber-600', 'icon_bg' => 'bg-amber-100/50'],
                    ['bg' => 'bg-rose-50', 'border' => 'border-rose-100', 'text' => 'text-rose-600', 'icon_bg' => 'bg-rose-100/50'],
                    ['bg' => 'bg-indigo-50', 'border' => 'border-indigo-100', 'text' => 'text-indigo-600', 'icon_bg' => 'bg-indigo-100/50'],
                    ['bg' => 'bg-violet-50', 'border' => 'border-violet-100', 'text' => 'text-violet-600', 'icon_bg' => 'bg-violet-100/50'],
                    ['bg' => 'bg-cyan-50', 'border' => 'border-cyan-100', 'text' => 'text-cyan-600', 'icon_bg' => 'bg-cyan-100/50'],
                ];
            @endphp
            @forelse($policeStations as $index => $station)
                @php
                    $stationStats = $stats[$station->id] ?? (object)['total' => 0, 'resolved' => 0, 'pending' => 0, 'overdue_sensitive' => 0];
                    $isAssigned = auth()->user()->hasRole('superior') && auth()->user()->police_station_id == $station->id;
                    $color = $colors[$index % count($colors)];
                @endphp
                <a href="{{ route('complaints.index', ['police_station_id' => $station->id]) }}" class="{{ $color['bg'] }} group p-5 rounded-2xl shadow-sm border {{ $isAssigned ? 'border-blue-500 ring-4 ring-blue-500/10' : $color['border'] . ' hover:border-slate-300' }} transition-all duration-300 hover:shadow-lg block">
                    <div class="flex justify-between items-start mb-4">
                        <div class="p-2 {{ $color['icon_bg'] }} rounded-lg group-hover:bg-white transition-colors">
                            <svg class="w-5 h-5 {{ $color['text'] }}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                            </svg>
                        </div>
                        @if($isAssigned)
                        <span class="text-[8px] font-black bg-blue-600 text-white px-2 py-0.5 rounded-full uppercase tracking-tighter shadow-lg shadow-blue-600/20">My Station</span>
                        @endif
                    </div>

                    <h3 class="text-lg font-black text-slate-800 mb-4 tracking-tight leading-tight">{{ $station->name }}</h3>
                    
                    <div class="grid grid-cols-2 gap-3 mb-4">
                        <div class="bg-white/60 rounded-xl p-2 border border-black/5">
                            <div class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-0.5">Total / Done</div>
                            <div class="text-lg font-black text-slate-900">
                                {{ $stationStats->total }} / <span class="text-emerald-600">{{ $stationStats->resolved }}</span>
                            </div>
                        </div>
                        <div class="bg-white/60 rounded-xl p-2 border border-black/5">
                            <div class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-0.5">Pending</div>
                            <div class="text-lg font-black text-slate-700">{{ $stationStats->pending }}</div>
                        </div>
                    </div>

                    @if($stationStats->overdue_sensitive > 0)
                        <div class="bg-rose-100/80 border border-rose-200 rounded-xl p-2.5 flex items-center justify-between">
                            <div class="flex items-center">
                                <div class="w-2 h-2 rounded-full bg-rose-600 animate-pulse mr-2"></div>
                                <span class="text-[10px] font-black text-rose-700 uppercase tracking-tight">Sensitive Overdue</span>
                            </div>
                            <span class="text-sm font-black text-rose-800">{{ $stationStats->overdue_sensitive }}</span>
                        </div>
                    @else
                        <div class="bg-slate-100/50 border border-slate-200/50 rounded-xl p-2.5 flex items-center justify-center">
                            <span class="text-[9px] font-bold text-slate-400 uppercase tracking-widest">No Critical Overdue</span>
                        </div>
                    @endif
                </a>            @empty
                <div class="col-span-full p-8 text-center bg-white rounded-3xl border-2 border-dashed border-slate-200">
                    <svg class="w-10 h-12 text-slate-200 mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4" />
                    </svg>
                    <p class="text-slate-400 text-xs font-black uppercase tracking-widest">No jurisdiction data available</p>
                </div>
            @endforelse
        </div>
    </div>
</x-app-layout>
