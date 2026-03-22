<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index()
    {
        $categories = Category::latest()->get();
        return view('categories.index', compact('categories'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'notification_enabled' => 'boolean',
            'priority' => 'required|string|in:High Priority,Medium Priority,Low Priority,none',
        ]);

        Category::create([
            'name' => $request->name,
            'notification_enabled' => $request->has('notification_enabled'),
            'priority' => $request->priority,
        ]);

        return redirect()->back()->with('success', 'Category added successfully.');
    }

    public function update(Request $request, Category $category)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'notification_enabled' => 'boolean',
            'priority' => 'required|string|in:High Priority,Medium Priority,Low Priority,none',
        ]);

        $category->update([
            'name' => $request->name,
            'notification_enabled' => $request->has('notification_enabled'),
            'priority' => $request->priority,
        ]);

        return redirect()->back()->with('success', 'Category updated successfully.');
    }

    public function toggleStatus(Category $category)
    {
        $category->update([
            'is_disabled' => !$category->is_disabled
        ]);

        $status = $category->is_disabled ? 'disabled' : 'enabled';
        return redirect()->back()->with('success', "Category has been $status.");
    }

    public function destroy(Category $category)
    {
        $category->delete();
        return redirect()->back()->with('success', 'Category deleted successfully.');
    }
}
