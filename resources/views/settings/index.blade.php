<x-app-layout>
    <div class="max-w-7xl mx-auto space-y-8">
        <!-- Header Section -->
        <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
                <h1 class="text-2xl font-black text-slate-800 tracking-tight uppercase italic">
                    Site <span class="text-blue-600">Settings</span>
                </h1>
                <p class="text-sm text-slate-500 font-medium">Customize your application identity and preferences.</p>
            </div>
        </div>

        @if(session('success'))
            <div class="bg-emerald-50 border border-emerald-200 text-emerald-700 px-4 py-3 rounded-xl text-sm font-bold">
                {{ session('success') }}
            </div>
        @endif

        @if ($errors->any())
            <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl text-sm font-bold">
                <ul class="list-disc list-inside">
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <form action="{{ route('settings.site') }}" method="POST" enctype="multipart/form-data" class="space-y-8 pb-12">
            @csrf
            @method('PATCH')

            <!-- General Settings -->
            <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="p-6 border-b border-slate-100 bg-slate-50/50">
                    <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest">General Information</h3>
                </div>
                
                <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2" for="site_name">Site Name</label>
                        <input type="text" id="site_name" name="site_name" value="{{ $settings['site_name'] ?? '' }}" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" placeholder="e.g. WBP Reception" />
                    </div>
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2" for="footer_text">Footer Text</label>
                        <input type="text" id="footer_text" name="footer_text" value="{{ $settings['footer_text'] ?? '' }}" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" placeholder="e.g. © 2024 West Bengal Police" />
                    </div>
                    <div class="md:col-span-2">
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2" for="site_description">Site Description</label>
                        <textarea id="site_description" name="site_description" rows="3" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" placeholder="A brief description of the site...">{{ $settings['site_description'] ?? '' }}</textarea>
                    </div>
                </div>
            </div>

            <!-- Visual Identity -->
            <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="p-6 border-b border-slate-100 bg-slate-50/50">
                    <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest">Visual Identity</h3>
                </div>
                
                <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-8">
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-4">Site Logo</label>
                        <div class="flex items-center gap-6">
                            <div class="h-20 w-20 rounded-2xl bg-slate-50 border-2 border-dashed border-slate-200 flex items-center justify-center overflow-hidden">
                                @if(isset($settings['site_logo']))
                                    <img src="{{ asset('storage/' . $settings['site_logo']) }}" class="h-full w-full object-contain p-2" />
                                @else
                                    <svg class="w-8 h-8 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                    </svg>
                                @endif
                            </div>
                            <div class="flex-1">
                                <input type="file" name="site_logo" class="block w-full text-xs text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-xs file:font-black file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 transition-all" />
                                <p class="mt-2 text-[10px] text-slate-400 font-medium uppercase tracking-tight">Recommended: PNG or SVG, max 2MB</p>
                            </div>
                        </div>
                    </div>
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-4">Favicon</label>
                        <div class="flex items-center gap-6">
                            <div class="h-12 w-12 rounded-xl bg-slate-50 border-2 border-dashed border-slate-200 flex items-center justify-center overflow-hidden">
                                @if(isset($settings['site_favicon']))
                                    <img src="{{ asset('storage/' . $settings['site_favicon']) }}" class="h-8 w-8 object-contain" />
                                @else
                                    <svg class="w-6 h-6 text-slate-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z" />
                                    </svg>
                                @endif
                            </div>
                            <div class="flex-1">
                                <input type="file" name="site_favicon" class="block w-full text-xs text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-xs file:font-black file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 transition-all" />
                                <p class="mt-2 text-[10px] text-slate-400 font-medium uppercase tracking-tight">Recommended: 32x32 or 64x64 PNG/ICO</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Contact Information -->
            <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="p-6 border-b border-slate-100 bg-slate-50/50">
                    <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest">Contact Information</h3>
                </div>
                
                <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2" for="contact_email">Support Email</label>
                        <input type="email" id="contact_email" name="contact_email" value="{{ $settings['contact_email'] ?? '' }}" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" placeholder="support@wbp.gov.in" />
                    </div>
                    <div>
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2" for="contact_phone">Helpline Number</label>
                        <input type="text" id="contact_phone" name="contact_phone" value="{{ $settings['contact_phone'] ?? '' }}" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" placeholder="+91 33 1234 5678" />
                    </div>
                    <div class="md:col-span-2">
                        <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2" for="address">Headquarters Address</label>
                        <textarea id="address" name="address" rows="2" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all" placeholder="Full address...">{{ $settings['address'] ?? '' }}</textarea>
                    </div>
                </div>
            </div>

            <div class="flex justify-end sticky bottom-6 z-20">
                <button type="submit" class="px-10 py-3.5 bg-blue-600 text-white text-xs font-black rounded-2xl hover:bg-blue-700 transition-all shadow-xl shadow-blue-600/40 uppercase tracking-widest border border-blue-500">
                    Commit Changes
                </button>
            </div>
        </form>
    </div>
</x-app-layout>
