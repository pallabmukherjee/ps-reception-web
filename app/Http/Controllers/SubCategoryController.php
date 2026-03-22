<?php

namespace App\Http\Controllers;

use App\Models\Category;
use App\Models\SubCategory;
use Illuminate\Http\Request;

class SubCategoryController extends Controller
{
    public function index()
    {
        $categories = Category::all();
        $subCategories = SubCategory::with('category')->latest()->get();
        return view('sub-categories.index', compact('categories', 'subCategories'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'category_id' => 'required|exists:categories,id',
            'name' => 'required|string|max:255',
        ]);

        SubCategory::create([
            'category_id' => $request->category_id,
            'name' => $request->name,
        ]);

        return redirect()->back()->with('success', 'Sub-Category added successfully.');
    }

    public function update(Request $request, SubCategory $subCategory)
    {
        $request->validate([
            'category_id' => 'required|exists:categories,id',
            'name' => 'required|string|max:255',
        ]);

        $subCategory->update([
            'category_id' => $request->category_id,
            'name' => $request->name,
        ]);

        return redirect()->back()->with('success', 'Sub-Category updated successfully.');
    }

    public function toggleStatus(SubCategory $subCategory)
    {
        $subCategory->update([
            'is_disabled' => !$subCategory->is_disabled
        ]);

        $status = $subCategory->is_disabled ? 'disabled' : 'enabled';
        return redirect()->back()->with('success', "Sub-Category has been $status.");
    }

    public function destroy(SubCategory $subCategory)
    {
        $subCategory->delete();
        return redirect()->back()->with('success', 'Sub-Category deleted successfully.');
    }
}
