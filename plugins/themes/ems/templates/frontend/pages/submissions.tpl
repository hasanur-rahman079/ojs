{**
 * templates/frontend/pages/submissions.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme submission instructions page
 *}
{include file="frontend/components/header.tpl" pageTitle="about.submissions"}

<div class="page page_submissions ems-submissions-page">
	<div class="submissions-container">
		<div class="submissions-content">
			<h1 class="submissions-title">
				{translate key="about.submissions"}
			</h1>

			<div class="submission-notification">
				{if $sections|@count == 0 || $currentContext->getData('disableSubmissions')}
					<p class="not-accepting">{translate key="author.submit.notAccepting"}</p>
				{else}
					{if $isUserLoggedIn}
						{capture assign="newSubmission"}<a href="{url page="submission"}" class="submission-link">{translate key="about.onlineSubmissions.newSubmission"}</a>{/capture}
						{capture assign="viewSubmissions"}<a href="{url page="submissions"}" class="submission-link">{translate key="about.onlineSubmissions.viewSubmissions"}</a>{/capture}
						<p>{translate key="about.onlineSubmissions.submissionActions" newSubmission=$newSubmission viewSubmissions=$viewSubmissions}</p>
					{else}
						{capture assign="login"}<a href="{url page="login"}" class="submission-link">{translate key="about.onlineSubmissions.login"}</a>{/capture}
						{capture assign="register"}<a href="{url page="user" op="register"}" class="submission-link">{translate key="about.onlineSubmissions.register"}</a>{/capture}
						<p>{translate key="about.onlineSubmissions.registrationRequired" login=$login register=$register}</p>
					{/if}
				{/if}
			</div>

			{if $currentContext->getLocalizedData('authorGuidelines')}
			<div class="author-guidelines-section">
				<h2 class="section-title">
					{translate key="about.authorGuidelines"}
					{include file="frontend/components/editLink.tpl" page="management" op="settings" path="workflow" anchor="submission/instructions" sectionTitleKey="about.authorGuidelines"}
				</h2>
				<div class="section-content">
					{$currentContext->getLocalizedData('authorGuidelines')}
				</div>
			</div>
			{/if}

			{if $submissionChecklist}
			<div class="submission-checklist-section">
				<h2 class="section-title">
					{translate key="about.submissionPreparationChecklist"}
					{include file="frontend/components/editLink.tpl" page="management" op="settings" path="workflow" anchor="submission/instructions" sectionTitleKey="about.submissionPreparationChecklist"}
				</h2>
				<div class="section-content checklist-content">
					{$submissionChecklist}
				</div>
			</div>
			{/if}

			{if isset($submissionChecklistAfterContent)}
				{$submissionChecklistAfterContent}
			{/if}

			{if $currentContext->getLocalizedData('copyrightNotice')}
			<div class="copyright-notice-section">
				<h2 class="section-title">
					{translate key="about.copyrightNotice"}
					{include file="frontend/components/editLink.tpl" page="management" op="settings" path="workflow" anchor="submission/instructions" sectionTitleKey="about.copyrightNotice"}
				</h2>
				<div class="section-content">
					{$currentContext->getLocalizedData('copyrightNotice')}
				</div>
			</div>
			{/if}

			{if $currentContext->getLocalizedData('privacyStatement')}
			<div class="privacy-statement-section">
				<h2 class="section-title">
					{translate key="about.privacyStatement"}
					{include file="frontend/components/editLink.tpl" page="management" op="settings" path="website" anchor="setup/privacy" sectionTitleKey="about.privacyStatement"}
				</h2>
				<div class="section-content">
					{$currentContext->getLocalizedData('privacyStatement')}
				</div>
			</div>
			{/if}
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}

