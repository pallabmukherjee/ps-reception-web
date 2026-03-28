<x-app-layout>
    <div class="max-w-7xl mx-auto space-y-8">
        <!-- Header Section -->
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
                <h1 class="text-2xl font-black text-slate-800 tracking-tight uppercase italic">
                    Alert <span class="text-blue-600">Categories</span>
                </h1>
                <p class="text-sm text-slate-500 font-medium">Define high-priority alert classifications and notification protocols.</p>
            </div>
        </div>

        <!-- Create Category Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50">
                <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest">Register Classification</h3>
            </div>
            
            <div class="p-6">
                <form action="{{ route('categories.store') }}" method="POST" class="space-y-6">
                    @csrf
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2" for="name">Classification Name</label>
                            <input type="text" id="name" name="name" required class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500" placeholder="e.g. Theft, Assault" />
                        </div>
                        <div>
                            <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2" for="priority">Dispatch Priority</label>
                            <select id="priority" name="priority" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500">
                                <option value="none">Normal Processing</option>
                                <option value="High Priority">Emergency Response (High)</option>
                                <option value="Medium Priority">Priority Response (Med)</option>
                                <option value="Low Priority">Standard Log (Low)</option>
                            </select>
                        </div>
                    </div>

                    <div class="flex items-center gap-3 p-4 bg-slate-50 rounded-xl border border-slate-100">
                        <input type="checkbox" id="notification_enabled" name="notification_enabled" class="h-5 w-5 text-blue-600 border-slate-300 rounded-lg focus:ring-blue-500" />
                        <label for="notification_enabled" class="text-sm font-bold text-slate-700 uppercase tracking-tighter">Enable Instant Mobile Dispatch Notifications</label>
                    </div>

                    <div class="flex justify-end">
                        <button type="submit" class="px-10 py-3 bg-blue-600 text-white text-xs font-black rounded-xl hover:bg-blue-700 transition-all shadow-lg shadow-blue-600/20 uppercase tracking-widest">
                            Authorize Category
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Table View -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-slate-50 text-slate-500">
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Classification</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Dispatch Protocol</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Priority</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Active Status</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        @forelse($categories as $category)
                            <tr class="hover:bg-slate-50/50 transition-colors">
                                <td class="px-6 py-4 font-bold text-slate-900">{{ $category->name }}</td>
                                <td class="px-6 py-4">
                                    @if($category->notification_enabled)
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-black bg-emerald-100 text-emerald-700 uppercase border border-emerald-200">Broadcast On</span>
                                    @else
                                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-black bg-slate-100 text-slate-500 uppercase border border-slate-200">Local Only</span>
                                    @endif
                                </td>
                                <td class="px-6 py-4">
                                    <span class="text-[10px] font-black uppercase tracking-widest {{ str_contains($category->priority, 'High') ? 'text-rose-600' : 'text-slate-500' }}">
                                        {{ $category->priority }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center px-2 py-1 rounded-lg text-[10px] font-black {{ $category->is_disabled ? 'bg-rose-50 text-rose-600' : 'bg-emerald-50 text-emerald-600' }} uppercase">
                                        {{ $category->is_disabled ? 'Deactivated' : 'Operational' }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-center gap-2">
                                        <button onclick="openEditModal({{ json_encode($category) }})" class="p-2 text-slate-400 hover:text-blue-600 transition-all"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg></button>
                                        <form action="{{ route('categories.toggle', $category) }}" method="POST">
                                            @csrf @method('PATCH')
                                            <button type="submit" class="p-2 {{ $category->is_disabled ? 'text-emerald-500' : 'text-amber-500' }} hover:scale-110 transition-transform">
                                                @if($category->is_disabled) <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                                                @else <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728L5.636 5.636"/></svg> @endif
                                            </button>
                                        </form>
                                        <form action="{{ route('categories.destroy', $category) }}" method="POST" onsubmit="return confirm('Archive category?')">
                                            @csrf @method('DELETE')
                                            <button type="submit" class="p-2 text-slate-400 hover:text-red-600 transition-all"><svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg></button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr><td colspan="5" class="px-6 py-12 text-center text-slate-400 font-medium italic">Database contains no classifications.</td></tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Edit Modal (Styled) -->
    <div id="editModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center hidden">
        <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden border border-slate-200">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
                <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest">Edit Category</h3>
                <button onclick="closeEditModal()" class="text-slate-400 hover:text-slate-600"><svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg></button>
            </div>
            <form id="editForm" method="POST" class="p-6 space-y-4">
                @csrf @method('PATCH')
                <div>
                    <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Category Name</label>
                    <input type="text" id="edit_name" name="name" required class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500" />
                </div>
                <div>
                    <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Priority Level</label>
                    <select id="edit_priority" name="priority" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500">
                        <option value="none">Select Priority</option>
                        <option value="High Priority">High Priority</option>
                        <option value="Medium Priority">Medium Priority</option>
                        <option value="Low Priority">Low Priority</option>
                    </select>
                </div>
                <div class="flex items-center gap-3 p-3 bg-slate-50 rounded-xl">
                    <input type="checkbox" id="edit_notification_enabled" name="notification_enabled" class="h-5 w-5 text-blue-600 border-slate-300 rounded-lg" />
                    <label for="edit_notification_enabled" class="text-xs font-black text-slate-700 uppercase">Enable Notifications</label>
                </div>
                <div class="pt-4 flex gap-3">
                    <button type="button" onclick="closeEditModal()" class="flex-1 py-2.5 bg-slate-100 text-slate-600 text-xs font-black rounded-xl uppercase tracking-widest">Cancel</button>
                    <button type="submit" class="flex-1 py-2.5 bg-blue-600 text-white text-xs font-black rounded-xl shadow-lg shadow-blue-600/20 uppercase tracking-widest">Update</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openEditModal(category) {
            document.getElementById('edit_name').value = category.name;
            document.getElementById('edit_notification_enabled').checked = category.notification_enabled;
            document.getElementById('edit_priority').value = category.priority;
            document.getElementById('editForm').action = `/categories/${category.id}`;
            document.getElementById('editModal').classList.remove('hidden');
        }
        function closeEditModal() { document.getElementById('editModal').classList.add('hidden'); }
    </script>
</x-app-layout>
