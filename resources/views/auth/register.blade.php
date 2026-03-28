<x-guest-layout>
    <div class="mb-8 text-center">
        <h2 class="text-2xl font-black text-slate-800 tracking-tight uppercase italic mb-2">Personnel <span class="text-blue-600">Registration</span></h2>
        <p class="text-sm text-slate-500 font-medium">Apply for official reception desk access.</p>
    </div>

    <form method="POST" action="{{ route('register') }}" class="space-y-5">
        @csrf

        <!-- Name -->
        <div>
            <label for="name" class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Official Name</label>
            <x-text-input id="name" class="block w-full rounded-2xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all px-4 py-3" type="text" name="name" :value="old('name')" required autofocus autocomplete="name" placeholder="Full Name" />
            <x-input-error :messages="$errors->get('name')" class="mt-2" />
        </div>

        <!-- Email Address -->
        <div>
            <label for="email" class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Official Email</label>
            <x-text-input id="email" class="block w-full rounded-2xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all px-4 py-3" type="email" name="email" :value="old('email')" required autocomplete="username" placeholder="john@wbp.gov.in" />
            <x-input-error :messages="$errors->get('email')" class="mt-2" />
        </div>

        <!-- Password -->
        <div>
            <label for="password" class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">New Password</label>
            <x-text-input id="password" class="block w-full rounded-2xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all px-4 py-3"
                            type="password"
                            name="password"
                            required autocomplete="new-password" placeholder="Min 8 characters" />
            <x-input-error :messages="$errors->get('password')" class="mt-2" />
        </div>

        <!-- Confirm Password -->
        <div>
            <label for="password_confirmation" class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Verify Password</label>
            <x-text-input id="password_confirmation" class="block w-full rounded-2xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500 transition-all px-4 py-3"
                            type="password"
                            name="password_confirmation" required autocomplete="new-password" placeholder="Repeat password" />
            <x-input-error :messages="$errors->get('password_confirmation')" class="mt-2" />
        </div>

        <div class="pt-4 space-y-4">
            <button type="submit" class="w-full py-4 bg-emerald-600 text-white text-xs font-black rounded-2xl hover:bg-emerald-700 transition-all shadow-lg shadow-emerald-600/20 uppercase tracking-widest">
                Submit Application
            </button>

            <div class="text-center">
                <a class="text-[10px] font-black text-slate-400 hover:text-blue-600 transition-colors uppercase tracking-widest" href="{{ route('login') }}">
                    {{ __('Already Registered? Sign In') }}
                </a>
            </div>
        </div>
    </form>
</x-guest-layout>
