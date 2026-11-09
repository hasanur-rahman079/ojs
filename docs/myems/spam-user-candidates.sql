-- Review-only candidate report for the ten-letter bot pattern audited on 2026-11-09.
-- This query never deletes users. Check the journal IDs before running elsewhere.
-- Accounts are shared site-wide. Review the output; do not treat all unvalidated users as spam.
-- Excludes staff, other journals, author email matches, and editorial/activity references.
-- Registration-only invitations and registration sessions are allowed; no login is recorded.

SELECT u.user_id,u.username,u.email,u.date_registered,
 (SELECT string_agg(setting_value,' | ') FROM user_settings us WHERE us.user_id=u.user_id AND setting_name='givenName') AS given_name,
 (SELECT string_agg(setting_value,' | ') FROM user_settings us WHERE us.user_id=u.user_id AND setting_name='familyName') AS family_name,
 (SELECT string_agg(setting_value,' | ') FROM user_settings us WHERE us.user_id=u.user_id AND setting_name='affiliation') AS affiliation
FROM users u
WHERE u.disabled=1 AND u.date_validated IS NULL AND u.date_last_login IS NULL
 AND u.username ~ '^[a-z]{10}$'
 AND EXISTS(SELECT 1 FROM user_settings s WHERE s.user_id=u.user_id AND s.setting_name='givenName' AND s.setting_value ~ '^[a-z]{10}$')
 AND EXISTS(SELECT 1 FROM user_settings s WHERE s.user_id=u.user_id AND s.setting_name='familyName' AND s.setting_value ~ '^[a-z]{10}$')
 AND EXISTS(SELECT 1 FROM user_settings s WHERE s.user_id=u.user_id AND s.setting_name='affiliation' AND s.setting_value ~ '^[a-z]{10}$')
 AND EXISTS(SELECT 1 FROM user_user_groups x JOIN user_groups g ON g.user_group_id=x.user_group_id WHERE x.user_id=u.user_id AND g.context_id IN(1,2))
 AND NOT EXISTS(SELECT 1 FROM user_user_groups x JOIN user_groups g ON g.user_group_id=x.user_group_id WHERE x.user_id=u.user_id AND (g.context_id IS NULL OR g.context_id NOT IN(1,2) OR g.role_id NOT IN(4096,65536,1048576)))
 AND NOT EXISTS(SELECT 1 FROM authors a WHERE lower(a.email)=lower(u.email))
 AND NOT EXISTS(SELECT 1 FROM "completed_payments" ref WHERE ref."user_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "edit_decisions" ref WHERE ref."editor_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "email_log" ref WHERE ref."sender_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "email_log_users" ref WHERE ref."user_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "event_log" ref WHERE ref."user_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "invitations" ref WHERE ref."inviter_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "invitations" ref WHERE ref."user_id"=u.user_id AND (ref.type<>'registrationAccess' OR ref.inviter_id IS NOT NULL))
 AND NOT EXISTS(SELECT 1 FROM "notes" ref WHERE ref."user_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "notifications" ref WHERE ref."user_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "query_participants" ref WHERE ref."user_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "review_assignments" ref WHERE ref."reviewer_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "reviewer_suggestions" ref WHERE ref."approver_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "reviewer_suggestions" ref WHERE ref."reviewer_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "reviewer_suggestions" ref WHERE ref."suggesting_user_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "stage_assignments" ref WHERE ref."user_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "subeditor_submission_group" ref WHERE ref."user_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "submission_comments" ref WHERE ref."author_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "submission_files" ref WHERE ref."uploader_user_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "subscriptions" ref WHERE ref."user_id"=u.user_id)
 AND NOT EXISTS(SELECT 1 FROM "temporary_files" ref WHERE ref."user_id"=u.user_id)
 ORDER BY u.user_id;
