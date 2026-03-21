<x-app-layout>
    <div class="max-w-7xl mt-6 mx-auto p-6 bg-white drop-shadow-lg rounded-lg font-sans">
        <h2 class="text-2xl font-bold text-center mb-4 text-gray-800 font-mono">Add New Police Station</h2>
        
        @if(session('success'))
            <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded text-center">
                {{ session('success') }}
            </div>
        @endif

        <form action="{{ route('police-stations.store') }}" method="POST">
            @csrf
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 font-mono" for="name">
                    Police Station Name
                </label>
                <input
                    type="text"
                    id="name"
                    name="name"
                    value="{{ old('name') }}"
                    required
                    class="mt-1 p-2 w-full border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 font-mono"
                    placeholder="Enter station name"
                />
                @error('name')
                    <p class="text-red-500 text-xs mt-1">{{ $message }}</p>
                @enderror
            </div>

            <div class="flex justify-center">
                <button
                    type="submit"
                    class="px-6 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-700 transition-colors font-mono font-bold"
                >
                    Add Police Station
                </button>
            </div>
        </form>
    </div>

    <div class="max-w-7xl mt-8 mx-auto p-6 bg-white drop-shadow-lg rounded-lg font-sans overflow-x-auto">
        <h2 class="text-2xl font-bold text-center mb-6 text-gray-800 font-mono">Police Stations List</h2>
        
        <table class="w-full text-left border-collapse font-mono">
            <thead>
                <tr class="bg-gray-100 border-b-2 border-gray-300">
                    <th class="p-3 text-sm font-bold text-gray-700">Station Name</th>
                    <th class="p-3 text-sm font-bold text-gray-700">Notification ID</th>
                    <th class="p-3 text-sm font-bold text-gray-700">Created At</th>
                    <th class="p-3 text-sm font-bold text-gray-700 text-center">Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($policeStations as $station)
                    <tr class="border-b border-gray-200 hover:bg-gray-50 transition-colors">
                        <td class="p-3 text-sm text-gray-800">{{ $station->name }}</td>
                        <td class="p-3 text-sm text-gray-600">{{ $station->notification_id }}</td>
                        <td class="p-3 text-sm text-gray-600">{{ $station->created_at->format('M d, Y') }}</td>
                        <td class="p-3 text-sm flex justify-center space-x-2">
                            <!-- Edit Action -->
                            <button onclick="openEditModal({{ $station->id }}, '{{ addslashes($station->name) }}')" class="px-3 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600 transition-colors font-bold">
                                Edit
                            </button>
                            
                            <!-- Delete Action -->
                            <form action="{{ route('police-stations.destroy', $station) }}" method="POST" onsubmit="return confirm('Are you sure you want to delete this station?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700 transition-colors font-bold">
                                    Delete
                                </button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="p-6 text-center text-gray-500 italic">No police stations added yet.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Edit Modal -->
    <div id="editModal" class="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center hidden">
        <div class="bg-white p-6 rounded-lg shadow-xl w-full max-w-md">
            <h3 class="text-xl font-bold mb-4 font-mono">Edit Police Station</h3>
            <form id="editForm" method="POST">
                @csrf
                @method('PATCH')
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono" for="edit_name">
                        Police Station Name
                    </label>
                    <input
                        type="text"
                        id="edit_name"
                        name="name"
                        required
                        class="mt-1 p-2 w-full border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 font-mono"
                    />
                </div>
                <div class="flex justify-end space-x-3">
                    <button type="button" onclick="closeEditModal()" class="px-4 py-2 bg-gray-300 text-gray-700 rounded hover:bg-gray-400 transition-colors font-mono font-bold">
                        Cancel
                    </button>
                    <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors font-mono font-bold">
                        Update
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openEditModal(id, name) {
            document.getElementById('edit_name').value = name;
            document.getElementById('editForm').action = `/police-stations/${id}`;
            document.getElementById('editModal').classList.remove('hidden');
        }

        function closeEditModal() {
            document.getElementById('editModal').classList.add('hidden');
        }
    </script>
</x-app-layout>
