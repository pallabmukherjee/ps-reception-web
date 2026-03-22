<x-app-layout>
    <div class="max-w-7xl mt-6 mx-auto p-6 bg-white drop-shadow-lg rounded-lg font-sans">
        <h2 class="text-2xl font-bold text-center mb-4 text-gray-800 font-mono">Add New Sub-Category</h2>
        
        @if(session('success'))
            <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded text-center">
                {{ session('success') }}
            </div>
        @endif

        <form action="{{ route('sub-categories.store') }}" method="POST">
            @csrf
            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 font-mono" for="name">
                    Sub-Category Name
                </label>
                <input
                    type="text"
                    id="name"
                    name="name"
                    value="{{ old('name') }}"
                    required
                    class="mt-1 p-2 w-full border border-gray-300 rounded-md font-mono"
                    placeholder="Enter sub-category name"
                />
            </div>

            <div class="mb-4">
                <label class="block text-sm font-medium text-gray-700 font-mono" for="category_id">
                    Select Main Category
                </label>
                <select
                    id="category_id"
                    name="category_id"
                    required
                    class="mt-1 p-2 w-full border border-gray-300 rounded-md font-mono"
                >
                    <option value="">Choose a category</option>
                    @foreach($categories as $category)
                        <option value="{{ $category->id }}" {{ old('category_id') == $category->id ? 'selected' : '' }}>
                            {{ $category->name }}
                        </option>
                    @endforeach
                </select>
            </div>

            <div class="flex justify-center">
                <button
                    type="submit"
                    class="px-6 py-2 bg-blue-500 text-white rounded-md hover:bg-blue-700 transition-colors font-mono font-bold"
                >
                    Add Sub-Category
                </button>
            </div>
        </form>
    </div>

    <div class="max-w-7xl mt-8 mx-auto p-6 bg-white drop-shadow-lg rounded-lg font-sans overflow-x-auto">
        <h2 class="text-2xl font-bold text-center mb-6 text-gray-800 font-mono">Sub-Categories List</h2>
        
        <table class="w-full text-left border-collapse font-mono">
            <thead>
                <tr class="bg-gray-100 border-b-2 border-gray-300">
                    <th class="p-3 text-sm font-bold text-gray-700">Sub-Category</th>
                    <th class="p-3 text-sm font-bold text-gray-700">Main Category</th>
                    <th class="p-3 text-sm font-bold text-gray-700">Status</th>
                    <th class="p-3 text-sm font-bold text-gray-700 text-center">Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($subCategories as $sub)
                    <tr class="border-b border-gray-200 hover:bg-gray-50 transition-colors">
                        <td class="p-3 text-sm text-gray-800">{{ $sub->name }}</td>
                        <td class="p-3 text-sm text-gray-600">{{ $sub->category->name }}</td>
                        <td class="p-3 text-sm">
                            @if($sub->is_disabled)
                                <span class="px-2 py-1 rounded-full text-xs font-bold bg-red-100 text-red-800">Disabled</span>
                            @else
                                <span class="px-2 py-1 rounded-full text-xs font-bold bg-green-100 text-green-800">Enabled</span>
                            @endif
                        </td>
                        <td class="p-3 text-sm flex justify-center space-x-2">
                            <button onclick="openEditModal({{ json_encode($sub) }})" class="px-3 py-1 bg-blue-500 text-white rounded font-bold">
                                Edit
                            </button>
                            <form action="{{ route('sub-categories.destroy', $sub) }}" method="POST" onsubmit="return confirm('Are you sure?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="px-3 py-1 bg-red-600 text-white rounded font-bold">
                                    Delete
                                </button>
                            </form>
                            <form action="{{ route('sub-categories.toggle', $sub) }}" method="POST">
                                @csrf
                                @method('PATCH')
                                <button type="submit" class="px-3 py-1 {{ $sub->is_disabled ? 'bg-green-600' : 'bg-yellow-500' }} text-white rounded font-bold">
                                    {{ $sub->is_disabled ? 'Enable' : 'Disable' }}
                                </button>
                            </form>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="p-6 text-center text-gray-500 italic">No sub-categories added yet.</td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Edit Modal -->
    <div id="editModal" class="fixed inset-0 bg-black bg-opacity-50 z-50 flex items-center justify-center hidden">
        <div class="bg-white p-6 rounded-lg shadow-xl w-full max-w-md">
            <h3 class="text-xl font-bold mb-4 font-mono">Edit Sub-Category</h3>
            <form id="editForm" method="POST">
                @csrf
                @method('PATCH')
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono" for="edit_name">Name</label>
                    <input type="text" id="edit_name" name="name" required class="mt-1 p-2 w-full border border-gray-300 rounded-md font-mono" />
                </div>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 font-mono" for="edit_category_id">Category</label>
                    <select id="edit_category_id" name="category_id" required class="mt-1 p-2 w-full border border-gray-300 rounded-md font-mono">
                        @foreach($categories as $category)
                            <option value="{{ $category->id }}">{{ $category->name }}</option>
                        @endforeach
                    </select>
                </div>
                <div class="mb-4 flex items-center">
                    <input type="checkbox" id="edit_is_disabled" name="is_disabled" class="h-4 w-4 text-blue-500 border-gray-300 rounded" />
                    <label class="ml-2 text-sm font-medium text-gray-700 font-mono" for="edit_is_disabled">Disable this sub-category</label>
                </div>
                <div class="flex justify-end space-x-3">
                    <button type="button" onclick="closeEditModal()" class="px-4 py-2 bg-gray-300 text-gray-700 rounded font-mono font-bold">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-blue-600 text-white rounded font-mono font-bold">Update</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openEditModal(sub) {
            document.getElementById('edit_name').value = sub.name;
            document.getElementById('edit_category_id').value = sub.category_id;
            document.getElementById('edit_is_disabled').checked = sub.is_disabled;
            document.getElementById('editForm').action = `/sub-categories/${sub.id}`;
            document.getElementById('editModal').classList.remove('hidden');
        }

        function closeEditModal() {
            document.getElementById('editModal').classList.add('hidden');
        }
    </script>
</x-app-layout>
