{**
 * templates/frontend/pages/userLoginAdmin.tpl
 *
 * Copyright (c) 2024-2025
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * @brief EMS theme admin login page
 *}
{include file="frontend/components/header.tpl" pageTitle="user.login"}

<div class="ems-login-page admin-login">
	<div class="login-container">
		<div class="login-card">
			<div class="login-header">
				<div class="login-logo">
					<div class="logo-icon admin-icon"></div>
					<span class="logo-text">ems.pub</span>
					<span class="admin-badge">Admin</span>
				</div>
				<h1 class="login-title">{translate key="plugins.themes.ems.admin.login.title"}</h1>
				<p class="login-subtitle">{translate key="plugins.themes.ems.admin.login.welcome"}</p>
			</div>

			<div class="login-content">
				{* Login message if redirected *}
				{if $loginMessage}
					<div class="alert alert-info">
						<i class="alert-icon">ℹ</i>
						<p>{translate key=$loginMessage}</p>
					</div>
				{/if}

				{* Error messages *}
				{if $error}
					<div class="alert alert-danger">
						<i class="alert-icon">⚠</i>
						<p>{translate key=$error reason=$reason}</p>
					</div>
				{/if}

				{* Admin login form *}
				{include file="frontend/components/loginForm.tpl" formType="loginPage"}

				{* Admin-specific options *}
				<div class="admin-options">
					<div class="security-notice">
						<i class="security-icon">🔒</i>
						<p>{translate key="plugins.themes.ems.admin.login.securityNotice"}</p>
					</div>
				</div>
			</div>
		</div>

		{* Admin features panel *}
		<div class="admin-features">
			<h2>{translate key="plugins.themes.ems.admin.features.title"}</h2>
			<div class="feature-item">
				<div class="feature-icon">⚙️</div>
				<h3>{translate key="plugins.themes.ems.admin.feature1.title"}</h3>
				<p>{translate key="plugins.themes.ems.admin.feature1.description"}</p>
			</div>
			<div class="feature-item">
				<div class="feature-icon">📊</div>
				<h3>{translate key="plugins.themes.ems.admin.feature2.title"}</h3>
				<p>{translate key="plugins.themes.ems.admin.feature2.description"}</p>
			</div>
			<div class="feature-item">
				<div class="feature-icon">👥</div>
				<h3>{translate key="plugins.themes.ems.admin.feature3.title"}</h3>
				<p>{translate key="plugins.themes.ems.admin.feature3.description"}</p>
			</div>
			<div class="feature-item">
				<div class="feature-icon">🛡️</div>
				<h3>{translate key="plugins.themes.ems.admin.feature4.title"}</h3>
				<p>{translate key="plugins.themes.ems.admin.feature4.description"}</p>
			</div>
		</div>
	</div>
</div>

{include file="frontend/components/authScripts.tpl"}
{include file="frontend/components/footer.tpl"}