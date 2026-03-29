<?php

namespace App\Notifications;

use App\Models\Complaint;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class SuperiorNoteAdded extends Notification
{
    use Queueable;

    protected $complaint;

    /**
     * Create a new notification instance.
     */
    public function __construct(Complaint $complaint)
    {
        $this->complaint = $complaint;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['database'];
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        $this->complaint->loadMissing('subCategory.category');
        
        return [
            'complaint_id' => $this->complaint->id,
            'complainant_name' => $this->complaint->complainant_name,
            'phone' => $this->complaint->phone,
            'category_name' => $this->complaint->subCategory->category->name ?? 'Unknown',
            'sub_category_name' => $this->complaint->subCategory->name ?? 'Unknown',
            'title' => '📝 New Official Note Added',
            'message' => "Superior added a note to complaint #{$this->complaint->id}.",
            'type' => 'note_added',
            'note' => $this->complaint->note,
            'complaint_created_at' => $this->complaint->created_at->toIso8601String(),
        ];
    }
}
