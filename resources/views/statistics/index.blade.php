<x-app-layout>
    <div class="max-w-7xl mx-auto space-y-6">
        <!-- Header Section -->
        <div>
            <h1 class="text-2xl font-black text-slate-800 tracking-tight uppercase italic">
                Analytical <span class="text-blue-600">Statistics</span>
            </h1>
            <p class="text-sm text-slate-500 font-medium">Visual representation of complaint distribution and data metrics.</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
            <!-- Filter Sidebar -->
            <div class="lg:col-span-4 space-y-6">
                <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
                    <form action="{{ route('statistics.index') }}" method="GET" class="space-y-4">
                        <div>
                            <label for="police_station_id" class="block text-xs font-bold text-slate-500 uppercase tracking-widest mb-2">
                                Data Scope
                            </label>
                            @if(auth()->user()->hasRole('superior'))
                                <div class="relative">
                                    <select disabled class="block w-full rounded-xl border-slate-200 bg-slate-100 text-slate-500 text-sm font-bold shadow-sm cursor-not-allowed">
                                        <option>{{ auth()->user()->policeStation->name ?? 'Assigned Station' }}</option>
                                    </select>
                                    <input type="hidden" name="police_station_id" value="{{ auth()->user()->police_station_id }}">
                                </div>
                                <p class="mt-2 text-[10px] text-slate-400 font-bold uppercase tracking-tight">Access restricted to your assigned station.</p>
                            @else
                                <select
                                    id="police_station_id"
                                    name="police_station_id"
                                    onchange="this.form.submit()"
                                    class="block w-full rounded-xl border-slate-200 text-slate-700 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all"
                                >
                                    <option value="">-- Global District View --</option>
                                    @foreach($policeStations as $station)
                                        <option value="{{ $station->id }}" {{ ($selectedStation && $selectedStation->id == $station->id) ? 'selected' : '' }}>
                                            {{ $station->name }}
                                        </option>
                                    @endforeach
                                </select>
                            @endif
                        </div>
                        <button
                            type="submit"
                            class="w-full flex justify-center py-2.5 px-4 border border-transparent text-xs font-black rounded-xl text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all uppercase tracking-widest shadow-lg shadow-blue-600/20"
                        >
                            Refresh Metrics
                        </button>
                    </form>
                </div>

                @if($selectedStation && $complaints->count() > 0)
                <div class="bg-blue-600 rounded-2xl p-6 text-white shadow-xl shadow-blue-600/20">
                    <div class="text-[10px] font-black uppercase tracking-widest opacity-70 mb-1">Total Dataset</div>
                    <div class="text-4xl font-black mb-4">{{ $complaints->count() }}</div>
                    <div class="text-sm font-medium opacity-90 italic">Complaints registered for {{ $selectedStation->name }} to date.</div>
                </div>
                @endif
            </div>

            <!-- Content Area -->
            <div class="lg:col-span-8">
                @if($complaintStats && $complaints->count() > 0)
                    <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                        <div class="p-6 border-b border-slate-100 flex items-center justify-between">
                            <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest">
                                Category Distribution
                            </h3>
                            <span class="text-[10px] font-black bg-slate-100 px-2 py-1 rounded text-slate-500 uppercase tracking-tighter">
                                {{ $selectedStation->name }}
                            </span>
                        </div>
                        
                        <div class="p-6 space-y-8">
                            @foreach($complaintStats as $type => $count)
                                @php
                                    $percentage = ($count / $complaints->count()) * 100;
                                    $colorClass = $loop->index % 2 == 0 ? 'bg-blue-600' : 'bg-red-500';
                                    $bgClass = $loop->index % 2 == 0 ? 'bg-blue-50' : 'bg-red-50';
                                @endphp
                                <div class="group">
                                    <div class="flex justify-between items-end mb-2">
                                        <div>
                                            <span class="text-sm font-bold text-slate-900 group-hover:text-blue-600 transition-colors">{{ $type }}</span>
                                            <div class="text-[10px] text-slate-400 font-bold uppercase tracking-widest">Type Breakdown</div>
                                        </div>
                                        <div class="text-right">
                                            <span class="text-sm font-black text-slate-900">
                                                {{ $count }}
                                            </span>
                                            <span class="text-[10px] text-slate-500 font-bold ml-1">
                                                ({{ number_format($percentage, 1) }}%)
                                            </span>
                                        </div>
                                    </div>
                                    <div class="w-full {{ $bgClass }} rounded-full h-3 overflow-hidden border border-slate-100">
                                        <div
                                            class="{{ $colorClass }} h-full rounded-full transition-all duration-1000 ease-out shadow-sm"
                                            style="width: 0%"
                                            data-width="{{ $percentage }}%"
                                        ></div>
                                    </div>
                                </div>
                            @endforeach
                        </div>
                    </div>
                    
                    <script>
                        document.addEventListener('DOMContentLoaded', () => {
                            setTimeout(() => {
                                document.querySelectorAll('[data-width]').forEach(el => {
                                    el.style.width = el.getAttribute('data-width');
                                });
                            }, 300);
                        });
                    </script>
                @elseif($selectedStation)
                    <div class="bg-white p-12 text-center rounded-2xl border-2 border-dashed border-slate-200">
                        <div class="flex flex-col items-center">
                            <svg class="w-16 h-16 text-slate-200 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                            </svg>
                            <h4 class="text-slate-500 text-sm font-black uppercase tracking-widest">No data collected</h4>
                            <p class="text-slate-400 text-xs mt-1 font-medium italic">There are no registered complaints for this station yet.</p>
                        </div>
                    </div>
                @else
                    <div class="bg-white p-12 text-center rounded-2xl border border-slate-200">
                        <div class="flex flex-col items-center">
                            <div class="w-16 h-16 bg-blue-50 text-blue-600 rounded-full flex items-center justify-center mb-4">
                                <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                            </div>
                            <h4 class="text-slate-800 text-sm font-black uppercase tracking-widest">Selection Required</h4>
                            <p class="text-slate-500 text-xs mt-1 font-medium">Please select a police station from the sidebar to view localized analytical data.</p>
                        </div>
                    </div>
                @endif
            </div>
        </div>
    </div>
</x-app-layout>
