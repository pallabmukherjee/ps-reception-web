<x-app-layout>
    <div class="max-w-7xl mt-6 mx-auto p-6 bg-white drop-shadow-lg rounded-lg font-sans">
        <h2 class="text-2xl font-bold text-center mb-4 text-gray-800 font-mono">Add New Alert Category</h2>
        
        @if(session('success'))
            <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded text-center">
                {{ session('success') }}
            </div>
        @endif

        <form action="{{ route('categories.store') }}" method="POST">
            @csrf
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 font-mono" for="name">
                    Category Name
                </label>
                <input
                    type="text"
                    id="name"
                    name="name"
                    value="{{ old('name') }}"
                    required
                    class="mt-1 p-2 w-full border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 font-mono"
                    placeholder="Enter category name"
                />
            </div>

            <div class="mb-4 flex items-center">
                <input
                    type="checkbox"
                    id="notification_enabled"
                    name="notification_enabled"
                    {{ old('notification_enabled') ? 'checked' : '' }}
                    class="h-4 w-4 text-blue-500 border-gray-300 rounded"
                    onchange="togglePriority(this)"
                />
                <label class="ml-2 text-sm font-medium text-gray-700 font-mono" for="notification_enabled">
                    Enable Notifications
                </label>
            </div>

            <div id="priority_container" class="mb-4 {{ old('notification_enabled') ? '' : 'hidden' }}">
                <label class="block text-sm font-medium text-gray-700 font-mono" for="priority">
                    Notification Priority
                </label>
                <select
                    id="priority"
                    name="priority"
                    class="mt-1 p-2 w-full border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 font-mono"
                >
                    <option value="none">Select Priority</option>
                    <option value="High Priority" {{ old('priority') == 'High Priority' ? 'selected' : '' }}>High Priority</option>
                    <option value="Medium Priority" {{ old('priority') == 'Medium Priority' ? 'selected' : '' }}>Medium Priority</option>
                    <option value="Low Priority" {{ old('priority') == 'Low Priority' ? 'selected' : '' }}>Low Priority</option>
                </select>
            </div>

            <div class="flex justify-center">
                <button
                    type="submit"
                    class="px-6 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-700 transition-colors font-mono font-bold"
                >
                    Add Category
                </button>
            </div>
        </form>
    </div>

    <div class="max-w-7xl mt-8 mx-auto p-6 bg-white drop-shadow-lg rounded-lg font-sans overflow-x-auto">
        <h2 class="text-2xl font-bold text-center mb-6 text-gray-800 font-mono">Categories List</h2>
        
        <table class="w-full text-left border-collapse font-mono">
            <thead>
                <tr class="bg-gray-100 border-b-2 border-gray-300">
                    <th class="p-3 text-sm font-bold text-gray-700">Category Name</th>
                    <th class="p-3 text-sm font-bold text-gray-700">Notifications</th>
                    <th class="p-3 text-sm font-bold text-gray-700">Priority</th>
                    <th class="p-3 text-sm font-bold text-gray-700">Status</th>
                    <th class="p-3 text-sm font-bold text-gray-700 text-center">Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($categories as $category)
                    <tr class="border-b border-gray-200 hover:bg-gray-50 transition-colors">
                        <td class="p-3 text-sm text-gray-800">{{ $category->name }}</td>
                        <td class="p-3 text-sm">
                            @if($category->notification_enabled)
                                <span class="px-2 py-1 bg-green-100 text-green-800 rounded-full text-xs font-bold">Enabled</span>
                            @else
                                <span class="px-2 py-1 bg-gray-100 text-gray-800 rounded-full text-xs font-bold">Disabled</span>
                            @endif
                        </td>
                        <td class="p-3 text-sm text-gray-600">{{ $category->priority }}</td>
                        <td class="p-3 text-sm">
                            @if($category->is_disabled)
                                <span class="px-2 py-1 rounded-full text-xs font-bold bg-red-100 text-red-800">Disabled</span>
                            @else
                                <span class="px-2 py-1 rounded-full text-xs font-bold bg-green-100 text-green-800">Enabled</span>
                            @endif
                        </td>
                        <td class="p-3 text-sm flex justify-center space-x-2">
                            <button onclick="openEditModal({{ json_encode($category) }})" class="px-3 py-1 bg-yellow-500 text-white rounded hover:bg-yellow-600 font-bold">
                                Edit
                            </button>
                            <form action="{{ route('categories.destroy', $category) }}" method="POST" onsubmit="return confirm('Are you sure?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700 font-bold">
                                    Delete
                                </button>
                            </form>
                            <form action="{{ route('categories.toggle', $category) }}" method="POST">
                                @csrf
                                @method('PATCH')
                                <button type="submit" class="px-3 py-1 {{ $category->is_disabled ? 'bg-green-600' : 'bg-yellow-500' }} text-white rounded font-bold">
                                    {{ $category->is_disabled ? 'Enable' : 'Disable' }}
                                </button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="p-6 text-center text-gray-500 italic">No categories added yet.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Edit Modal -->
    <div id="editModal" class="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center hidden">
        <div class="bg-white p-6 rounded-lg shadow-xl w-full max-w-md">
            <h3 class="text-xl font-bold mb-4 font-mono">Edit Category</h3>
            <form id="editForm" method="POST">
                @csrf
                @method('PATCH')
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono" for="edit_name">
                        Category Name
                    </label>
                    <input type="text" id="edit_name" name="name" required class="mt-1 p-2 w-full border border-gray-300 rounded-md font-mono" />
                </div>
                <div class="mb-4 flex items-center">
                    <input type="checkbox" id="edit_notification_enabled" name="notification_enabled" class="h-4 w-4 text-blue-500 border-gray-300 rounded" onchange="togglePriority(this, 'edit_priority_container')" />
                    <label class="ml-2 text-sm font-medium text-gray-700 font-mono" for="edit_notification_enabled">Enable Notifications</label>
                </div>
                <div id="edit_priority_container" class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono" for="edit_priority">Priority</label>
                    <select id="edit_priority" name="priority" class="mt-1 p-2 w-full border border-gray-300 rounded-md font-mono">
                        <option value="none">Select Priority</option>
                        <option value="High Priority">High Priority</option>
                        <option value="Medium Priority">Medium Priority</option>
                        <option value="Low Priority">Low Priority</option>
                    </select>
                </div>
                <div class="flex justify-end space-x-3">
                    <button type="button" onclick="closeEditModal()" class="px-4 py-2 bg-gray-300 text-gray-700 rounded font-mono font-bold">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded font-mono font-bold">Update</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function togglePriority(checkbox, containerId = 'priority_container') {
            const container = document.getElementById(containerId);
            if (checkbox.checked) {
                container.classList.remove('hidden');
            } else {
                container.classList.add('hidden');
            }
        }

        function openEditModal(category) {
            document.getElementById('edit_name').value = category.name;
            document.getElementById('edit_notification_enabled').checked = category.notification_enabled;
            document.getElementById('edit_priority').value = category.priority;
            
            togglePriority(document.getElementById('edit_notification_enabled'), 'edit_priority_container');
            
            document.getElementById('editForm').action = `/categories/${category.id}`;
            document.getElementById('editModal').classList.remove('hidden');
        }

        function closeEditModal() {
            document.getElementById('editModal').classList.add('hidden');
        }
    </script>
</x-app-layout>
