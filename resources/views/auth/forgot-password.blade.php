<x-guest-layout>
    <div class="mb-8 text-center">
        <h2 class="text-2xl font-black text-slate-800 tracking-tight uppercase italic mb-2">Password <span class="text-rose-600">Recovery</span></h2>
        <p class="text-sm text-slate-500 font-medium leading-relaxed">System will dispatch a secure reset link to your official email ID.</p>
    </div>

    <!-- Session Status -->
    <x-auth-session-status class="mb-4" :status="session('status')" />

    <form method="POST" action="{{ route('password.email') }}" class="space-y-6">
        @csrf

        <!-- Email Address -->
        <div>
            <label for="email" class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Registered Email</label>
            <x-text-input id="email" class="block w-full rounded-2xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all px-4 py-3" type="email" name="email" :value="old('email')" required autofocus placeholder="Official Email Address" />
            <x-input-error :messages="$errors->get('email')" class="mt-2" />
        </div>

        <div class="pt-4 space-y-4">
            <button type="submit" class="w-full py-4 bg-blue-600 text-white text-xs font-black rounded-2xl hover:bg-blue-700 transition-all shadow-lg shadow-blue-600/20 uppercase tracking-widest">
                Dispatch Reset Link
            </button>

            <div class="text-center">
                <a class="text-[10px] font-black text-slate-400 hover:text-blue-600 transition-colors uppercase tracking-widest" href="{{ route('login') }}">
                    {{ __('Back to Authorization') }}
                </a>
            </div>
        </div>
    </form>
</x-guest-layout>
