<x-app-layout>
    <div class="max-w-4xl mx-auto p-6 bg-white drop-shadow-lg rounded-lg mt-6 font-sans">
        <h2 class="text-2xl font-bold mb-4 font-mono">Complaint Statistics</h2>
        
        <form action="{{ route('statistics.index') }}" method="GET" class="mb-6">
            <div class="mb-4">
                <label for="police_station_id" class="block text-sm font-medium text-gray-700 font-mono">
                    Select Police Station
                </label>
                <select
                    id="police_station_id"
                    name="police_station_id"
                    onchange="this.form.submit()"
                    class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md font-mono shadow-sm"
                >
                    <option value="">--Select a station--</option>
                    @foreach($policeStations as $station)
                        <option value="{{ $station->id }}" {{ ($selectedStation && $selectedStation->id == $station->id) ? 'selected' : '' }}>
                            {{ $station->name }}
                        </option>
                    @endforeach
                </select>
            </div>
            <button
                type="submit"
                class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 font-mono font-bold"
            >
                Get Statistics
            </button>
        </form>

        @if($complaintStats && $complaints->count() > 0)
            <div class="mt-8 pt-6 border-t border-gray-100">
                <h3 class="text-xl font-bold mb-2 font-mono text-gray-800">
                    Statistics for {{ $selectedStation->name }}
                </h3>
                <p class="mb-6 font-mono text-gray-600">Total Complaints: <span class="text-blue-600 font-bold">{{ $complaints->count() }}</span></p>
                
                <div class="space-y-6">
                    @foreach($complaintStats as $type => $count)
                        @php
                            $percentage = ($count / $complaints->count()) * 100;
                        @endphp
                        <div class="mb-2 font-mono">
                            <div class="flex justify-between mb-1">
                                <span class="text-base font-medium text-gray-700">{{ $type }}</span>
                                <span class="text-sm font-medium text-gray-700">
                                    {{ $count }} / {{ $complaints->count() }} ({{ number_format($percentage, 2) }}%)
                                </span>
                            </div>
                            <div class="w-full bg-gray-200 rounded-full h-3">
                                <div
                                    class="bg-blue-600 h-3 rounded-full transition-all duration-500"
                                    style="width: {{ $percentage }}%"
                                ></div>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
        @elseif($selectedStation)
            <div class="mt-8 p-6 text-center bg-gray-50 rounded-lg border-2 border-dashed border-gray-200 font-mono">
                <p class="text-gray-500">No complaints found for {{ $selectedStation->name }}.</p>
            </div>
        @endif
    </div>
</x-app-layout>
