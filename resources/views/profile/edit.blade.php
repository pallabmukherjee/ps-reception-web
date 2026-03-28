<x-app-layout>
    <div class="max-w-7xl mx-auto space-y-8">
        <!-- Header Section -->
        <div>
            <h1 class="text-2xl font-black text-slate-800 tracking-tight uppercase italic">
                Official <span class="text-blue-600">Settings</span>
            </h1>
            <p class="text-sm text-slate-500 font-medium">Manage your official credentials and security preferences.</p>
        </div>

        <div class="grid grid-cols-1 gap-8">
            <!-- Profile Info -->
            <div class="bg-white rounded-3xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="p-6 border-b border-slate-100 bg-slate-50/50">
                    <h3 class="text-xs font-black text-slate-800 uppercase tracking-widest flex items-center">
                        <svg class="w-4 h-4 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                        Identity Information
                    </h3>
                </div>
                <div class="p-8 max-w-2xl">
                    @include('profile.partials.update-profile-information-form')
                </div>
            </div>

            <!-- Password Update -->
            <div class="bg-white rounded-3xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="p-6 border-b border-slate-100 bg-slate-50/50">
                    <h3 class="text-xs font-black text-slate-800 uppercase tracking-widest flex items-center">
                        <svg class="w-4 h-4 mr-2 text-rose-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 10-8 0v4h8z"/></svg>
                        Security & Access
                    </h3>
                </div>
                <div class="p-8 max-w-2xl">
                    @include('profile.partials.update-password-form')
                </div>
            </div>

            @hasrole('receptionist')
            <!-- Account Deletion (Restricted) -->
            <div class="bg-white rounded-3xl shadow-sm border border-rose-100 overflow-hidden">
                <div class="p-6 border-b border-rose-50 bg-rose-50/30">
                    <h3 class="text-xs font-black text-rose-800 uppercase tracking-widest flex items-center">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                        Critical Actions
                    </h3>
                </div>
                <div class="p-8 max-w-2xl">
                    @include('profile.partials.delete-user-form')
                </div>
            </div>
            @endhasrole
        </div>
    </div>
</x-app-layout>
