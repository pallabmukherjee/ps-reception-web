<section>
    <header>
        <h2 class="text-xs font-black text-slate-800 uppercase tracking-widest">
            {{ __('Access Management') }}
        </h2>

        <p class="mt-1 text-xs font-medium text-slate-500 uppercase tracking-tighter">
            {{ __('Ensure your account is utilizing a robust, complex credential set.') }}
        </p>
    </header>

    <form method="post" action="{{ route('password.update') }}" class="mt-8 space-y-6">
        @csrf
        @method('put')

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div>
                <label for="update_password_current_password" class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Current Credential</label>
                <x-text-input id="update_password_current_password" name="current_password" type="password" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500" autocomplete="current-password" placeholder="••••••••" />
                <x-input-error :messages="$errors->updatePassword->get('current_password')" class="mt-2" />
            </div>

            <div>
                <label for="update_password_password" class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">New Identity Key</label>
                <x-text-input id="update_password_password" name="password" type="password" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500" autocomplete="new-password" placeholder="••••••••" />
                <x-input-error :messages="$errors->updatePassword->get('password')" class="mt-2" />
            </div>

            <div>
                <label for="update_password_password_confirmation" class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Confirm Key</label>
                <x-text-input id="update_password_password_confirmation" name="password_confirmation" type="password" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500" autocomplete="new-password" placeholder="••••••••" />
                <x-input-error :messages="$errors->updatePassword->get('password_confirmation')" class="mt-2" />
            </div>
        </div>

        <div class="flex items-center gap-4 pt-4 border-t border-slate-50">
            <button type="submit" class="px-8 py-2.5 bg-rose-600 text-white text-xs font-black rounded-xl hover:bg-rose-700 transition-all shadow-lg shadow-rose-600/20 uppercase tracking-widest">
                Update Security
            </button>

            @if (session('status') === 'password-updated')
                <p
                    x-data="{ show: true }"
                    x-show="show"
                    x-transition
                    x-init="setTimeout(() => show = false, 2000)"
                    class="text-[10px] font-black text-emerald-600 uppercase tracking-widest animate-pulse"
                >{{ __('Key Rotated Successfully') }}</p>
            @endif
        </div>
    </form>
</section>
