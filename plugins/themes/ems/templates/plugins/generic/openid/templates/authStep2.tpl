{**
 * templates/frontend/pages/authStep2.tpl
 *
 * Copyright (c) 2020 Leibniz Institute for Psychology Information (https://leibniz-psychology.org/)
 * Copyright (c) 2024 Simon Fraser University
 * Copyright (c) 2024 John Willinsky
 * Distributed under the GNU GPL v3. For full terms see the file LICENSE.
 *
 * EMS Theme: Display the OpenID Auth second step with custom styling
 *}

{include file="frontend/components/header.tpl" pageTitle="plugins.generic.openid.step2.title"}

<div class="page page_oauth ems-register-page">
	<div class="register-wrapper">
		<div class="register-container">
			<div class="register-card">
				<div class="register-content">
					<div class="register-header">
						<p class="register-subtitle">Complete your account setup to get started</p>
					</div>

					{include file="common/formErrors.tpl"}

					<form class="register-form" id="oauth" method="post" action="{url page="openid" op="registerOrConnect"}" onsubmit="console.log('Form submitting...'); return true;">
						{csrf}
						<input type="hidden" name="oauthId" id="oauthId" value="{$oauthId}">
						<input type="hidden" name="selectedProvider" id="selectedProvider" value="{$selectedProvider}">
						<input type="hidden" name="returnTo" id="returnTo" value="{$returnTo}">

						{* Choice Selection *}
						{if empty($disableConnect) || $disableConnect != "1"}
							<div class="choice-section">
								<h3 class="choice-title">Do you already have an account?</h3>
								<div class="choice-buttons">
									<button type="button" id="showLoginForm" class="choice-btn active">
										<span class="choice-text">Yes, connect my account</span>
									</button>
									<button type="button" id="showRegisterForm" class="choice-btn">
										<span class="choice-text">No, create new account</span>
									</button>
								</div>
							</div>
						{/if}

						{* Registration Form *}
						<div {if empty($disableConnect) || $disableConnect != "1"}id="register-form"{/if} class="form-section">
							<fieldset class="register">
								<div class="form-notification" style="display: none;">
									<div class="notification-content">
										{if $siteTitle}
											{$help}
										{else}
											{translate key='plugins.generic.openid.step2.help.siteNameMissing'}
										{/if}
									</div>
								</div>

								{* Two-column layout for name fields *}
							<div class="form-row">
								<div class="form-group">
									<label for="givenName" class="form-label">
										Given name <span class="required">*</span>
									</label>
									<input 
										type="text" 
										name="givenName" 
										id="givenName" 
										class="form-input" 
										value="{$givenName|escape}" 
										placeholder="Enter your given name"
										maxlength="255" 
										required 
										aria-required="true"
									>
								</div>
								
								<div class="form-group">
									<label for="familyName" class="form-label">
										Family name
									</label>
									<input 
										type="text" 
										name="familyName" 
										id="familyName" 
										class="form-input" 
										value="{$familyName|escape}" 
										placeholder="Enter your family name"
										maxlength="255"
									>
								</div>
							</div>

							{* Two-column layout for email and username *}
							<div class="form-row">
								<div class="form-group">
									<label for="email" class="form-label">
										Email address <span class="required">*</span>
									</label>
									<input 
										type="email" 
										name="email" 
										id="email" 
										class="form-input" 
										value="{$email|escape}" 
										placeholder="Enter your email address"
										maxlength="90" 
										required 
										aria-required="true"
									>
								</div>
								
								<div class="form-group">
									<label for="username" class="form-label">
										Username <span class="required">*</span>
									</label>
									<input 
										type="text" 
										name="username" 
										id="username" 
										class="form-input" 
										value="{$username|escape}" 
										placeholder="Choose a username"
										maxlength="32" 
										required 
										aria-required="true"
									>
								</div>
							</div>

							{* Two-column layout for affiliation and country *}
							<div class="form-row">
								<div class="form-group">
									<label for="affiliation" class="form-label">
										Affiliation <span class="required">*</span>
									</label>
									<input 
										type="text" 
										name="affiliation" 
										id="affiliation" 
										class="form-input" 
										value="{$affiliation|escape}" 
										placeholder="Enter your affiliation"
										required 
										aria-required="true"
									>
								</div>
								
								<div class="form-group">
									<label for="country" class="form-label">
										Country <span class="required">*</span>
									</label>
									<select 
										name="country" 
										id="country" 
										class="form-select" 
										required 
										aria-required="true"
									>
										<option value="">Select your country</option>
										{html_options options=$countries selected=$country}
									</select>
								</div>
							</div>

							</fieldset>
							
							<fieldset class="consent">
								<div class="fields">
									{* Privacy consent - always required *}
									<div class="optin optin-privacy">
										<label>
											<input type="checkbox" name="privacyConsent" value="1" required{if $privacyConsent} checked="checked"{/if}>
											{capture assign="privacyUrl"}{url router=$smarty.const.ROUTE_PAGE page="about" op="privacy"}{/capture}
											{translate key="user.register.form.privacyConsent" privacyUrl=$privacyUrl}
											<span class="required" aria-hidden="true">*</span>
											<span class="pkp_screen_reader">
												{translate key="common.required"}
											</span>
										</label>
									</div>
								</div>
								
								{* Ask the user to opt into public email notifications *}
								<div class="fields">
									<div class="optin optin-email">
										<label>
											<input type="checkbox" name="emailConsent" id="emailConsent" value="1" {if $emailConsent} checked="checked"{/if}>
											{translate key="user.register.form.emailConsent"}
										</label>
									</div>
								</div>
								
								{* Reviewer consent *}
								<div class="fields">
									<div class="optin optin-reviewer">
										<label>
											<input type="checkbox" name="reviewerConsent" value="1" {if $reviewerConsent} checked="checked"{/if}>
											Yes, I would like to be contacted with requests to review submissions to this journal.
										</label>
									</div>
								</div>
							</fieldset>

							{* Reviewer Section *}
							{assign var=userCanRegisterReviewer value=0}
							{foreach from=$reviewerUserGroups[$contextId] item=userGroup}
								{if $userGroup->permitSelfRegistration}
									{assign var=userCanRegisterReviewer value=$userCanRegisterReviewer+1}
								{/if}
							{/foreach}
							{if $userCanRegisterReviewer}
								<div class="reviewer-section">
									<h4 class="reviewer-title">Reviewer Information</h4>
									{if $userCanRegisterReviewer > 1}
										<p class="reviewer-prompt">{translate key="user.reviewerPrompt"}</p>
										{capture assign="checkboxLocaleKey"}user.reviewerPrompt.userGroup{/capture}
									{else}
										{capture assign="checkboxLocaleKey"}user.reviewerPrompt.optin{/capture}
									{/if}
									
									<div class="form-group checkbox-group">
										{foreach from=$reviewerUserGroups[$contextId] item=userGroup}
											{if $userGroup->permitSelfRegistration}
												<label class="checkbox-label">
													{assign var="userGroupId" value=$userGroup->id}
													<input type="checkbox" name="reviewerGroup[{$userGroupId}]" class="checkbox-input reviewerGroupInput"
														value="1"{if in_array($userGroupId, $userGroupIds)} checked="checked"{/if}>
													<span class="checkbox-text">{translate key=$checkboxLocaleKey userGroup=$userGroup->getLocalizedData('name')}</span>
												</label>
											{/if}
										{/foreach}
									</div>
									
									<div class="form-group">
										<label for="interests" class="form-label">
											{translate key="user.interests"}
										</label>
										<input 
											type="text" 
											name="interests" 
											id="interests" 
											class="form-input reviewerGroupInput" 
											value="{$interests|escape}" 
											placeholder="e.g., Plant Biology, Agricultural Science, Molecular Research..."
										>
									</div>
								</div>
							{/if}

							<div class="buttons">
								<button class="register-button" type="submit" name="register" value="1" onclick="console.log('Register button clicked'); return true;">
									Complete Registration
								</button>
							</div>
						</div>

						{* Login Form *}
						{if empty($disableConnect) || $disableConnect != "1"}
							<div id="login-form" class="form-section">
								<fieldset class="login">
									<div class="form-notification" style="display: none;">
										<div class="notification-content">
											{if $siteTitle}
												{$connect}
											{else}
												{translate key='plugins.generic.openid.step2.connect.siteNameMissing'}
											{/if}
										</div>
									</div>

									<div class="form-group">
									<label for="usernameLogin" class="form-label">
										Username <span class="required">*</span>
									</label>
									<input 
										type="text" 
										name="usernameLogin" 
										id="usernameLogin" 
										class="form-input" 
										value="{$usernameLogin|escape}" 
										placeholder="Enter your username"
										maxlength="32" 
										aria-required="true"
										disabled
									>
								</div>
								
								<div class="form-group">
									<label for="passwordLogin" class="form-label">
										Password <span class="required">*</span>
									</label>
									<input 
										type="password" 
										name="passwordLogin" 
										id="passwordLogin" 
										class="form-input" 
										value="{$passwordLogin|escape}" 
										placeholder="Enter your password"
										maxlength="32" 
										aria-required="true"
										disabled
									>
									<div class="password-actions">
										<a href="{url page="login" op="lostPassword"}" class="forgot-link">
											Forgot your password?
										</a>
									</div>
								</div>

								<button class="connect-button" type="submit" name="connect">
									Connect Account
								</button>
								</fieldset>
							</div>
						{/if}
					</form>
				</div>
			</div>
		</div>
	</div>
</div>

{* JavaScript for form switching *}
<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function() {
	const showLoginForm = document.getElementById('showLoginForm');
	const showRegisterForm = document.getElementById('showRegisterForm');
	const loginForm = document.getElementById('login-form');
	const registerForm = document.getElementById('register-form');
	
	if (showLoginForm && showRegisterForm && loginForm && registerForm) {
		// Set initial state - show register form by default
		loginForm.style.display = 'none';
		registerForm.style.display = 'block';
		showLoginForm.classList.remove('active');
		showRegisterForm.classList.add('active');
		console.log('Initial state set - register form visible');
		
		showLoginForm.addEventListener('click', function(e) {
			e.preventDefault();
			loginForm.style.display = 'block';
			registerForm.style.display = 'none';
			showLoginForm.classList.add('active');
			showRegisterForm.classList.remove('active');
			
			// Enable and add required attributes to login form fields
			document.getElementById('usernameLogin').disabled = false;
			document.getElementById('passwordLogin').disabled = false;
			document.getElementById('usernameLogin').setAttribute('required', 'required');
			document.getElementById('passwordLogin').setAttribute('required', 'required');
			
			// Disable and remove required attributes from register form fields
			document.getElementById('givenName').disabled = true;
			document.getElementById('email').disabled = true;
			document.getElementById('username').disabled = true;
			document.getElementById('affiliation').disabled = true;
			document.getElementById('country').disabled = true;
			document.getElementById('givenName').removeAttribute('required');
			document.getElementById('email').removeAttribute('required');
			document.getElementById('username').removeAttribute('required');
			document.getElementById('affiliation').removeAttribute('required');
			document.getElementById('country').removeAttribute('required');
		});
		
		showRegisterForm.addEventListener('click', function(e) {
			e.preventDefault();
			loginForm.style.display = 'none';
			registerForm.style.display = 'block';
			showLoginForm.classList.remove('active');
			showRegisterForm.classList.add('active');
			
			// Disable and remove required attributes from login form fields
			document.getElementById('usernameLogin').disabled = true;
			document.getElementById('passwordLogin').disabled = true;
			document.getElementById('usernameLogin').removeAttribute('required');
			document.getElementById('passwordLogin').removeAttribute('required');
			
			// Enable and add required attributes to register form fields
			document.getElementById('givenName').disabled = false;
			document.getElementById('email').disabled = false;
			document.getElementById('username').disabled = false;
			document.getElementById('affiliation').disabled = false;
			document.getElementById('country').disabled = false;
			document.getElementById('givenName').setAttribute('required', 'required');
			document.getElementById('email').setAttribute('required', 'required');
			document.getElementById('username').setAttribute('required', 'required');
			document.getElementById('affiliation').setAttribute('required', 'required');
			document.getElementById('country').setAttribute('required', 'required');
		});
	}
});
</script>

{include file="frontend/components/footer.tpl"}
