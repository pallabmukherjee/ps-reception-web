<section>
    <header>
        <h2 class="text-xs font-black text-slate-800 uppercase tracking-widest">
            {{ __('Personnel Information') }}
        </h2>

        <p class="mt-1 text-xs font-medium text-slate-500 uppercase tracking-tighter">
            {{ __("Maintain your account's primary identification details.") }}
        </p>
    </header>

    <form id="send-verification" method="post" action="{{ route('verification.send') }}">
        @csrf
    </form>

    <form method="post" action="{{ route('profile.update') }}" class="mt-8 space-y-6">
        @csrf
        @method('patch')

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label for="name" class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Display Name</label>
                <x-text-input id="name" name="name" type="text" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500" :value="old('name', $user->name)" required autofocus autocomplete="name" />
                <x-input-error class="mt-2" :messages="$errors->get('name')" />
            </div>

            <div>
                <label for="email" class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Official Email ID</label>
                <x-text-input id="email" name="email" type="email" class="block w-full rounded-xl border-slate-200 text-sm font-bold shadow-sm focus:border-blue-500 focus:ring-blue-500" :value="old('email', $user->email)" required autocomplete="username" />
                <x-input-error class="mt-2" :messages="$errors->get('email')" />

                @if ($user instanceof \Illuminate\Contracts\Auth\MustVerifyEmail && ! $user->hasVerifiedEmail())
                    <div class="mt-2 p-3 bg-amber-50 rounded-xl border border-amber-100">
                        <p class="text-[10px] font-bold text-amber-800 uppercase tracking-tighter">
                            {{ __('Awaiting Verification.') }}

                            <button form="send-verification" class="ml-2 underline text-blue-600 hover:text-blue-800">
                                {{ __('Dispatch Link.') }}
                            </button>
                        </p>

                        @if (session('status') === 'verification-link-sent')
                            <p class="mt-1 text-[10px] font-black text-emerald-600 uppercase">
                                {{ __('Security link transmitted.') }}
                            </p>
                        @endif
                    </div>
                @endif
            </div>
        </div>

        <div class="flex items-center gap-4 pt-4 border-t border-slate-50">
            <button type="submit" class="px-8 py-2.5 bg-blue-600 text-white text-xs font-black rounded-xl hover:bg-blue-700 transition-all shadow-lg shadow-blue-600/20 uppercase tracking-widest">
                Authorize Changes
            </button>

            @if (session('status') === 'profile-updated')
                <p
                    x-data="{ show: true }"
                    x-show="show"
                    x-transition
                    x-init="setTimeout(() => show = false, 2000)"
                    class="text-[10px] font-black text-emerald-600 uppercase tracking-widest animate-pulse"
                >{{ __('Success: Record Modified') }}</p>
            @endif
        </div>
    </form>
</section>
