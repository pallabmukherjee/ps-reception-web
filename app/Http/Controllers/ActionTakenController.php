<?php

namespace App\Http\Controllers;

use App\Models\ActionTaken;
use Illuminate\Http\Request;

class ActionTakenController extends Controller
{
    public function index()
    {
        $actions = ActionTaken::latest()->get();
        return view('settings.action-taken', compact('actions'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        ActionTaken::create($request->all());

        return redirect()->back()->with('success', 'Action Taken option added successfully.');
    }

    public function update(Request $request, ActionTaken $actionTaken)
    {
        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $actionTaken->update($request->all());

        return redirect()->back()->with('success', 'Action Taken option updated successfully.');
    }

    public function destroy(ActionTaken $actionTaken)
    {
        $actionTaken->delete();
        return redirect()->back()->with('success', 'Action Taken option deleted successfully.');
    }
}
