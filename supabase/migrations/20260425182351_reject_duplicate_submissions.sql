UPDATE activity_submissions
SET status = 'rejected',
    admin_notes = COALESCE(admin_notes || ' | ', '') || 'Doublon détecté lors de l''audit (titre identique à une autre soumission)',
    reviewed_at = COALESCE(reviewed_at, now()),
    reviewed_by = COALESCE(reviewed_by, 'audit-deduplication')
WHERE id IN (437, 378, 328, 367, 414, 446, 434, 336, 397, 366, 348, 347, 381, 448, 352, 372, 401, 447, 349, 350, 394, 444, 329, 449, 282, 365, 419, 396, 370);
