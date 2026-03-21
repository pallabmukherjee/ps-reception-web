<x-app-layout>
    <div class="container mx-auto px-4 font-sans antialiased">
        <h1 class="text-4xl font-bold text-center my-8 text-gray-800">Krishnanagar Police District</h1>

        <div class="flex justify-center mb-8">
            <div class="bg-white shadow-lg rounded-lg p-6 w-full md:w-1/2 lg:w-1/3 text-center border-t-4 border-blue-600">
                <h2 class="text-2xl font-bold mb-2 text-gray-700">Total Complaints</h2>
                <p class="text-5xl font-bold text-blue-600">{{ $totalEntries }}</p>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            @forelse($policeStations as $station)
                <div class="bg-white shadow-lg rounded-lg p-6 text-center hover:shadow-xl transition-shadow duration-300">
                    <h3 class="text-xl font-bold mb-2 text-gray-800">{{ $station->name }}</h3>
                    <p class="text-sm text-gray-600">Total Complaints</p>
                    <p class="text-3xl font-bold text-gray-800">{{ $stationCounts[$station->id] ?? 0 }}</p>
                </div>
            @empty
                <div class="col-span-full text-center p-12 bg-white rounded-lg shadow">
                    <p class="text-gray-500 italic">No police stations found. Please add them in the administration panel.</p>
                </div>
            @endforelse
        </div>
    </div>
</x-app-layout>
