{**
 * templates/frontend/pages/userLostPasswordConfirm.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme password reset email sent confirmation page
 *}

{include file="frontend/components/header.tpl" pageTitle="user.lostPassword"}

<div class="page page_lost_password_confirm ems-email-sent-page">
	<div class="email-sent-container">
		<div class="email-sent-card">
			{* Brand Logo *}
			<div class="email-sent-header">
				<img src="{$baseUrl}/plugins/themes/ems/templates/images/ems_brand.png" alt="ems.pub" class="email-sent-logo">
			</div>

			{* Email Sent Content *}
			<div class="email-sent-content">
				<div class="email-sent-icon">
					📧
				</div>
				
				<h1 class="email-sent-title">{translate key="plugins.themes.ems.checkYourEmail"}</h1>
				<p class="email-sent-subtitle">{translate key="plugins.themes.ems.passwordResetSent"}</p>

				<div class="email-sent-instructions">
					<p>{translate key="plugins.themes.ems.emailInstructions"}</p>
					<ul>
						<li>{translate key="plugins.themes.ems.checkSpamFolder"}</li>
						<li>{translate key="plugins.themes.ems.contactSupport"}</li>
					</ul>
				</div>

				{* Back to Login Button *}
				<div class="email-sent-footer">
					<a href="{url page="login"}" class="back-to-login-button">
						{translate key="plugins.themes.ems.backToLogin"}
					</a>
					
					<p class="resend-text">
						{translate key="plugins.themes.ems.didntReceiveEmail"}
						<a href="{url page="login" op="lostPassword"}" class="resend-link">
							{translate key="plugins.themes.ems.resendEmail"}
						</a>
					</p>
				</div>
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/footer.tpl"}
