<x-guest-layout>
    <div class="mb-8 text-center">
        <h2 class="text-2xl font-black text-slate-800 tracking-tight uppercase italic mb-2">Authorized <span class="text-blue-600">Login</span></h2>
        <p class="text-sm text-slate-500 font-medium">Access official reception management panel.</p>
    </div>

    <!-- Session Status -->
    <x-auth-session-status class="mb-4" :status="session('status')" />

    <form method="POST" action="{{ route('login') }}" class="space-y-6">
        @csrf

        <!-- Email Address -->
        <div>
            <label for="email" class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Personnel Email</label>
            <x-text-input id="email" class="block w-full rounded-2xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all px-4 py-3" type="email" name="email" :value="old('email')" required autofocus autocomplete="username" placeholder="john@wbp.gov.in" />
            <x-input-error :messages="$errors->get('email')" class="mt-2" />
        </div>

        <!-- Password -->
        <div>
            <label for="password" class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Access Password</label>
            <x-text-input id="password" class="block w-full rounded-2xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all px-4 py-3"
                            type="password"
                            name="password"
                            required autocomplete="current-password" placeholder="••••••••" />
            <x-input-error :messages="$errors->get('password')" class="mt-2" />
        </div>

        <!-- Remember Me -->
        <div class="flex items-center justify-between">
            <label for="remember_me" class="inline-flex items-center">
                <input id="remember_me" type="checkbox" class="rounded-lg border-slate-300 text-blue-600 shadow-sm focus:ring-blue-500 w-5 h-5" name="remember">
                <span class="ms-3 text-xs font-bold text-slate-600 uppercase tracking-tighter">{{ __('Keep me signed in') }}</span>
            </label>
        </div>

        <div class="pt-4 space-y-4">
            <button type="submit" class="w-full py-4 bg-blue-600 text-white text-xs font-black rounded-2xl hover:bg-blue-700 transition-all shadow-lg shadow-blue-600/20 uppercase tracking-widest">
                Authorize Session
            </button>

            @if (Route::has('password.request'))
                <div class="text-center">
                    <a class="text-xs font-bold text-slate-400 hover:text-blue-600 transition-colors uppercase tracking-widest" href="{{ route('password.request') }}">
                        {{ __('Forgotten Credentials?') }}
                    </a>
                </div>
            @endif
        </div>
    </form>
</x-guest-layout>
