<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\PoliceStation;
use Illuminate\Http\Request;
use Spatie\Permission\Models\Role;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index()
    {
        $users = User::with(['roles', 'policeStation'])->latest()->get();
        $roles = Role::all();
        $policeStations = PoliceStation::all();
        return view('users.index', compact('users', 'roles', 'policeStations'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
            'role' => 'required|exists:roles,name',
            'police_station_id' => 'nullable|exists:police_stations,id',
        ]);

        $user = User::create([
            'name' => $request->name,
            'full_name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'police_station_id' => $request->police_station_id,
        ]);

        $user->assignRole($request->role);

        return redirect()->back()->with('success', 'User created successfully.');
    }

    public function update(Request $request, User $user)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            'role' => 'required|exists:roles,name',
            'police_station_id' => 'nullable|exists:police_stations,id',
        ]);

        $user->update([
            'name' => $request->name,
            'full_name' => $request->name,
            'email' => $request->email,
            'police_station_id' => $request->police_station_id,
        ]);

        if ($request->password) {
            $user->update(['password' => Hash::make($request->password)]);
        }

        $user->syncRoles([$request->role]);

        return redirect()->back()->with('success', 'User updated successfully.');
    }

    public function destroy(User $user)
    {
        if ($user->id === auth()->id()) {
            return redirect()->back()->with('error', 'You cannot delete yourself.');
        }
        $user->delete();
        return redirect()->back()->with('success', 'User deleted successfully.');
    }
}
