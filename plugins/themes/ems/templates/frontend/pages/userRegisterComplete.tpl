{**
 * templates/frontend/pages/userRegisterComplete.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme registration completion page - modern and clean design
 *}
{include file="frontend/components/header.tpl" pageTitle="user.login.registrationComplete"}

<div class="page page_register_complete ems-register-complete-page">
	<div class="complete-container">
		{* Success Card *}
		<div class="complete-card">
			{* Success Icon *}
			<div class="success-icon-wrapper">
				<svg class="success-icon" width="80" height="80" viewBox="0 0 80 80" fill="none" xmlns="http://www.w3.org/2000/svg">
					<circle cx="40" cy="40" r="40" fill="#10B981" fill-opacity="0.1"/>
					<circle cx="40" cy="40" r="32" fill="#10B981" fill-opacity="0.2"/>
					<path d="M55 32L35 52L25 42" stroke="#10B981" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
				</svg>
			</div>

			{* Success Message *}
			<div class="complete-header">
				<h1 class="complete-title">Registration Successful!</h1>
				<p class="complete-subtitle">{translate key="user.login.registrationComplete.instructions"}</p>
			</div>

			{* Email Validation Notice *}
			{if $requireValidation}
				<div class="alert alert-info">
					<svg class="alert-icon" width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
						<path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z" fill="#3B82F6"/>
					</svg>
					<div class="alert-content">
						<p class="alert-text">{translate key="user.login.accountNotValidated" email=$email}</p>
					</div>
				</div>
			{/if}

			{* Quick Actions *}
			<div class="complete-actions">
				<h3 class="actions-title">What would you like to do next?</h3>
				<div class="actions-grid">
					{if array_intersect([PKP\security\Role::ROLE_ID_MANAGER, PKP\security\Role::ROLE_ID_SUB_EDITOR, PKP\security\Role::ROLE_ID_ASSISTANT, PKP\security\Role::ROLE_ID_REVIEWER], (array)$userRoles)}
						<a href="{url page="submissions"}" class="action-card">
							<div class="action-icon">
								<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
									<path d="M8 6h16a2 2 0 012 2v16a2 2 0 01-2 2H8a2 2 0 01-2-2V8a2 2 0 012-2z" stroke="#019863" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
									<path d="M12 14h8M12 18h8" stroke="#019863" stroke-width="2" stroke-linecap="round"/>
								</svg>
							</div>
							<div class="action-content">
								<h4 class="action-title">{translate key="user.login.registrationComplete.manageSubmissions"}</h4>
								<p class="action-description">View and manage your submissions</p>
							</div>
						</a>
					{/if}
					
					{if $currentContext}
						<a href="{url page="submission"}" class="action-card">
							<div class="action-icon">
								<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
									<path d="M16 8v16M8 16h16" stroke="#019863" stroke-width="2" stroke-linecap="round"/>
									<circle cx="16" cy="16" r="12" stroke="#019863" stroke-width="2" fill="none"/>
								</svg>
							</div>
							<div class="action-content">
								<h4 class="action-title">{translate key="user.login.registrationComplete.newSubmission"}</h4>
								<p class="action-description">Start a new submission</p>
							</div>
						</a>
					{/if}

					<a href="{url router=PKP\core\PKPApplication::ROUTE_PAGE page="user" op="profile"}" class="action-card">
						<div class="action-icon">
							<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
								<circle cx="16" cy="12" r="5" stroke="#019863" stroke-width="2" fill="none"/>
								<path d="M7 26c0-5 4-9 9-9s9 4 9 9" stroke="#019863" stroke-width="2" stroke-linecap="round" fill="none"/>
							</svg>
						</div>
						<div class="action-content">
							<h4 class="action-title">{translate key="user.editMyProfile"}</h4>
							<p class="action-description">Update your profile information</p>
						</div>
					</a>

					<a href="{url page="index"}" class="action-card">
						<div class="action-icon">
							<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
								<path d="M16 6l10 8v12H6V14l10-8z" stroke="#019863" stroke-width="2" stroke-linejoin="round" fill="none"/>
								<path d="M12 26V16h8v10" stroke="#019863" stroke-width="2" fill="none"/>
							</svg>
						</div>
						<div class="action-content">
							<h4 class="action-title">{translate key="user.login.registrationComplete.continueBrowsing"}</h4>
							<p class="action-description">Explore the journal homepage</p>
						</div>
					</a>
				</div>
			</div>

			{* Primary Button *}
			{if !$requireValidation}
				<div class="primary-action">
					<a href="{url page="login"}" class="btn-primary">
						Sign In to Your Account
					</a>
				</div>
			{/if}
		</div>

		{* Help Section *}
		{if $currentContext && ($currentContext->getData('supportEmail') || $currentContext->getData('contactEmail'))}
			<div class="complete-help">
				<svg class="help-icon" width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
					<circle cx="24" cy="24" r="20" stroke="#0a3047" stroke-width="2" fill="none"/>
					<path d="M24 18v8M24 30h.01" stroke="#0a3047" stroke-width="2" stroke-linecap="round"/>
				</svg>
				<h3 class="help-title">Need Help?</h3>
				<p class="help-description">If you have any questions or need assistance, our support team is here to help.</p>
				<a href="{url page="about" op="contact"}" class="help-link">Contact Support</a>
			</div>
		{/if}
	</div>
</div>

{include file="frontend/components/footer.tpl"}