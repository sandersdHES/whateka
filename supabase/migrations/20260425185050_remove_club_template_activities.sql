-- Les 3 clubs (440, 441, 442) ont ete auto-approuves dans activities mais
-- ce sont des fiches template sans match planifie : ils ne devraient pas
-- apparaitre dans les recos user. Les soumissions originales (458, 460, 469)
-- restent en pending pour que l'admin puisse y ajouter les matchs.
DELETE FROM favorites WHERE activity_id IN (440, 441, 442);
DELETE FROM activities WHERE id IN (440, 441, 442);

-- Remettre les soumissions correspondantes en pending si elles ont ete
-- approved (pour que admin puisse retraiter) :
UPDATE activity_submissions 
SET status = 'pending', reviewed_at = NULL, reviewed_by = NULL,
    admin_notes = COALESCE(admin_notes || ' | ', '') || 'Reset par audit : doit etre saisi avec match specifique avant approbation'
WHERE id IN (458, 460, 469) AND status = 'approved';
