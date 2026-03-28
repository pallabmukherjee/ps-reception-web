<x-app-layout>
    <div class="max-w-7xl mx-auto space-y-8">
        <!-- Header Section -->
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
                <h1 class="text-2xl font-black text-slate-800 tracking-tight uppercase italic">
                    User <span class="text-blue-600">Management</span>
                </h1>
                <p class="text-sm text-slate-500 font-medium">Create and manage system users and their access roles.</p>
            </div>
        </div>

        <!-- Create User Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50">
                <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest">Register New Authority</h3>
            </div>
            
            <div class="p-6">
                <form action="{{ route('users.store') }}" method="POST" class="grid grid-cols-1 md:grid-cols-3 gap-6">
                    @csrf
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Full Name</label>
                        <input type="text" name="name" required class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" placeholder="John Doe" />
                    </div>
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Email Address</label>
                        <input type="email" name="email" required class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" placeholder="john@wbp.gov.in" />
                    </div>
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Access Password</label>
                        <input type="password" name="password" required class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" placeholder="••••••••" />
                    </div>
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">System Role</label>
                        <select name="role" required class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all">
                            <option value="">Select Role</option>
                            @foreach($roles as $role)
                                <option value="{{ $role->name }}">{{ ucfirst($role->name) }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Assigned Station</label>
                        <select name="police_station_id" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all">
                            <option value="">None (Global)</option>
                            @foreach($policeStations as $station)
                                <option value="{{ $station->id }}">{{ $station->name }}</option>
                            @endforeach
                        </select>
                    </div>
                    <div class="flex items-end">
                        <button type="submit" class="w-full py-2.5 bg-blue-600 text-white text-xs font-black rounded-xl hover:bg-blue-700 transition-all shadow-lg shadow-blue-600/20 uppercase tracking-widest">
                            Create Account
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Users Table Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-slate-50 text-slate-500">
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">User Identity</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Access Role</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest">Jurisdiction</th>
                            <th class="px-6 py-4 text-[10px] font-black uppercase tracking-widest text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        @foreach($users as $user)
                            <tr class="hover:bg-slate-50/50 transition-colors">
                                <td class="px-6 py-4">
                                    <div class="font-bold text-slate-900">{{ $user->name }}</div>
                                    <div class="text-[10px] text-slate-500 font-bold mt-0.5 uppercase tracking-tighter">{{ $user->email }}</div>
                                    @if($user->phone_number)
                                    <a href="tel:{{ $user->phone_number }}" class="text-[10px] text-blue-600 font-black mt-1 flex items-center hover:underline">
                                        <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                                        </svg>
                                        {{ $user->phone_number }}
                                    </a>
                                    @endif
                                </td>
                                <td class="px-6 py-4">
                                    @php
                                        $role = $user->roles->pluck('name')->first() ?? 'No Role';
                                        $roleColor = match($role) {
                                            'super' => 'bg-rose-100 text-red-700 border-rose-200',
                                            'admin' => 'bg-amber-100 text-amber-700 border-amber-200',
                                            'superior' => 'bg-indigo-100 text-indigo-700 border-indigo-200',
                                            default => 'bg-slate-100 text-slate-700 border-slate-200',
                                        };
                                    @endphp
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-black {{ $roleColor }} uppercase tracking-tighter shadow-sm border">
                                        {{ $role }}
                                    </span>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="text-[10px] text-slate-600 font-black uppercase tracking-widest">
                                        {{ $user->policeStation->name ?? 'GLOBAL DISTRICT' }}
                                    </div>
                                </td>
                                <td class="px-6 py-4">
                                    <div class="flex items-center justify-center gap-2">
                                        <button onclick="openEditModal({{ json_encode($user->load('roles')) }})" class="p-2 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-all">
                                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                            </svg>
                                        </button>
                                        <form action="{{ route('users.destroy', $user) }}" method="POST" onsubmit="return confirm('Revoke access for this user?')">
                                            @csrf @method('DELETE')
                                            <button type="submit" class="p-2 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-all">
                                                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                                </svg>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Edit Modal (Styled) -->
    <div id="editModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center hidden">
        <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden border border-slate-200">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50 flex items-center justify-between">
                <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest">Edit Credentials</h3>
                <button onclick="closeEditModal()" class="text-slate-400 hover:text-slate-600 transition-colors">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                </button>
            </div>
            
            <form id="editForm" method="POST" class="p-6 space-y-4">
                @csrf @method('PUT')
                <div>
                    <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Full Name</label>
                    <input type="text" id="edit_name" name="name" required class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" />
                </div>
                <div>
                    <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Email Address</label>
                    <input type="email" id="edit_email" name="email" required class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" />
                </div>
                <div>
                    <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Update Password</label>
                    <input type="password" name="password" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" placeholder="Empty to keep current" />
                </div>
                <div>
                    <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">System Role</label>
                    <select id="edit_role" name="role" required class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all">
                        @foreach($roles as $role)
                            <option value="{{ $role->name }}">{{ ucfirst($role->name) }}</option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Assigned Station</label>
                    <select id="edit_police_station" name="police_station_id" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all">
                        <option value="">None (Global)</option>
                        @foreach($policeStations as $station)
                            <option value="{{ $station->id }}">{{ $station->name }}</option>
                        @endforeach
                    </select>
                </div>
                
                <div class="pt-4 flex gap-3">
                    <button type="button" onclick="closeEditModal()" class="flex-1 py-2.5 bg-slate-100 text-slate-600 text-xs font-black rounded-xl hover:bg-slate-200 transition-all uppercase tracking-widest">Cancel</button>
                    <button type="submit" class="flex-1 py-2.5 bg-blue-600 text-white text-xs font-black rounded-xl hover:bg-blue-700 transition-all shadow-lg shadow-blue-600/20 uppercase tracking-widest">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openEditModal(user) {
            document.getElementById('edit_name').value = user.name;
            document.getElementById('edit_email').value = user.email;
            if (user.roles && user.roles.length > 0) {
                document.getElementById('edit_role').value = user.roles[0].name;
            } else {
                document.getElementById('edit_role').value = '';
            }
            document.getElementById('edit_police_station').value = user.police_station_id || '';
            document.getElementById('editForm').action = `/users/${user.id}`;
            document.getElementById('editModal').classList.remove('hidden');
        }
        function closeEditModal() { document.getElementById('editModal').classList.add('hidden'); }
    </script>
</x-app-layout>
