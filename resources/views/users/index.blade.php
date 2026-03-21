<x-app-layout>
    <div class="max-w-7xl mt-6 mx-auto p-6 bg-white drop-shadow-lg rounded-lg font-sans">
        <h2 class="text-2xl font-bold text-center mb-4 text-gray-800 font-mono">Create New User</h2>
        
        @if(session('success'))
            <div class="mb-4 p-4 bg-green-100 text-green-700 rounded text-center">{{ session('success') }}</div>
        @endif
        @if(session('error'))
            <div class="mb-4 p-4 bg-red-100 text-red-700 rounded text-center">{{ session('error') }}</div>
        @endif

        <form action="{{ route('users.store') }}" method="POST">
            @csrf
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono">Full Name</label>
                    <input type="text" name="name" required class="mt-1 p-2 w-full border rounded-md font-mono" placeholder="Enter name" />
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono">Email</label>
                    <input type="email" name="email" required class="mt-1 p-2 w-full border rounded-md font-mono" placeholder="Enter email" />
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono">Password</label>
                    <input type="password" name="password" required class="mt-1 p-2 w-full border rounded-md font-mono" placeholder="Min 8 characters" />
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono">Role</label>
                    <select name="role" required class="mt-1 p-2 w-full border rounded-md font-mono">
                        <option value="">Select Role</option>
                        @foreach($roles as $role)
                            <option value="{{ $role->name }}">{{ ucfirst($role->name) }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono">Police Station (Optional)</label>
                    <select name="police_station_id" class="mt-1 p-2 w-full border rounded-md font-mono">
                        <option value="">None</option>
                        @foreach($policeStations as $station)
                            <option value="{{ $station->id }}">{{ $station->name }}</option>
                        @endforeach
                    </select>
                </div>
            </div>

            <div class="flex justify-center mt-4">
                <button type="submit" class="px-6 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-700 font-mono font-bold">
                    Create User
                </button>
            </div>
        </form>
    </div>

    <div class="max-w-7xl mt-8 mx-auto p-6 bg-white drop-shadow-lg rounded-lg font-sans overflow-x-auto">
        <h2 class="text-2xl font-bold text-center mb-6 text-gray-800 font-mono">System Users</h2>
        <table class="w-full text-left border-collapse font-mono">
            <thead>
                <tr class="bg-gray-100 border-b-2 border-gray-300">
                    <th class="p-3 text-sm font-bold text-gray-700">Name</th>
                    <th class="p-3 text-sm font-bold text-gray-700">Email</th>
                    <th class="p-3 text-sm font-bold text-gray-700">Role</th>
                    <th class="p-3 text-sm font-bold text-gray-700">Station</th>
                    <th class="p-3 text-sm font-bold text-gray-700 text-center">Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach($users as $user)
                    <tr class="border-b hover:bg-gray-50">
                        <td class="p-3 text-sm text-gray-800">{{ $user->name }}</td>
                        <td class="p-3 text-sm text-gray-600">{{ $user->email }}</td>
                        <td class="p-3 text-sm capitalize">
                            <span class="px-2 py-1 rounded-full text-xs font-bold {{ $user->hasRole('super') ? 'bg-red-100 text-red-800' : 'bg-blue-100 text-blue-800' }}">
                                {{ $user->roles->pluck('name')->first() }}
                            </span>
                        </td>
                        <td class="p-3 text-sm text-gray-600">{{ $user->policeStation->name ?? 'N/A' }}</td>
                        <td class="p-3 text-sm flex justify-center space-x-2">
                            <button onclick="openEditModal({{ json_encode($user->load('roles')) }})" class="px-3 py-1 bg-yellow-500 text-white rounded font-bold">Edit</button>
                            <form action="{{ route('users.destroy', $user) }}" method="POST" onsubmit="return confirm('Are you sure?')">
                                @csrf @method('DELETE')
                                <button type="submit" class="px-3 py-1 bg-red-600 text-white rounded font-bold">Delete</button>
                            </form>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <!-- Edit Modal (Simplified for brevity, similar structure to previous ones) -->
    <div id="editModal" class="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center hidden">
        <div class="bg-white p-6 rounded-lg shadow-xl w-full max-w-md max-h-[90vh] overflow-y-auto">
            <h3 class="text-xl font-bold mb-4 font-mono">Edit User</h3>
            <form id="editForm" method="POST">
                @csrf @method('PATCH')
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono">Full Name</label>
                    <input type="text" id="edit_name" name="name" required class="mt-1 p-2 w-full border rounded-md font-mono" />
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono">Email</label>
                    <input type="email" id="edit_email" name="email" required class="mt-1 p-2 w-full border rounded-md font-mono" />
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono">New Password (Optional)</label>
                    <input type="password" name="password" class="mt-1 p-2 w-full border rounded-md font-mono" />
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono">Role</label>
                    <select id="edit_role" name="role" required class="mt-1 p-2 w-full border rounded-md font-mono">
                        @foreach($roles as $role)
                            <option value="{{ $role->name }}">{{ ucfirst($role->name) }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono">Police Station</label>
                    <select id="edit_police_station" name="police_station_id" class="mt-1 p-2 w-full border rounded-md font-mono">
                        <option value="">None</option>
                        @foreach($policeStations as $station)
                            <option value="{{ $station->id }}">{{ $station->name }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="flex justify-end space-x-3">
                    <button type="button" onclick="closeEditModal()" class="px-4 py-2 bg-gray-300 rounded font-bold font-mono">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded font-bold font-mono">Update</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openEditModal(user) {
            document.getElementById('edit_name').value = user.name;
            document.getElementById('edit_email').value = user.email;
            document.getElementById('edit_role').value = user.roles[0].name;
            document.getElementById('edit_police_station').value = user.police_station_id || '';
            document.getElementById('editForm').action = `/users/${user.id}`;
            document.getElementById('editModal').classList.remove('hidden');
        }
        function closeEditModal() { document.getElementById('editModal').classList.add('hidden'); }
    </script>
</x-app-layout>
